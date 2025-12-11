# Minlopro - Search Account (Headless Action)

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VS Code, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within mkdocs-material, define mermaid plugin in `mkdocs.yml` as described in https://squidfunk.github.io/mkdocs-material/extensions/mermaid/
%% - As a last resort, you can copy-paste this MermaidJS code into https://mermaid.live/ to see the flow diagram

flowchart TB
START(["START<br/><b>AutoLaunched Flow</b></br>"]):::startClass
click START "#general-information" "4165766413"

Search_Accounts_via_HTTP_GET("⚡ <em></em><br/>Search Accounts via HTTP GET"):::actionCalls
click Search_Accounts_via_HTTP_GET "#search_accounts_via_http_get" "2502640740"

Capture_Error_Message[\"🟰 <em></em><br/>Capture Error Message"/]:::assignments
click Capture_Error_Message "#capture_error_message" "2044754553"

Capture_Found_Accounts_Details[\"🟰 <em></em><br/>Capture Found Accounts Details"/]:::assignments
click Capture_Found_Accounts_Details "#capture_found_accounts_details" "2929108767"

Cast_Search_Results_To_Account_SObjects{{"♻️ <em></em><br/>Cast Search Results To Account SObjects"}}:::transforms
click Cast_Search_Results_To_Account_SObjects "#cast_search_results_to_account_sobjects" "2725531125"

Search_Accounts_via_HTTP_GET --> Cast_Search_Results_To_Account_SObjects
Search_Accounts_via_HTTP_GET -. Fault .->Capture_Error_Message
Capture_Error_Message --> END_Capture_Error_Message
Capture_Found_Accounts_Details --> END_Capture_Found_Accounts_Details
START -->  Search_Accounts_via_HTTP_GET
Cast_Search_Results_To_Account_SObjects --> Capture_Found_Accounts_Details
END_Capture_Error_Message(( END )):::endClass
END_Capture_Found_Accounts_Details(( END )):::endClass


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
|Process Type| Auto Launched Flow|
|Label|Minlopro - Search Account (Headless Action)|
|Status|Active|
|Description|Headless auto-launched flow that searches for Account records via SOSL query.|
|Environments|Default|
|Interview Label|Minlopro - Search {!$Flow.CurrentDateTime}|
| Builder Type (PM)|LightningFlowBuilder|
| Canvas Mode (PM)|AUTO_LAYOUT_CANVAS|
| Origin Builder Type (PM)|LightningFlowBuilder|
|Connector|[Search_Accounts_via_HTTP_GET](#search_accounts_via_http_get)|
|Next Node|[Search_Accounts_via_HTTP_GET](#search_accounts_via_http_get)|


## Variables

|Name|Data Type|Is Collection|Is Input|Is Output|Object Type|Description|
|:-- |:--:|:--:|:--:|:--:|:--:|:--  |
|errorMessage|String|⬜|⬜|✅|<!-- -->|<!-- -->|
|foundAccounts|SObject|✅|⬜|✅|Account|<!-- -->|
|foundAccountsAsJson|Apex|⬜|⬜|⬜|<!-- -->|<!-- -->|
|foundAccountsSize|Number|⬜|⬜|✅|<!-- -->|<!-- -->|
|searchKeyword|String|⬜|✅|⬜|<!-- -->|<!-- -->|


## Formulas

|Name|Data Type|Expression|Description|
|:-- |:--:|:-- |:--  |
|soslQuery|String|'FIND {' + {!searchKeyword} + '} IN NAME FIELDS RETURNING Account(Id, Name, Description) LIMIT 10'|<!-- -->|


## Flow Nodes Details

### Search_Accounts_via_HTTP_GET

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Action Call|
|Label|Search Accounts via HTTP GET|
|Action Type|External Service|
|Action Name|MinloproSearchAccount.Search Accounts|
|Fault Connector|[Capture_Error_Message](#capture_error_message)|
|Flow Transaction Model|Automatic|
|Name Segment|MinloproSearchAccount.Search Accounts|
|Offset|0|
|Output Parameters|assignToReference: foundAccountsAsJson<br/>name: 2XX<br/>|
|Q (input)|soslQuery|
|Connector|[Cast_Search_Results_To_Account_SObjects](#cast_search_results_to_account_sobjects)|


### Capture_Error_Message

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Assignment|
|Label|Capture Error Message|


#### Assignments

|Assign To Reference|Operator|Value|
|:-- |:--:|:--: |
|errorMessage| Assign|$Flow.FaultMessage|




### Capture_Found_Accounts_Details

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Assignment|
|Label|Capture Found Accounts Details|


#### Assignments

|Assign To Reference|Operator|Value|
|:-- |:--:|:--: |
|foundAccounts| Assign|[Cast_Search_Results_To_Account_SObjects](#cast_search_results_to_account_sobjects)|
|foundAccountsSize| Assign Count|foundAccounts|




### Cast_Search_Results_To_Account_SObjects

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Transform|
|Label|Cast Search Results To Account SObjects|
|Data Type|SObject|
|Object Type|Account|
|Is Collection|✅|
|Scale|0|
|Store Output Automatically|✅|
|Connector|[Capture_Found_Accounts_Details](#capture_found_accounts_details)|


#### Transform actions

|Transform Type|Value|Output Field Api Name|
|:-- |:--:|:--  |
|Map|foundAccountsAsJson.searchRecords[$EachItem].Description|Description|
|Map|foundAccountsAsJson.searchRecords[$EachItem].Id|Id|
|Map|foundAccountsAsJson.searchRecords[$EachItem].Name|Name|








___

_Documentation generated from branch develop by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_