#!/bin/bash

# How to use:
# - bash ./scripts/release/release_deploy.sh
# - echo 'ORG_ALIAS' | bash ./scripts/release/release_deploy.sh

# Enable errexit option to exit on command failure
set -e

# TODO - generate manifests using SGD (comparion current branch with 'main' branch)
# TODO - collect Apex test names (default to dummy test class)

# Capture target org alias;
read -p "🔶 Enter target org alias to run QUICK DEPLOY against: " TARGET_ORG_ALIAS
echo "🔵 Running quick deploy against [$TARGET_ORG_ALIAS] organization..."

# Initiate deployment validation;
jobInfoJson=$(npx dotenv -e ".env" -- sf project deploy validate \
  --target-org "$TARGET_ORG_ALIAS" \
  --manifest "manifests/package.xml" \
  --pre-destructive-changes "manifests/destructiveChangesPre.xml" \
  --post-destructive-changes "manifests/destructiveChangesPost.xml" \
  --test-level "RunSpecifiedTests" \
  --tests "DatatableControllerTest" --tests "CCFAuthProviderPluginTest" \
  --verbose \
  --async \
  --ignore-warnings \
  --json \
  --wait 20)

# Extract and parse Job ID;
jobIdWithQuotes=$(echo "$jobInfoJson" | jq '.result.id')
jobId="${jobIdWithQuotes//\"/}"
echo "Job ID (18) = $jobId"

# Resume deployment watching/polling by Job ID;
sf project deploy resume --job-id "$jobId"

# Run quick deploy by Job ID;
sf project deploy quick \
  --target-org "$TARGET_ORG_ALIAS" \
  --job-id "$jobId" \
  --verbose \
  --wait 20

echo 'Done!'
