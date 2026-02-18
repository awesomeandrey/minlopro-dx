public inherited sharing class TH_AgentWork_Monitor extends BasicTriggerHandler {
    public override void beforeInsert(List<SObject> newRecords) {
        Logger.debug(this.cloneKeyFields(newRecords));
    }

    public override void afterInsert(List<SObject> newRecords) {
        Logger.debug(this.cloneKeyFields(newRecords));
    }

    public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        Logger.debug(this.cloneKeyFields(oldMap.values()));
    }

    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        Logger.debug(this.cloneKeyFields(newMap.values()));
    }

    public override void afterDelete(List<SObject> oldRecords) {
        Logger.debug(this.cloneKeyFields(oldRecords));
    }

    private List<AgentWork> cloneKeyFields(List<AgentWork> originalRecords) {
        List<AgentWork> clonedRecords = new List<AgentWork>();
        for (AgentWork aw : originalRecords) {
            clonedRecords.add(this.cloneKeyFields(aw));
        }
        return clonedRecords;
    }

    private static final Set<String> KEY_FIELDS = new Set<String>{
        // Identity fields
        'Id',
        'Name',
        'OwnerId',
        'UserId',
        // Status & timestamps
        'Status',
        'AssignedDateTime',
        'AcceptDateTime',
        'DeclineDateTime',
        'CloseDateTime',
        'DeclineReason',
        // Routing configuration
        'RoutingModel',
        'RoutingType',
        'RoutingPriority',
        'ServiceChannelId',
        // Capacity settings
        'CapacityWeight',
        'CapacityPercentage',
        'IsInterruptible',
        // Queue & group identifiers
        'OriginalGroupId',
        'OriginalQueueId',
        // Work item reference
        'WorkItemId'
    };

    private AgentWork cloneKeyFields(AgentWork sourceRecord) {
        Map<String, Object> allFields = sourceRecord.getPopulatedFieldsAsMap();
        Map<String, Object> filtered = new Map<String, Object>();
        for (String fieldName : KEY_FIELDS) {
            if (allFields.containsKey(fieldName)) {
                filtered.put(fieldName, allFields.get(fieldName));
            }
        }
        return (AgentWork) JSON.deserialize(JSON.serialize(filtered), AgentWork.class);
    }
}
