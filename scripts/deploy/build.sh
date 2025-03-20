#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/build.sh

set -e
echo "🔵 Building environment and installing dependencies..."
echo
mkdir -p "build"

# Install Salesforce CLI (v2)
sfCliPackageName="@salesforce/cli"
if npm ls -g "$sfCliPackageName" &>/dev/null; then
  echo "Updating [$sfCliPackageName] globally."
  npm update @salesforce/cli --global
else
  echo "Installing [$sfCliPackageName] globally."
  npm install @salesforce/cli --global
fi
sf --version

# Install core Salesforce CLI plugins
echo 'Installing SF CLI plugins...'
# https://github.com/scolladon/sfdx-git-delta
echo y | sf plugins install "sfdx-git-delta@latest"
# https://sfdx-hardis.cloudity.com
echo y | sf plugins install "sfdx-hardis@latest"
# https://help.sfdmu.com/get-started
echo y | sf plugins install "sfdmu@latest"
# https://forcedotcom.github.io/sfdx-scanner/en/v3.x/scanner-commands/run/
echo y | sf plugins install "@salesforce/sfdx-scanner"
# https://developer.salesforce.com/docs/atlas.en-us.bi_dev_guide_cli_reference.meta/bi_dev_guide_cli_reference/bi_cli_reference.htm
echo y | sf plugins install "@salesforce/analytics"
sf plugins

# Install the rest of dependencies via NPM
npm install
npm list

# Install Ubuntu OS utility tools (`xmllint`, `xmlstarlet` and others)
if [[ -f /etc/os-release ]] && grep -qi "ubuntu" /etc/os-release; then
    echo "Detected Ubuntu OS. Installing utility tools..."
    sudo apt-get update
    sudo apt-get install -y xmlstarlet
    sudo apt-get install -y libxml2-utils
fi

# Verify tools installation/presence
{
  echo "xmlstarlet = $(xmlstarlet --version)"
  echo "xmllint = $(xmllint --version)"
  echo "node = $(node --version)"
  echo "npm = $(npm --version)"
  echo "java = $(java --version)"
  echo "prettier = $(prettier --version)"
  echo "rsync = $(rsync --version)"
} 2> /dev/null

# Create '.env' file based on template
envFile=".env"
if ! [ -f "$envFile" ]; then
  cp -f "scripts/.env.manifest" "$envFile"
fi
