#!/usr/bin/env bash

# How to use:
# - bash ./scripts/crm-analytics/refresh.sh
# - echo $TXT_WITH_INPUTS | bash ./scripts/crm-analytics/refresh.sh

# Enable errexit option to exit on command failure
set -e

# Capture Scratch Org alias;
read -p "🔶 Enter Scratch Org Alias: " TARGET_ORG_ALIAS
echo "🔵 Refreshing CRM Analytics assets from [$TARGET_ORG_ALIAS] org..."

# Add folder-level ignore file to make sure the retrieval operation succeeds
touch "src/minlopro-crma/.forceignore"

# Initiate retrieval
sf project retrieve start \
  --target-org "$TARGET_ORG_ALIAS" \
  --source-dir "src/minlopro-crma" \
  --ignore-conflicts \
  --wait 15

# Remove CRMA ignore file in order to let standard SF CLI push/pull commands ignore WAVE metadata
rm -f "src/minlopro-crma/.forceignore"
