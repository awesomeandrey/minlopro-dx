#!/bin/bash

# Prerequisites:
#   Enable 'read/write' permission for GitHub workflows in Settings > Actions > General > Workflow Permissions.
# How to use:
# - bash ./scripts/automations/reset_and_commit_destructive_manifests.sh

# Enable errexit option to exit on command failure
set -e

# Reset XML files content
node scripts/util/js/reset_destructive_manifests.js

# Prettify XML files content
prettierExec="./node_modules/.bin/prettier"
"$prettierExec" --write "manifests/**"

# Define the files to track
file1="manifests/destructiveChangesPre.xml"
file2="manifests/destructiveChangesPost.xml"

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
    git commit -m "Automation: Reset Destructive Manifests"
    git push origin HEAD
else
    echo "No changes detected in destructive manifests."
fi
