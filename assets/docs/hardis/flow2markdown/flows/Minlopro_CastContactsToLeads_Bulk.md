# Minlopro - Cast Contacts To Leads (Bulk)

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VS Code, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within mkdocs-material, define mermaid plugin in `mkdocs.yml` as described in https://squidfunk.github.io/mkdocs-material/extensions/mermaid/
%% - As a last resort, you can copy-paste this MermaidJS code into https://mermaid.live/ to see the flow diagram

flowchart TB
START(["START<br/><b>Screen Flow</b>"]):::startClass
click START "#general-information" "2341737882"

Create_Leads_via_HTTP_POST("⚡ <em></em><br/>Create Leads via HTTP POST"):::actionCalls
click Create_Leads_via_HTTP_POST "#create_leads_via_http_post" "187876858"

Calculate_Contacts_Count[\"🟰 <em></em><br/>Calculate Contacts Count"/]:::assignments
click Calculate_Contacts_Count "#calculate_contacts_count" "2289117099"

Check_Account_Selection{"🔀 <em></em><br/>Check Account Selection"}:::decisions
click Check_Account_Selection "#check_account_selection" "2543124364"

Verify_Records_Selection_And_User_Permissions{"🔀 <em></em><br/>Verify Records Selection & User Permissions"}:::decisions
click Verify_Records_Selection_And_User_Permissions "#verify_records_selection_and_user_permissions" "1003782354"

Select_Contacts[("🔍 <em></em><br/>Select Contacts")]:::recordLookups
click Select_Contacts "#select_contacts" "351118762"

Update_Contacts[("🛠️ <em></em><br/>Update Contacts")]:::recordUpdates
click Update_Contacts "#update_contacts" "1805384428"

Account_Selection_Screen(["💻 <em></em><br/>Account Selection Screen"]):::screens
click Account_Selection_Screen "#account_selection_screen" "2708085060"

Callout_Error_Screen(["💻 <em></em><br/>Callout Error Screen"]):::screens
click Callout_Error_Screen "#callout_error_screen" "2075084022"

Failed_Contact_Update_Screen(["💻 <em></em><br/>Failed Contact Update Screen"]):::screens
click Failed_Contact_Update_Screen "#failed_contact_update_screen" "1340544200"

PreviewAndConfirmationScreen(["💻 <em></em><br/>Preview & Confirmation Screen"]):::screens
click PreviewAndConfirmationScreen "#previewandconfirmationscreen" "1258855806"

Results_Screen(["💻 <em></em><br/>Results Screen"]):::screens
click Results_Screen "#results_screen" "4124102998"

Suspend_Screen(["💻 <em></em><br/>Suspend Screen"]):::screens
click Suspend_Screen "#suspend_screen" "3136558922"

Mark_Contacts_As_Processed{{"♻️ <em></em><br/>Mark Contacts As Processed"}}:::transforms
click Mark_Contacts_As_Processed "#mark_contacts_as_processed" "3827616622"

Transform_Contacts_To_Leads{{"♻️ <em></em><br/>Transform Contacts To Leads"}}:::transforms
click Transform_Contacts_To_Leads "#transform_contacts_to_leads" "335609201"

