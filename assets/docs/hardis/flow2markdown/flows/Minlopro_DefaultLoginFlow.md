# Minlopro - Default Login Flow

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VsCode, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within mkdocs-material, define mermaid plugin in `mkdocs.yml` as described in https://squidfunk.github.io/mkdocs-material/extensions/mermaid/
%% - At last resort, you can copy-paste this MermaidJS code in https://mermaid.live/ to see the Flow Diagram

flowchart TB
START(["START<br/><b>Screen Flow</b>"]):::startClass
click START "#general-information" "4177813087"

AssignForceLogout[\"🟰 <em></em><br/>Assign Force Logout"/]:::assignments
click AssignForceLogout "#assignforcelogout" "322814333"

GetRunningUser[("🔍 <em></em><br/>Get Running User")]:::recordLookups
click GetRunningUser "#getrunninguser" "115952168"

UnknownUserScreen(["💻 <em></em><br/>Unknown User Screen"]):::screens
click UnknownUserScreen "#unknownuserscreen" "2375937641"

UserDetailsScreen(["💻 <em></em><br/>User Details Screen"]):::screens
click UserDetailsScreen "#userdetailsscreen" "3071544924"

AssignForceLogout --> END_AssignForceLogout
GetRunningUser --> UserDetailsScreen
GetRunningUser -. Fault .->UnknownUserScreen
UnknownUserScreen --> AssignForceLogout
UserDetailsScreen --> END_UserDetailsScreen
START -->  GetRunningUser
END_AssignForceLogout(( END )):::endClass
END_UserDetailsScreen(( END )):::endClass


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


