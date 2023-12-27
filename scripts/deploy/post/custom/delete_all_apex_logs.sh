#!/bin/bash

# How to use:
# - bash ./scripts/deploy/post/custom/delete_all_apex_logs.sh

# Capture target org alias;
read -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

echo "🔵 Purging Apex Logs from [$TARGET_ORG_ALIAS] organization..."

# Define constants;
buildFolderName="build"
apexLogsCsvFilePath="$buildFolderName/apex_logs.csv"

mkdir -p $buildFolderName

sf data query \
  --target-org $TARGET_ORG_ALIAS \
  --query "SELECT Id FROM ApexLog" \
  --result-format "csv" > "$apexLogsCsvFilePath"

# Check if there are logs fetched;
wordsCount=$(wc -w < $apexLogsCsvFilePath)
if (($wordsCount < 10)); then
  echo 'There are not so many Apex Logs to delete so far.'
  rm $apexLogsCsvFilePath
  exit 0
fi

sf data delete bulk \
  --target-org $TARGET_ORG_ALIAS \
  --sobject ApexLog \
  --file $apexLogsCsvFilePath \
  --wait 10

rm $apexLogsCsvFilePath
