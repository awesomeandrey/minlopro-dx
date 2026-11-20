<!-- This file is auto-generated. if you do not want it to be overwritten, set TRUE in the line below -->
<!-- DO_NOT_OVERWRITE_DOC=FALSE -->

# Minlopro - Leave Request - Update Record

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VS Code, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within a Zensical site, define the mermaid custom fence in `mkdocs.yml` as described in https://zensical.org/docs/
%% - As a last resort, you can copy-paste this MermaidJS code into https://mermaid.live/ to see the flow diagram

flowchart TB
START(["START<br/><b>AutoLaunched Flow</b></br>"]):::startClass
click START "#general-information" "3498908508"

Update_Leave_Request[("🛠️ <em></em><br/>Update Leave Request")]:::recordUpdates
click Update_Leave_Request "#update_leave_request" "1341166827"

Update_Leave_Request --> END_Update_Leave_Request
START -->  Update_Leave_Request
END_Update_Leave_Request(( END )):::endClass


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
|Process Type|Auto Launched Flow|
|Label|Minlopro - Leave Request - Update Record|
|Status|Active|
|Description|Utility flow referenced in Flow Approval Process.|
|Environments|Default|
|Interview Label|Minlopro - Leave Request - Update Record {!$Flow.CurrentDateTime}|
|BuilderType (PM)|LightningFlowBuilder|
|CanvasMode (PM)|AUTO_LAYOUT_CANVAS|
|OriginBuilderType (PM)|LightningFlowBuilder|
|Connector|[Update_Leave_Request](#update_leave_request)|
|Next Node|[Update_Leave_Request](#update_leave_request)|


## Variables

|Name|Data Type|Is Collection|Is Input|Is Output|Object Type|Description|
|:-- |:--:|:--:|:--:|:--:|:--:|:--  |
|recordId|String|⬜|✅|⬜|<!-- -->|Leave Request record ID.|
|status|String|⬜|✅|⬜|<!-- -->|Value to apply for Leave Request record 'Status' field.|
|statusComment|String|⬜|✅|⬜|<!-- -->|Value to apply for Leave Request record 'Status Comment' field.|


## Flow Nodes Details

### Update_Leave_Request

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Update|
|Object|LeaveRequest__c|
|Label|Update Leave Request|


#### Filters (logic: **and**)

|Filter Id|Field|Operator|Value|
|:-- |:-- |:--:|:--: |
|1|Id|Equal To|recordId|




#### Input Assignments

|Field|Value|
|:-- |:--: |
|StatusComment__c|statusComment|
|Status__c|[status](#status)|








___

_Documentation generated from branch develop by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_