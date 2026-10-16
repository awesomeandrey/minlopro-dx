#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/get_frontdoor_url.sh
# - echo $ORG_ALIAS | bash ./scripts/util/get_frontdoor_url.sh
#
# Extracts the access token and instance URL for a target org and exchanges
# them for a one-time frontdoor.jsp URL via Salesforce's Frontdoor Single
# Access API, which logs the bearer straight into the UI.
# Docs: https://help.salesforce.com/s/articleView?id=xcloud.frontdoor_singleaccess.htm&type=5

# Enable errexit option to exit on command failure
set -e

# Capture target org alias;
read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

if [ -z "$TARGET_ORG_ALIAS" ]; then
  echo "❌ Error: target org alias is required" >&2
  exit 1
fi

# Extract instance URL for the target org;
orgInfo=$(sf org display --target-org "$TARGET_ORG_ALIAS" --json)
instanceUrl=$(echo "$orgInfo" | jq -r '.result.instanceUrl // empty')

# Extract access token for the target org;
# Note: 'sf org display --verbose' redacts the access token, so it must be
# fetched separately via 'sf org auth show-access-token'.
tokenInfo=$(sf org auth show-access-token --target-org "$TARGET_ORG_ALIAS" --json)
accessToken=$(echo "$tokenInfo" | jq -r '.result.accessToken // empty')

if [ -z "$accessToken" ] || [ -z "$instanceUrl" ]; then
  echo "❌ Error: Could not retrieve access token and/or instance URL for org [$TARGET_ORG_ALIAS]" >&2
  exit 1
fi

# Strip any trailing slash from the instance URL
instanceUrl="${instanceUrl%/}"

echo "🔵 Exchanging access token for a frontdoor URL via Frontdoor Single Access API on [$instanceUrl]..." >&2

response=$(
  curl -sS -G "${instanceUrl}/services/oauth2/singleaccess" \
    -H "Authorization: Bearer ${accessToken}" \
    --data-urlencode "redirect_uri=/lightning/page/home"
)

frontdoorUrl=$(echo "$response" | jq -r '.frontdoor_uri // empty')

if [ -z "$frontdoorUrl" ]; then
  echo "❌ Error: Frontdoor Single Access API did not return a frontdoor_uri. Raw response:" >&2
  echo "$response" >&2
  exit 1
fi

echo "$frontdoorUrl"
