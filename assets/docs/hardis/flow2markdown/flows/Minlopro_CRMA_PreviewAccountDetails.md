# Minlopro - CRMA - Preview Account Details

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VS Code, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within mkdocs-material, define mermaid plugin in `mkdocs.yml` as described in https://squidfunk.github.io/mkdocs-material/extensions/mermaid/
%% - As a last resort, you can copy-paste this MermaidJS code into https://mermaid.live/ to see the flow diagram

flowchart TB
START(["START<br/><b>Screen Flow</b>"]):::startClass
click START "#general-information" "528089668"

Is_Account_Found{"🔀 <em></em><br/>Is Account Found?"}:::decisions
click Is_Account_Found "#is_account_found" "2004696813"

Select_Account[("🔍 <em></em><br/>Select Account")]:::recordLookups
click Select_Account "#select_account" "1203919046"

Account_Details_Screen(["💻 <em></em><br/>Account Details Screen"]):::screens
click Account_Details_Screen "#account_details_screen" "1049372089"

Account_Id_Not_Provided(["💻 <em></em><br/>Account Id Not Provided"]):::screens
click Account_Id_Not_Provided "#account_id_not_provided" "3889066951"

Is_Account_Found --> |"Account Found"| Account_Details_Screen
Is_Account_Found --> |"Account Not Found"| Account_Id_Not_Provided
Select_Account --> Is_Account_Found
Account_Details_Screen --> END_Account_Details_Screen
Account_Id_Not_Provided --> END_Account_Id_Not_Provided
START -->  Select_Account
END_Account_Details_Screen(( END )):::endClass
END_Account_Id_Not_Provided(( END )):::endClass


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
|Label|Minlopro - CRMA - Preview Account Details|
|Status|Active|
|Description|Sample Screen Flow embedded into CRM Analytics dashboard. The flow aims to show Account record details of the Opportunity selected in the dashboard.|
|Environments|Default|
|Interview Label|Minlopro - CRMA - Preview Account Details {!$Flow.CurrentDateTime}|
| Builder Type (PM)|LightningFlowBuilder|
| Canvas Mode (PM)|AUTO_LAYOUT_CANVAS|
| Origin Builder Type (PM)|LightningFlowBuilder|
|Connector|[Select_Account](#select_account)|
|Next Node|[Select_Account](#select_account)|


## Variables

|Name|Data Type|Is Collection|Is Input|Is Output|Object Type|Description|
|:-- |:--:|:--:|:--:|:--:|:--:|:--  |
|selectedAccountId|String|⬜|✅|⬜|<!-- -->|<!-- -->|


## Flow Nodes Details

### Is_Account_Found

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Decision|
|Label|Is Account Found?|
|Default Connector|[Account_Id_Not_Provided](#account_id_not_provided)|
|Default Connector Label|Account Not Found|


#### Rule Account_Found (Account Found)

|<!-- -->|<!-- -->|
|:---|:---|
|Connector|[Account_Details_Screen](#account_details_screen)|
|Condition Logic|and|




|Condition Id|Left Value Reference|Operator|Right Value|
|:-- |:-- |:--:|:--: |
|1|Select_Account.Name| Is Null|⬜|




### Select_Account

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Lookup|
|Object|Account|
|Label|Select Account|
|Assign Null Values If No Records Found|⬜|
|Get First Record Only|✅|
|Store Output Automatically|✅|
|Connector|[Is_Account_Found](#is_account_found)|


#### Filters (logic: **and**)

|Filter Id|Field|Operator|Value|
|:-- |:-- |:--:|:--: |
|1|Id| Equal To|selectedAccountId|




### Account_Details_Screen

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|Account Details Screen|
|Allow Back|⬜|
|Allow Finish|✅|
|Allow Pause|⬜|
|Next Or Finish Button Label|Close|
|Show Footer|✅|
|Show Header|⬜|


#### AccountId

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p>Record ID: <strong>{!selectedAccountId}</strong></p>|
|Field Type| Display Text|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
|Parent Field|[Account_Details_Screen_Section1_Column1](#account_details_screen_section1_column1)|




#### AccountName

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p>Name: <strong>{!Select_Account.Name}</strong></p>|
|Field Type| Display Text|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
|Parent Field|[Account_Details_Screen_Section1_Column1](#account_details_screen_section1_column1)|




#### Account_Details_Screen_Section1_Column1

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region|
|Is Required|⬜|
|Parent Field|[Account_Details_Screen_Section1](#account_details_screen_section1)|
|Width (input)|6|




#### AccountIndustry

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p>Industry: <strong>{!Select_Account.Industry}</strong></p>|
|Field Type| Display Text|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
|Parent Field|[Account_Details_Screen_Section1_Column2](#account_details_screen_section1_column2)|




#### Account_Details_Screen_Section1_Column2

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region|
|Is Required|⬜|
|Parent Field|[Account_Details_Screen_Section1](#account_details_screen_section1)|
|Width (input)|6|




#### Account_Details_Screen_Section1

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region Container|
|Is Required|⬜|
|Region Container Type| Section Without Header|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|




### Account_Id_Not_Provided

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|Account Id Not Provided|
|Allow Back|⬜|
|Allow Finish|✅|
|Allow Pause|⬜|
|Next Or Finish Button Label|Close|
|Show Footer|✅|
|Show Header|⬜|


#### AccountIdNotProvided

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p style="text-align: center;"><strong style="font-size: 14px; color: rgb(124, 22, 22);">Account ID was not provided!</strong></p>|
|Field Type| Display Text|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|








___

_Documentation generated from branch develop by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_