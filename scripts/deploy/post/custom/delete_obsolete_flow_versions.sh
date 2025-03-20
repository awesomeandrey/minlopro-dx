#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/post/custom/delete_obsolete_flow_versions.sh

# Note: there can be a dependency on existing flow interviews. They can be deleted manually from Salesforce UI (see App Launcher > Paused Flows).

# Capture target org alias;
read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

echo "🔵 Purging obsolete Flow Versions from [$TARGET_ORG_ALIAS] organization..."

sf hardis:org:purge:flow \
  --target-org "$TARGET_ORG_ALIAS" \
  --allowpurgefailure \
  --skipauth \
  --no-prompt \
  --delete-flow-interviews
