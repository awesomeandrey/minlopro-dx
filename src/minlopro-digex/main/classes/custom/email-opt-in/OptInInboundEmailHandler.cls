/**
 * Taken from https://github.com/trailheadapps/apex-recipes/wiki/InboundEmailHandlerRecipes
 *
 * This class does not specify a sharing model. This is on purpose - when this class is executed, by the inbound email system,
 * it will execute in a system context and pieces of this class need to be able to read all contacts - which is a common use case.
 * Because of this, we're suppressing the PMD ApexSharingViolation warning.
 */
@SuppressWarnings('PMD.ApexSharingViolations')
public class OptInInboundEmailHandler implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Logger.SAVE_LOGS_SYNC = true;
        Logger.debug('email.subject -> {0}', Lists.of(email.subject));
        Logger.debug('email.plainTextBody -> {0}', Lists.of(email.plainTextBody));
        Logger.debug('envelope.fromAddress -> {0}', Lists.of(envelope.fromAddress));

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.success = true;
        try {
            final String fromAddress = envelope.fromAddress;
            List<Account> foundPersonAccounts = [
                SELECT Id, Name, PersonHasOptedOutOfEmail, PersonTitle, OwnerId
                FROM Account
                WHERE PersonEmail = :fromAddress AND IsPersonAccount = TRUE
                LIMIT 1
            ];
            if (foundPersonAccounts.isEmpty()) {
                // Unknown Contact;
                result.message = 'Unfortunately, we could not handle your request.';
                return result;
            }

            // Process matched Contact record;
            Account customer = foundPersonAccounts[0];
            if (this.hasOptedIn(email.plainTextBody)) {
                customer.PersonTitle = 'OPT-IN';
                customer.PersonHasOptedOutOfEmail = false;
                result.message = String.format('Dear {0}, thank you for Opt-In!', Lists.of(customer.Name));
            } else if (this.hasOptedOut(email.plainTextBody)) {
                customer.PersonTitle = 'OPT-OUT';
                customer.PersonHasOptedOutOfEmail = true;
                result.message = String.format(
                    '{0}, we got it! Thank you for your time! You opted out.',
                    Lists.of(customer.Name)
                );
            } else {
                customer.PersonTitle = 'PENDING';
                customer.PersonHasOptedOutOfEmail = false;
                result.message = String.format('{0}, we could not understand your intentions...', Lists.of(customer.Name));
            }
            // Update particular field only;
            update new Account(
                Id = customer.Id,
                PersonTitle = customer.PersonTitle,
                PersonHasOptedOutOfEmail = customer.PersonHasOptedOutOfEmail
            );

            // Capture incoming email as activity;
            EmailMessage activityItem = this.composeEmailMessage(email, envelope);
            // activityItem.ActivityId = smsTask.Id;
            activityItem.RelatedToId = customer.Id;
            activityItem.ToIds = Lists.of(customer.OwnerId); // This reply is addressed to agent who owns the record;
            insert activityItem;
        } catch (Exception ex) {
            result.success = true;
            result.message = Exceptions.getDetails(ex).toString();
            Logger.error(ex);
        }
        return result;
    }

    private Boolean hasOptedIn(String responseAsText) {
        if (String.isBlank(responseAsText)) {
            return false;
        }
        return responseAsText.startsWithIgnoreCase('yes') ||
            responseAsText.startsWithIgnoreCase('confirm') ||
            responseAsText.startsWithIgnoreCase('subscribe');
    }

    private Boolean hasOptedOut(String responseAsText) {
        if (String.isBlank(responseAsText)) {
            return false;
        }
        return responseAsText.startsWithIgnoreCase('no') ||
            responseAsText.startsWithIgnoreCase('stop') ||
            responseAsText.startsWithIgnoreCase('unsubscribe');
    }

    private EmailMessage composeEmailMessage(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        EmailMessage messageItem = new EmailMessage();
        messageItem.Subject = email.subject;
        messageItem.FromAddress = envelope.fromAddress;
        messageItem.FromName = email.fromName;
        messageItem.ToAddress = envelope.toAddress;
        messageItem.TextBody = email.plainTextBody;
        messageItem.HtmlBody = email.htmlBody;
        messageItem.Status = '3'; // aka 'Sent' status;
        messageItem.Headers = String.valueOf(email.headers);
        messageItem.Incoming = true;
        messageItem.MessageDate = Datetime.now();
        return messageItem;
    }
}
