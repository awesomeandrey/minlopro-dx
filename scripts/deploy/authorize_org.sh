#!/bin/bash

# How to use:
# - bash ./scripts/deploy/authorize_org.sh --sfdxUrl "force://..."
# - bash ./scripts/deploy/authorize_org.sh --sfdxUrl "force://..." --orgAlias "ORG_ALIAS"

# Input variables;
orgAlias="TARGET_ORG"
sfdxUrl=""
# Parse command-line arguments;
while [[ $# -gt 0 ]]; do
    case $1 in
        --orgAlias)
            orgAlias="$2"
            shift # past argument
            shift # past value
            ;;
        --sfdxUrl)
            sfdxUrl="$2"
            shift # past argument
            shift # past value
            ;;
        *)
            shift # past argument
            ;;
    esac
done
# Check if sfdxUrl was provided;
if [ -z "$sfdxUrl" ]; then
    echo "Error: sfdxUrl parameter is mandatory"
    echo "Usage: $0 --sfdxUrl \"force://...\" [--orgAlias \"ORG_ALIAS\"]"
    exit 1
fi
buildFolder="build"
sfAuthUrlFile="$buildFolder/target-org-auth-url.txt"
echo "🔵 Authorizing [$orgAlias] organization..."
echo

# Save sf auth URL into a text file;
mkdir -p "$buildFolder"
touch $sfAuthUrlFile
echo $sfdxUrl > "$sfAuthUrlFile"

# Authorize Salesforce org and set it as default one;
sf org login sfdx-url \
  --sfdx-url-file $sfAuthUrlFile \
  --alias "$orgAlias" \
  --set-default
