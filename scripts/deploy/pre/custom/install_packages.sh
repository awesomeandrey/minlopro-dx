#!/bin/bash

# How to use:
# - bash ./scripts/deploy/pre/custom/install_packages.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/pre/custom/install_packages.sh

# Enable errexit option to exit on command failure
set -e

# Capture target org alias
read -p "🔶 Enter target org alias to install packages in: " TARGET_ORG_ALIAS
echo "🔵 Installing packages in [$TARGET_ORG_ALIAS] organization..."

# Capture connected DevHub username
DEV_HUB_ALIAS=$(bash ./scripts/util/get_dev_hub_username.sh)

# Check if DevHub is connected
if [ -z "${DEV_HUB_ALIAS+x}" ] || [ -z "$DEV_HUB_ALIAS" ] || [ "$DEV_HUB_ALIAS" = "null" ]; then
  npx cowsay -W 100 "DevHub org connection is undefined; skipping packages installation"
  exit 0
fi

echo "DevHub Username = [$DEV_HUB_ALIAS]"

# Fetch packages info
echo "Fetching installed packages from the DevHub org..."
installedPackagesAsJson=$(sf package installed list --target-org "$DEV_HUB_ALIAS" --json)
echo "$installedPackagesAsJson"

# Install package one-by-one
echo "$installedPackagesAsJson" | jq -c '.result[]' | while read -r packageInfo; do
  packageName=$(echo "$packageInfo" | jq -r '.SubscriberPackageName')
  packageNamespace=$(echo "$packageInfo" | jq -r '.SubscriberPackageNamespace')
  packageVersionId=$(echo "$packageInfo" | jq -r '.SubscriberPackageVersionId')
  packageVersionName=$(echo "$packageInfo" | jq -r '.SubscriberPackageVersionName')
  echo "🆔 Installing '$packageName' ($packageVersionName) [$packageNamespace]..."
  sf package install \
      --package "$packageVersionId" \
      --target-org "$TARGET_ORG_ALIAS" \
      --wait 15 \
      --no-prompt
done
