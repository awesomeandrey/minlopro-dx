#!/bin/bash

# How to use:
# - bash ./scripts/deploy/post/custom/display_records_count.sh

# Capture target org alias;
read -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

echo "🔵 Displaying Records Count from [$TARGET_ORG_ALIAS] organization..."

# Display record counts;
sf org list sobject record-counts \
  --target-org "$TARGET_ORG_ALIAS" \
  --sobject Account \
  --sobject Contact \
  --sobject Lead \
  --sobject Opportunity \
  --sobject CurrencyType \
  --sobject EmailTemplate \
  --sobject Task \
  --sobject LogEntry__c
