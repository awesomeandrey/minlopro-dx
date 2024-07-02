#!/bin/bash

# How to use:
# - bash ./scripts/util/import_sample_data.sh
# - echo $ORG_ALIAS | bash ./scripts/util/import_sample_data.sh

# Capture target org alias;
read -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

echo "🔵 Importing sample data into [$TARGET_ORG_ALIAS] organization..."
echo

# Import Accounts, Contacts & Opportunities (by plan);
sf data import tree \
  --target-org "$TARGET_ORG_ALIAS" \
  --plan "config/data/plan-Account-Contact-Opportunity.json"

# Import Currency Types (by file);
sf data import tree \
  --target-org "$TARGET_ORG_ALIAS" \
  --files "config/data/sample-CurrencyTypes.json"

# Import Leads (by file);
sf data import tree \
  --target-org "$TARGET_ORG_ALIAS" \
  --files "config/data/sample-Leads.json"

# Display record counts;
sf org list sobject record-counts \
  --target-org "$TARGET_ORG_ALIAS" \
  --sobject Account \
  --sobject Contact \
  --sobject Lead \
  --sobject Opportunity \
  --sobject CurrencyType
