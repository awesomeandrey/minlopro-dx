#!/bin/bash

# How to use:
# - bash ./scripts/deploy/authorize_org.sh
# - echo ${{secrets.GitHub_Action_Secret}} | bash ./scripts/deploy/authorize_org.sh
# - echo 'force://...' | bash ./scripts/deploy/authorize_org.sh

# Capture target org SF AUTH URL (should be in 'force://PlatformCLI:...salesforce.com' format);
echo "🔶 Provide SF AUTH URL:"
read SF_AUTH_URL

orgAlias="TARGET_ORG"
buildFolder="build"
sfAuthUrlFile="$buildFolder/target-org-auth-url.txt"

echo "🔵 Authorizing [$orgAlias] organization..."

# Save sf auth URL into a text file
mkdir -p "$buildFolder"
touch $sfAuthUrlFile
echo $SF_AUTH_URL > "$sfAuthUrlFile"

# Authorize Salesforce org and set it as default one
sf org login sfdx-url \
  --sfdx-url-file $sfAuthUrlFile \
  --alias "$orgAlias" \
  --set-default
sf org display --target-org "$orgAlias"
