#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/data-seeding/delete_all_object_records.sh
# - bash ./scripts/util/data-seeding/delete_all_object_records.sh "$TARGET_ORG_ALIAS" "OBJECT_API_NAME"

# Enable errexit option to exit on command failure
set -e

TARGET_ORG_ALIAS=$1
OBJECT_API_NAME=$2

if [ -z "$TARGET_ORG_ALIAS" ] || [ -z "$OBJECT_API_NAME" ]; then
  read -r -p "🔶 Enter Org Alias: " TARGET_ORG_ALIAS
  read -r -p "🔶 Enter Object API Name: " OBJECT_API_NAME
fi

echo "🔵 Deleting all [$OBJECT_API_NAME] records in [$TARGET_ORG_ALIAS] org..."

mkdir -p "build"
recordsToDeleteCsv="build/${TARGET_ORG_ALIAS}-${OBJECT_API_NAME}.csv"

# Bulk export DRSs records
sf data export bulk \
  --target-org "$TARGET_ORG_ALIAS" \
  --query "SELECT Id FROM $OBJECT_API_NAME LIMIT 10000" \
  --output-file "$recordsToDeleteCsv" \
  --result-format "csv" \
  --wait 10

if [[ $(wc -w < "$recordsToDeleteCsv") -lt 5 ]]; then
    echo "No data to delete."
    exit 0
fi

# Bulk delete DRSs records
sf data delete bulk \
  --target-org "$TARGET_ORG_ALIAS" \
  --sobject "$OBJECT_API_NAME" \
  --file "$recordsToDeleteCsv" \
  --wait 10 \
  