#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/get_project_api_version.sh
# - varName=$(bash ./scripts/util/get_project_api_version.sh)

FILE="sfdx-project.json"
apiVersion=$(jq -r '.sourceApiVersion' "$FILE")
echo "$apiVersion"
