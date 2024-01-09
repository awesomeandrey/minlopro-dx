#!/bin/bash

# How to use:
# - bash ./scripts/util/export_sample_data.sh
# - echo $ORG_ALIAS | bash ./scripts/util/export_sample_data.sh

# Capture target org alias;
read -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

mkdir -p "build"
echo "🔵 Exporting sample data from [$TARGET_ORG_ALIAS]..."
sf data export tree \
  --target-org $TARGET_ORG_ALIAS \
  --query "config/data/query.txt" \
  --plan \
  --prefix "export" \
  --output-dir "build"
