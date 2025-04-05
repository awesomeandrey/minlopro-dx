#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/common/sgd_generate_manifests.sh
# - bash ./scripts/deploy/common/sgd_generate_manifests.sh "$FROM_REF" "$TO_REF"
# - echo $TXT_FILE_WITH_BRANCH_NAMES | bash ./scripts/deploy/common/sgd_generate_manifests.sh

FROM_REF=$1
TO_REF=$2

if [ -z "$FROM_REF" ] || [ -z "$TO_REF" ]; then
  read -r -p "🔶 Enter branch name / commit SHA to capture changes FROM: " FROM_REF
  read -r -p "🔶 Enter branch name / commit SHA to capture changes UP TO: " TO_REF
fi

echo "🔵 Generating XML manifests from [$FROM_REF] to [$TO_REF]..."
echo

# Define constants;
sgdFolder="build/sgd"
packageXml="$sgdFolder/package/package.xml"
destructiveChangesXml="$sgdFolder/destructiveChanges/destructiveChanges.xml"

# Create SGD folder;
mkdir -p "$sgdFolder"

# Invoke SGD plugin and generate manifests;
sf sgd source delta \
  --from "$FROM_REF" \
  --to "$TO_REF" \
  --output-dir "$sgdFolder" \
  --source-dir "src" \
  --ignore-file '.forceignore'

# Output results;
echo "📜 SGD DIRECTORY"
tree "$sgdFolder"
echo "📜 SGD PACKAGE.XML"
cat "$packageXml"
echo
echo "📜 SGD DESTRUCTIVE_CHANGES.XML"
cat "$destructiveChangesXml"
echo

# Copy 'package.xml' manifest to 'manifests' folder;
cp -f "$packageXml" "manifests/package.xml"
