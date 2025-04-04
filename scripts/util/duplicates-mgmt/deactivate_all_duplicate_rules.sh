#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/duplicates-mgmt/deactivate_all_duplicate_rules.sh
# - echo $TARGET_ORG_ALIAS | bash ./scripts/util/duplicates-mgmt/deactivate_all_duplicate_rules.sh

# Enable errexit option to exit on command failure
set -e

# Capture Org alias
read -r -p "🔶 Enter Org Alias: " TARGET_ORG_ALIAS

echo "🔵 Deactivating all duplicate rules in [$TARGET_ORG_ALIAS] org..."

# Get project API version
PROJECT_API_VERSION=$(bash ./scripts/util/get_project_api_version.sh)

workingDir="build/deactivated-duplicate-rules"
rm -rf "$workingDir"
mkdir -p "$workingDir"

# Create manifest file
echo "Generating manifest file..."
MANIFEST_FILE="$workingDir/package.xml"

touch "$MANIFEST_FILE"
cat <<EOL > "$MANIFEST_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>*</members>
        <name>DuplicateRule</name>
    </types>
    <version>$PROJECT_API_VERSION</version>
</Package>
EOL

# Retrieve Duplicate Rules metadata from the Salesforce Org
echo "Retrieving duplicate rules metadata from [$TARGET_ORG_ALIAS] org..."
sf project retrieve start \
 --target-org "$TARGET_ORG_ALIAS" \
 --manifest "$MANIFEST_FILE" \
 --target-metadata-dir "$workingDir" \
 --unzip \
 --zip-file-name "package" \
 --wait 10

# Check if duplicate rules folder exists
if [ ! -d "./$workingDir/package/unpackaged/duplicateRules" ]; then
    echo "No Duplicate Rules found in the org."
    exit 0
fi

# Deactivate each Duplicate Rule
echo "Deactivating duplicate rules..."
for file in "$workingDir/package/unpackaged/duplicateRules"/*; do
    xmlstarlet ed -L -u "//*[local-name()='isActive']" -v "false" "$file"
done

# Deploying deactivated Duplicate Rules back to the Salesforce Org
echo "Deploying deactivated duplicate rules back to the [$TARGET_ORG_ALIAS] org..."
sf project deploy start \
   --target-org "$TARGET_ORG_ALIAS" \
   --metadata-dir "./$workingDir/package/unpackaged" \
   --verbose \
   --ignore-warnings \
   --ignore-conflicts \
   --wait 10

echo "Done!"
