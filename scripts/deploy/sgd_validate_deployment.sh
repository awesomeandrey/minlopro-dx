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
  printf "\nMake sure to generate manifests via SGD plugin prior to running this script!\n"
  exit 0
fi

# Check if there are metadata changes detected;
sgdPackageXmlLinesCount=$(wc -l < $sgdPackageXml)
printf "\nSGD Package XML lines count = ${sgdPackageXmlLinesCount}\n"
preDestructiveChangesXmlLinesCount=$(wc -l < $preDestructiveChangesXml)
printf "PRE-Destructive XML lines count = ${preDestructiveChangesXmlLinesCount}\n"
postDestructiveChangesXmlLinesCount=$(wc -l < $postDestructiveChangesXml)
printf "POST-Destructive XML lines count = ${postDestructiveChangesXmlLinesCount}\n"

if (($sgdPackageXmlLinesCount < 6)) && (($preDestructiveChangesXmlLinesCount < 6)) && (($postDestructiveChangesXmlLinesCount < 6)); then
  printf '\nThere are no metadata changes detected!\n'
  exit 0
fi

# Capture target org alias;
printf "Enter target org alias to validate deploy against:\n"
read TARGET_ORG_ALIAS

# Otherwise validate deployment;
printf "Target Org Alias: [$TARGET_ORG_ALIAS]\n"
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
