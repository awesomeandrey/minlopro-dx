#!/bin/bash

# How to use:
# - bash ./scripts/util/retrieve_by_manifest.sh
# - echo $ORG_ALIAS | bash ./scripts/util/retrieve_by_manifest.sh

# Capture target org alias;
read -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

manifestPath="manifests/package.xml"
targetDirPath="retrieved-src"

echo "🔵 Retrieving metadata by [$manifestPath] manifest from [$TARGET_ORG_ALIAS] into [$targetDirPath] folder..."

if [ -d "$targetDirPath" ]; then
  rm -rf "$targetDirPath"
fi

mkdir -p "$targetDirPath"

sf project retrieve start \
    --manifest "$manifestPath" \
    --target-org "$TARGET_ORG_ALIAS" \
    --output-dir "$targetDirPath" \
    --ignore-conflicts
