# Minlopro - Bot 🤖 - Log Variables

## Flow Diagram

```mermaid
%% If you read this, your Markdown visualizer does not handle MermaidJS syntax.
%% - If you are in VS Code, install extension `Markdown Preview Mermaid Support` at https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
%% - If you are using sfdx-hardis, try to define env variable `MERMAID_MODES=cli,docker` ,then run again the command to regenerate markdown with SVG images.
%% - If you are within a Zensical site, define the mermaid custom fence in `mkdocs.yml` as described in https://zensical.org/docs/
%% - As a last resort, you can copy-paste this MermaidJS code into https://mermaid.live/ to see the flow diagram

flowchart TB
START(["START<br/><b>AutoLaunched Flow</b></br>"]):::startClass
click START "#general-information" "3759719070"

Log_To_Output_Variable[\"🟰 <em></em><br/>Log To Output Variable"/]:::assignments
click Log_To_Output_Variable "#log_to_output_variable" "3865384891"

Log_To_Output_Variable --> END_Log_To_Output_Variable
START -->  Log_To_Output_Variable
END_Log_To_Output_Variable(( END )):::endClass


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
|Label|Minlopro - Bot 🤖 - Log Variables|
|Status|Active|
|Description|Sample flow invoked from Einstein Bot context.|
|Environments|Default|
|Interview Label|Minlopro_Bot_LogVariables {!$Flow.CurrentDateTime}|
|Run In Mode|Default Mode|
|BuilderType (PM)|LightningFlowBuilder|
|CanvasMode (PM)|AUTO_LAYOUT_CANVAS|
|OriginBuilderType (PM)|LightningFlowBuilder|
|Connector|[Log_To_Output_Variable](#log_to_output_variable)|
|Next Node|[Log_To_Output_Variable](#log_to_output_variable)|


## Variables

|Name|Data Type|Is Collection|Is Input|Is Output|Object Type|Description|
|:-- |:--:|:--:|:--:|:--:|:--:|:--  |
|botVariables|String|✅|⬜|⬜|<!-- -->|<!-- -->|
|context_ChannelType|String|⬜|✅|⬜|<!-- -->|<!-- -->|
|context_ContactId|String|⬜|✅|⬜|<!-- -->|<!-- -->|
|context_EchoMessage|String|⬜|✅|⬜|<!-- -->|<!-- -->|
|context_EndUserId|String|⬜|✅|⬜|<!-- -->|<!-- -->|
|outputText|String|⬜|⬜|✅|<!-- -->|<!-- -->|
|system_CurrentConversationLanguage|String|⬜|✅|⬜|<!-- -->|<!-- -->|
|system_LastCustomerInput|String|⬜|✅|⬜|<!-- -->|<!-- -->|


## Formulas

|Name|Data Type|Expression|Description|
|:-- |:--:|:-- |:--  |
|outputTextFormula|String|'(context_EchoMessage=' + {!context_EchoMessage} + '), ' +<br/>'(context_EndUserId=' + {!context_EndUserId} + '), ' +<br/>'(context_ChannelType=' + {!context_ChannelType} + '), ' +<br/>'(context_ContactId=' + {!context_ContactId} + '), ' +<br/>'(system_LastCustomerInput=' + {!system_LastCustomerInput} + '), ' +<br/>'(system_CurrentConversationLanguage=' + {!system_CurrentConversationLanguage} + ')'|<!-- -->|


## Flow Nodes Details

### Log_To_Output_Variable

|<!-- -->|<!-- -->|
|:---|:---|
|Type|Assignment|
|Label|Log To Output Variable|


#### Assignments

|Assign To Reference|Operator|Value|
|:-- |:--:|:--: |
|outputText|Assign|outputTextFormula|








___

_Documentation generated from branch develop by [sfdx-hardis](https://sfdx-hardis.cloudity.com), featuring [salesforce-flow-visualiser](https://github.com/toddhalfpenny/salesforce-flow-visualiser)_