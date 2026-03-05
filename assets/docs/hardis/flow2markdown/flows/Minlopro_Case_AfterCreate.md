# Minlopro - Case - After Create

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VS Code, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within mkdocs-material, define mermaid plugin in `mkdocs.yml` as described in https://squidfunk.github.io/mkdocs-material/extensions/mermaid/
%% - As a last resort, you can copy-paste this MermaidJS code into https://mermaid.live/ to see the flow diagram

flowchart TB
START(["START<br/><b>AutoLaunched Flow</b></br>Type: <b> Record After Save</b>"]):::startClass
click START "#general-information" "3735637331"

Log_Transaction_Details("⚙️ <em></em><br/>Log Transaction Details"):::actionCalls
click Log_Transaction_Details "#log_transaction_details" "1294091538"

Route_Critical_Case[["🔗 <em>Subflow</em><br/>Route Critical Case"]]:::subflows
click Route_Critical_Case "#route_critical_case" "2148799817"

Log_Transaction_Details --> Route_Critical_Case
START -->  Log_Transaction_Details
Route_Critical_Case --> END_Route_Critical_Case
END_Route_Critical_Case(( END )):::endClass


classDef actionCalls fill:#D4E4FC,color:black,text-decoration:none,max-height:100px
classDef assignments fill:#FBEED7,color:black,text-decoration:none,max-height:100px
classDef collectionProcessors fill:#F0E3FA,color:black,text-decoration:none,max-height:100px
classDef customErrors fill:#FFE9E9,color:black,text-decoration:none,max-height:100px
classDef decisions fill:#FDEAF6,color:black,text-decoration:none,max-height:100px
classDef loops fill:#FDEAF6,color:black,text-decoration:none,max-height:100px
classDef recordCreates fill:#FFF8C9,color:black,text-decoration:none,max-height:100px
classDef recordDeletes fill:#FFF8C9,color:black,text-decoration:none,max-height:100px
classDef recordLookups fill:#EDEAFF,color:black,text-decoration:none,max-height:100px
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
|Object|Case|
|Process Type| Auto Launched Flow|
|Trigger Type| Record After Save|
|Record Trigger Type| Create|
|Label|Minlopro - Case - After Create|
|Status|Active|
|Description|Captures critical Case creation and routes to special queue!|
|Environments|Default|
|Interview Label|Minlopro_Case_AfterCreate {!$Flow.CurrentDateTime}|
| Builder Type (PM)|LightningFlowBuilder|
| Canvas Mode (PM)|AUTO_LAYOUT_CANVAS|
| Origin Builder Type (PM)|LightningFlowBuilder|
|Connector|[Log_Transaction_Details](#log_transaction_details)|
|Next Node|[Log_Transaction_Details](#log_transaction_details)|


## Formulas

|Name|Data Type|Expression|Description|
|:-- |:--:|:-- |:--  |
|hasCriticalSubject|Boolean|CONTAINS(LOWER({!$Record.Subject}),'critical')|<!-- -->|


## Flow Nodes Details

### Log_Transaction_Details

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Action Call|
|Label|Log Transaction Details|
|Action Type|Apex|
|Action Name|FlowLogger|
|Flow Transaction Model|Automatic|
|Name Segment|FlowLogger|
|Offset|0|
|Message (input)|Entry Point 'Case' record-triggered flow|
|Connector|[Route_Critical_Case](#route_critical_case)|


### Route_Critical_Case

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Subflow|
|Label|Route Critical Case|
|Flow Name|Minlopro_Omni_RouteCriticalCases|


#### Input Assignments

|Field|Value|
|:-- |:--: |
|<!-- -->|$Record.Id|








___

_Documentation generated from branch develop by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_