public virtual with sharing class DlrsDeveloperModeTriggerHandler extends BasicTriggerHandler {
    public override Integer getMaxLoopCount() {
        return 50;
    }

    public override void afterDelete(List<SObject> oldRecords) {
        update dlrs.RollupService.rollup(oldRecords);
    }

    public override void afterInsert(List<SObject> newRecords) {
        update dlrs.RollupService.rollup(newRecords);
    }

    public override void afterUndelete(List<SObject> newRecords) {
        update dlrs.RollupService.rollup(newRecords);
    }

    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        dlrs.RollupService.rollup(oldMap, newMap, this.objectType);
    }
}
