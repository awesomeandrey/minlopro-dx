/**
 * This Apex controller is invoked on behalf of Digital Experience Site guest user.
 * 'without sharing' modifier is intentionally used here to allow controlled access to records
 * to capture & process SMS Opt-In consents sent via emails.
 */
public without sharing class LmSmsOptInConsentController {
    @AuraEnabled
    public static Boolean validateAndCaptureOptInConsent(Id accountId, String codeToVerify) {
        LmSmsEmailService emailService = new LmSmsEmailService();
        try {
            // Verify MAC code;
            if (!emailService.verifyCode(Blob.valueOf(accountId), codeToVerify)) {
                throw new IllegalArgumentException('Verification Error: Code Does Not Match!');
            }
            // TODO - to be implemented as a separate ticket/work item;
            return false;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
