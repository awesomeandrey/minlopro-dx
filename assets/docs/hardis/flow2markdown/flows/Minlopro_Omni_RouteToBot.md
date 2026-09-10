# Minlopro - Omni 🔱 - Route To Bot (Inbound)

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VS Code, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within a Zensical site, define the mermaid custom fence in `mkdocs.yml` as described in https://zensical.org/docs/
%% - As a last resort, you can copy-paste this MermaidJS code into https://mermaid.live/ to see the flow diagram

flowchart TB
START(["START"]):::startClass
click START "#general-information" "1454237146"

Capture_Error_Log("⚙️ <em></em><br/>Capture Error & Log"):::actionCalls
click Capture_Error_Log "#capture_error_log" "2029947761"

RoutingAction("⚡ <em></em><br/>Route to Osama"):::actionCalls
click RoutingAction "#routingaction" "1391290176"

Find_Fallback_Queue[("🔍 <em></em><br/>Find Fallback Queue")]:::recordLookups
click Find_Fallback_Queue "#find_fallback_queue" "2357930503"

Capture_Error_Log --> END_Capture_Error_Log
RoutingAction --> END_RoutingAction
RoutingAction -. Fault .->Capture_Error_Log
Find_Fallback_Queue --> RoutingAction
START -->  Find_Fallback_Queue
END_Capture_Error_Log(( END )):::endClass
END_RoutingAction(( END )):::endClass


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
|Process Type|Routing Flow|
|Label|Minlopro - Omni 🔱 - Route To Bot (Inbound)|
|Status|Active|
|Description|TODO|
|Environments|Default|
|Interview Label|Minlopro_Omni_RouteToBot (Inbound) {!$Flow.CurrentDateTime}|
|BuilderType (PM)|LightningFlowBuilder|
|CanvasMode (PM)|AUTO_LAYOUT_CANVAS|
|OriginBuilderType (PM)|LightningFlowBuilder|
|Connector|[Find_Fallback_Queue](#find_fallback_queue)|
|Next Node|[Find_Fallback_Queue](#find_fallback_queue)|


## Variables

|Name|Data Type|Is Collection|Is Input|Is Output|Object Type|Description|
|:-- |:--:|:--:|:--:|:--:|:--:|:--  |
|recordId|String|⬜|✅|⬜|<!-- -->|<!-- -->|


## Flow Nodes Details

### Capture_Error_Log

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Action Call|
|Label|Capture Error & Log|
|Action Type|Apex|
|Action Name|FlowLogger|
|Flow Transaction Model|Automatic|
|Name Segment|FlowLogger|
|Offset|0|
|level (input)|inputConfiguratorMode: Resource<br/>stringValue: ERROR<br/>|
|message (input)|elementReference: $Flow.FaultMessage<br/>inputConfiguratorMode: Resource<br/>|


### RoutingAction

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Action Call|
|Label|Route to Osama|
|Action Type|Route Work|
|Action Name|routeWork|
|Description|Routes all messages to your enhanced bot.|
|Fault Connector|[Capture_Error_Log](#capture_error_log)|
|Flow Transaction Model|CurrentTransaction|
|Name Segment|routeWork|
|Offset|0|
|Version String|2.0.0|
|recordId (input)|recordId|
|serviceChannelLabel (input)|Messaging|
|serviceChannelDevName (input)|sfdc_livemessage|
|routingType (input)|Bot|
|routingConfigLabel (input)|<!-- -->|
|agentLabel (input)|<!-- -->|
|queueLabel (input)|<!-- -->|
|skillOption (input)|<!-- -->|
|skillRequirementsResourceItem (input)|<!-- -->|
|botLabel (input)|Osama|
|externalConversationBotLabel (input)|<!-- -->|
|copilotLabel (input)|<!-- -->|
|agentforceEmployeeAgentLabel (input)|<!-- -->|
|digitalWorkerLabel (input)|<!-- -->|
|isQueueVariable (input)|✅|
|routingStartOption (input)|<!-- -->|
|serviceChannelId (input)|setupReference: sfdc_livemessage<br/>setupReferenceType: ServiceChannel<br/>|
|routingConfigId (input)|<!-- -->|
|botId (input)|setupReference: Osama<br/>setupReferenceType: BotDefinition<br/>|
|copilotId (input)|<!-- -->|
|agentforceEmployeeAgentId (input)|<!-- -->|
|externalConversationBotId (input)|<!-- -->|
|digitalWorkerId (input)|<!-- -->|
|queueId (input)|Find_Fallback_Queue.Id|
|agentId (input)|<!-- -->|


### Find_Fallback_Queue

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Lookup|
|Object|Group|
|Label|Find Fallback Queue|
|Assign Null Values If No Records Found|⬜|
|Get First Record Only|✅|
|Store Output Automatically|✅|
|Connector|[RoutingAction](#routingaction)|


#### Filters (logic: **and**)

|Filter Id|Field|Operator|Value|
|:-- |:-- |:--:|:--: |
|1|Type|Equal To|Queue|
|2|DeveloperName|Equal To|DigEx_SiteMessagingRequests|








___

_Documentation generated from branch develop by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_