#!/bin/bash

# Define constants;
targetOrgAlias=$1
sgdFolder="manifests/sgd"
packageXml="$sgdFolder/package/package.xml"
destructiveChangesXml="$sgdFolder/destructiveChanges/destructiveChanges.xml"

if grep -r '<members>' $sgdFolder; then
  sfdx force:source:deploy \
    --checkonly \
    --target-org $targetOrgAlias \
    --verbose \
    --ignorewarnings \
    --manifest "$packageXml" \
    --postdestructivechanges "$destructiveChangesXml"
else
  printf "\n No source-backed components present in the package. Nothing to validate! \n"
  exit 0
fi
