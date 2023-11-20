#!/bin/bash

# How to use:
# - bash ./scripts/deploy/build.sh

mkdir -p "build"

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
echo y | sf plugins:install "sfdx-git-delta@stable"

# Install the rest of dependencies via NPM
npm install
