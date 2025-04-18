public without sharing class SendOptInEmailAction {
    private static final OptInEmailService optInService = (OptInEmailService) Application.Service.newInstance(
        OptInEmailService.class
    );

    @InvocableMethod(Label='Send Opt-In Email')
    public static void invoke(List<EmailRequest> requests) {
        Logger.debug('Invocable Action Context');
        final EmailRequest req = requests[0];
        final Id templateId = req.templateId;
        final List<Id> accountIds = collectAccountIds(requests);

        // Compose email messages;
        List<Messaging.SingleEmailMessage> emailMessages = optInService.composeEmailMessagesByTemplateId(accountIds, templateId);

        Messaging.SingleEmailMessage messageItem = emailMessages[0];
        Logger.debug('To = {0}', Lists.of(messageItem.getToAddresses().toString()));
        Logger.debug('Sender Name = {0}', Lists.of(messageItem.getSenderDisplayName()));
        Logger.debug('Save As Activity = {0}', Lists.of(messageItem.getSaveAsActivity().toString()));

        // Note -> Total number of sendEmail methods allowed = 10 (sync/async);

        List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailMessages, false);
        for (Messaging.SendEmailResult sendResultItem : sendResults) {
            Logger.debug('Send Result > {0}', Lists.of(sendResultItem.isSuccess().toString()));
            if (!sendResultItem.isSuccess()) {
                Logger.error('Send Errors > {0}', Lists.of(sendResultItem.getErrors().toString()));
            }
        }
    }

    private static List<Id> collectAccountIds(List<EmailRequest> requests) {
        List<Id> accountIds = new List<Id>();
        for (EmailRequest req : requests) {
            if (String.isNotBlank(req.accountId)) {
                accountIds.add(req.accountId);
            }
        }
        return accountIds;
    }

    public class EmailRequest {
        @InvocableVariable(Label='Account ID' Required=true)
        public Id accountId;
        @InvocableVariable(Label='Email Template ID' Required=true)
        public Id templateId;
        @InvocableVariable(Label='Temporary Variable' DefaultValue='Some Default Value')
        public String temporaryVariable;
    }
}