Create_Leads_via_HTTP_POST --> Mark_Contacts_As_Processed
Create_Leads_via_HTTP_POST -. Fault .->Callout_Error_Screen
Calculate_Contacts_Count --> Verify_Records_Selection_And_User_Permissions
Check_Account_Selection --> |"Selected Account Is Blank"| Account_Selection_Screen
Check_Account_Selection --> |"Default Outcome"| Transform_Contacts_To_Leads
Verify_Records_Selection_And_User_Permissions --> |"Ineligible"| Suspend_Screen
Verify_Records_Selection_And_User_Permissions --> |"Eligible"| PreviewAndConfirmationScreen
Select_Contacts --> Calculate_Contacts_Count
Update_Contacts --> Results_Screen
Update_Contacts -. Fault .->Failed_Contact_Update_Screen
Account_Selection_Screen --> Check_Account_Selection
Callout_Error_Screen --> END_Callout_Error_Screen
Failed_Contact_Update_Screen --> END_Failed_Contact_Update_Screen
PreviewAndConfirmationScreen --> Account_Selection_Screen
Results_Screen --> END_Results_Screen
Suspend_Screen --> END_Suspend_Screen
START -->  Select_Contacts
Mark_Contacts_As_Processed --> Update_Contacts
Transform_Contacts_To_Leads --> Create_Leads_via_HTTP_POST
END_Callout_Error_Screen(( END )):::endClass
END_Failed_Contact_Update_Screen(( END )):::endClass
END_Results_Screen(( END )):::endClass
END_Suspend_Screen(( END )):::endClass


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
|Label|Minlopro - Cast Contacts To Leads (Bulk)|
|Status|Active|
|Description|Casts Contacts to Leads through Salesforce Composite API. Only 1 HTTP callout is used to insert records in bulk. The flow also leverages Screen Actions.|
|Environments|Default|
|Interview Label|Minlopro - Cast Contacts To Leads (Bulk) {!$Flow.CurrentDateTime}|
|Run In Mode| Default Mode|
| Builder Type (PM)|LightningFlowBuilder|
| Canvas Mode (PM)|AUTO_LAYOUT_CANVAS|
| Origin Builder Type (PM)|LightningFlowBuilder|
|Connector|[Select_Contacts](#select_contacts)|
|Next Node|[Select_Contacts](#select_contacts)|


## Variables

|Name|Data Type|Is Collection|Is Input|Is Output|Object Type|Description|
|:-- |:--:|:--:|:--:|:--:|:--:|:--  |
|contactsSize|Number|⬜|⬜|⬜|<!-- -->|<!-- -->|
|ids|String|✅|✅|⬜|<!-- -->|Contact IDs selected from the list view|
|selectedAccount|SObject|⬜|⬜|⬜|Account|<!-- -->|


## Flow Nodes Details

### Create_Leads_via_HTTP_POST

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Action Call|
|Label|Create Leads via HTTP POST|
|Action Type|External Service|
|Action Name|MinloproCreateLeadsApiBulk.Create Leads|
|Fault Connector|[Callout_Error_Screen](#callout_error_screen)|
|Flow Transaction Model|NewTransaction|
|Name Segment|MinloproCreateLeadsApiBulk.Create Leads|
|Offset|0|
|Store Output Automatically|✅|
|Body (input)|[Transform_Contacts_To_Leads](#transform_contacts_to_leads)|
|Connector|[Mark_Contacts_As_Processed](#mark_contacts_as_processed)|


### Calculate_Contacts_Count

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Assignment|
|Label|Calculate Contacts Count|
|Connector|[Verify_Records_Selection_And_User_Permissions](#verify_records_selection_and_user_permissions)|


#### Assignments

|Assign To Reference|Operator|Value|
|:-- |:--:|:--: |
|contactsSize| Assign Count|[Select_Contacts](#select_contacts)|




### Check_Account_Selection

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Decision|
|Label|Check Account Selection|
|Default Connector|[Transform_Contacts_To_Leads](#transform_contacts_to_leads)|
|Default Connector Label|Default Outcome|


#### Rule Selected_Account_Is_Blank (Selected Account Is Blank)

|<!-- -->|<!-- -->|
|:---|:---|
|Connector|isGoTo: true<br/>targetReference: Account_Selection_Screen<br/>|
|Condition Logic|and|




|Condition Id|Left Value Reference|Operator|Right Value|
|:-- |:-- |:--:|:--: |
|1|AccountsDataTable.firstSelectedRow| Is Null|✅|




### Verify_Records_Selection_And_User_Permissions

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Decision|
|Label|Verify Records Selection & User Permissions|
|Default Connector|[PreviewAndConfirmationScreen](#previewandconfirmationscreen)|
|Default Connector Label|Eligible|


#### Rule Ineligible (Ineligible)

|<!-- -->|<!-- -->|
|:---|:---|
|Connector|[Suspend_Screen](#suspend_screen)|
|Condition Logic|or|




|Condition Id|Left Value Reference|Operator|Right Value|
|:-- |:-- |:--:|:--: |
|1|contactsSize| Equal To|numberValue: 0<br/>|
|2|$Permission.IsLeadManager| Equal To|⬜|




### Select_Contacts

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Lookup|
|Object|Contact|
|Label|Select Contacts|
|Assign Null Values If No Records Found|⬜|
|Get First Record Only|⬜|
|Queried Fields|- Id<br/>- LastName<br/>- FirstName<br/>- Title<br/>- Phone<br/>- Email<br/>- LeadSource<br/>- MobilePhone<br/>- Name<br/>- IsCastToLead__c<br/>|
|Store Output Automatically|✅|
|Connector|[Calculate_Contacts_Count](#calculate_contacts_count)|


#### Filters (logic: **and**)

|Filter Id|Field|Operator|Value|
|:-- |:-- |:--:|:--: |
|1|Id| In|ids|
|2|IsCastToLead__c| Equal To|⬜|




### Update_Contacts

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Record Update|
|Label|Update Contacts|
|Fault Connector|[Failed_Contact_Update_Screen](#failed_contact_update_screen)|
|Input Reference|[Mark_Contacts_As_Processed](#mark_contacts_as_processed)|
|Connector|[Results_Screen](#results_screen)|


### Account_Selection_Screen

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|Account Selection Screen|
|Actions|name: SearchAccountAction<br/>actionName: Minlopro_SearchAccount_HeadlessAction<br/>actionType: flow<br/>inputParameters:<br/>&nbsp;&nbsp;name: searchKeyword<br/>&nbsp;&nbsp;value:<br/>&nbsp;&nbsp;&nbsp;&nbsp;elementReference: accountSearchKeyword<br/>label: Minlopro - Search Account (Headless Action)<br/>nameSegment: Minlopro_SearchAccount_HeadlessAction<br/>|
|Allow Back|✅|
|Allow Finish|✅|
|Allow Pause|⬜|
|Next Or Finish Button Label|Select Account & Proceed|
|Show Footer|✅|
|Show Header|✅|
|Triggers|eventName: flow__screenfieldclick<br/>eventSource: dhjwhbdw<br/>handlers:<br/>&nbsp;&nbsp;screenActionName: SearchAccountAction<br/>|
|Connector|[Check_Account_Selection](#check_account_selection)|


#### accountSearchKeyword

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type|String|
|Field Text|Account Search Keyword|
|Field Type| Input Field|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Required|✅|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
|Parent Field|[Account_Selection_Screen_Section1_Column1](#account_selection_screen_section1_column1)|




#### SelectedAccountName

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p>Selected Account: <strong><em>{!AccountsDataTable.firstSelectedRow.Name}</em></strong></p>|
|Field Type| Display Text|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
|Visibility Rule|conditionLogic: and<br/>conditions:<br/>&nbsp;&nbsp;leftValueReference: AccountsDataTable.firstSelectedRow.Id<br/>&nbsp;&nbsp;operator: IsNull<br/>&nbsp;&nbsp;rightValue:<br/>&nbsp;&nbsp;&nbsp;&nbsp;booleanValue: false<br/>|
|Parent Field|[Account_Selection_Screen_Section1_Column1](#account_selection_screen_section1_column1)|




#### Account_Selection_Screen_Section1_Column1

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region|
|Is Required|⬜|
|Parent Field|[Account_Selection_Screen_Section1](#account_selection_screen_section1)|
|Width (input)|4|




#### dhjwhbdw

|<!-- -->|<!-- -->|
|:---|:---|
|Extension Name|flowruntime:actionButtonField|
|Field Type| Component Instance|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Required|✅|
|Store Output Automatically|✅|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
|Parent Field|[Account_Selection_Screen_Section1_Column2](#account_selection_screen_section1_column2)|
|Label (input)|🔍 Search Account|
|Is Success (input)|SearchAccountAction.IsSuccess|
|In Progress (input)|SearchAccountAction.InProgress|
|Error Message (input)|SearchAccountAction.ErrorMessage|




#### Account_Selection_Screen_Section1_Column2

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region|
|Is Required|⬜|
|Parent Field|[Account_Selection_Screen_Section1](#account_selection_screen_section1)|
|Width (input)|2|




#### Account_Selection_Screen_Section1_Column3

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region|
|Is Required|⬜|
|Parent Field|[Account_Selection_Screen_Section1](#account_selection_screen_section1)|
|Width (input)|6|




#### Account_Selection_Screen_Section1

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region Container|
|Is Required|⬜|
|Region Container Type| Section Without Header|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|




#### NoAccountsFoundText

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p style="text-align: center;"><strong style="font-size: 14px;">{!accountSearchKeyword}</strong><span style="font-size: 14px;"> search keyword provided no Accounts results...</span></p>|
|Field Type| Display Text|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
|Visibility Rule|conditionLogic: and<br/>conditions:<br/>&nbsp;&nbsp;leftValueReference: SearchAccountAction.Results.foundAccountsSize<br/>&nbsp;&nbsp;operator: EqualTo<br/>&nbsp;&nbsp;rightValue:<br/>&nbsp;&nbsp;&nbsp;&nbsp;numberValue: 0<br/>|




#### AccountsDataTable

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type Mappings|typeName: T<br/>typeValue: Account<br/>|
|Extension Name|flowruntime:datatable|
|Field Type| Component Instance|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Required|✅|
|Store Output Automatically|✅|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
|Visibility Rule|conditionLogic: and<br/>conditions:<br/>&nbsp;&nbsp;leftValueReference: SearchAccountAction.Results.foundAccountsSize<br/>&nbsp;&nbsp;operator: NotEqualTo<br/>&nbsp;&nbsp;rightValue:<br/>&nbsp;&nbsp;&nbsp;&nbsp;numberValue: 0<br/>|
|Label (input)|Found Accounts|
|Selection Mode (input)|SINGLE_SELECT|
|Min Row Selection (input)|1|
|Table Data (input)|SearchAccountAction.Results.foundAccounts|
|Is Show Search Bar (input)|✅|
|Max Row Selection (input)|1|
|Columns (input)|[{"apiName":"Name","guid":"column-a201","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":0,"label":"Account Name","type":"text"},{"apiName":"Id","guid":"column-cfdf","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":1,"label":"Account ID","type":"text"},{"apiName":"Description","guid":"column-018c","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":2,"label":"Account Description","type":"text"}]|
|Should Display Label (input)|✅|




#### ErrorAccountsSearchText

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p style="text-align: center;"><span style="color: rgb(228, 36, 36); font-size: 14px;">Accounts could not be found due to </span><strong style="color: rgb(228, 36, 36); font-size: 14px;"><em>{!SearchAccountAction.Results.errorMessage}</em></strong></p>|
|Field Type| Display Text|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
|Visibility Rule|conditionLogic: and<br/>conditions:<br/>&nbsp;&nbsp;leftValueReference: SearchAccountAction.Results.errorMessage<br/>&nbsp;&nbsp;operator: IsNull<br/>&nbsp;&nbsp;rightValue:<br/>&nbsp;&nbsp;&nbsp;&nbsp;booleanValue: false<br/>|




### Callout_Error_Screen

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|Callout Error Screen|
|Allow Back|⬜|
|Allow Finish|✅|
|Allow Pause|⬜|
|Next Or Finish Button Label|Done|
|Show Footer|✅|
|Show Header|✅|


#### CalloutErrorText

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p style="text-align: center;"><span style="color: rgb(173, 30, 30);">The HTTP callout failed. The selected Contacts could not be cast to Leads.</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="color: rgb(173, 30, 30); background-color: rgb(255, 255, 255);">HTTP Response Status: </span><strong style="color: rgb(173, 30, 30);">{!$Flow.FaultMessage}</strong></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="color: rgb(173, 30, 30);">HTTP payload below failed to send.</span></p>|
|Field Type| Display Text|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|




#### CalloutPayload

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p><span style="font-family: tahoma; font-size: 12px;">{!Transform_Contacts_To_Leads.records}</span></p>|
|Field Type| Display Text|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
|Parent Field|[HTTP_Request_Payload_Column1](#http_request_payload_column1)|




#### HTTP_Request_Payload_Column1

|<!-- -->|<!-- -->|
|:---|:---|
|Field Type| Region|
|Is Required|⬜|
|Parent Field|[HTTP_Request_Payload](#http_request_payload)|
|Width (input)|12|




#### HTTP_Request_Payload

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|HTTP Request Payload|
|Field Type| Region Container|
|Is Required|⬜|
|Region Container Type| Section With Header|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|




### Failed_Contact_Update_Screen

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|Failed Contact Update Screen|
|Allow Back|⬜|
|Allow Finish|✅|
|Allow Pause|⬜|
|Next Or Finish Button Label|Continue|
|Show Footer|✅|
|Show Header|✅|


#### FailedContactUpdateText

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p style="text-align: center;"><span style="color: rgb(189, 37, 37);">{!Mark_Contacts_As_Processed} could not be marked as 'cast' due to</span></p><p style="text-align: center;"><strong style="color: rgb(189, 37, 37);">{!$Flow.FaultMessage}</strong></p>|
|Field Type| Display Text|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|




### PreviewAndConfirmationScreen

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|Preview & Confirmation Screen|
|Allow Back|⬜|
|Allow Finish|✅|
|Allow Pause|⬜|
|Next Or Finish Button Label|Cast To Leads|
|Show Footer|✅|
|Show Header|✅|
|Stage Reference|Preview|
|Connector|[Account_Selection_Screen](#account_selection_screen)|


#### InfoText

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p style="text-align: center;"><span style="font-size: 14px;">You're about to cast </span><strong style="font-size: 14px;">{!contactsSize}</strong><span style="font-size: 14px;"> Contacts to Leads via Loopback Connected App leveraging Salesforce REST API.</span></p>|
|Field Type| Display Text|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|




#### ContactsDatatable

|<!-- -->|<!-- -->|
|:---|:---|
|Data Type Mappings|typeName: T<br/>typeValue: Contact<br/>|
|Extension Name|flowruntime:datatable|
|Field Type| Component Instance|
|Inputs On Next Nav To Assoc Scrn| Use Stored Values|
|Is Required|✅|
|Store Output Automatically|✅|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|
|Label (input)|Contacts to Cast|
|Selection Mode (input)|NO_SELECTION|
|Min Row Selection (input)|numberValue: 0<br/>|
|Table Data (input)|[Select_Contacts](#select_contacts)|
|Should Display Label (input)|✅|
|Columns (input)|[{"apiName":"Name","guid":"column-a951","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":0,"label":"Full Name","type":"text"},{"apiName":"Title","guid":"column-6a6e","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":1,"label":"Title","type":"text"},{"apiName":"Email","guid":"column-9ba6","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":2,"label":"Email","type":"email"},{"apiName":"MobilePhone","guid":"column-88e4","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":3,"label":"Mobile Phone","type":"phone"},{"apiName":"IsCastToLead__c","guid":"column-34b8","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":4,"label":"Cast To Lead?","type":"boolean"}]|
|Max Row Selection (input)|numberValue: 0<br/>|




### Results_Screen

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|Results Screen|
|Allow Back|⬜|
|Allow Finish|✅|
|Allow Pause|⬜|
|Next Or Finish Button Label|Done|
|Show Footer|✅|
|Show Header|✅|
|Stage Reference|Results|


#### SuccessText

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p style="text-align: center;"><strong style="font-size: 14px;">{!contactsSize}</strong><span style="font-size: 14px;"> Contacts were cast to Leads </span><strong style="color: rgb(30, 154, 53); font-size: 14px;">successfully</strong><span style="font-size: 14px;">!</span></p>|
|Field Type| Display Text|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|




### Suspend_Screen

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Screen|
|Label|Suspend Screen|
|Allow Back|⬜|
|Allow Finish|✅|
|Allow Pause|⬜|
|Next Or Finish Button Label|Close|
|Show Footer|✅|
|Show Header|✅|


#### SuspendText

|<!-- -->|<!-- -->|
|:---|:---|
|Field Text|<p style="text-align: center;"><strong style="font-size: 14px; color: rgb(211, 118, 17);">There are no eligible Contact records selected, or you do not have necessary permission level.</strong></p>|
|Field Type| Display Text|
|Style Properties|verticalAlignment:<br/>&nbsp;&nbsp;stringValue: top<br/>width:<br/>&nbsp;&nbsp;stringValue: 12<br/>|




### Mark_Contacts_As_Processed

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Transform|
|Label|Mark Contacts As Processed|
|Data Type|SObject|
|Object Type|Contact|
|Is Collection|✅|
|Scale|0|
|Store Output Automatically|✅|
|Connector|[Update_Contacts](#update_contacts)|


#### Transform actions

|Transform Type|Value|Output Field Api Name|
|:-- |:--:|:--  |
|Map|Select_Contacts[$EachItem].Id|Id|
|Map|true|IsCastToLead__c|




### Transform_Contacts_To_Leads

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Transform|
|Label|Transform Contacts To Leads|
|Data Type|Apex|
|Apex Class|ExternalService__MinloproCreateLeadsApiBulk_Createx20Leads_IN_body|
|Is Collection|⬜|
|Scale|0|
|Store Output Automatically|✅|
|Connector|[Create_Leads_via_HTTP_POST](#create_leads_via_http_post)|


#### Transform actions

|Transform Type|Value|Output Field Api Name|
|:-- |:--:|:--  |
|Map|Select_Contacts[$EachItem].Email|records[$EachItem].Email|
|Map|Select_Contacts[$EachItem].FirstName|records[$EachItem].FirstName|
|Map|Select_Contacts[$EachItem].LastName|records[$EachItem].LastName|
|Map|Select_Contacts[$EachItem].Phone|records[$EachItem].Phone|
|Map|Select_Contacts[$EachItem].Title|records[$EachItem].Title|
|Map|Select_Contacts[$EachItem].Id|records[$EachItem].attributes.referenceId|
|Map|Lead|records[$EachItem].attributes.z0type|
|Map|Contact2Lead|records[$EachItem].LeadSource|
|Map|formulaDataType: String<br/>formulaExpression: '''Selected Account ID = '' + {!AccountsDataTable.firstSelectedRow.Id}'<br/>|records[$EachItem].Description|








___

_Documentation generated from branch develop by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_