#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/common/build.sh

set -e
echo "🔵 Building environment and installing dependencies..."
echo
mkdir -p "build"

# Install Salesforce CLI (v2)
sfCliVersion="2.100"
sfCliPackageName="@salesforce/cli"
if ! npm ls -g "$sfCliPackageName" &> /dev/null; then
  echo "Installing [$sfCliPackageName@${sfCliVersion}] globally."
  npm install @salesforce/cli@${sfCliVersion} --global
  # Run `npm update @salesforce/cli --global` to update CLI locally
fi
echo "Salesforce CLI: $(sf --version)"

# Install Salesforce CLI Plugins
installedPluginNames=$(sf plugins --json | jq 'map(.name)')
install_sf_plugin() {
  local name="$1"
  if echo "$installedPluginNames" | grep -q "$name"; then
    echo "[$name] plugin is already installed."
  else
    echo y | sf plugins install "$name" > /dev/null
  fi
}

echo "Installing Salesforce CLI Plugins..."
# https://github.com/scolladon/sfdx-git-delta
install_sf_plugin "sfdx-git-delta"
# https://sfdx-hardis.cloudity.com
install_sf_plugin "sfdx-hardis"
# https://help.sfdmu.com/get-started
install_sf_plugin "sfdmu"
# https://developer.salesforce.com/docs/atlas.en-us.bi_dev_guide_cli_reference.meta/bi_dev_guide_cli_reference/bi_cli_reference.htm
install_sf_plugin "@salesforce/analytics"
# https://developer.salesforce.com/docs/platform/lwc/guide/get-started-test-components.html
install_sf_plugin "@salesforce/plugin-lightning-dev"

# Install the rest of dependencies via NPM
npm ci --silent; echo
echo "NPM global packages: $(npm list -g)"
echo "NPM local packages: $(npm list)"

# Install Ubuntu OS utility tools (`xmllint`, `xmlstarlet` and others)
if [[ -f /etc/os-release ]] && grep -qi "ubuntu" /etc/os-release; then
    echo "Detected Ubuntu OS. Installing utility tools..."
    sudo apt-get update > /dev/null
    sudo apt-get install -y xmlstarlet libxml2-utils > /dev/null
fi

# Verify tools installation/presence
{
  echo; echo "===== CLI Tools ====="
  echo "xmlstarlet = $(xmlstarlet --version)"
  echo "xmllint = $(xmllint --version)"
  echo "node = $(node --version)"
  echo "npm = $(npm --version)"
  echo "java = $(java --version)"
  echo "npx prettier = $(npx prettier --version)"
  echo "rsync = $(rsync --version)"
} 2> /dev/null

# Create '.env' file based on template
envFile=".env"
if ! [ -f "$envFile" ]; then
  cp -f "scripts/.env.manifest" "$envFile"
fi
