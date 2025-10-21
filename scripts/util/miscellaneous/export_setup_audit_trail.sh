#!/usr/bin/env bash

# Capture target org alias;
read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

echo "🔵 Exporting Audit Trail from [$TARGET_ORG_ALIAS] organization..."

# Define constants;
buildFolderName="build"
auditTrailCsvFilename="$buildFolderName/setup_audit_trail.csv"

mkdir -p $buildFolderName

sf data query \
  --target-org "$TARGET_ORG_ALIAS" \
  --query "SELECT Id, Action, Section, CreatedDate, CreatedBy.Name, Display FROM SetupAuditTrail ORDER BY CreatedDate DESC" \
  --result-format csv > "$auditTrailCsvFilename"
