#!/usr/bin/env bash

# How to use:
# - bash ./scripts/release/release_deploy.sh
# - echo 'ORG_ALIAS' | bash ./scripts/release/release_deploy.sh

# Capture inputs;
read -p "🔶 Enter target org alias to run QUICK DEPLOY against: " TARGET_ORG_ALIAS
read -p "🔶 Enter Job ID: " JOB_ID
echo "🔵 Running quick deploy by [$JOB_ID] job ID against [$TARGET_ORG_ALIAS] organization..."
echo

# Run quick deploy by Job ID;
sf project deploy quick \
  --target-org "$TARGET_ORG_ALIAS" \
  --job-id "$JOB_ID" \
  --verbose \
  --wait 20
