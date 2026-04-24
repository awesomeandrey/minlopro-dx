@SuppressWarnings('PMD')
public inherited sharing class AccountDncUtils {
    public static Boolean isFeatureEnabled() {
        // TODO - look at rate limits
        return FeatureToggle.isActive('EnableAccountDncVerification');
    }
}
