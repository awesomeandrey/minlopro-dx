#!/bin/bash

# How to use:
# - bash ./scripts/util/get_target_org_site_url.sh
# - varName=$(bash ./scripts/util/get_target_org_site_url.sh)

# Get the input Salesforce instance URL
targetOrgAlias=$(bash ./scripts/util/get_target_org_alias.sh)
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
