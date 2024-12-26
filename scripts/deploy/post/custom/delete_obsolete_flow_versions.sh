#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/post/custom/delete_obsolete_flow_versions.sh

# Note: there can be a dependency on existing flow interviews. They can be deleted manually from Salesforce UI (see App Launcher > Paused Flows).

# Capture target org alias;
read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

echo "🔵 Purging obsolete Flow Versions from [$TARGET_ORG_ALIAS] organization..."

# Define constants;
buildFolderName="build"
csvFileName="$buildFolderName/flow_version_IDs_to_delete.csv"

mkdir -p "$buildFolderName"
rm -f "$csvFileName"

sf data query \
  --query "SELECT Id FROM Flow WHERE Status = 'Obsolete'" \
  --target-org "$TARGET_ORG_ALIAS" \
  --use-tooling-api \
  --result-format csv > "$csvFileName"

if ! grep -q Id "$csvFileName"; then
  echo 'No obsolete flow versions to delete.'
  echo
  rm "$csvFileName"
  exit 0
fi

while read -r c; do
  if [[ "$c" != "Id" && "$c" != "Your query returned no results." ]]; then
    sf data delete record \
      --sobject "Flow" \
      --record-id "$c" \
      --target-org "$TARGET_ORG_ALIAS" \
      --use-tooling-api
  fi
done < "$csvFileName"
