#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/pre/env-var-scripts/get_minlopro_cert_id.sh
# - varName=$(bash ./scripts/deploy/pre/env-var-scripts/get_minlopro_cert_id.sh)

trap 'echo "invalid_certificate_id"' ERR
set -e

read -r -p "🔶 Enter target org alias: " targetOrgAlias

certificateId=$(
  sf data query \
    --query "SELECT Id FROM Certificate WHERE DeveloperName = 'Minlopro' LIMIT 1" \
    --target-org "$targetOrgAlias" \
    --use-tooling-api \
    --json | jq -r '.result.records[0].Id'
)

echo "${certificateId:0:15}"
