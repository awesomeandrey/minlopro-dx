#!/bin/bash

# How to use:
# - bash ./scripts/util/deactivate_all_duplicate_rules.sh
# - echo $ORG_ALIAS | bash ./scripts/util/deactivate_all_duplicate_rules.sh

# Enable errexit option to exit on command failure
set -e

# Capture Org alias
read -p "🔶 Enter Org Alias: " ORG_ALIAS

echo "🔵 Deactivating all duplicate rules in [$ORG_ALIAS] org..."

# Get project API version
PROJECT_API_VERSION=$(bash ./scripts/util/get_project_api_version.sh)

# Create manifest file
echo "Generating manifest file..."
MANIFEST_FILE="build/package.xml"

rm -rf "build"
mkdir -p "build"

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
echo "Retrieving duplicate rules metadata from [$ORG_ALIAS] org..."
sf project retrieve start \
 --target-org "$ORG_ALIAS" \
 --manifest "$MANIFEST_FILE" \
 --target-metadata-dir "build" \
 --unzip \
 --zip-file-name "package" \
 --wait 10

# Check if duplicate rules folder exists
if [ ! -d "./build/package/unpackaged/duplicateRules" ]; then
    echo "No Duplicate Rules found in the org."
    exit 0
fi

# Determine OS and define 'sed' command based on OS
OS="$(uname)"
if [[ "$OS" == "Darwin" ]]; then
    # MacOS
    echo "SED command is adapted for Mac OS."
    SED_COMMAND="sed -i '' "
else
    # Linux
    echo "SED command is adapted for Linux OS."
    SED_COMMAND="sed -i "
fi

# Deactivate each Duplicate Rule
echo "Deactivating duplicate rules..."
for file in ./build/package/unpackaged/duplicateRules/*; do
    $SED_COMMAND 's/<isActive>true<\/isActive>/<isActive>false<\/isActive>/' "$file"
done

# Deploying deactivated Duplicate Rules back to the Salesforce Org
echo "Deploying deactivated duplicate rules back to the [$ORG_ALIAS] org..."
sf project deploy start \
   --target-org "$ORG_ALIAS" \
   --metadata-dir "./build/package/unpackaged" \
   --verbose \
   --ignore-warnings \
   --ignore-conflicts \
   --wait 10

echo "Done!"
