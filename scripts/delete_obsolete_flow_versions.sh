#!/bin/bash

# Define constants;
targetOrg=$1 #Mandatory parameter!
buildFolderName="./build"
csvFileName="$buildFolderName/flow_version_IDs_to_delete.csv"

mkdir -p $buildFolderName

echo "Querying obsolete flow versions..."
sfdx data query \
  --query "SELECT Id FROM Flow WHERE Status = 'Obsolete'" \
  --target-org $1 \
  -t \
  --result-format csv >"$csvFileName"

if ! grep -q Id "$csvFileName"; then
  echo 'No obsolete flow versions to delete.'
  rm $csvFileName
  exit 0
fi

echo "Deleting obsolete flow versions..."

while read c; do
  if [[ "$c" != "Id" && "$c" != "Your query returned no results." ]]; then
    sfdx data delete record --sobject Flow --record-id $c --target-org $1 -t
  fi
done <"$csvFileName"

rm $csvFileName
