## Integration Setup

This document provides details on the integration setup for the Salesforce org, listing the key metadata items required for smooth operation.

### Metadata Items

**Yes! There are 3 metadata components with the same API name! 😏**

| **Name**                     | **Type**                    | **Description**                                                                                                                                                                                                                                                                 |
| ---------------------------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `MinloproSalesforceLoopback` | _Connected Application_     | Salesforce loopback connected app (enabled for multiple OAuth 2.0 flows).                                                                                                                                                                                                       |
| `MinloproSalesforceLoopback` | _External Credential_       | Securely stores Client ID / Client Secret of `MinloproSalesforceLoopback` connected application.                                                                                                                                                                                |
| `MinloproSalesforceLoopback` | _Named Credential_          | Used to make HTTP callouts in Apex by referencing secrets via [Apex Callout Expressions](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_callouts_named_credentials_merge_fields.htm).                                                            |
| `SalesforceRestApi`          | _Named Credential (Legacy)_ | Used together with `Loopback_CCF` auth provider (AP). The AP configuration leverages _Apex Callout Expressions_ to fetch secrets from `MinloproSalesforceLoopback` external credential and invoke token callout through `MinloproSalesforceLoopback` named credential endpoint. |
| `SalesforceRestApi2`         | _Named Credential (Legacy)_ | Used together with `Loopback_WSPKCE` auth provider (AP). The AP configuration CAN'T leverage _Apex Callout Expressions_ because of specifics of corresponding OAuth 2.0 flow (in particular you can reference NC secrets during actual HTTP callout ONLY!).                     |
| `SalesforceRestApi3`         | _Named Credential (Legacy)_ | Used together with `Loopback_JWT` auth provider (AP). The AP configuration depends on certificate generated in Salesforce org via _Certificate and Key Management_ Setup menu.                                                                                                  |

### Notes

This setup was originally inspired by this article - https://apexlibra.org/apex/secure-auth-provider-secrets.
