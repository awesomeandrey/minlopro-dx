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

    @AuraEnabled
    public static ApprovalProcessController.Node generateHierarchyGraph(String processInstanceId) {
        try {
            Logger.debug(processInstanceId);
            // Compose root node;
            List<ProcessInstance> processInstances = [
                SELECT
                    Id,
                    Status,
                    SubmittedBy.Name,
                    LastActor.Name,
                    (SELECT Id, ProcessNodeName, NodeStatus, LastActor.Name FROM Nodes),
                    (SELECT Id, StepStatus, Actor.Name FROM Steps),
                    (SELECT Id, OriginalActor.Name, Actor.Name FROM Workitems),
                    (SELECT Id, StepStatus, CreatedDate, Comments FROM StepsAndWorkitems)
                FROM ProcessInstance
                WHERE Id = :processInstanceId
                LIMIT 100
            ];
            Logger.debug(processInstances.size());
            ProcessInstance processInstanceRecord = processInstances[0];
            Node rootNode = new Node(processInstanceRecord);
            rootNode.addChildren(processInstanceRecord.Steps);
            rootNode.addChildren(processInstanceRecord.Nodes);
            rootNode.addChildren(processInstanceRecord.StepsAndWorkitems);
            rootNode.addChildren(processInstanceRecord.Workitems);
            return rootNode;
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class Node {
        public SObjectType sObjectType {
            get {
                return this.record?.getSObjectType();
            }
        }

        @AuraEnabled
        public SObject record;

        @AuraEnabled
        public Id recordId {
            get {
                return this.record?.Id;
            }
            private set;
        }

        @AuraEnabled
        public String objectName {
            get {
                return this.sObjectType?.toString();
            }
        }

        @AuraEnabled
        public String displayName {
            get {
                if (this.sObjectType == ProcessInstance.SObjectType) {
                    String status = (String) this.record.get(ProcessInstance.Status);
                    return String.format('PI ({0})', Lists.of(status.toUpperCase()));
                } else if (this.sObjectType == ProcessInstanceStep.SObjectType) {
                    String stepStatus = (String) this.record.get(ProcessInstanceStep.StepStatus);
                    return String.format('PIS-{0}', Lists.of(stepStatus));
                } else if (this.sObjectType == ProcessInstanceNode.SObjectType) {
                    String nodeName = (String) this.record.get(ProcessInstanceNode.ProcessNodeName);
                    String nodeStatus = (String) this.record.get(ProcessInstanceNode.NodeStatus);
                    return String.format('PIN-[{0}]-{1}', Lists.of(nodeName, nodeStatus));
                } else if (this.sObjectType == ProcessInstanceWorkitem.SObjectType) {
                    String actorId = (Id) this.record.get(ProcessInstanceWorkitem.ActorId);
                    return String.format('PIWI-{0}', Lists.of(actorId));
                } else if (this.sObjectType == ProcessInstanceHistory.SObjectType) {
                    return String.format('PIH', Lists.of(''));
                }
                return 'Unknown Node Type';
            }
        }

        @AuraEnabled
        public List<ApprovalProcessController.Node> children { get; set; }

        public Node() {
            this.children = new List<ApprovalProcessController.Node>();
        }

        public Node(SObject record) {
            this();
            this.record = record;
        }

        public void addChild(SObject record) {
            this.addChild(new Node(record));
        }

        public void addChild(ApprovalProcessController.Node nodeItem) {
            this.children.add(nodeItem);
        }

        public void addChildren(List<SObject> records) {
            List<ApprovalProcessController.Node> nodeItems = new List<ApprovalProcessController.Node>();
            for (SObject record : records) {
                nodeItems.add(new ApprovalProcessController.Node(record));
            }
            this.addChildren(nodeItems);
        }

        public void addChildren(List<ApprovalProcessController.Node> nodeItems) {
            this.children.addAll(nodeItems);
        }
    }
}
