List<BotVersion> versions = [
    SELECT Id, DeveloperName, Status, BotDefinition.MasterLabel, BotDefinition.DeveloperName, BotDefinition.Type, VersionNumber
    FROM BotVersion
    WHERE BotDefinition.DeveloperName = 'Osama' AND VersionNumber = 1
    LIMIT 1
];
if (versions.isEmpty()) {
    Logger.debug('Einstein Bot version not found.');
    return;
}
BotVersion osamaBotVersion1 = versions[0];
ConnectApi.BotVersionActivationInfo deactivationInfo = ConnectApi.BotVersionActivation.updateVersionStatus(
    osamaBotVersion1.Id,
    ConnectApi.BotVersionActivationStatus.Inactive,
    null
);
Logger.debug('Deactivating Einstein Bot version with Id = {0}. {1}', Lists.of(osamaBotVersion1.Id, deactivationInfo.toString()));
