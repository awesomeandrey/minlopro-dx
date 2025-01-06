#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/authorize_org_jwt.sh --orgAlias "ORG_ALIAS"
# - npx dotenv -e ".env" -- bash ./scripts/util/authorize_org_jwt.sh --orgAlias "ORG_ALIAS"

# Prerequisites:
# - configure env variable for Salesforce username parameter
# - configure env variable for Salesforce instance URL parameter (test VS prod)
# - configure env variable for Salesforce Client ID parameter (bound to Connected App)
# - configure env variable for Salesforce private key parameter (base64 encoded)

# Initialize variables
orgAlias=""

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --orgAlias) orgAlias="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if the parameter value was provided
if [ -z "$orgAlias" ]; then
    echo "Error: --orgAlias parameter value not provided."
    echo "Usage: $0 --orgAlias <value>"
    exit 1
fi

echo "🔵 Authorizing [$orgAlias] organization..."

privateKeyFile="build/private.key"
mkdir -p "build"
touch "$privateKeyFile"

echo "Decoding private key..."
echo "$SF_JWT_ENCODED_PRIVATE_KEY" | base64 --decode > "$privateKeyFile"

sf org login jwt \
  --username "$SF_USERNAME" \
  --jwt-key-file "$privateKeyFile" \
  --instance-url "https://test.salesforce.com" \
  --client-id "$SF_JWT_CLIENT_ID" \
  --alias "$orgAlias"
sf org list auth
