#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/pre/custom/2_deactivate_flows.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/pre/custom/2_deactivate_flows.sh

read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS
echo "🔵 Deactivating flows for [$TARGET_ORG_ALIAS] organization..."

declare -a flow_api_names
flow_api_names=("Minlopro_CodeAnalyzerTest" "Minlopro_MessagesRoutedToAgentsAndQueues" "Minlopro_SearchFirstAccount")

if [ ${#flow_api_names[@]} -eq 0 ]; then
  echo "No flows to deactivate."
  exit 0
fi

for flow_name in "${flow_api_names[@]}"; do
  bash ./scripts/util/flows-mgmt/deactivate_flow_by_developer_name.sh \
    "$TARGET_ORG_ALIAS" \
    "$flow_name"
done
