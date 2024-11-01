public abstract with sharing class BasicTriggerHandler {
    protected SObjectType objectType;

    public void setObjectType(SObjectType objectType) {
        this.objectType = objectType;
    }

    public BasicTriggerHandler() {
    }

    public virtual Integer getMaxLoopCount() {
        /**
         * The returned value should consider each trigger phase as an additional counter.
         * "-1" is treated as an infinite count.
         */
        return -1;
    }

    public virtual void beforeDelete(List<SObject> oldRecords) {
    }

    public virtual void beforeInsert(List<SObject> newRecords) {
    }

    public virtual void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
    }

    public virtual void afterDelete(List<SObject> oldRecords) {
    }

    public virtual void afterInsert(List<SObject> newRecords) {
    }

    public virtual void afterUndelete(List<SObject> newRecords) {
    }

    public virtual void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
    }
}
