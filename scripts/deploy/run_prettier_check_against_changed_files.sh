#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/run_prettier_check_against_changed_files.sh
# - echo "develop" | bash ./scripts/deploy/run_prettier_check_against_changed_files.sh

# Define constants;
buildFolderName="build"
srcFolderName="src"
copiedSrcFolderPath="$buildFolderName/$srcFolderName"
srcFilePrefix="$srcFolderName/"
changedFilesPath="$buildFolderName/changedFiles.txt"

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

# Extract changed files and save those names into the text file;
touch "$changedFilesPath"
git diff --name-only "$BASE" HEAD > "$changedFilesPath"

# Copy each SRC-changed file into a separate folder preserving folders hierarchy;
grep "$srcFilePrefix" "$changedFilesPath" | while read -r filepath; do
  if [ -f "$filepath" ]; then
    rsync -R "$filepath" "$buildFolderName"
  fi
done

echo "📜 BUILD FOLDER TREE"
rm "$changedFilesPath"
tree "$buildFolderName"

if ! [ "$(ls $copiedSrcFolderPath)" ]; then
  echo "⚪ No changed files detected in [$copiedSrcFolderPath] folder!"
  exit 0
fi

echo "node = $(node --version)"
echo "npm = $(npm --version)"
echo "java = $(java --version)"
echo "prettier = $(npx prettier --version)"

# Invoke prettier;
npx prettier --check "$copiedSrcFolderPath/**" --ignore-path "./.prettierignore"

# Capture the exit code
prettier_exit_code=$?
if [ $prettier_exit_code -eq 2 ]; then
  echo "⚪ Override Prettier exit code!"
  exit 0
else
  exit $prettier_exit_code
fi
