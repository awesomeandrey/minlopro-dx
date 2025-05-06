#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/common/authorize_org.sh "force://..."
# - bash ./scripts/deploy/common/authorize_org.sh "force://..." "ORG_ALIAS"

set -e

# Input variables;
sfdxUrl="$1"
customOrgAlias="$2"

# Check if sfdxUrl was provided;
if [ -z "$sfdxUrl" ]; then
    echo "Error: <SfdxUrl> parameter is mandatory"
    echo "Usage: $0 \"force://...\" [\"org-alias\"]"
    exit 1
fi

buildFolder="build"
sfAuthUrlFile="$buildFolder/target-org-auth-url.txt"
echo "🔵 Authorizing Salesforce organization..."

# Save Auth URL into a text file;
mkdir -p "$buildFolder"
touch "$sfAuthUrlFile"
echo "$sfdxUrl" > "$sfAuthUrlFile"

# Authorize Salesforce org and set it as default one;
sf org login sfdx-url --sfdx-url-file "$sfAuthUrlFile" --set-default

# Purge file with SFDX url;
rm -rf "$sfAuthUrlFile"

# Capture org details;
orgInfo=$(sf org display --json)
orgUsername=$(echo "$orgInfo" | jq -r '.result.username')
orgId=$(echo "$orgInfo" | jq -r '.result.id')
# orgInstanceUrl=$(echo "$orgInfo" | jq -r '.result.instanceUrl')

# Compose custom org alias if not set;
if [ -z "$customOrgAlias" ]; then
  customOrgAlias="$orgUsername-$orgId"
fi
sf alias set "$customOrgAlias" "$orgUsername"
sf config set target-org "$customOrgAlias"

sf org list auth
