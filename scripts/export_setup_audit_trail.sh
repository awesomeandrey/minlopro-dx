#!/bin/bash

# Define constants;
targetOrg=$1 #Mandatory parameter!
buildFolderName="./build"
auditTrailCsvFilename="$buildFolderName/setup_audit_trail.csv"

mkdir -p $buildFolderName

sfdx data query --target-org $targetOrg \
  --query "SELECT Id,Action,Section,CreatedDate,CreatedBy.Name,Display FROM SetupAuditTrail ORDER BY CreatedDate DESC" \
  --resultformat csv > "$auditTrailCsvFilename"
