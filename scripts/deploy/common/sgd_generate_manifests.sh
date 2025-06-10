#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/common/sgd_generate_manifests.sh
# - bash ./scripts/deploy/common/sgd_generate_manifests.sh "$FROM_REF" "$TO_REF" "$TARGET_ORG_ALIAS"
# - echo $TXT_FILE_WITH_BRANCH_NAMES | bash ./scripts/deploy/common/sgd_generate_manifests.sh

FROM_REF=$1
TO_REF=$2
TARGET_ORG_ALIAS=$3

defaultTargetOrgAlias=$(bash ./scripts/util/get_target_org_alias.sh)
if [ -z "$FROM_REF" ] || [ -z "$TO_REF" ]; then
  read -r -p "🔶 Enter branch name / commit SHA to capture changes FROM: " FROM_REF
  read -r -p "🔶 Enter branch name / commit SHA to capture changes UP TO: " TO_REF
  read -r -p "🔶 Enter target Salesforce org alias (default = $defaultTargetOrgAlias): " TARGET_ORG_ALIAS
fi
TARGET_ORG_ALIAS=${TARGET_ORG_ALIAS:-${defaultTargetOrgAlias}}

echo "🔵 Generating XML manifests from [$FROM_REF] to [$TO_REF] for [$TARGET_ORG_ALIAS] organization..."
echo

# Define constants
sgdFolder="build/sgd"
packageXml="$sgdFolder/package/package.xml"
destructiveChangesXml="$sgdFolder/destructiveChanges/destructiveChanges.xml"
forceignore=".forceignore"

# Exclude CRM Analytics metadata if target Salesforce org is not CRMA-eligible
soqlQuery="SELECT COUNT(Id) FROM PermissionSetLicense WHERE DeveloperName = 'EinsteinAnalyticsPlusPsl'"
crmAnalyticsLicensesCount=$(sf data query --target-org "$TARGET_ORG_ALIAS" --query "$soqlQuery" --json | jq -r '.result.records[0].expr0')
echo "CRM Analytics Licenses Count = $crmAnalyticsLicensesCount"
trap 'git restore .forceignore' EXIT
if [ "$crmAnalyticsLicensesCount" -eq 0 ]; then
  {
    echo
    echo "# CRM Analytics"
    echo "**/minlopro-crm-analytics"
  } >> "$forceignore"
  echo "Excluded CRM Analytics metadata from deployment bundle."
else
  echo "[$TARGET_ORG_ALIAS] organization is CRM Analytics eligible."
fi

# Create SGD folder;
mkdir -p "$sgdFolder"

# Invoke SGD plugin and generate manifests;
sf sgd source delta \
  --from "$FROM_REF" \
  --to "$TO_REF" \
  --output-dir "$sgdFolder" \
  --source-dir "src" \
  --ignore-file "$forceignore"

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
