#!/bin/bash

# Define constants;
targetOrg=$1 #Mandatory parameter!
buildFolderName="./build"
apexLogsCsvFilePath="$buildFolderName/apex_logs.csv"

mkdir -p $buildFolderName

echo "Querying Apex Logs..."
sfdx data query \
  --target-org $targetOrg \
  -q "SELECT Id FROM ApexLog" \
  -r "csv" > "$apexLogsCsvFilePath"

# Check if there are logs fetched;
wordsCount=$(wc -w < $apexLogsCsvFilePath)
if (($wordsCount < 10)); then
  echo 'There are not so many Apex Logs to delete so far.'
  rm $apexLogsCsvFilePath
  exit 0
fi

sfdx force:data:bulk:delete \
  --target-org $targetOrg \
  -s ApexLog \
  -f $apexLogsCsvFilePath

rm $apexLogsCsvFilePath
