#!/bin/bash

# How to use:
# - bash ./scripts/util/delete_all_apex_logs.sh

# Capture target org alias;
printf "Enter target org alias:\n"
read TARGET_ORG_ALIAS

# Define constants;
buildFolderName="build"
apexLogsCsvFilePath="$buildFolderName/apex_logs.csv"

mkdir -p $buildFolderName

echo "Querying Apex Logs from [$TARGET_ORG_ALIAS]..."
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

echo "Deleting Apex Logs from [$TARGET_ORG_ALIAS]..."
sf data delete bulk \
  --target-org $TARGET_ORG_ALIAS \
  --sobject ApexLog \
  --file $apexLogsCsvFilePath \
  --wait 10

rm $apexLogsCsvFilePath
