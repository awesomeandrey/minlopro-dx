#!/bin/bash

# How to use:
# - bash ./scripts/deploy/validate.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/validate.sh

# Capture target org alias;
read -p "🔶 Enter target org alias to validate deploy against: " TARGET_ORG_ALIAS

# Invoke source deploy to target org (dry-run);
echo "🔵 Validate deployment against [$TARGET_ORG_ALIAS] organization..."
sf project deploy start \
  --target-org $TARGET_ORG_ALIAS \
  --manifest "manifests/package.xml" \
  --pre-destructive-changes "manifests/destructiveChangesPre.xml" \
  --post-destructive-changes "manifests/destructiveChangesPost.xml" \
  --verbose \
  --ignore-conflicts \
  --ignore-warnings \
  --dry-run \
  --test-level NoTestRun \
  --wait 20
