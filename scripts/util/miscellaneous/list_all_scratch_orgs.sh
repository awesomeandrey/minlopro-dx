#!/usr/bin/env bash

devHubAlias=$(sf config get target-dev-hub --json | jq -r '.result[0].value')
echo "🔵 Listing scratch orgs for [$devHubAlias] DevHub..."

sf data query \
  --query "SELECT Name, OrgName, CreatedDate, SignupEmail, ScratchOrg, SignupUsername, ExpirationDate FROM ActiveScratchOrg ORDER BY ExpirationDate DESC" \
  --target-org "$devHubAlias"
