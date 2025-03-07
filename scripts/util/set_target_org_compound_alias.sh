#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/set_target_org_compound_alias.sh

targetOrgAlias=$(sf config get target-org --json | jq -r '.result[0].value' 2> /dev/null)

if [ -z "$targetOrgAlias" ]; then
  echo "No default target-org detected!"
  sf config list
  exit 1
fi

targetOrgInfoJson=$(sf org display --target-org="$targetOrgAlias" --json)
targetOrgUsername=$(echo "$targetOrgInfoJson" | jq -r '.result.username')
targetOrgInstanceUrl=$(echo "$targetOrgInfoJson" | jq -r '.result.instanceUrl')
# targetOrgInstanceUrlDomain=$(echo "$targetOrgInstanceUrl" | awk -F '//' '{print $2}' | awk -F '.' '{print $1}')
# targetOrgCompoundAlias="${targetOrgUsername} ⏩ ${targetOrgInstanceUrl}"
targetOrgCompoundAlias="${targetOrgUsername}|${targetOrgInstanceUrl}"
sf alias set "$targetOrgCompoundAlias" "$targetOrgUsername" &> /dev/null

echo "$targetOrgCompoundAlias"
