#!/bin/bash

# How to use:
# - bash ./scripts/crm-analytics/retrieve_metadata_by_wave_app.sh

# Enable errexit option to exit on command failure
set -e

# Capture Scratch Org alias;
read -p "🔶 Enter target org alias to pull WAVE metadata from: " TARGET_ORG_ALIAS
read -p "🔶 Enter Wave application API name: " WAVE_APP_NAME

# Override input variables manually for testing purposes!
# TARGET_ORG_ALIAS="crma-devhub"
# WAVE_APP_NAME="Minlopro_DX_Analytics"

echo "🔵 Pulling [$WAVE_APP_NAME] app content from [$TARGET_ORG_ALIAS] org..."

# Cleanup working directory
metadataDir="build/$WAVE_APP_NAME"
rm -rf "$metadataDir"
mkdir -p "$metadataDir"

# Retrieve metadata by manifest
sf project retrieve start \
    --manifest "./scripts/crm-analytics/assets/crma-package.xml" \
    --target-org "$TARGET_ORG_ALIAS" \
    --output-dir "$metadataDir" \
    --ignore-conflicts \
    --wait 30

# Iterate through files in the directory
KEYWORD=">$WAVE_APP_NAME</"
for file in "$metadataDir/wave"/*; do
  # Check if the filename contains the keyword
  if grep -q "$KEYWORD" "$file"; then
    echo "Keeping file: $(basename "$file")"
  else
    echo "Deleting file: $(basename "$file")"
    rm "$file"
  fi
done
echo "Files have been filtered based on the keyword."

# Compose manifest file with metadata for the WAVE application
tempManifest="temp/crma-package.xml"
touch "$tempManifest"
echo "$metadataDir/wave" | node ./scripts/crm-analytics/js/compose_app_manifest_from_metadata.js
cat "$tempManifest"

# Cleanup working directory (again)
metadataDir="build/$WAVE_APP_NAME"
rm -rf "$metadataDir"
mkdir -p "$metadataDir"

# Initiate retrieve now based on refined manifest file
sf project retrieve start \
    --manifest "$tempManifest" \
    --target-org "$TARGET_ORG_ALIAS" \
    --output-dir "$metadataDir" \
    --ignore-conflicts \
    --wait 15
