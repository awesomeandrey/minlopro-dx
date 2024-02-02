// Collect target profiles and users;
Map<Id, Profile> affectedProfiles = new Map<Id, Profile>(
    [
        SELECT Id, Name
        FROM Profile
        WHERE Name IN ('System Administrator', 'DigEx Profile', 'Minlopro User')
        LIMIT 10
    ]
);
Map<Id, User> affectedUsers = new Map<Id, User>(
    [
        SELECT Id, Name
        FROM User
        WHERE Alias IN ('autoproc')
        LIMIT 10
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
