# Minlopro - Omni 🔱 - Route Critical Cases

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VS Code, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within mkdocs-material, define mermaid plugin in `mkdocs.yml` as described in https://squidfunk.github.io/mkdocs-material/extensions/mermaid/
%% - As a last resort, you can copy-paste this MermaidJS code into https://mermaid.live/ to see the flow diagram

flowchart TB
START(["START"]):::startClass
click START "#general-information" "2359866923"

Capture_Error_And_Log("⚙️ <em></em><br/>Capture Error & Log"):::actionCalls
click Capture_Error_And_Log "#capture_error_and_log" "3511232908"

Check_Availability_for_Cases_Routing("⚡ <em></em><br/>Check Availability for Cases Routing"):::actionCalls
click Check_Availability_for_Cases_Routing "#check_availability_for_cases_routing" "22922813"

Log_Availability_Output("⚙️ <em></em><br/>Log Availability Output"):::actionCalls
click Log_Availability_Output "#log_availability_output" "908502605"

Route_Critical_Case("⚡ <em></em><br/>Route Critical Case"):::actionCalls
click Route_Critical_Case "#route_critical_case" "2365181630"

Check_Case_Criticality{"🔀 <em></em><br/>Check Case Criticality"}:::decisions
click Check_Case_Criticality "#check_case_criticality" "996673248"

Critical_Cases_Queue[("🔍 <em></em><br/>Critical Cases Queue")]:::recordLookups
click Critical_Cases_Queue "#critical_cases_queue" "371970367"

Target_Case[("🔍 <em></em><br/>Target Case")]:::recordLookups
click Target_Case "#target_case" "1250900342"

