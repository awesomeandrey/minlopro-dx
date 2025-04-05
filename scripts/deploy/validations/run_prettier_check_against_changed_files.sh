#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/validations/run_prettier_check_against_changed_files.sh
# - echo "develop" | bash ./scripts/deploy/validations/run_prettier_check_against_changed_files.sh

# Define constants;
buildFolderName="build"
srcFolderName="src"
copiedSrcFolderPath="$buildFolderName/$srcFolderName"
srcFilePrefix="$srcFolderName/"

# Capture target org alias;
read -r -p "🔶 Enter target branch name to compare changes against: " baseRef

# Delete 'build' folder if it exists;
if [ -d "$buildFolderName" ]; then
  rm -rf "$buildFolderName"
fi

echo "🔵 Running prettier checks against baseRef [$baseRef]..."
echo

# Create 'build' folder;
mkdir -p "$buildFolderName"
# Create 'build/src' folder;
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

echo "📜 BUILD FOLDER TREE"
tree "$buildFolderName"

if [ -z "$(ls $copiedSrcFolderPath)" ]; then
  echo "⚪ No changed files detected in [$copiedSrcFolderPath] folder!"
  exit 0
fi

# Invoke prettier (directly specifying '.prettierignore' file);
npx prettier --check "$copiedSrcFolderPath/**" --ignore-path ".prettierignore"
