#!/bin/bash

# How to use:
# - bash ./scripts/deploy/build.sh
# - bash ./scripts/deploy/build.sh -a

mkdir -p "build"

# Flag that forces installation of mandatory modules only
INSTALL_ALL_MODULES=false
while getopts "a" opt; do
  case $opt in
    a)
      # Set flag_a to true when -a is specified
      INSTALL_ALL_MODULES=true
      ;;
    \?)
      # Invalid option
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Install SF CLI (v2);
sfCliPackageName="@salesforce/cli"
if npm ls -g "$sfCliPackageName" &>/dev/null; then
  echo "$sfCliPackageName is already installed globally."
else
  echo "$sfCliPackageName is not installed globally."
  npm install @salesforce/cli --global
  echo 'Installed SF CLI! Hooray!'
fi
sf --version

# Install SF CLI plugins
echo 'Installing SF CLI plugins...'
# https://github.com/scolladon/sfdx-git-delta
echo y | sf plugins:install "sfdx-git-delta@stable"
if [ "$INSTALL_ALL_MODULES" = true ]; then
  # https://help.sfdmu.com/get-started
  echo y | sf plugins:install "sfdmu"
  # https://forcedotcom.github.io/sfdx-scanner/en/v3.x/scanner-commands/run/
  echo y | sf plugins:install "@salesforce/sfdx-scanner"
fi

# Install the rest of dependencies via NPM
npm install

echo "🔵Done!"
