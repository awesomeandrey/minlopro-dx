#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/get_messaging_service_channel_id.sh
# - varName=$(bash ./scripts/util/get_messaging_service_channel_id.sh)

# Capture target org alias;
read -r -p "🔶 Enter target org alias: " targetOrgAlias

messagingServiceChannelId=$(
  sf data query \
    --query "SELECT Id, DeveloperName, MasterLabel FROM ServiceChannel WHERE DeveloperName = 'sfdc_livemessage' LIMIT 1" \
    --target-org "$targetOrgAlias" \
    --json | jq -r '.result.records[0].Id'
)
echo "$messagingServiceChannelId"
