#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/crm-analytics/retrieve_metadata_by_wave_app.sh

set -e

# Capture Scratch Org alias;
read -r -p "🔶 Enter target org alias to pull WAVE metadata from: " TARGET_ORG_ALIAS
read -r -p "🔶 Enter Wave application API name: " WAVE_APP_NAME

echo "🔵 Pulling [$WAVE_APP_NAME] app content from [$TARGET_ORG_ALIAS] org..."

METADATA_DIR="build/$WAVE_APP_NAME"

cleanup_dir(){
  rm -rf "$METADATA_DIR"
  mkdir -p "$METADATA_DIR"
}

cleanup_dir

# Retrieve all WAVE metadata (by global manifest)
sf project retrieve start \
    --manifest "./scripts/util/crm-analytics/all-wave-metadata-package.xml" \
    --target-org "$TARGET_ORG_ALIAS" \
    --output-dir "$METADATA_DIR" \
    --ignore-conflicts \
    --wait 10

# Iterate through metadata files in the directory
KEYWORD=">$WAVE_APP_NAME</"
for file in "$METADATA_DIR/wave"/*; do
  # Check if the filename contains the keyword
  if grep -q "$KEYWORD" "$file"; then
    echo "Keeping file: $(basename "$file")"
  else
    echo "Deleting file: $(basename "$file")"
    rm "$file"
  fi
done
echo "Files have been filtered based on the keyword."

# Compose manifest file with metadata for the WAVE application (JS script also depends on "build/wave-app-package.xml" filepath!)
tempManifest="build/wave-app-package.xml"
touch "$tempManifest"
echo "$METADATA_DIR/wave"| node ./scripts/util/crm-analytics/compose_app_manifest_from_metadata.js
cat "$tempManifest"

cleanup_dir

# Initiate retrieve now based on refined manifest file
sf project retrieve start \
    --manifest "$tempManifest" \
    --target-org "$TARGET_ORG_ALIAS" \
    --output-dir "$METADATA_DIR" \
    --ignore-conflicts \
    --wait 10
