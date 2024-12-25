#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/data-seeding/import_sample_data.sh
# - echo $ORG_ALIAS | bash ./scripts/util/data-seeding/import_sample_data.sh

# Capture target org alias;
read -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

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
