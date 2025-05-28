#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/validations/copy_changed_files.sh "develop"
# - bash ./scripts/deploy/validations/copy_changed_files.sh "aaa0c1b76dd923d4f276b2f7b386ff4769487fa5"

set -e

baseRef="$1"
if [ -z "$baseRef" ]; then
  echo "🔴 Base ref is mandatory! Usage: $0 'BRANCH_NAME|COMMIT_SHA'"
  exit 1
fi

buildFolderName="build"
srcFolderName="src"
copiedSrcFolderPath="$buildFolderName/$srcFolderName"
srcFilePrefix="$srcFolderName/"

if [ -d "$buildFolderName" ]; then
  rm -rf "$buildFolderName"
fi

mkdir -p "$buildFolderName"
mkdir -p "$copiedSrcFolderPath"

# Grab HEAD commit SHA from source branch;
BASE=$(git merge-base "$baseRef" HEAD)
echo "BASE commit in [$baseRef] is [$BASE]"

# Identify changed files within 'src' directory;
git diff --name-only "$BASE" HEAD | grep "^$srcFilePrefix" | while read -r filepath; do
  if [ -f "$filepath" ]; then
    # Copy each SRC-changed file into a separate folder preserving folders hierarchy;
    rsync -R "$filepath" "$buildFolderName"
  fi
done

echo "📜 CHANGED FILES TREE"
tree "$buildFolderName"
