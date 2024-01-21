#!/bin/bash

# How to use:
# - bash ./scripts/util/import_sample_data.sh
# - echo $ORG_ALIAS | bash ./scripts/util/import_sample_data.sh

# Capture target org alias;
read -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

echo "🔵 Importing sample data into [$TARGET_ORG_ALIAS] organization..."
echo

# Import Accounts and Contacts
sf data import tree \
  --target-org "$TARGET_ORG_ALIAS" \
  --plan "config/data/sample-Account-Contact-plan.json"

# Import CurrencyTypes
 sf data import tree \
  --target-org "$TARGET_ORG_ALIAS" \
  --files "config/data/sample-CurrencyTypes.json"
