public inherited sharing class TH_Car_LogInventoryChanges extends BasicTriggerHandler {
    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        Logger.debug('Updating cars inventory...');
    }
}
