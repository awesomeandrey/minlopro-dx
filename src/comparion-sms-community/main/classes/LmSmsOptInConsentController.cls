/**
 *
 */
public without sharing class LmSmsOptInConsentController {
    @AuraEnabled
    public static Boolean validateAndCaptureOptInConsent(Id accountId, String codeToVerify) {
        try {
            // TODO - to be implemented as a separate ticket/work item;
            return false;
        } catch (Exception ex) {
            System.debug('\n\n ex.getMessage() => ' + ex.getMessage() + '\n');
            System.debug('\n\n ex.getStackTraceString() => ' + ex.getStackTraceString() + '\n');
            System.debug('\n\n ex.getTypeName() => ' + ex.getTypeName() + '\n');
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
