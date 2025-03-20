#!/usr/bin/env bash

# How to use:
# - bash ./scripts/crm-analytics/refresh.sh
# - echo "ORG_ALIAS" | bash ./scripts/crm-analytics/refresh.sh

# Enable errexit option to exit on command failure
set -e

# Capture Scratch Org alias;
read -r -p "🔶 Enter Scratch Org Alias: " TARGET_ORG_ALIAS
echo "🔵 Refreshing CRM Analytics assets from [$TARGET_ORG_ALIAS] org..."
rootDir="src/minlopro-crm-analytics"

# Add folder-level ignore file to make sure the retrieval operation succeeds
touch "$rootDir/.forceignore"

# Initiate retrieval
bash ./scripts/util/refresh.sh "$TARGET_ORG_ALIAS" "$rootDir"

# Remove CRMA ignore file in order to let standard SF CLI push/pull commands ignore WAVE metadata
rm -f "$rootDir/.forceignore"
