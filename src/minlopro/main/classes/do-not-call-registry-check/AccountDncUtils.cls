@SuppressWarnings('PMD')
public inherited sharing class AccountDncUtils {
    private static final Long RATE_WINDOW_MS = 60 * 1000L; // 1 minute
    private static final Long RATE_LIMIT = 200; // 200 callouts per 1 minute
    @TestVisible
    private static final String CACHE_KEY = 'DncCalloutCount';
    private final static Cache.OrgPartition DEFAULT_PARTITION = SystemInfoController.getDefaultCachePartition();

    public static Boolean isFeatureEnabled() {
        return FeatureToggle.isActive('EnableAccountDncVerification');
    }

    public static Boolean hasExceededRateLimit() {
        return getCurrentRateConsumption() >= RATE_LIMIT;
    }

    public static Long getCurrentRateConsumption() {
        RateWindow window = (RateWindow) DEFAULT_PARTITION.get(CACHE_KEY);
        if (window == null || isWindowExpired(window)) {
            return 0L;
        }
        return window.count;
    }

    public static void appendRateConsumption(Integer value) {
        RateWindow window = (RateWindow) DEFAULT_PARTITION.get(CACHE_KEY);
        if (window == null || isWindowExpired(window)) {
            window = new RateWindow(value);
        } else {
            window.count += value;
        }
        DEFAULT_PARTITION.put(CACHE_KEY, window, 7200);
    }

    private static Boolean isWindowExpired(RateWindow window) {
        return System.currentTimeMillis() - window.windowStartMs > RATE_WINDOW_MS;
    }

    public class RateWindow {
        public Long count;
        public Long windowStartMs;

        public RateWindow(Integer initialCount) {
            this.count = initialCount;
            this.windowStartMs = System.currentTimeMillis();
        }
    }
}
