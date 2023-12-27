#!/bin/bash

# How to use:
# - bash ./scripts/deploy/sgd_validate_deployment.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/sgd_validate_deployment.sh

# Define constants;
manifestsFolder="manifests"
sgdFolder="manifests/sgd"
sgdPackageXml="$sgdFolder/package/package.xml"

# Destructive manifest files are pulled from 'manifests' folder instead of 'sgd'
preDestructiveChangesXml="$manifestsFolder/destructiveChangesPre.xml"
postDestructiveChangesXml="$manifestsFolder/destructiveChangesPost.xml"

# Check if SGD manifests exist;
if ! [ -d "$sgdFolder" ]; then
  echo "⚪ Make sure to generate manifests via SGD plugin prior to running this script!"
  exit 0
fi

# Check if there are metadata changes detected;
sgdPackageXmlLinesCount=$(wc -l < $sgdPackageXml)
echo "SGD Package XML lines count = ${sgdPackageXmlLinesCount}" | xargs
preDestructiveChangesXmlLinesCount=$(wc -l < $preDestructiveChangesXml)
echo "PRE-Destructive XML lines count = ${preDestructiveChangesXmlLinesCount}" | xargs
postDestructiveChangesXmlLinesCount=$(wc -l < $postDestructiveChangesXml)
echo "POST-Destructive XML lines count = ${postDestructiveChangesXmlLinesCount}" | xargs

if (($sgdPackageXmlLinesCount < 6)) && (($preDestructiveChangesXmlLinesCount < 6)) && (($postDestructiveChangesXmlLinesCount < 6)); then
  echo '⚪ There are no metadata changes detected!'
  exit 0
fi

# Capture target org alias;
read -p "🔶 Enter target org alias to validate deploy against: " TARGET_ORG_ALIAS

# Otherwise validate deployment;
echo "🔵 Validating partial deployment against [$TARGET_ORG_ALIAS] organization..."
echo
sf project deploy start \
  --target-org $TARGET_ORG_ALIAS \
  --manifest "$sgdPackageXml" \
  --pre-destructive-changes "$preDestructiveChangesXml" \
  --post-destructive-changes "$postDestructiveChangesXml" \
  --verbose \
  --ignore-conflicts \
  --ignore-warnings \
  --dry-run \
  --test-level NoTestRun \
  --wait 20

# Get previous command code;
deploymentStatusCode=$?

exit $deploymentStatusCode
