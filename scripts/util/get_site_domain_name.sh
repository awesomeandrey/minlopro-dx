#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/get_site_domain_name.sh
# - echo $ORG_ALIAS | bash ./scripts/util/get_site_domain_name.sh

# Enable errexit option to exit on command failure
set -e

# Capture target org alias;
read -r -p "🔶 Enter target org alias: " targetOrgAlias

# Get Salesforce Instance URL
targetOrgInstanceUrl=$(sf org display --json --target-org="$targetOrgAlias" | jq -r '.result.instanceUrl')

# Extract the org domain (substring between 'https://' and '.my.salesforce')
targetOrgSiteDomainName=$(echo "$targetOrgInstanceUrl" | sed -E 's|https://([^\.]+(\.[^\.]+)*)\.my\.salesforce.*|\1|')

# Output the result
echo "$targetOrgSiteDomainName"
