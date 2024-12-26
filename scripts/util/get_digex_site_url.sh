#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/get_digex_site_url.sh
# - echo $ORG_ALIAS | bash ./scripts/util/get_digex_site_url.sh

# Enable errexit option to exit on command failure
set -e

# Capture target org alias;
read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

# Query to get the Site Id;
siteId=$(sf data query --query "SELECT Id FROM Site WHERE Name = 'DigEx'" --target-org "$TARGET_ORG_ALIAS" --json | jq -r '.result.records[0].Id')

# Check if the Site Id is retrieved;
if [ -z "$siteId" ] || [ "$siteId" == "null" ]; then
    echo null
    exit 0
fi

# Query to get the Secure URL from SiteDetail
secureUrl=$(sf data query --query "SELECT SecureUrl FROM SiteDetail WHERE DurableId = '$siteId'" --target-org "$TARGET_ORG_ALIAS" --json | jq -r '.result.records[0].SecureUrl')
echo "$secureUrl"
