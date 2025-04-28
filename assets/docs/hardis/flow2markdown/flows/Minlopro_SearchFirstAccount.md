# Minlopro - Search First Account

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VsCode, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within mkdocs-material, define mermaid plugin in `mkdocs.yml` as described in https://squidfunk.github.io/mkdocs-material/extensions/mermaid/
%% - At last resort, you can copy-paste this MermaidJS code in https://mermaid.live/ to see the Flow Diagram

flowchart TB
START(["START<br/><b>Screen Flow</b>"]):::startClass
click START "#general-information" "3263047891"

Search_Accounts_via_HTTP_GET("⚡ <em></em><br/>Search Accounts via HTTP GET"):::actionCalls
click Search_Accounts_via_HTTP_GET "#search_accounts_via_http_get" "4068503304"

Compute_Found_Accounts_Size[\"🟰 <em></em><br/>Compute Found Accounts Size"/]:::assignments
click Compute_Found_Accounts_Size "#compute_found_accounts_size" "3900973732"

Extract_First_Found_Account[\"🟰 <em></em><br/>Extract First Found Account"/]:::assignments
click Extract_First_Found_Account "#extract_first_found_account" "3792896053"

Iterate_Through_Found_Accounts{{"🔁 <em></em><br/>Iterate Through Found Accounts"}}:::loops
click Iterate_Through_Found_Accounts "#iterate_through_found_accounts" "1681855233"

Callout_Error_Screen(["💻 <em></em><br/>Callout Error Screen"]):::screens
click Callout_Error_Screen "#callout_error_screen" "872223558"

Query_Results_Screen(["💻 <em></em><br/>Query Results Screen"]):::screens
click Query_Results_Screen "#query_results_screen" "910082871"

Search_Keyword_Screen(["💻 <em></em><br/>Search Keyword Screen"]):::screens
click Search_Keyword_Screen "#search_keyword_screen" "3449864410"

