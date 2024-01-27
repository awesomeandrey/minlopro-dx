#!/bin/bash

# How to use:
# - bash ./scripts/release/sgd_generate_manifests.sh
# - echo "release/**" | bash ./scripts/release/sgd_generate_manifests.sh

# Releases are expected to be created against 'main' branch directly
FROM_REF="main"

read -p "🔶 Enter release branch name to capture changes UP TO: " TO_REF
echo "🔵 Generating XML manifests from [$FROM_REF] to [$TO_REF]..."
echo

# Define constants;
buildFolder="build"
srcFolder="src"
sgdFolder="manifests/sgd"
sgdPackageXml="$sgdFolder/package/package.xml"

# Destructive manifest files are pulled from 'manifests' folder instead of 'sgd'
preDestructiveChangesXml="manifests/destructiveChangesPre.xml"
postDestructiveChangesXml="manifests/destructiveChangesPost.xml"

# Create folders;
mkdir -p "$sgdFolder"
mkdir -p "$buildFolder"

# Invoke SGD plugin and generate manifests;
sf sgd:source:delta \
  --from $FROM_REF \
  --to $TO_REF \
  --output $sgdFolder \
  --source $srcFolder \
  --ignore '.forceignore'

# Output results;
echo "📜 RELEASE PRE_DESTRUCTIVE_CHANGES.XML (static)"
cat "$preDestructiveChangesXml"
echo "📜 RELEASE PACKAGE.XML (SGD)"
cat "$sgdPackageXml"
echo
echo "📜 RELEASE POST_DESTRUCTIVE_CHANGES.XML (static)"
cat "$postDestructiveChangesXml"

# Check if any manifest file contains metadata references
if ! grep -q '<members>' "$sgdPackageXml" && ! grep -q '<members>' "$preDestructiveChangesXml" && ! grep -q '<members>' "$postDestructiveChangesXml"; then
  echo "🔴 No metadata references were detected in manifests."
  exit 1
fi

# Copy manifests to 'build' folder
echo
cp -f "$sgdPackageXml" "$buildFolder/package.xml"
cp -f "$preDestructiveChangesXml" "$buildFolder/destructiveChangesPre.xml"
cp -f "$postDestructiveChangesXml" "$buildFolder/destructiveChangesPost.xml"
tree "$buildFolder"
