## Integration Setup

This document provides details on the integration setup for the Salesforce org, listing the key metadata items required for smooth operation.

### Metadata Items

| **Name**            | **Type**                    | **Description**                                                                                                                                                                                                                                                                                                                                                                        |
| ------------------- | --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `MinloproLogin`     | _Named Credential_          | Linked to `Minlopro` external credential that securely stores Client ID/Secret for the current organization. The secrets belong to `SFDC_CCF_Echo` connected application.                                                                                                                                                                                                              |
| `SalesforceRestApi` | _Named Credential (Legacy)_ | Used together with `Custom_Salesforce_Auth_Provider` auth provider (AP). The AP configuration leverages [Apex expressions](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_callouts_named_credentials_merge_fields.htm) to fetch secrets from `Minlopro` external credential and invoke token callout through `MinloproLogin` named credential endpoint. |

### Notes

This setup was originally inspired by this article - https://apexlibra.org/apex/secure-auth-provider-secrets.
