#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/metadata/refresh_metadata.sh
# - bash ./scripts/util/metadata/refresh_metadata.sh "org_alias" "src"

TARGET_ORG_ALIAS="$1"
METADATA_FOLDER_PATH="$2"

if [ -z "$TARGET_ORG_ALIAS" ] || [ -z "$METADATA_FOLDER_PATH" ]; then
  read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS
  read -r -p "🔶 Enter folder path with metadata to refresh: " METADATA_FOLDER_PATH
fi

echo "🔵 Refreshing metadata in [$METADATA_FOLDER_PATH] from [$TARGET_ORG_ALIAS] org..."

# Initiate retrieval
sf project retrieve start \
  --target-org "$TARGET_ORG_ALIAS" \
  --source-dir "$METADATA_FOLDER_PATH" \
  --ignore-conflicts \
  --wait 10
