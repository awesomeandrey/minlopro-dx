#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/post/custom/delete_apex_logs.sh

# Capture target org alias;
read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

echo "🔵 Purging Apex Logs from [$TARGET_ORG_ALIAS] organization..."

# Define constants;
buildFolderName="build"
apexLogsCsvFilePath="$buildFolderName/apex_logs_to_delete.csv"

mkdir -p $buildFolderName

sf data query \
  --target-org "$TARGET_ORG_ALIAS" \
  --query "SELECT Id FROM ApexLog WHERE LastModifiedDate < LAST_N_DAYS:7" \
  --result-format "csv" > "$apexLogsCsvFilePath"

# Check if there are logs fetched;
wordsCount=$(wc -w < $apexLogsCsvFilePath)
if (("$wordsCount" < 10)); then
  echo 'There are not so many Apex Logs to delete so far.'
  echo
  rm $apexLogsCsvFilePath
  exit 0
fi

sf data delete bulk \
  --target-org "$TARGET_ORG_ALIAS" \
  --sobject "ApexLog" \
  --file "$apexLogsCsvFilePath" \
  --wait 10

rm $apexLogsCsvFilePath
