#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/common/authorize_org_sfdx_url.sh "force://..."
# - bash ./scripts/deploy/common/authorize_org_sfdx_url.sh "force://..." "ORG_ALIAS"

set -e

sfdxUrl="$1"
customOrgAlias="$2"

if [ -z "$sfdxUrl" ]; then
    echo "Error: <SfdxUrl> parameter is mandatory"
    echo "Usage: $0 \"force://...\" [\"org-alias\"]"
    exit 1
fi

buildFolder="build"
sfAuthUrlFile="$buildFolder/target-org-auth-url.txt"

trap 'rm -rf $sfAuthUrlFile' EXIT
mkdir -p "$buildFolder"
touch "$sfAuthUrlFile"
echo "$sfdxUrl" > "$sfAuthUrlFile"

echo "🔵 Authorizing Salesforce organization..."
sf org login sfdx-url --sfdx-url-file "$sfAuthUrlFile" --set-default

orgInfo=$(sf org display --json)
orgUsername=$(echo "$orgInfo" | jq -r '.result.username')
orgId=$(echo "$orgInfo" | jq -r '.result.id')

# Compose custom org alias if not set
if [ -z "$customOrgAlias" ]; then
  customOrgAlias="sf-$orgId-$orgUsername"
fi
sf alias set "$customOrgAlias" "$orgUsername"
sf config set target-org "$customOrgAlias"

sf org list auth
