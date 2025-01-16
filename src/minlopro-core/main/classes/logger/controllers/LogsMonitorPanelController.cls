public with sharing class LogsMonitorPanelController {
    private final static Cache.OrgPartition LOGS_PARTITION = Cache.Org.getPartition('local.LogsMonitor');
    private final static String RATIO_KEY = 'leftDivRatio';
    private final static Integer DEFAULT_RATIO = 75;

    @AuraEnabled(Cacheable=true)
    public static Boolean hasPartitionDefined() {
        return LOGS_PARTITION != null;
    }

    @AuraEnabled
    public static Integer getRatio() {
        if (!LOGS_PARTITION.contains(RATIO_KEY)) {
            return DEFAULT_RATIO;
        }
        return (Integer) LOGS_PARTITION.get(RATIO_KEY);
    }

    @AuraEnabled
    public static void setRatio(Integer ratio) {
        LOGS_PARTITION.put(RATIO_KEY, ratio);
    }

    @AuraEnabled
    public static List<Object> getLoggerSettingsBySetupOwners() {
        try {
            Map<Id, Map<String, String>> settingBySetupOwnerId = new Map<Id, Map<String, String>>();
            Set<Id> userOrProfileIds = new Set<Id>();
            for (LoggerSettings__c setting : [
                SELECT SetupOwner.Id, SetupOwner.Name, SetupOwner.Type
                FROM LoggerSettings__c
                WHERE LogsEmissionDate__c >= TODAY
            ]) {
                // Exclude org default setting;
                String setupOwnerType = setting.SetupOwner.Type;
                if (setupOwnerType.equalsIgnoreCase('00D')) {
                    continue;
                }
                Id setupOwnerId = setting.SetupOwner.Id;
                String normalisedSetupOwnerType = setupOwnerType.equalsIgnoreCase('User') ? 'user' : 'profile';
                settingBySetupOwnerId.put(
                    setupOwnerId,
                    new Map<String, String>{ 'ownerId' => setupOwnerId, 'type' => normalisedSetupOwnerType }
                );
                // Capture user / profile ID;
                userOrProfileIds.add(setupOwnerId);
            }
            Map<Id, String> userOrProfileNameByUserOrProfileId = new Map<Id, String>();
            for (Profile profileItem : [SELECT Name FROM Profile WHERE Id IN :userOrProfileIds]) {
                userOrProfileNameByUserOrProfileId.put(profileItem.Id, profileItem.Name);
            }
            for (User userItem : [SELECT Name FROM User WHERE Id IN :userOrProfileIds]) {
                userOrProfileNameByUserOrProfileId.put(userItem.Id, userItem.Name);
            }
            // Update human-readable user / profile name;
            for (Id ownerId : settingBySetupOwnerId.keySet()) {
                settingBySetupOwnerId.get(ownerId).put('name', userOrProfileNameByUserOrProfileId.get(ownerId));
            }
            return settingBySetupOwnerId.values();
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(Exceptions.getDetails(ex).toString());
        }
    }
}
