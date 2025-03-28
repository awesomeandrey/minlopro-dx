public inherited sharing class OptInEmailService {
    private final String SIGNATURE_KEY = 'salesforce_rocks!';
    private final AccountSelector accountSelector = (AccountSelector) Application.Selector.newInstance(Account.SObjectType);
    private final EmailTemplateSelector templateSelector = (EmailTemplateSelector) Application.Selector.newInstance(
        EmailTemplate.SObjectType
    );

    public List<Messaging.SingleEmailMessage> composeEmailMessagesByTemplateId(List<Id> accountIds, Id templateId) {
        // Collect Accounts;
        List<Account> targetAccounts = this.accountSelector.selectByIdWithMode(accountIds, AccessLevel.SYSTEM_MODE);
        Logger.debug('Accounts Size = {0}', Lists.of(String.valueOf(targetAccounts.size())));
        if (targetAccounts.isEmpty()) {
            throw new IllegalArgumentException('Accounts were not found by IDs provided!');
        }

        // Retrieve Email Template;
        List<EmailTemplate> targetTemplates = this.templateSelector.selectSObjectsById(Sets.of(templateId));
        Logger.debug('Email Templates Size = {0}', Lists.of(String.valueOf(targetTemplates.size())));
        if (targetTemplates.isEmpty()) {
            throw new IllegalArgumentException('Email Template was not found!');
        }
        final EmailTemplate targetTemplate = targetTemplates[0];
        Logger.debug('Template = {0}', Lists.of(targetTemplate.Name));

        // Resolve DigEx confirmation page URL;
        final String confirmationPageUrl = this.resolveOptInPageUrl();
        Logger.debug('Confirmation Page URL = {0}', Lists.of(confirmationPageUrl));

        // Capture org-wide email address (if configured);
        List<OrgWideEmailAddress> oweAddresses = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress LIMIT 1];
        OrgWideEmailAddress oweAddress = oweAddresses.isEmpty() ? null : oweAddresses.get(0);

        // Generate email messages;
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for (Account accountItem : targetAccounts) {
            // Render template (counts against SOQL limits);
            Messaging.SingleEmailMessage emailItem = Messaging.renderStoredEmailTemplate(targetTemplate.Id, null, accountItem.Id);
            // Specify org-wide email address (this resolves 'Sender Display Name' automatically);
            if (oweAddress != null) {
                Logger.debug('Used Org-Wide Email Address: {0}', oweAddresses);
                emailItem.setOrgWideEmailAddressId(oweAddresses.get(0).Id);
            } else {
                // Logger.debug('Overrode sender name manually');
                emailItem.setSenderDisplayName('Minlopro Opt-In Engagement');
            }
            // Specify TO email address;
            emailItem.setToAddresses(Lists.of(accountItem.PersonEmail));
            // Save as activity item (common error > `saveAsActivity must be false when sending mail to users`)
            emailItem.setSaveAsActivity(true);
            // Build & resolve confirmation page link (with signature!);
            String code = this.generateMac(Blob.valueOf(accountItem.Id));
            String accountConfirmationUrl = String.format(
                '{0}?accountId={1}&code={2}',
                Lists.of(confirmationPageUrl, accountItem.Id, code)
            );
            Logger.debug('Account Confirmation URL = {0}', Lists.of(accountConfirmationUrl));
            emailItem.setHtmlBody(emailItem.htmlBody.replace('@OPT_IN_CONFIRMATION_LINK', accountConfirmationUrl));
            emailMessages.add(emailItem);
        }
        return emailMessages;
    }

    public String generateMac(Blob content) {
        Blob mac = Crypto.generateMac('hmacSHA256', content, Blob.valueOf(this.SIGNATURE_KEY));
        return EncodingUtil.convertToHex(mac);
    }

    public Boolean verifyMac(Blob content, String macToCheck) {
        String computedSignature = this.generateMac(content);
        return macToCheck.equals(computedSignature);
    }

    private String resolveOptInPageUrl() {
        Network myNetwork = [SELECT Id FROM Network WHERE Name = 'DigEx'];
        String siteBaseUrl = Network.getLoginUrl(myNetwork.Id).removeEnd('/login');
        return String.format('{0}/{1}', Lists.of(siteBaseUrl, 'opt-in-confirmation'));
    }
}
