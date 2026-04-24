@SuppressWarnings('PMD')
public with sharing class LogsMonitorPanelController {
    private final static Cache.OrgPartition DEFAULT_PARTITION = SystemInfoController.getDefaultCachePartition();
    private final static String RATIO_KEY = 'leftDivRatio';
    private final static Integer DEFAULT_RATIO = 75;

    @AuraEnabled
    public static Boolean hasPartitionDefined() {
        return DEFAULT_PARTITION != null;
    }

    @AuraEnabled
    public static Integer getRatio() {
        if (!DEFAULT_PARTITION.contains(RATIO_KEY)) {
            return DEFAULT_RATIO;
        }
        return (Integer) DEFAULT_PARTITION.get(RATIO_KEY);
    }

    @AuraEnabled
    public static void setRatio(Integer ratio) {
        DEFAULT_PARTITION.put(RATIO_KEY, ratio);
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

    @AuraEnabled
    public static void enableLogs() {
        try {
            // Collect target profiles and users;
            Map<Id, Profile> affectedProfiles = new Map<Id, Profile>(
                [
                    SELECT Id, Name
                    FROM Profile
                    WHERE Name IN ('System Administrator', 'DigEx Profile', 'Minlopro User')
                    LIMIT 5
                ]
            );
            Map<Id, User> affectedUsers = new Map<Id, User>(
                [
                    SELECT Id, Name
                    FROM User
                    WHERE Alias IN ('autoproc')
                    LIMIT 1
                ]
            );
            Set<Id> affectedProfilesAndUsers = new Set<Id>();
            affectedProfilesAndUsers.addAll(affectedProfiles.keySet());
            affectedProfilesAndUsers.addAll(affectedUsers.keySet());

            // Retrieve existing logger setting;
            Map<Id, LoggerSettings__c> existingLogSettingByOwnerId = new Map<Id, LoggerSettings__c>();
            for (LoggerSettings__c settingItem : [SELECT Id, Name, SetupOwnerId, LogsEmissionDate__c FROM LoggerSettings__c]) {
                existingLogSettingByOwnerId.put(settingItem.SetupOwnerId, settingItem);
            }

            // Prolong logger settings for profiles and users;
            List<LoggerSettings__c> settingsToUpsert = new List<LoggerSettings__c>();
            for (Id profileOrUserId : affectedProfilesAndUsers) {
                if (existingLogSettingByOwnerId.containsKey(profileOrUserId)) {
                    // Update;
                    LoggerSettings__c existingSettings = existingLogSettingByOwnerId.get(profileOrUserId);
                    existingSettings.LogsEmissionDate__c = Date.today().addDays(10);
                    settingsToUpsert.add(existingSettings);
                } else {
                    // Create;
                    settingsToUpsert.add(
                        new LoggerSettings__c(SetupOwnerId = profileOrUserId, LogsEmissionDate__c = Date.today().addDays(10))
                    );
                }
            }
            if (!settingsToUpsert.isEmpty()) {
                upsert settingsToUpsert;
            }

            List<SObject> profilesAndUsers = new List<SObject>();
            profilesAndUsers.addAll(affectedProfiles.values());
            profilesAndUsers.addAll(affectedUsers.values());
            DebugTableFormatter formatter = new DebugTableFormatter(Lists.of('Id', 'Name'), profilesAndUsers);
            formatter.log('⚪ Updated logger settings for the profiles/users:\n');
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(Exceptions.getDetails(ex).toString());
        }
    }
}