```

<!-- Flow description -->

## General Information

|<!-- -->|<!-- -->|
|:---|:---|
|Process Type| Flow|
|Label|Minlopro - Default Login Flow|
|Status|Active|
|Description|Customizes login experience for Minlopro users.|
|Environments|Default|
|Interview Label|Minlopro - Login Flow {!$Flow.CurrentDateTime}|
| Builder Type (PM)|LightningFlowBuilder|
| Canvas Mode (PM)|AUTO_LAYOUT_CANVAS|
| Origin Builder Type (PM)|LightningFlowBuilder|
|Connector|[GetRunningUser](#getrunninguser)|
|Next Node|[GetRunningUser](#getrunninguser)|


## Variables

|Name|Data Type|Is Collection|Is Input|Is Output|Object Type|Description|
|:-- |:--:|:--:|:--:|:--:|:--:|:--  |
|LoginFlow_Application|String|⬜|✅|⬜|<!-- -->|<!-- -->|
|LoginFlow_Community|String|⬜|✅|⬜|<!-- -->|<!-- -->|
|LoginFlow_FinishLocation|String|⬜|⬜|✅|<!-- -->|This variable determines where to send the user when the flow is completed.|
|LoginFlow_ForceLogout|Boolean|⬜|⬜|✅|<!-- -->|When this variable is set to TRUE, the user is immediately logged out.|
|LoginFlow_IpAddress|String|⬜|✅|⬜|<!-- -->|<!-- -->|
|LoginFlow_LoginSubType|String|⬜|✅|⬜|<!-- -->|<!-- -->|
|LoginFlow_LoginType|String|⬜|✅|⬜|<!-- -->|<!-- -->|
|LoginFlow_Platform|String|⬜|✅|⬜|<!-- -->|<!-- -->|
|LoginFlow_SessionLevel|String|⬜|✅|⬜|<!-- -->|<!-- -->|
|LoginFlow_UserAgent|String|⬜|✅|⬜|<!-- -->|<!-- -->|
|LoginFlow_UserId|String|⬜|✅|⬜|<!-- -->|<!-- -->|


## Flow Nodes Details

### AssignForceLogout

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Assignment|
|Label|Assign Force Logout|


#### Assignments

|Assign To Reference|Operator|Value|
|:-- |:--:|:--: |
|LoginFlow_ForceLogout| Assign|✅|




### GetRunningUser

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Lookup|
|Object|User|
|Label|Get Running User|
|Assign Null Values If No Records Found|⬜|
|Fault Connector|[UnknownUserScreen](#unknownuserscreen)|
|Get First Record Only|✅|
|Store Output Automatically|✅|
|Connector|[UserDetailsScreen](#userdetailsscreen)|


#### Filters (logic: **and**)

|Filter Id|Field|Operator|Value|
|:-- |:-- |:--:|:--: |
|1|Id| Equal To|LoginFlow_UserId|




### UnknownUserScreen

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|Unknown User Screen|
|Allow Back|⬜|
|Allow Finish|✅|
|Allow Pause|⬜|
|Next Or Finish Button Label|Force Logout|
|Show Footer|✅|
|Show Header|✅|
|Connector|[AssignForceLogout](#assignforcelogout)|


#### HelpText

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p style="text-align: center;"><em style="color: rgb(199, 74,<br/>                16);">{!$Flow.FaultMessage}</em></p><p style="text-align:<br/>                center;"><em>Force logout...</em></p>|
|Field Type| Display Text|




### UserDetailsScreen

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|User Details Screen|
|Allow Back|⬜|
|Allow Finish|✅|
|Allow Pause|⬜|
|Next Or Finish Button Label|Take me to Minlopro!|
|Show Footer|✅|
|Show Header|✅|


#### LoginType

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Default Value|LoginFlow_LoginType|
|Field Text|Login Type|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Read Only|true|
|Is Required|⬜|
|Parent Field|[FlowInputVariables_Column1](#flowinputvariables_column1)|




#### LoginSubType

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Default Value|LoginFlow_LoginSubType|
|Field Text|Login SubType|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Read Only|true|
|Is Required|⬜|
|Parent Field|[FlowInputVariables_Column1](#flowinputvariables_column1)|




#### IpAddress

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Default Value|LoginFlow_IpAddress|
|Field Text|IP Address|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Read Only|true|
|Is Required|⬜|
|Parent Field|[FlowInputVariables_Column1](#flowinputvariables_column1)|




#### Community

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Default Value|LoginFlow_Community|
|Field Text|Community|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Read Only|true|
|Is Required|⬜|
|Parent Field|[FlowInputVariables_Column1](#flowinputvariables_column1)|




#### SessionLevel

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Default Value|LoginFlow_SessionLevel|
|Field Text|Session Level|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Read Only|true|
|Is Required|⬜|
|Parent Field|[FlowInputVariables_Column1](#flowinputvariables_column1)|




#### FlowInputVariables_Column1

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region|
|Is Required|⬜|
|Parent Field|[FlowInputVariables](#flowinputvariables)|
|Width (input)|6|




#### UserAgent

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Default Value|LoginFlow_UserAgent|
|Field Text|User Agent|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Read Only|true|
|Is Required|⬜|
|Parent Field|[FlowInputVariables_Column2](#flowinputvariables_column2)|




#### Platform

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Default Value|LoginFlow_Platform|
|Field Text|Platform|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Read Only|true|
|Is Required|⬜|
|Parent Field|[FlowInputVariables_Column2](#flowinputvariables_column2)|




#### Application

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Default Value|LoginFlow_Application|
|Field Text|Application|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Read Only|true|
|Is Required|⬜|
|Parent Field|[FlowInputVariables_Column2](#flowinputvariables_column2)|




#### UserId

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Default Value|LoginFlow_UserId|
|Field Text|User ID|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Read Only|true|
|Is Required|⬜|
|Parent Field|[FlowInputVariables_Column2](#flowinputvariables_column2)|




#### FlowInputVariables_Column2

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region|
|Is Required|⬜|
|Parent Field|[FlowInputVariables](#flowinputvariables)|
|Width (input)|6|




#### FlowInputVariables

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|Flow Input Variables|
|Field Type| Region Container|
|Is Required|⬜|
|Region Container Type| Section With Header|




#### FullName

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Default Value|GetRunningUser.Name|
|Field Text|Full Name|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Read Only|true|
|Is Required|⬜|
|Parent Field|[UserInfo_Column1](#userinfo_column1)|




#### UserInfo_Column1

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region|
|Is Required|⬜|
|Parent Field|[UserInfo](#userinfo)|
|Width (input)|6|




#### Username

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Default Value|GetRunningUser.Username|
|Field Text|Username|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Read Only|true|
|Is Required|⬜|
|Parent Field|[UserInfo_Column2](#userinfo_column2)|




#### UserInfo_Column2

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region|
|Is Required|⬜|
|Parent Field|[UserInfo](#userinfo)|
|Width (input)|6|




#### UserInfo

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|User Info|
|Field Type| Region Container|
|Is Required|⬜|
|Region Container Type| Section With Header|




#### FinishLocation

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Default Value|LoginFlow_FinishLocation|
|Field Text|Finish Location|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Required|⬜|
|Parent Field|[FlowOutputVariables_Column1](#flowoutputvariables_column1)|




#### ForceLogout

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|Boolean|
|Default Value|LoginFlow_ForceLogout|
|Field Text|Force Logout?|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Required|✅|
|Parent Field|[FlowOutputVariables_Column1](#flowoutputvariables_column1)|




#### FlowOutputVariables_Column1

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region|
|Is Required|⬜|
|Parent Field|[FlowOutputVariables](#flowoutputvariables)|
|Width (input)|6|




#### FlowOutputVariables_Column2

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region|
|Is Required|⬜|
|Parent Field|[FlowOutputVariables](#flowoutputvariables)|
|Width (input)|6|




#### FlowOutputVariables

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|Flow Output Variables|
|Field Type| Region Container|
|Is Required|⬜|
|Region Container Type| Section With Header|








___

_Documentation generated from branch develop by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_