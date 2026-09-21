# Integrations

Metadata for connecting this org to external systems and to itself (loopback), covering both
**inbound** auth (Auth Providers, SAML SSO, External Client Apps) and **outbound** callouts (Named
Credentials, External Credentials, External Auth Identity Providers).

## Updating External Auth Identity Provider (EAIP) credentials

EAIP credentials (Client ID/Secret) aren't stored in the metadata XML - they're set separately via
the Metadata API's named-credential REST endpoint, using the Salesforce CLI:

```bash
npx sf api request rest \
  "/services/data/v67.0/named-credentials/external-auth-identity-provider-credentials/<EAIP_DEVELOPER_NAME>" \
  --method PUT \
  --target-org <TARGET_ORG_ALIAS> \
  --body '{
    "credentials": [
      {
        "credentialName": "clientId",
        "credentialValue": "<CLIENT_ID>"
      },
      {
        "credentialName": "clientSecret",
        "credentialValue": "<CLIENT_SECRET>"
      }
    ]
  }'
```
