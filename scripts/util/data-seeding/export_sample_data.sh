#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/data-seeding/export_sample_data.sh

# Capture target org alias;
read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

mkdir -p "build"
echo "🔵 Exporting sample data from [$TARGET_ORG_ALIAS]..."

# Export Accounts, Contacts and Opportunities;
sf data export tree \
    --target-org "$TARGET_ORG_ALIAS" \
    --query "config/data/soql-queries/Account-Contact-Opportunity.soql" \
    --plan \
    --prefix "export" \
    --output-dir "build"

# Export Currency Types;
sf data export tree \
    --target-org "$TARGET_ORG_ALIAS" \
    --query "SELECT Id, IsoCode, ConversionRate, DecimalPlaces, IsActive, IsCorporate FROM CurrencyType" \
    --prefix "export" \
    --output-dir "build"

# Export Leads;
sf data export tree \
    --target-org "$TARGET_ORG_ALIAS" \
    --query "config/data/soql-queries/Lead.soql" \
    --prefix "export" \
    --output-dir "build"

# Export Knowledge Articles with Data Category Selections;
sf data export tree \
    --target-org "$TARGET_ORG_ALIAS" \
    --query "config/data/soql-queries/Knowledge__kav-Knowledge__DataCategorySelection.soql" \
    --plan \
    --prefix "export" \
    --output-dir "build"
