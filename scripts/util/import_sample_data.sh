#!/bin/bash

# How to use:
# - bash ./scripts/util/import_sample_data.sh
# - echo $ORG_ALIAS | bash ./scripts/util/import_sample_data.sh

# Capture target org alias;
printf "🔶 Enter target org alias:\n"
read TARGET_ORG_ALIAS

echo "🔵 Importing sample data into [$TARGET_ORG_ALIAS] organization..."

sf data import tree \
  --target-org $TARGET_ORG_ALIAS \
  --plan "config/data/sample-Account-Contact-plan.json"
