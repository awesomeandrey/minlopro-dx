@IsTest
private class FeatureToggleTest {
    @TestSetup
    static void setup() {
        Assert.isNotNull(selectSampleFeatureToggle(), 'There are no feature toggles available');
    }

    @IsTest
    static void testIsActive() {
        FeatureToggle__mdt sampleToggle = selectSampleFeatureToggle();
        Boolean isActive = FeatureToggle.isActive(sampleToggle.DeveloperName);
        Assert.areEqual(sampleToggle.Active__c, isActive, 'Feature toggle mismatch');
    }

    static FeatureToggle__mdt selectSampleFeatureToggle() {
        return FeatureToggle__mdt.getAll().values().get(0);
    }
}
