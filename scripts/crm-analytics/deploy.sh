#!/usr/bin/env bash

# How to use:
# - bash ./scripts/crm-analytics/deploy.sh
# - echo $TXT_WITH_INPUTS | bash ./scripts/crm-analytics/deploy.sh

# Enable errexit option to exit on command failure
set -e

# Capture Scratch Org alias;
read -r -p "🔶 Enter Scratch Org Alias: " TARGET_ORG_ALIAS
echo "🔵 Deploying CRM Analytics assets to [$TARGET_ORG_ALIAS] org..."

# Cleanup working directory
rm -rf "build/minlopro-crm-analytics"

# Copy CRMA assets to 'build' folder
mkdir -p "build"
cp -r "src/minlopro-crm-analytics" "build"

# Add folder-level ignore file to make sure the manifest captures all metadata
touch "build/.forceignore"

# Initiate deployment
sf project deploy start \
  --target-org "$TARGET_ORG_ALIAS" \
  --source-dir "build/minlopro-crm-analytics" \
  --verbose \
  --ignore-conflicts \
  --ignore-warnings \
  --wait 20
