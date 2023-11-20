#!/bin/bash

# How to use:
# - bash ./scripts/util/export_setup_audit_trail.sh

# Capture target org alias;
printf "Enter target org alias:\n"
read TARGET_ORG_ALIAS

# Define constants;
buildFolderName="build"
auditTrailCsvFilename="$buildFolderName/setup_audit_trail.csv"

mkdir -p $buildFolderName

sf data query \
  --target-org $TARGET_ORG_ALIAS \
  --query "SELECT Id,Action,Section,CreatedDate,CreatedBy.Name,Display FROM SetupAuditTrail ORDER BY CreatedDate DESC" \
  --result-format csv > "$auditTrailCsvFilename"
