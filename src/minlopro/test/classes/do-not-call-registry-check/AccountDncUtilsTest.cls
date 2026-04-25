@SuppressWarnings('PMD')
@IsTest
private class AccountDncUtilsTest {
    private static final String CACHE_KEY = AccountDncUtils.CACHE_KEY;
    private static final Cache.OrgPartition PARTITION = SystemInfoController.getDefaultCachePartition();

    @IsTest
    static void testIsFeatureEnabled() {
        Boolean result = AccountDncUtils.isFeatureEnabled();
        Assert.isNotNull(result);
    }

    @IsTest
    static void testGetCurrentRateConsumptionWhenEmpty() {
        clearCache();
        Assert.areEqual(0L, AccountDncUtils.getCurrentRateConsumption());
    }

    @IsTest
    static void testAppendCreatesWindow() {
        clearCache();
        AccountDncUtils.appendRateConsumption(10);
        Assert.areEqual(10L, AccountDncUtils.getCurrentRateConsumption());
    }

    @IsTest
    static void testAppendAccumulatesWithinWindow() {
        clearCache();
        AccountDncUtils.appendRateConsumption(10);
        AccountDncUtils.appendRateConsumption(25);
        Assert.areEqual(35L, AccountDncUtils.getCurrentRateConsumption());
    }

    @IsTest
    static void testHasNotExceededRateLimit() {
        clearCache();
        AccountDncUtils.appendRateConsumption(10);
        Assert.isFalse(AccountDncUtils.hasExceededRateLimit());
    }

    @IsTest
    static void testHasExceededRateLimit() {
        clearCache();
        AccountDncUtils.appendRateConsumption(200);
        Assert.isTrue(AccountDncUtils.hasExceededRateLimit());
    }

    @IsTest
    static void testGetCurrentRateConsumptionWhenWindowExpired() {
        clearCache();
        seedStaleWindow(150);
        Assert.areEqual(0L, AccountDncUtils.getCurrentRateConsumption());
    }

    @IsTest
    static void testAppendResetsExpiredWindow() {
        clearCache();
        seedStaleWindow(150);
        AccountDncUtils.appendRateConsumption(5);
        Assert.areEqual(5L, AccountDncUtils.getCurrentRateConsumption());
    }

    private static void seedStaleWindow(Integer count) {
        AccountDncUtils.RateWindow staleWindow = new AccountDncUtils.RateWindow(count);
        staleWindow.windowStartMs = System.currentTimeMillis() - 120000L; // 2 minutes ago, past the 1-minute window
        PARTITION.put(CACHE_KEY, staleWindow, 7200);
    }

    private static void clearCache() {
        PARTITION.remove(CACHE_KEY);
    }
}
