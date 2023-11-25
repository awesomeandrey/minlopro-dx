#!/bin/bash

# How to use:
# - bash ./scripts/util/get_target_dev_hub_alias.sh
# - varName=$(bash ./scripts/util/get_target_dev_hub_alias.sh)

targetDevHubAlias=$(sf config get target-dev-hub --json | jq -r '.result[0].value')
echo $targetDevHubAlias
