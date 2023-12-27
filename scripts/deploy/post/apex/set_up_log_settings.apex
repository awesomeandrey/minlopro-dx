Map<Id, Profile> affectedProfiles = new Map<Id, Profile>([
        SELECT Id, Name
        FROM Profile
        WHERE Name IN ('System Administrator', 'DigEx Profile' )
        LIMIT 10
]);

Map<Id, LoggerSettings__c> logSettingByOwnerId = new Map<Id, LoggerSettings__c>();
for (LoggerSettings__c settingItem : [SELECT Id, Name, SetupOwnerId, LogsEmissionDate__c FROM LoggerSettings__c]) {
    logSettingByOwnerId.put(settingItem.SetupOwnerId, settingItem);
}

List<LoggerSettings__c> settingsToUpsert = new List<LoggerSettings__c>();
for (Profile profileItem : affectedProfiles.values()) {
    if (logSettingByOwnerId.containsKey(profileItem.Id)) {
        // Update;
        LoggerSettings__c existingSettings = logSettingByOwnerId.get(profileItem.Id);
        existingSettings.LogsEmissionDate__c = Date.today().addDays(10);
        settingsToUpsert.add(existingSettings);
    } else {
        // Create;
        settingsToUpsert.add(new LoggerSettings__c(SetupOwnerId = profileItem.Id, LogsEmissionDate__c = Date.today().addDays(10)));
    }
}

if (!settingsToUpsert.isEmpty()) {
    upsert settingsToUpsert;
}

System.debug(String.format(
        '\n\n >>> Updated logger settings for the profiles: {0} \n',
        Lists.of(JSON.serializePretty(affectedProfiles))
));
