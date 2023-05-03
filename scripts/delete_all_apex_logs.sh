#!/bin/bash

# Define constants;
targetOrg=$1 #Mandatory parameter!
buildFolderName="./build"
apexLogsCsvFilename="$buildFolderName/apex_logs.csv"

mkdir -p $buildFolderName

sfdx data query \
  --target-org $targetOrg \
  -q "SELECT Id FROM ApexLog" \
  -r "csv" > "$apexLogsCsvFilename"

sfdx force:data:bulk:delete \
  --target-org $targetOrg \
  -s ApexLog \
  -f $apexLogsCsvFilename

rm $apexLogsCsvFilename
