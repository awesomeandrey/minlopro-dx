public with sharing class CarSalePlaygroundController {
    @AuraEnabled(cacheable=true)
    public static List<Car__c> getCars() {
        try {
            return [SELECT Id, Name, Model__c, QuantityAvailable__c FROM Car__c ORDER BY QuantityAvailable__c DESC LIMIT 10];
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void publishCarSaleEvents(List<CarSaleEvent__e> events) {
        try {
            // TODO - publish with callback
            EventBus.publish(events);
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
