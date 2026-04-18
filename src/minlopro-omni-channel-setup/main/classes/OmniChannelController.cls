public with sharing class OmniChannelController {
    @AuraEnabled(Cacheable=true)
    public static List<ServicePresenceStatus> getServicePresenceStatuses() {
        try {
            return [SELECT Id, MasterLabel, DeveloperName FROM ServicePresenceStatus];
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
