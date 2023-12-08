#!/bin/bash

# How to use:
# - bash ./scripts/util/import_sample_data.sh
# - echo $ORG_ALIAS | bash ./scripts/util/import_sample_data.sh

# Capture target org alias;
echo "🔶 Enter target org alias:"
read TARGET_ORG_ALIAS

echo "🔵 Importing sample data into [$TARGET_ORG_ALIAS] organization..."

sf data import tree \
  --target-org $TARGET_ORG_ALIAS \
  --plan "config/data/sample-Account-Contact-plan.json"
