public with sharing class DigExLoginController {
    @AuraEnabled
    public static void setExperienceId() {
        try {
            /**
             * The Site.setExperienceId method specifically sets the Experience Cloud site (Experience) ID
             * for the current guest user session. This is particularly useful in scenarios where a single
             * Salesforce org hosts multiple Experience Cloud sites and there's a need to programmatically
             * control or switch the context in which the guest user is operating,
             * especially for visual customization, content variation, and functionality differences
             * between multiple experiences.
             * By setting the Experience ID, developers can ensure that the guest user session is associated
             * with the correct Experience Cloud site, allowing for a consistent and tailored user experience.
             */
            Logger.debug('Is Guest User? = {0}', Lists.of(Auth.CommunitiesUtil.isGuestUser().toString()));
            if (Auth.CommunitiesUtil.isGuestUser()) {
                Network digEx = [SELECT Id FROM Network WHERE Name = 'DigEx' LIMIT 1];
                Logger.debug('DigEx ID = {0}', Lists.of(digEx.Id));
                Site.setExperienceId(digEx.Id);
            }
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String loginWithCredentials(String username, String password) {
        try {
            Logger.debug('DigEx: logging in user with credentials');
            Logger.debug('Username = {0}', Lists.of(username));
            PageReference loginPageRef = Site.login(username, password, null);
            Logger.debug('Login Page URL = {0}', Lists.of(loginPageRef.getUrl()));
            return loginPageRef.getUrl();
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
