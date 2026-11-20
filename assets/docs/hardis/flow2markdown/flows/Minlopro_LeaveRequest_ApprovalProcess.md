<!-- This file is auto-generated. if you do not want it to be overwritten, set TRUE in the line below -->
<!-- DO_NOT_OVERWRITE_DOC=FALSE -->

# Minlopro - Leave Request - Two Stage Approval

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VS Code, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within a Zensical site, define the mermaid custom fence in `mkdocs.yml` as described in https://zensical.org/docs/
%% - As a last resort, you can copy-paste this MermaidJS code into https://mermaid.live/ to see the flow diagram

flowchart TB
START(["START<br/><b>LeaveRequest__c</b><br/>Type: <b>Record After Save</b><br/>On: <b>Update</b>"]):::startClass
click START "#general-information" "2892942386"

HRPB_Approval{"🔀 <em></em><br/>HRPB Approval"}:::decisions
click HRPB_Approval "#hrpb_approval" "740707952"

LineManagerApproval{"🔀 <em></em><br/>Line Manager Approval"}:::decisions
click LineManagerApproval "#linemanagerapproval" "1408804431"

HRPB_Approval --> |"HRPB Approve"| Final_Stage
HRPB_Approval --> |"HRBP Reject"| Fault_Rejection_Stage
LineManagerApproval --> |"LM Approve"| Approval_Stage_2
LineManagerApproval --> |"LM Reject"| Fault_Rejection_Stage
START -->  Approval_Stage_1


classDef actionCalls fill:#D4E4FC,color:black,text-decoration:none,max-height:100px
classDef assignments fill:#FBEED7,color:black,text-decoration:none,max-height:100px
classDef collectionProcessors fill:#F0E3FA,color:black,text-decoration:none,max-height:100px
classDef customErrors fill:#FFE9E9,color:black,text-decoration:none,max-height:100px
classDef decisions fill:#FDEAF6,color:black,text-decoration:none,max-height:100px
classDef loops fill:#FDEAF6,color:black,text-decoration:none,max-height:100px
classDef recordCreates fill:#FFF8C9,color:black,text-decoration:none,max-height:100px
classDef recordDeletes fill:#FFF8C9,color:black,text-decoration:none,max-height:100px
classDef recordLookups fill:#EDEAFF,color:black,text-decoration:none,max-height:100px
classDef recordRollbacks fill:#FFF8C9,color:black,text-decoration:none,max-height:100px
classDef recordUpdates fill:#FFF8C9,color:black,text-decoration:none,max-height:100px
classDef screens fill:#DFF6FF,color:black,text-decoration:none,max-height:100px
classDef subflows fill:#D4E4FC,color:black,text-decoration:none,max-height:100px
classDef startClass fill:#D9F2E6,color:black,text-decoration:none,max-height:100px
classDef endClass fill:#F9BABA,color:black,text-decoration:none,max-height:100px
classDef transforms fill:#FDEAF6,color:black,text-decoration:none,max-height:100px


```

<!-- Flow description -->

## General Information

|<!-- -->|<!-- -->|
|:---|:---|
|Object|LeaveRequest__c|
|Process Type|Approval Workflow|
|Trigger Type|Record After Save|
|Record Trigger Type|Update|
|Label|Minlopro - Leave Request - Two Stage Approval|
|Status|Active|
|Does Require Record Changed To Meet Criteria|✅|
|Description|Multi-stage approval flow to handle leave requests.|
|Environments|Default|
|Interview Label|Minlopro_LeaveRequest_ApprovalProcess {!$Flow.CurrentDateTime}|
|Run In Mode|System Mode Without Sharing|
|BuilderType (PM)|LightningFlowBuilder|
|CanvasMode (PM)|AUTO_LAYOUT_CANVAS|
|OriginBuilderType (PM)|LightningFlowBuilder|
|Connector|Approval_Stage_1|
|Next Node|Approval_Stage_1|


#### Filters (logic: **and**)

|Filter Id|Field|Operator|Value|
|:-- |:-- |:--:|:--: |
|1|Status__c|Equal To|New|


## Formulas

|Name|Data Type|Expression|Description|
|:-- |:--:|:-- |:--  |
|faultOrRejectionMessage|String|IF(ISBLANK({!$Flow.FaultMessage}), 'LM approval decision = ' + {!LM_Approval.Outputs.approvalDecision} + ' | HRBP approval decision = ' + {!HRBP_Approval.Outputs.approvalDecision}, {!$Flow.FaultMessage})|<!-- -->|


## Flow Nodes Details

### HRPB_Approval

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Decision|
|Label|HRPB Approval|
|Default Connector|isGoTo: true<br/>targetReference: Fault_Rejection_Stage<br/>|
|Default Connector Label|HRBP Reject|


#### Rule HRPB_Approve (HRPB Approve)

|<!-- -->|<!-- -->|
|:---|:---|
|Connector|Final_Stage|
|Condition Logic|and|




|Condition Id|Left Value Reference|Operator|Right Value|
|:-- |:-- |:--:|:--: |
|1|HRBP_Approval.Outputs.approvalDecision|Equal To|Approve|




### LineManagerApproval

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Decision|
|Label|Line Manager Approval|
|Default Connector|isGoTo: true<br/>targetReference: Fault_Rejection_Stage<br/>|
|Default Connector Label|LM Reject|


#### Rule LM_Approv (LM Approve)

|<!-- -->|<!-- -->|
|:---|:---|
|Connector|Approval_Stage_2|
|Condition Logic|and|




|Condition Id|Left Value Reference|Operator|Right Value|
|:-- |:-- |:--:|:--: |
|1|LM_Approval.Outputs.approvalDecision|Equal To|Approve|








___

_Documentation generated from branch develop by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_