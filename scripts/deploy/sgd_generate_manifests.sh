#!/bin/bash

# How to use:
# - bash ./scripts/deploy/sgd_generate_manifests.sh
# - echo $TXT_FILE_WITH_BRANCH_NAMES | bash ./scripts/deploy/sgd_generate_manifests.sh

printf "🔶 Enter branch name / commit SHA to capture changes FROM:\n"
read FROM_REF
printf "🔶 Enter branch name / commit SHA to capture changes UP TO:\n"
read TO_REF

printf "🔵 Generating XML manifests from [$FROM_REF] to [$TO_REF]...\n"

# Define constants;
srcFolder="src"
sgdFolder="manifests/sgd"
packageXml="$sgdFolder/package/package.xml"
destructiveChangesXml="$sgdFolder/destructiveChanges/destructiveChanges.xml"

# Create SGD folder;
mkdir -p "$sgdFolder"

# Invoke SGD plugin and generate manifests;
sf sgd:source:delta \
  --from $FROM_REF \
  --to $TO_REF \
  --output $sgdFolder \
  --source $srcFolder \
  --ignore '.forceignore' &&

# Output results;
tree "$sgdFolder"
printf "\n---SGD PACKAGE.XML---\n" && cat "$packageXml"
printf "\n---SGD DESTRUCTIVE_CHANGES.XML---\n" && cat "$destructiveChangesXml"
