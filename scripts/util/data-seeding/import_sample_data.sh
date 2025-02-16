#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/data-seeding/import_sample_data.sh
# - echo $ORG_ALIAS | bash ./scripts/util/data-seeding/import_sample_data.sh

# Capture target org alias;
read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

echo "🔵 Importing sample data into [$TARGET_ORG_ALIAS] organization..."
echo

# Import Accounts, Contacts & Opportunities (by plan);
sf data import tree \
  --target-org "$TARGET_ORG_ALIAS" \
  --plan "config/data/samples/plan-Account-Contact-Opportunity.json"

# Import Currency Types (by file);
sf data import tree \
  --target-org "$TARGET_ORG_ALIAS" \
  --files "config/data/samples/sample-CurrencyTypes.json"

# Import Leads (by file);
sf data import tree \
  --target-org "$TARGET_ORG_ALIAS" \
  --files "config/data/samples/sample-Leads.json"

# Import PersonAccounts (by CSV file);
personAccountRecordTypeIdQuery="SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = TRUE AND DeveloperName = 'Customer' LIMIT 1"
personAccountRecordTypeId=$(sf data query --query "$personAccountRecordTypeIdQuery" --target-org "$TARGET_ORG_ALIAS" --json | jq -r '.result.records[0].Id')
echo "Importing PersonAccounts with Record Type ID: $personAccountRecordTypeId"

mkdir -p "build"
personAccountsCsv="config/data/csv/Duplicate-PersonAccounts.csv"
personAccountsCsvCopy="build/$(basename "$personAccountsCsv")"
cp "$personAccountsCsv" "$personAccountsCsvCopy"

csvContent=$(<"$personAccountsCsvCopy") # Replace 'PERSON_ACCOUNT_RT_ID' keyword with ID;
echo "${csvContent//PERSON_ACCOUNT_RT_ID/$personAccountRecordTypeId}" > "$personAccountsCsvCopy"

sf data import bulk \
  --target-org "$TARGET_ORG_ALIAS" \
  --file "$personAccountsCsvCopy" \
  --sobject "Account" \
