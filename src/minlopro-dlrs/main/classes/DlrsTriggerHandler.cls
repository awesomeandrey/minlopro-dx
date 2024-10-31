public virtual with sharing class DlrsTriggerHandler extends BasicTriggerHandler {
    public override Integer getMaxLoopCount() {
        return 50;
    }

    public override void beforeDelete(List<SObject> oldRecords) {
        dlrs.RollupService.triggerHandler(this.objectType);
    }

    public override void beforeInsert(List<SObject> newRecords) {
        dlrs.RollupService.triggerHandler(this.objectType);
    }

    public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        dlrs.RollupService.triggerHandler(this.objectType);
    }

    public override void afterDelete(List<SObject> oldRecords) {
        dlrs.RollupService.triggerHandler(this.objectType);
    }

    public override void afterInsert(List<SObject> newRecords) {
        dlrs.RollupService.triggerHandler(this.objectType);
    }

    public override void afterUndelete(List<SObject> newRecords) {
        dlrs.RollupService.triggerHandler(this.objectType);
    }

    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        dlrs.RollupService.triggerHandler(this.objectType);
    }
}
