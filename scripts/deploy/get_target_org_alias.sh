#!/bin/bash

# How to use:
# - bash ./scripts/deploy/get_target_org_alias.sh
# - varName=$(bash ./scripts/deploy/get_target_org_alias.sh)

targetOrgAlias=$(sf config get target-org --json | jq -r '.result[0].value')
echo $targetOrgAlias