Capture_Error_And_Log --> END_Capture_Error_And_Log
Check_Availability_for_Cases_Routing --> Log_Availability_Output
Check_Availability_for_Cases_Routing -. Fault .->Capture_Error_And_Log
Log_Availability_Output --> Route_Critical_Case
Route_Critical_Case --> END_Route_Critical_Case
Route_Critical_Case -. Fault .->Capture_Error_And_Log
Check_Case_Criticality --> |"Critical Case Detected"| Critical_Cases_Queue
Check_Case_Criticality --> |"Default Outcome"| END_Check_Case_Criticality
Critical_Cases_Queue --> Check_Availability_for_Cases_Routing
Target_Case --> Check_Case_Criticality
START -->  Target_Case
END_Capture_Error_And_Log(( END )):::endClass
END_Route_Critical_Case(( END )):::endClass
END_Check_Case_Criticality(( END )):::endClass


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
|Process Type| Routing Flow|
|Label|Minlopro - Omni 🔱 - Route Critical Cases|
|Status|Active|
|Environments|Default|
|Interview Label|Minlopro_Omni_RouteCriticalCases {!$Flow.CurrentDateTime}|
| Builder Type (PM)|LightningFlowBuilder|
| Canvas Mode (PM)|AUTO_LAYOUT_CANVAS|
| Origin Builder Type (PM)|LightningFlowBuilder|
|Connector|[Target_Case](#target_case)|
|Next Node|[Target_Case](#target_case)|


## Variables

|Name|Data Type|Is Collection|Is Input|Is Output|Object Type|Description|
|:-- |:--:|:--:|:--:|:--:|:--:|:--  |
|estimatedWaitTime|Number|⬜|⬜|⬜|<!-- -->|<!-- -->|
|onlineAgentsNum|Number|⬜|⬜|⬜|<!-- -->|<!-- -->|
|queuedWorkItemsNum|Number|⬜|⬜|⬜|<!-- -->|<!-- -->|
|recordId|String|⬜|✅|⬜|<!-- -->|Case Record ID|


## Formulas

|Name|Data Type|Expression|Description|
|:-- |:--:|:-- |:--  |
|availabilityLog|String|'Estimated Wait Time # = ' + TEXT({!estimatedWaitTime}) + ' | Online Agents # = ' + TEXT({!onlineAgentsNum}) + ' | Queued Work Items # = ' + TEXT({!queuedWorkItemsNum})|<!-- -->|
|isCriticalCase|Boolean|CONTAINS(LOWER({!Target_Case.Subject}), 'critical') || CONTAINS(LOWER({!Target_Case.Subject}), 'asap')|<!-- -->|


## Flow Nodes Details

### Capture_Error_And_Log

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Action Call|
|Label|Capture Error & Log|
|Action Type|Apex|
|Action Name|FlowLogger|
|Flow Transaction Model|CurrentTransaction|
|Name Segment|FlowLogger|
|Offset|0|
|Level (input)|ERROR|
|Message (input)|$Flow.FaultMessage|


### Check_Availability_for_Cases_Routing

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Action Call|
|Label|Check Availability for Cases Routing|
|Action Type|Check Availability For Routing|
|Action Name|checkAvailabilityForRouting|
|Fault Connector|isGoTo: true<br/>targetReference: Capture_Error_And_Log<br/>|
|Flow Transaction Model|CurrentTransaction|
|Name Segment|checkAvailabilityForRouting|
|Offset|0|
|Output Parameters|- assignToReference: queuedWorkItemsNum<br/>&nbsp;&nbsp;name: queueSize<br/>- assignToReference: onlineAgentsNum<br/>&nbsp;&nbsp;name: onlineAgentsCount<br/>- assignToReference: estimatedWaitTime<br/>&nbsp;&nbsp;name: estimatedWaitTime<br/>|
|Version String|2.0.0|
|Routing Type (input)|QueueBased|
|Service Channel Label (input)|Cases|
|Is Queue Variable (input)|✅|
|Skill Option (input)|<!-- -->|
|Selected Outputs (input)|GET_ALL|
|Skill Requirements Resource Item (input)|<!-- -->|
|Service Channel Id (input)|setupReference: Cases<br/>setupReferenceType: ServiceChannel<br/>|
|Agent Id (input)|<!-- -->|
|Queue Id (input)|Critical_Cases_Queue.Id|
|Service Channel Dev Name (input)|Cases|
|Queue Label (input)|<!-- -->|
|Agent Label (input)|<!-- -->|
|Connector|[Log_Availability_Output](#log_availability_output)|


### Log_Availability_Output

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Action Call|
|Label|Log Availability Output|
|Action Type|Apex|
|Action Name|FlowLogger|
|Flow Transaction Model|CurrentTransaction|
|Name Segment|FlowLogger|
|Offset|0|
|Message (input)|availabilityLog|
|Connector|[Route_Critical_Case](#route_critical_case)|


### Route_Critical_Case

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Action Call|
|Label|Route Critical Case|
|Action Type|Route Work|
|Action Name|routeWork|
|Fault Connector|[Capture_Error_And_Log](#capture_error_and_log)|
|Flow Transaction Model|CurrentTransaction|
|Name Segment|routeWork|
|Offset|0|
|Version String|2.0.0|
|Record Id (input)|Target_Case.Id|
|Service Channel Label (input)|Cases|
|Service Channel Dev Name (input)|Cases|
|Routing Type (input)|QueueBased|
|Routing Config Label (input)|<!-- -->|
|Agent Label (input)|<!-- -->|
|Queue Label (input)|<!-- -->|
|Skill Option (input)|<!-- -->|
|Skill Requirements Resource Item (input)|<!-- -->|
|Bot Label (input)|<!-- -->|
|External Conversation Bot Label (input)|<!-- -->|
|Copilot Label (input)|<!-- -->|
|Agentforce Employee Agent Label (input)|<!-- -->|
|Is Queue Variable (input)|✅|
|Service Channel Id (input)|setupReference: Cases<br/>setupReferenceType: ServiceChannel<br/>|
|Routing Config Id (input)|<!-- -->|
|Bot Id (input)|<!-- -->|
|Copilot Id (input)|<!-- -->|
|Agentforce Employee Agent Id (input)|<!-- -->|
|External Conversation Bot Id (input)|<!-- -->|
|Queue Id (input)|Critical_Cases_Queue.Id|
|Agent Id (input)|<!-- -->|


### Check_Case_Criticality

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Decision|
|Label|Check Case Criticality|
|Default Connector Label|Default Outcome|


#### Rule Critical_Case_Detected (Critical Case Detected)

|<!-- -->|<!-- -->|
|:---|:---|
|Connector|[Critical_Cases_Queue](#critical_cases_queue)|
|Condition Logic|and|




|Condition Id|Left Value Reference|Operator|Right Value|
|:-- |:-- |:--:|:--: |
|1|[Target_Case](#target_case)| Is Null|⬜|
|2|isCriticalCase| Equal To|✅|




### Critical_Cases_Queue

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Lookup|
|Object|Group|
|Label|Critical Cases Queue|
|Assign Null Values If No Records Found|⬜|
|Get First Record Only|✅|
|Store Output Automatically|✅|
|Connector|[Check_Availability_for_Cases_Routing](#check_availability_for_cases_routing)|


#### Filters (logic: **and**)

|Filter Id|Field|Operator|Value|
|:-- |:-- |:--:|:--: |
|1|Type| Equal To|Queue|
|2|DeveloperName| Equal To|Minlopro_CriticalWorkItems|




### Target_Case

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Lookup|
|Object|Case|
|Label|Target Case|
|Assign Null Values If No Records Found|⬜|
|Get First Record Only|✅|
|Store Output Automatically|✅|
|Connector|[Check_Case_Criticality](#check_case_criticality)|


#### Filters (logic: **and**)

|Filter Id|Field|Operator|Value|
|:-- |:-- |:--:|:--: |
|1|Id| Equal To|recordId|








___

_Documentation generated from branch develop by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_