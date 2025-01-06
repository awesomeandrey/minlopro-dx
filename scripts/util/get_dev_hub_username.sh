#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/get_dev_hub_username.sh
# - varName=$(bash ./scripts/util/get_dev_hub_username.sh)

devHubAlias=$(bash ./scripts/util/get_dev_hub_alias.sh)
devHubUsername=$(sf org display user --json --target-org="$devHubAlias" | jq -r '.result.username')
echo "$devHubUsername"
