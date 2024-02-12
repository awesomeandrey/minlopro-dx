public abstract with sharing class BasicTriggerHandler {
    public BasicTriggerHandler() {
    }

    public virtual Integer getMaxLoopCount() {
        /**
         * The returned value should consider each trigger phase as an additional counter.
         * "-1" is treated as an infinite count.
         */
        return -1;
    }

    public virtual void beforeInsert(List<SObject> newRecords) {
    }

    public virtual void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
    }

    public virtual void afterInsert(List<SObject> newRecords) {
    }

    public virtual void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
    }
}
