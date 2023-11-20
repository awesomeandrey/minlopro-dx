#!/bin/bash

# How to use:
# - bash ./scripts/deploy/deploy.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/deploy.sh

# Capture target org alias;
printf "Enter target org alias to run hard deploy against:\n"
read TARGET_ORG_ALIAS

# Invoke source deploy to target org;
printf "Target Org Alias: [$TARGET_ORG_ALIAS]\n"
sf project deploy start \
  --target-org $TARGET_ORG_ALIAS \
  --manifest manifests/package.xml \
  --pre-destructive-changes manifests/destructiveChangesPre.xml \
  --post-destructive-changes manifests/destructiveChangesPost.xml \
  --verbose \
  --ignore-conflicts \
  --ignore-warnings \
  --wait 20
