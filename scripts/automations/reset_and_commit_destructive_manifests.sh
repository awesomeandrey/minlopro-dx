#!/bin/bash

# Prerequisites:
#   Enable 'read/write' permission for GitHub workflows in Settings > Actions > General > Workflow Permissions.
# How to use:
# - bash ./scripts/automations/reset_and_commit_destructive_manifests.sh

echo "🔵 Resetting destructive manifests..."

# Enable errexit option to exit on command failure
set -e

# Define constants
buildFolder="build"
manifestsFolder="manifests"
preDestructiveChangesXml="$manifestsFolder/destructiveChangesPre.xml"
postDestructiveChangesXml="$manifestsFolder/destructiveChangesPost.xml"
tempManifestXml="$buildFolder/tempManifest.xml"

# Reset XML files content via utility command
mkdir -p "$buildFolder"
touch "$tempManifestXml"
xmlstarlet ed -d "//*[local-name()='types']" "$preDestructiveChangesXml" > "$tempManifestXml" && mv "$tempManifestXml" "$preDestructiveChangesXml"
xmlstarlet ed -d "//*[local-name()='types']" "$postDestructiveChangesXml" > "$tempManifestXml" && mv "$tempManifestXml" "$postDestructiveChangesXml"

# Prettify XML files content
echo "prettier version = $(npx prettier --version)"
npx prettier --write "$manifestsFolder/**"

# Define the files to track
file1="$preDestructiveChangesXml"
file2="$postDestructiveChangesXml"

# Function to check if a file is modified
is_file_modified() {
    [[ $(git status --porcelain | grep "^ M $1$") ]] && return 0 || return 1
}

# Track changes in files
file1_modified=0
file2_modified=0

if is_file_modified "$file1"; then
    file1_modified=1
fi

if is_file_modified "$file2"; then
    file2_modified=1
fi

# If any file is modified, create a commit
if [[ $file1_modified -eq 1 || $file2_modified -eq 1 ]]; then
    git reset
    git add "$file1" "$file2"
    git status --porcelain
    git commit -m "Automation: Reset Destructive Manifests 🚗"
    git push origin HEAD
else
    echo "⚪ No changes detected in destructive manifests."
fi
