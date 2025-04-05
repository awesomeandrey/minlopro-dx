public with sharing class TH_Lead_Sample1 extends BasicTriggerHandler {
    public override void beforeInsert(List<SObject> newRecords) {
        Logger.debug(newRecords);
    }
}
