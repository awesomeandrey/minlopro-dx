/**
 * Pre-requisite: navigate to Setup > Process Automation Settings > Enable record locking and unlocking in Apex.
 */
public with sharing class ApprovalProcessController {
    private static final String OPP_PROCESS_DEF_NAME = 'ApproveHighRevenueOpportunity';
    private static final ProcessInstanceSelector processInstanceSelector = (ProcessInstanceSelector) Application.Selector.newInstance(
        ProcessInstance.SObjectType
    );

    @AuraEnabled(Cacheable=true)
    public static Boolean isLocked(Id recordId) {
        try {
            if (String.isBlank(recordId)) {
                return false;
            }
            return Approval.isLocked(recordId);
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<ProcessInstance> getProcessInstancesByRecordId(Id recordId) {
        try {
            Map<Id, List<ProcessInstance>> processInstanceMap = processInstanceSelector.selectByTargetObjectIds(
                Lists.of(recordId)
            );
            return processInstanceMap.containsKey(recordId) ? processInstanceMap.get(recordId) : new List<ProcessInstance>();
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void lock(Id recordId) {
        try {
            Approval.lock(recordId);
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void unlock(Id recordId) {
        try {
            Approval.unlock(recordId);
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String submitOpportunityForApproval(Id opportunityId, Id submitterId, Boolean skipEntryCriteria) {
        try {
            // Find process definition first;
            List<ProcessDefinition> processDefinitions = [
                SELECT Id, DeveloperName
                FROM ProcessDefinition
                WHERE DeveloperName = :OPP_PROCESS_DEF_NAME
                LIMIT 1
            ];
            if (processDefinitions.isEmpty()) {
                throw new IllegalArgumentException(
                    String.format('Opportunity approval process not found: [{0}].', Lists.of(OPP_PROCESS_DEF_NAME))
                );
            }
            ProcessDefinition processDef = processDefinitions[0];
            Logger.debug('Process Definition ID: {0}', Lists.of(processDef.Id));
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments('Submitting Opportunity request for approval from APEX.');
            approvalRequest.setObjectId(opportunityId);
            approvalRequest.setSubmitterId(submitterId);
            // Pass 'DeveloperName' instead of 'Id';
            approvalRequest.setProcessDefinitionNameOrId(processDef.DeveloperName);
            approvalRequest.setSkipEntryCriteria(skipEntryCriteria);
            approvalRequest.setNextApproverIds(new List<Id>{ UserInfo.getUserId() });
            Approval.ProcessResult result = Approval.process(approvalRequest);
            Logger.debug('After PSR instantiation.');
            return JSON.serialize(result);
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
