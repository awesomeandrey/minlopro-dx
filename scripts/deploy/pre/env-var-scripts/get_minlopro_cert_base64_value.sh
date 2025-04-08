#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/pre/env-var-scripts/get_minlopro_cert_base64_value.sh
# - varName=$(bash ./scripts/deploy/pre/env-var-scripts/get_minlopro_cert_base64_value.sh)

trap 'echo "invalid_certificate_base64_value"' ERR
trap 'rm -f "$tempFile"' ERR

set -e

read -r -p "🔶 Enter target org alias: " targetOrgAlias

orgInfoJson=$(sf org display --target-org="$targetOrgAlias" --json)
instanceUrl=$(echo "$orgInfoJson" | jq -r '.result.instanceUrl')
accessToken=$(echo "$orgInfoJson" | jq -r '.result.accessToken')

downloadUrl=$(
  sf data query \
    --query "SELECT CertificateChain FROM Certificate WHERE DeveloperName = 'Minlopro' LIMIT 1" \
    --target-org "$targetOrgAlias" \
    --use-tooling-api \
    --json | jq -r '.result.records[0].CertificateChain'
)

tempFile=$(mktemp)
curl -s -X GET "$instanceUrl/$downloadUrl" \
  -H "Authorization: Bearer $accessToken" \
  -H "Accept: text/plain" \
  -o "$tempFile"

result=$(base64 -w 0 < "$tempFile")
echo "\"$result\""
