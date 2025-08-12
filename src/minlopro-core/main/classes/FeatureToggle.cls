/**
 * @description Provides a centralized framework for feature toggles, allowing for the dynamic activation
 * or deactivation of application features using Custom Metadata Types.
 */
public with sharing class FeatureToggle {
    /**
     * @description Checks if a specific feature toggle is active.
     * @param featureName The DeveloperName of the FeatureToggle__mdt record.
     * @return `true` if the feature toggle is active, `false` otherwise.
     */
    @AuraEnabled(Cacheable=true)
    public static Boolean isActive(String featureName) {
        FeatureToggle__mdt toggle = FeatureToggle__mdt.getInstance(featureName);
        return (toggle != null && toggle.Active__c);
    }
}
