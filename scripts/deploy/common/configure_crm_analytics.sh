#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/common/configure_crm_analytics.sh
# - bash ./scripts/deploy/common/configure_crm_analytics.sh "$SOURCE_ORG_ALIAS" "$TARGET_ORG_ALIAS"

set -euo pipefail

SOURCE_ORG_ALIAS="${1:-}"
TARGET_ORG_ALIAS="${2:-}"

if [ -z "$SOURCE_ORG_ALIAS" ]; then
  read -r -p "🔶 Enter source org alias to pull Event Log Files from: " SOURCE_ORG_ALIAS
fi
if [ -z "$TARGET_ORG_ALIAS" ]; then
  read -r -p "🔶 Enter target org alias to configure CRM Analytics in: " TARGET_ORG_ALIAS
fi

if [ -z "$SOURCE_ORG_ALIAS" ] || [ -z "$TARGET_ORG_ALIAS" ]; then
  echo "❌ Error: source and target org aliases are required"
  exit 1
fi

API_VERSION=$(bash ./scripts/util/get_project_api_version.sh)

echo "🔵 Configuring CRM Analytics in [$TARGET_ORG_ALIAS] organization..."

# Import event log files into CRM Analytics datasets (add more event types here as needed)
EVENT_TYPES=("LightningLogger" "Login")

for EVENT_TYPE in "${EVENT_TYPES[@]}"; do
  bash scripts/util/event-monitoring/elf.sh \
    --source-org-alias "$SOURCE_ORG_ALIAS" \
    --target-org-alias "$TARGET_ORG_ALIAS" \
    --event-type "$EVENT_TYPE" \
    --mode "download-and-upload-to-dataset" \
    --api-version "$API_VERSION" \
    --folder "MinloproEventMonitoring" \
    --elf-limit 30 \
    --metadata "scripts/util/event-monitoring/event-metadata-json/${EVENT_TYPE}-v${API_VERSION}.json"
done
sleep 60

# List CRM Analytics assets via Salesforce CLI plugin
sf analytics app list --target-org "$TARGET_ORG_ALIAS"; echo
sf analytics dashboard list --target-org "$TARGET_ORG_ALIAS"; echo
sf analytics dataflow list --target-org "$TARGET_ORG_ALIAS"; echo
sf analytics dataset list --target-org "$TARGET_ORG_ALIAS"; echo
sf analytics lens list --target-org "$TARGET_ORG_ALIAS"; echo
sf analytics recipe list --target-org "$TARGET_ORG_ALIAS"

# Invoke CRM Analytics recipes
invoke_recipes(){
  local json_input="$1"
  if echo "$json_input" | jq -e ".result" > /dev/null; then
    array_length=$(echo "$json_input" | jq ".result | length")
    if (( array_length > 0 )); then
      echo "$json_input" | jq -c ".result[]" | while read -r record; do
        recipe_id=$(echo "$record" | jq -r '.recipeid')
        sf analytics recipe start -i "$recipe_id" -o "$TARGET_ORG_ALIAS" || true
      done
    fi
  fi
}
invoke_recipes "$(sf analytics recipe list --target-org "$TARGET_ORG_ALIAS" --json)"

echo "✅ CRM Analytics configuration done!"
