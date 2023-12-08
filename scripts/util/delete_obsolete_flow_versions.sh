#!/bin/bash

# How to use:
# - bash ./scripts/util/delete_obsolete_flow_versions.sh

# Capture target org alias;
echo "🔶 Enter target org alias:"
read TARGET_ORG_ALIAS

echo "🔵 Purging obsolete Flow Versions from [$TARGET_ORG_ALIAS] organization..."

# Define constants;
buildFolderName="build"
csvFileName="$buildFolderName/flow_version_IDs_to_delete.csv"

mkdir -p $buildFolderName

sf data query \
  --query "SELECT Id FROM Flow WHERE Status = 'Obsolete'" \
  --target-org $TARGET_ORG_ALIAS \
  --use-tooling-api \
  --result-format csv > "$csvFileName"

if ! grep -q Id "$csvFileName"; then
  echo 'No obsolete flow versions to delete.'
  rm $csvFileName
  exit 0
fi

while read c; do
  if [[ "$c" != "Id" && "$c" != "Your query returned no results." ]]; then
    sf data delete record \
      --sobject Flow \
      --record-id $c \
      --target-org $TARGET_ORG_ALIAS \
      --use-tooling-api
  fi
done < "$csvFileName"

rm $csvFileName