Search_Accounts_via_HTTP_GET --> Compute_Found_Accounts_Size
Search_Accounts_via_HTTP_GET -. Fault .->Callout_Error_Screen
Compute_Found_Accounts_Size --> Iterate_Through_Found_Accounts
Extract_First_Found_Account --> Query_Results_Screen
Iterate_Through_Found_Accounts --> |"For Each"|Extract_First_Found_Account
Iterate_Through_Found_Accounts ---> |"After Last"|Query_Results_Screen
Callout_Error_Screen --> END_Callout_Error_Screen
Query_Results_Screen --> END_Query_Results_Screen
Search_Keyword_Screen --> Search_Accounts_via_HTTP_GET
START -->  Search_Keyword_Screen
END_Callout_Error_Screen(( END )):::endClass
END_Query_Results_Screen(( END )):::endClass


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
|Process Type| Flow|
|Label|Minlopro - Search First Account|
|Status|Active|
|Description|Screen Flow that searches for Account records via SOSL query and captures the 1st one found.|
|Environments|Default|
|Interview Label|Minlopro - Search First Account {!$Flow.CurrentDateTime}|
| Builder Type (PM)|LightningFlowBuilder|
| Canvas Mode (PM)|AUTO_LAYOUT_CANVAS|
| Origin Builder Type (PM)|LightningFlowBuilder|
|Connector|[Search_Keyword_Screen](#search_keyword_screen)|
|Next Node|[Search_Keyword_Screen](#search_keyword_screen)|


## Variables

|Name|Data Type|Is Collection|Is Input|Is Output|Object Type|Description|
|:-- |:--:|:--:|:--:|:--:|:--:|:--  |
|firstFoundAccount|Apex|⬜|⬜|⬜|<!-- -->|<!-- -->|
|foundAccounts|Apex|⬜|⬜|⬜|<!-- -->|<!-- -->|
|foundAccountsSize|Number|⬜|⬜|⬜|<!-- -->|<!-- -->|
|selectedAccount|SObject|⬜|⬜|✅|Account|Output Account variable selected by running user|
|selectedAccountId|String|⬜|⬜|✅|<!-- -->|<!-- -->|


## Formulas

|Name|Data Type|Expression|Description|
|:-- |:--:|:-- |:--  |
|soslQuery|String|'FIND {' + {!Account_Search_Keyword} + '} IN NAME FIELDS RETURNING Account(Id, Name, Description) LIMIT 10'|<!-- -->|


## Flow Nodes Details

### Search_Accounts_via_HTTP_GET

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Action Call|
|Label|Search Accounts via HTTP GET|
|Action Type|External Service|
|Action Name|MinloproSearchAccount.Search Accounts|
|Fault Connector|[Callout_Error_Screen](#callout_error_screen)|
|Flow Transaction Model|Automatic|
|Name Segment|MinloproSearchAccount.Search Accounts|
|Offset|0|
|Output Parameters|assignToReference: foundAccounts<br/>name: 2XX<br/>|
|Q (input)|soslQuery|
|Connector|[Compute_Found_Accounts_Size](#compute_found_accounts_size)|


### Compute_Found_Accounts_Size

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Assignment|
|Label|Compute Found Accounts Size|
|Connector|[Iterate_Through_Found_Accounts](#iterate_through_found_accounts)|


#### Assignments

|Assign To Reference|Operator|Value|
|:-- |:--:|:--: |
|foundAccountsSize| Assign Count|foundAccounts.searchRecords|




### Extract_First_Found_Account

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Assignment|
|Label|Extract First Found Account|
|Connector|isGoTo: true<br/>targetReference: Query_Results_Screen<br/>|


#### Assignments

|Assign To Reference|Operator|Value|
|:-- |:--:|:--: |
|firstFoundAccount| Assign|[Iterate_Through_Found_Accounts](#iterate_through_found_accounts)|
|selectedAccountId| Assign|Iterate_Through_Found_Accounts.Id|




### Iterate_Through_Found_Accounts

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Loop|
|Label|Iterate Through Found Accounts|
|Collection Reference|foundAccounts.searchRecords|
|Iteration Order|Asc|
|Next Value Connector|[Extract_First_Found_Account](#extract_first_found_account)|
|No More Values Connector|[Query_Results_Screen](#query_results_screen)|


### Callout_Error_Screen

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|Callout Error Screen|
|Allow Back|⬜|
|Allow Finish|✅|
|Allow Pause|⬜|
|Next Or Finish Button Label|Close|
|Show Footer|✅|
|Show Header|✅|


#### CalloutErrorText

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p style="text-align: center;"><span style="font-size: 14px; color: rgb(195, 32, 32);">HTTP callout failed with </span><strong style="font-size: 14px; color: rgb(195, 32, 32);">{!$Flow.FaultMessage}</strong><span style="font-size: 14px; color: rgb(195, 32, 32);"> error.</span></p>|
|Field Type| Display Text|




### Query_Results_Screen

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|Query Results Screen|
|Allow Back|✅|
|Allow Finish|✅|
|Allow Pause|⬜|
|Back Button Label|Re-Enter Search Keyword|
|Next Or Finish Button Label|Select & Proceed|
|Show Footer|✅|
|Show Header|✅|


#### NoResultsFoundText

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p style="text-align: center;"><em style="font-size: 14px;">No Accounts were found by '</em><strong style="font-size: 14px;"><em>{!Account_Search_Keyword}</em></strong><em style="font-size: 14px;">' search keyword. Try another one!</em></p>|
|Field Type| Display Text|
|Visibility Rule|conditionLogic: and<br/>conditions:<br/>&nbsp;&nbsp;leftValueReference: foundAccountsSize<br/>&nbsp;&nbsp;operator: EqualTo<br/>&nbsp;&nbsp;rightValue:<br/>&nbsp;&nbsp;&nbsp;&nbsp;numberValue: 0<br/>|




#### FirstFoundAccountInfo

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p><strong>{!foundAccountsSize} </strong>accounts were found!</p><p><br></p><p><u>First Account Details﻿</u></p><p><em>Id = </em><em style="color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);">{!firstFoundAccount.Id}</em></p><p><em>Name = {!firstFoundAccount.Name}</em></p><p><br></p><p><u>Output Variables</u></p><p><em>selectedAccountId = {!selectedAccountId}</em></p>|
|Field Type| Display Text|
|Visibility Rule|conditionLogic: and<br/>conditions:<br/>&nbsp;&nbsp;leftValueReference: foundAccountsSize<br/>&nbsp;&nbsp;operator: GreaterThan<br/>&nbsp;&nbsp;rightValue:<br/>&nbsp;&nbsp;&nbsp;&nbsp;numberValue: 0<br/>|




### Search_Keyword_Screen

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|Search Keyword Screen|
|Allow Back|⬜|
|Allow Finish|✅|
|Allow Pause|⬜|
|Next Or Finish Button Label|Search|
|Show Footer|✅|
|Show Header|✅|
|Connector|[Search_Accounts_via_HTTP_GET](#search_accounts_via_http_get)|


#### Account_Search_Keyword

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Field Text|Account Search Keyword|
|Field Type| Input Field|
|Help Text|<p>Type in keyword to search for Account(s)</p>|
|Inputs On Next Nav To Assoc Scrn| Reset Values|
|Is Required|✅|
|Validation Rule|errorMessage: <p>Keyword should be 2 characters at least</p><br/>formulaExpression: LEN({!Account_Search_Keyword}) >= 2<br/>|








___

_Documentation generated from branch develop by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_