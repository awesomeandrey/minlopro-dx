#!/bin/bash

# How to use:
# - bash ./scripts/util/get_dev_hub_alias.sh
# - varName=$(bash ./scripts/util/get_dev_hub_alias.sh)

devHubAlias=$(sf config get target-dev-hub --json | jq -r '.result[0].value')
echo "$devHubAlias"
