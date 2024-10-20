#!/bin/bash

# How to use:
# - bash ./scripts/util/get_target_org_username.sh
# - varName=$(bash ./scripts/util/get_target_org_username.sh)

targetOrgAlias=$(bash ./scripts/util/get_target_org_alias.sh)
targetOrgUsername=$(sf org display user --json --target-org="$targetOrgAlias" | jq -r '.result.username')
echo "$targetOrgUsername"

# Optional approach (does not imply 'jq' utility):
# targetOrgUsername=$(sf org display user --target-org="$targetOrgAlias" | grep 'Username' | sed 's/.*Username *//;s/ *$//')
