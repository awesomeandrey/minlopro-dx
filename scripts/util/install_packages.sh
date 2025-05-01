#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/install_packages.sh

read -r -p "🔶 Enter source org alias to read installed packaged from: " SOURCE_ORG_ALIAS
read -r -p "🔶 Enter target org alias to install packages in: " TARGET_ORG_ALIAS

echo "🔵 Fetching installed packages from [$SOURCE_ORG_ALIAS] org and installing them in [$TARGET_ORG_ALIAS] org..."

installedPackagesAsJson=$(sf package installed list --target-org "$SOURCE_ORG_ALIAS" --json)
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
      --wait 10 \
      --no-prompt
done
