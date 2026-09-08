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
ConnectApi.BotVersionActivationInfo activationInfo = ConnectApi.BotVersionActivation.updateVersionStatus(
    osamaBotVersion1.Id,
    ConnectApi.BotVersionActivationStatus.Active,
    null
);
Logger.debug('Activating Einstein Bot version with Id = {0}. {1}', Lists.of(osamaBotVersion1.Id, activationInfo.toString()));
