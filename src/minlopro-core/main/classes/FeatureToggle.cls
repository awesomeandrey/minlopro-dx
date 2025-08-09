public with sharing class FeatureToggle {
    private static final Map<String, Boolean> featureToggleCache = new Map<String, Boolean>();
    /**
     * @description Checks if a specific feature toggle is active.
     * @param featureName The DeveloperName of the FeatureToggle__mdt record.
     * @return True if the feature is active, otherwise false.
     */
    @AuraEnabled(Cacheable=true)
    public static Boolean isActive(String featureName) {
        if (featureToggleCache.containsKey(featureName)) {
            return featureToggleCache.get(featureName);
        }
        FeatureToggle__mdt toggle = FeatureToggle__mdt.getInstance(featureName);
        Boolean isActive = (toggle != null && toggle.Active__c);
        featureToggleCache.put(featureName, isActive);
        return isActive;
    }
}
