#!/bin/bash

# How to use:
# - bash ./scripts/deploy/authorize_org.sh
# - echo ${{secrets.QA_AUTH_URL}} | bash ./scripts/deploy/authorize_org.sh
# - echo 'force://...' | bash ./scripts/deploy/authorize_org.sh

# Capture target org SF AUTH URL (should be in 'force://PlatformCLI:...salesforce.com' format);
printf "Provide SF AUTH URL:\n"
read SF_AUTH_URL

buildFolder="build"
sfAuthUrlFile="$buildFolder/target-org-auth-url.txt"

# Save sf auth URL into a text file
mkdir -p "$buildFolder"
touch $sfAuthUrlFile
echo $SF_AUTH_URL > "$sfAuthUrlFile"

# Authorize Salesforce org and set it as default one
sf org login sfdx-url \
  --sfdx-url-file $sfAuthUrlFile \
  --alias TARGET_ORG \
  --set-default
sf org display
echo '\nDone!'
