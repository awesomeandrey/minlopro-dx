#!/bin/bash

# How to use:
# - bash ./scripts/deploy/validate.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/validate.sh

# Capture target org alias;
printf "🔶 Enter target org alias to validate deploy against:\n"
read TARGET_ORG_ALIAS

# Invoke source deploy to target org (dry-run);
printf "🔵 Validate deployment against [$TARGET_ORG_ALIAS] organization...\n"
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
