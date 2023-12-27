#!/bin/bash

# How to use:
# - bash ./scripts/deploy/sgd_generate_manifests.sh
# - echo $TXT_FILE_WITH_BRANCH_NAMES | bash ./scripts/deploy/sgd_generate_manifests.sh

read -p "🔶 Enter branch name / commit SHA to capture changes FROM: " FROM_REF
read -p "🔶 Enter branch name / commit SHA to capture changes UP TO: " TO_REF

echo "🔵 Generating XML manifests from [$FROM_REF] to [$TO_REF]..."

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
echo "📜 SGD PACKAGE.XML"
cat "$packageXml"
echo
echo "📜 SGD DESTRUCTIVE_CHANGES.XML"
cat "$destructiveChangesXml"
