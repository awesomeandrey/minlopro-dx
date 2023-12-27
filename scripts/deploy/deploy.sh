#!/bin/bash

# How to use:
# - bash ./scripts/deploy/deploy.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/deploy.sh

# Capture target org alias;
read -p "🔶 Enter target org alias to run hard deploy against: " TARGET_ORG_ALIAS

# Invoke source deploy to target org;
echo "🔵 Deploying to [$TARGET_ORG_ALIAS] organization..."
echo
sf project deploy start \
  --target-org $TARGET_ORG_ALIAS \
  --manifest "manifests/package.xml" \
  --pre-destructive-changes "manifests/destructiveChangesPre.xml" \
  --post-destructive-changes "manifests/destructiveChangesPost.xml" \
  --verbose \
  --ignore-conflicts \
  --ignore-warnings \
  --wait 20
