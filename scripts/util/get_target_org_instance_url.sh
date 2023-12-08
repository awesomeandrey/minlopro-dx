#!/bin/bash

# How to use:
# - bash ./scripts/util/get_target_org_instance_url.sh
# - varName=$(bash ./scripts/util/get_target_org_instance_url.sh)

targetOrgAlias=$(bash ./scripts/util/get_target_org_alias.sh)
targetOrgInstanceUrl=$(sf org display --json --target-org="$targetOrgAlias" | jq -r '.result.instanceUrl')
echo $targetOrgInstanceUrl
