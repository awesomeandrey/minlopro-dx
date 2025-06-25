#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/flows-mgmt/deactivate_flow_by_developer_name.sh "TARGET_ORG_ALIAS" "FLOW_DEVELOPER_NAME"

set -e

TARGET_ORG_ALIAS="$1"
FLOW_DEVELOPER_NAME="$2"

if [ -z "$TARGET_ORG_ALIAS" ] || [ -z "$FLOW_DEVELOPER_NAME" ]; then
  echo "Invalid input!"
  echo "Usage: $0 'org_alias' 'flow_developer_name'"
  exit 1
fi

# Step 1 - Retrieve Active Flow Version ID
echo "🔵 Deactivating [${FLOW_DEVELOPER_NAME}] flow..."
flowDefinitionToDeactivate=$(
  sf data query \
    --target-org "$TARGET_ORG_ALIAS" \
    --query "SELECT Id, DeveloperName, ActiveVersionId FROM FlowDefinition WHERE DeveloperName = '${FLOW_DEVELOPER_NAME}' LIMIT 1" \
    --use-tooling-api \
    --json | jq '.result.records[0]' 2> /dev/null
)
if [ -z "$flowDefinitionToDeactivate" ] || [ "$flowDefinitionToDeactivate" == "null" ]; then
  echo "[${FLOW_DEVELOPER_NAME}] was not found."
  exit 0
fi

flowDefinitionToDeactivate=$(echo "$flowDefinitionToDeactivate" | jq 'del(.attributes)')
echo "$flowDefinitionToDeactivate" | jq -r 'to_entries[] | .key + "\t" + (.value | tostring)' | column -t -s $'\t'

# Step 2 - Reset active flow version number
flowDefinitionIdToDeactivate=$(echo "$flowDefinitionToDeactivate" | jq -r '.Id')
sf data update record \
  --target-org "$TARGET_ORG_ALIAS" \
  --sobject "FlowDefinition" \
  --record-id "$flowDefinitionIdToDeactivate" \
  --values "Metadata='{\"activeVersionNumber\":0}'" \
  --use-tooling-api
echo "Done!" && echo
