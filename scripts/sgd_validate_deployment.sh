#!/bin/bash

# Sample Execution:
# bash ./scripts/sgd_validate_deployment.sh TARGET_ORG_ALIAS

# Define constants;
targetOrgAlias=$1
sgdFolder="manifests/sgd"
packageXml="$sgdFolder/package/package.xml"
destructiveChangesXml="$sgdFolder/destructiveChanges/destructiveChanges.xml"

# Check if there are metadata changes detected;
packageXmlLinesCount=$(wc -l < $packageXml)
printf "\n Package XML lines count = ${packageXmlLinesCount} \n"
destructiveChangesXmlLinesCount=$(wc -l < $destructiveChangesXml)
printf "\n Destructive XML lines count = ${destructiveChangesXmlLinesCount} \n"
if (($packageXmlLinesCount < 10)) && (($destructiveChangesXmlLinesCount < 10)); then
  printf '\n There are no metadata changes detected! \n'
  exit 0
fi

# Ignore '.forceignore' file settings when generating manifest;
mv '.forceignore' '.forceignore_skip'

# Otherwise validate deployment;
sfdx force:source:deploy \
  --checkonly \
  --target-org $targetOrgAlias \
  --verbose \
  --ignorewarnings \
  --manifest "$packageXml" \
  --postdestructivechanges "$destructiveChangesXml"

deploymentStatus=$?

# Revert changes;
mv '.forceignore_skip' '.forceignore'

exit $deploymentStatus