#!/bin/bash

# Define constants;
targetOrg=$1 #Mandatory parameter!
buildFolderName="./build"
apexLogsCsvFilePath="$buildFolderName/apex_logs.csv"

mkdir -p $buildFolderName

sfdx data query \
  --target-org $targetOrg \
  -q "SELECT Id FROM ApexLog" \
  -r "csv" > "$apexLogsCsvFilePath"

if ! [ -s $apexLogsCsvFilePath ]; then
  printf "\n<----- No Apex Logs found in [$apexLogsCsvFilePath] file! ----->\n"
  exit 0
fi

sfdx force:data:bulk:delete \
  --target-org $targetOrg \
  -s ApexLog \
  -f $apexLogsCsvFilePath

rm $apexLogsCsvFilePath
