#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/get_site_url.sh
# - echo $ORG_ALIAS | bash ./scripts/util/get_site_url.sh

# Enable errexit option to exit on command failure
set -e

# Capture target org alias;
read -r -p "🔶 Enter target org alias: " targetOrgAlias

# Get Salesforce Instance URL
targetOrgInstanceUrl=$(sf org display --json --target-org="$targetOrgAlias" | jq -r '.result.instanceUrl')

# Extract the protocol (http or https)
protocol=$(echo "$targetOrgInstanceUrl" | grep -oE '^https?://')

# Extract the subdomain part from the URL (everything before .my.salesforce.com or .scratch.my.salesforce.com)
subdomain=$(echo "$targetOrgInstanceUrl" | sed -E 's|https?://([^\.]+)\..*|\1|')

# Check if the URL contains '.scratch.' keyword
if echo "$targetOrgInstanceUrl" | grep -q ".scratch."; then
    # If '.scratch.' is present, construct the Site URL with '.scratch.'
    targetOrgSiteUrl="${protocol}${subdomain}.scratch.my.site.com"
else
    # Otherwise, construct the Site URL without '.scratch.'
    targetOrgSiteUrl="${protocol}${subdomain}.my.site.com"
fi

# Output the result
echo "$targetOrgSiteUrl"
