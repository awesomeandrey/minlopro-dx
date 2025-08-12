#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/pre/custom/2_deactivate_flows.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/pre/custom/2_deactivate_flows.sh

read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS
echo "🔵 Deactivating flows for [$TARGET_ORG_ALIAS] organization..."

# bash ./scripts/util/flows-mgmt/deactivate_flow_by_developer_name.sh "$TARGET_ORG_ALIAS" "Minlopro_CodeAnalyzerTest"
