public inherited sharing class ProcessInstanceSelector extends fflib_SObjectSelector {
    private final Repository repository = (Repository) Application.Service.newInstance(Repository.class);
    private static final String STATUS_STARTED = 'Started';
    private static final String STATUS_PENDING = 'Pending';
    private static final String STATUS_APPROVED = 'Approved';
    private static final String STATUS_REJECTED = 'Rejected';

    public SObjectType getSObjectType() {
        return ProcessInstance.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            ProcessInstance.Id,
            ProcessInstance.CompletedDate,
            ProcessInstance.CreatedById,
            ProcessInstance.CreatedById,
            ProcessInstance.LastActorId,
            ProcessInstance.ProcessDefinitionId,
            ProcessInstance.Status,
            ProcessInstance.SubmittedById,
            ProcessInstance.TargetObjectId
        };
    }

    public Map<Id, List<ProcessInstance>> selectByTargetObjectIds(List<Id> targetObjectIds) {
        return this.selectByStatusAndTargetObjectIds(
            new List<String>{
                ProcessInstanceSelector.STATUS_STARTED,
                ProcessInstanceSelector.STATUS_PENDING,
                ProcessInstanceSelector.STATUS_APPROVED,
                ProcessInstanceSelector.STATUS_REJECTED
            },
            targetObjectIds
        );
    }

    private Map<Id, List<ProcessInstance>> selectByStatusAndTargetObjectIds(
        List<String> processStatuses,
        List<Id> targetObjectIds
    ) {
        fflib_QueryFactory queryFactory = this.newQueryFactory(false, true, true);
        queryFactory.setLimit(1000);
        queryFactory.setOrdering(ProcessInstance.CreatedById, fflib_QueryFactory.SortOrder.ASCENDING);
        queryFactory.setCondition(
            String.format('Status IN :{0} AND TargetObjectId IN :{1}', Lists.of('processStatuses', 'targetObjectIds'))
        );
        Logger.debug(queryFactory.toSOQL());
        List<ProcessInstance> processInstances = this.repository.queryWithBinds(
            queryFactory.toSOQL(),
            new Map<String, Object>{ 'processStatuses' => processStatuses, 'targetObjectIds' => targetObjectIds },
            System.AccessLevel.SYSTEM_MODE
        );
        Logger.debug(processInstances.size());
        // Put result set into map;
        Map<Id, List<ProcessInstance>> processInstancesByTargetObjectIds = new Map<Id, List<ProcessInstance>>();
        for (ProcessInstance pItem : processInstances) {
            Id targetObjectId = pItem.TargetObjectId;
            if (!processInstancesByTargetObjectIds.containsKey(targetObjectId)) {
                processInstancesByTargetObjectIds.put(targetObjectId, new List<ProcessInstance>());
            }
            processInstancesByTargetObjectIds.get(targetObjectId).add(pItem);
        }
        return processInstancesByTargetObjectIds;
    }
}
