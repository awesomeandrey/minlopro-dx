#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/data-seeding/import_sample_data.sh

# Capture target org alias;
read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

echo "🔵 Importing sample data into [$TARGET_ORG_ALIAS] organization..."
echo

import_sample_records() {
  # Import Accounts, Contacts & Opportunities (by plan)
  sf data import tree \
    --target-org "$TARGET_ORG_ALIAS" \
    --plan "config/data/samples/plan-Account-Contact-Opportunity.json"

  # Import Currency Types (by file)
  sf data import tree \
    --target-org "$TARGET_ORG_ALIAS" \
    --files "config/data/samples/sample-CurrencyTypes.json"

  # Import Leads (by file)
  sf data import tree \
    --target-org "$TARGET_ORG_ALIAS" \
    --files "config/data/samples/sample-Leads.json"
}

import_duplicate_person_accounts() {
  # Import PersonAccounts (by CSV file)
  personAccountRecordTypeIdQuery="SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = TRUE AND DeveloperName = 'Customer' LIMIT 1"
  personAccountRecordTypeId=$(sf data query --query "$personAccountRecordTypeIdQuery" --target-org "$TARGET_ORG_ALIAS" --json | jq -r '.result.records[0].Id')
  if [ -z "$personAccountRecordTypeId" ] || [ "$personAccountRecordTypeId" = "null" ]; then
    echo "PersonAccount (PA) record type was not found. Skipping PAs load."
    return 0
  fi
  echo "Importing PersonAccounts with Record Type ID: $personAccountRecordTypeId"

  mkdir -p "build"
  personAccountsCsv="config/data/csv/Duplicate-PersonAccounts.csv"
  personAccountsCsvCopy="build/$(basename "$personAccountsCsv")"
  cp "$personAccountsCsv" "$personAccountsCsvCopy"

  # Replace 'PERSON_ACCOUNT_RT_ID' keyword with ID;
  csvContent=$(<"$personAccountsCsvCopy")
  echo "${csvContent//PERSON_ACCOUNT_RT_ID/$personAccountRecordTypeId}" > "$personAccountsCsvCopy"

  sf data import bulk \
    --target-org "$TARGET_ORG_ALIAS" \
    --file "$personAccountsCsvCopy" \
    --sobject "Account"
}

select_skill_id_by_name() {
  local developerName="$1"
  sf data query \
    --query "SELECT Id FROM Skill WHERE DeveloperName = '$developerName' LIMIT 1" \
    --target-org "$TARGET_ORG_ALIAS" \
    --json | jq -r '.result.records[0].Id'
}

import_service_resources() {
  # Resolve Admin user ID
  adminUserId=$(sf org display user --target-org "$TARGET_ORG_ALIAS" --json | jq -r '.result.id')
  if [ -z "$adminUserId" ] || [ "$adminUserId" = "null" ]; then
    echo "Admin user ID could not be resolved. Skipping service resources load."
    return 0
  fi
  # Resolve Skill IDs
  englishSkillId=$(select_skill_id_by_name "English")
  if [ -z "$englishSkillId" ] || [ "$englishSkillId" = "null" ]; then
    echo "English Skill record was not found. Skipping service resources load."
    return 0
  fi
  ukrainianSkillId=$(select_skill_id_by_name "Ukrainian")
  if [ -z "$ukrainianSkillId" ] || [ "$ukrainianSkillId" = "null" ]; then
    echo "Ukrainian Skill record was not found. Skipping service resources load."
    return 0
  fi

  echo "Importing ServiceResource for $adminUserId user (with $englishSkillId and $ukrainianSkillId skills)"
  mkdir -p "build"

  # Copy & patch ServiceResource file
  serviceResourceJson="config/data/samples/sample-ServiceResource.json"
  serviceResourceJsonCopy="build/$(basename "$serviceResourceJson")"
  cp "$serviceResourceJson" "$serviceResourceJsonCopy"
  content=$(<"$serviceResourceJsonCopy")
  echo "${content//ADMIN_USER_ID/$adminUserId}" > "$serviceResourceJsonCopy"

  # Copy & patch ServiceResourceSkill file
  serviceResourceSkillJson="config/data/samples/sample-ServiceResourceSkill.json"
  serviceResourceSkillJsonCopy="build/$(basename "$serviceResourceSkillJson")"
  cp "$serviceResourceSkillJson" "$serviceResourceSkillJsonCopy"
  content=$(<"$serviceResourceSkillJsonCopy")
  content="${content//ENGLISH_SKILL_ID/$englishSkillId}"
  echo "${content//UKRAINIAN_SKILL_ID/$ukrainianSkillId}" > "$serviceResourceSkillJsonCopy"

  # Copy plan to build/ so relative file references resolve correctly
  planJson="config/data/samples/plan-ServiceResource-ServiceResourceSkill.json"
  planJsonCopy="build/$(basename "$planJson")"
  cp "$planJson" "$planJsonCopy"

  sf data import tree \
    --target-org "$TARGET_ORG_ALIAS" \
    --plan "$planJsonCopy"
}

import_sample_records
import_duplicate_person_accounts
import_service_resources
