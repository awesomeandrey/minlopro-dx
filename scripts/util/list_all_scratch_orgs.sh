#!/bin/bash

# How to use:
# - bash ./scripts/util/list_all_scratch_orgs.sh

devHubAlias=$(bash ./scripts/util/get_dev_hub_alias.sh)
echo "🔵 Listing scratch orgs for [$devHubAlias] DevHub..."

sf data query \
  --query "SELECT Name, OrgName, CreatedDate, SignupEmail, ScratchOrg, SignupUsername, ExpirationDate FROM ActiveScratchOrg ORDER BY ExpirationDate DESC" \
  --target-org "$devHubAlias" \
  --wait 10