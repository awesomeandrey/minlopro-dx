# Minlopro - User - After Create

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VsCode, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within mkdocs-material, define mermaid plugin in `mkdocs.yml` as described in https://squidfunk.github.io/mkdocs-material/extensions/mermaid/
%% - At last resort, you can copy-paste this MermaidJS code in https://mermaid.live/ to see the Flow Diagram

flowchart TB
START(["START<br/><b>AutoLaunched Flow</b></br>Type: <b> Record After Save</b>"]):::startClass
click START "#general-information" "1458920534"

Create_PSA_Prototype[\"🟰 <em></em><br/>Create PSA Prototype"/]:::assignments
click Create_PSA_Prototype "#create_psa_prototype" "34437075"

Check_User_Profile{"🔀 <em></em><br/>Check User Profile"}:::decisions
click Check_User_Profile "#check_user_profile" "2709133180"

Insert_PSA[("➕ <em></em><br/>Insert PSA")]:::recordCreates
click Insert_PSA "#insert_psa" "1484458409"

Find_Minlopro_DigEx_PSG[("🔍 <em></em><br/>Find Minlopro DigEx PSG")]:::recordLookups
click Find_Minlopro_DigEx_PSG "#find_minlopro_digex_psg" "3436419395"

Create_PSA_Prototype --> Insert_PSA
Check_User_Profile --> |"DigEx Partner"| Find_Minlopro_DigEx_PSG
Check_User_Profile --> |"Default Outcome"| END_Check_User_Profile
Insert_PSA --> END_Insert_PSA
Find_Minlopro_DigEx_PSG --> Create_PSA_Prototype
START --> |"Run Immediately"| Check_User_Profile
END_Check_User_Profile(( END )):::endClass
END_Insert_PSA(( END )):::endClass


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
|Object|User|
|Process Type| Auto Launched Flow|
|Trigger Type| Record After Save|
|Record Trigger Type| Create|
|Label|Minlopro - User - After Create|
|Status|Active|
|Description|RTF for User object that handles AFTER INSERT phase along with Async path.|
|Environments|Default|
|Interview Label|Minlopro - User - After Create {!$Flow.CurrentDateTime}|
| Builder Type (PM)|LightningFlowBuilder|
| Canvas Mode (PM)|AUTO_LAYOUT_CANVAS|
| Origin Builder Type (PM)|LightningFlowBuilder|


#### Scheduled Paths

|Label|Name|Offset Number|Offset Unit|Record Field|Time Source|Connector|
|:-- |:-- |:-- |:-- |:-- |:-- |:--  |
|<!-- -->|<!-- -->|<!-- -->|<!-- -->|<!-- -->|<!-- -->|[Check_User_Profile](#check_user_profile)|


## Variables

|Name|Data Type|Is Collection|Is Input|Is Output|Object Type|Description|
|:-- |:--:|:--:|:--:|:--:|:--:|:--  |
|digExUserPsa|SObject|⬜|⬜|⬜|PermissionSetAssignment|Permission Set Assignment record for newly created DigEx user.|


## Flow Nodes Details

### Create_PSA_Prototype

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Assignment|
|Label|Create PSA Prototype|
|Connector|[Insert_PSA](#insert_psa)|


#### Assignments

|Assign To Reference|Operator|Value|
|:-- |:--:|:--: |
|digExUserPsa.AssigneeId| Assign|$Record.Id|
|digExUserPsa.PermissionSetGroupId| Assign|Find_Minlopro_DigEx_PSG.Id|




### Check_User_Profile

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Decision|
|Label|Check User Profile|
|Default Connector Label|Default Outcome|


#### Rule DigEx_Partner (DigEx Partner)

|<!-- -->|<!-- -->|
|:---|:---|
|Connector|[Find_Minlopro_DigEx_PSG](#find_minlopro_digex_psg)|
|Condition Logic|and|




|Condition Id|Left Value Reference|Operator|Right Value|
|:-- |:-- |:--:|:--: |
|1|$Record.Profile.Name| Equal To|DigEx Partner|




### Insert_PSA

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Create|
|Label|Insert PSA|
|Input Reference|digExUserPsa|


### Find_Minlopro_DigEx_PSG

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Lookup|
|Object|PermissionSetGroup|
|Label|Find Minlopro DigEx PSG|
|Assign Null Values If No Records Found|⬜|
|Get First Record Only|✅|
|Store Output Automatically|✅|
|Connector|[Create_PSA_Prototype](#create_psa_prototype)|


#### Filters (logic: **and**)

|Filter Id|Field|Operator|Value|
|:-- |:-- |:--:|:--: |
|1|DeveloperName| Equal To|Minlopro_PSG_DigExUser|








___

_Documentation generated from branch develop by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_