#!/bin/bash

# How to use:
# - bash ./scripts/deploy/deploy.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/deploy.sh

# Capture target org alias;
echo "🔶 Enter target org alias to run hard deploy against:"
read TARGET_ORG_ALIAS

# Invoke source deploy to target org;
echo "🔵 Deploying to [$TARGET_ORG_ALIAS] organization..."
sf project deploy start \
  --target-org $TARGET_ORG_ALIAS \
  --manifest "manifests/package.xml" \
  --pre-destructive-changes "manifests/destructiveChangesPre.xml" \
  --post-destructive-changes "manifests/destructiveChangesPost.xml" \
  --verbose \
  --ignore-conflicts \
  --ignore-warnings \
  --wait 20
