#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/authorize_org_jwt.sh [ 4 required params ]

set -e

# Required
sfUsername="$1"
sfClientId="$2"
sfInstanceUrl="$3"
sfPrivateKeyEncoded="$4"

# Optional
sfCustomOrgAlias="$5"

if [ -z "$sfUsername" ] || [ -z "$sfClientId" ] || [ -z "$sfInstanceUrl" ] || [ -z "$sfPrivateKeyEncoded" ]; then
    echo "Error: some parameters were not provided."
    echo "Usage: $0 [ 4 required params ]"
    exit 1
fi

echo "🔵 Authorizing Salesforce organization..."

privateKeyFile="build/private.key"
trap 'rm -rf $privateKeyFile' EXIT
mkdir -p "build" && touch "$privateKeyFile"

echo "Decoding private key..."
echo "$sfPrivateKeyEncoded" | base64 --decode > "$privateKeyFile"

sf org login jwt \
  --username "$sfUsername" \
  --client-id "$sfClientId" \
  --instance-url "$sfInstanceUrl" \
  --jwt-key-file "$privateKeyFile"

# Set alias;
if [ -n "$sfCustomOrgAlias" ]; then
  sf alias set "$sfCustomOrgAlias" "$sfUsername"
fi

sf org list auth
