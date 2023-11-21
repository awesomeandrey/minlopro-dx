#!/bin/bash

# How to use:
# - bash ./scripts/deploy/run_prettier_check_against_changed_files.sh TARGET_BRANCH_NAME

# Define constants;
baseRef=$1 #Mandatory parameter!
buildFolderName="./build"
srcFolderName="src"
copiedSrcFolderPath="$buildFolderName/$srcFolderName"
srcFilePrefix="$srcFolderName/"
changedFiles="changedFiles.txt"
changedFilesPath="$buildFolderName/$changedFiles"

printf "baseRef is [$baseRef]\n"

# Create 'build' folder;
mkdir -p "$buildFolderName"
# Create 'build/src' folder;
mkdir -p "$copiedSrcFolderPath"

# Grab HEAD commit SHA from source branch;
BASE=$(git merge-base $baseRef HEAD)

printf "BASE commit in [$baseRef] is [$BASE]\n"

# Extract changed files and save those names into the text file;
touch "$changedFilesPath"
git diff --name-only $BASE HEAD > "$changedFilesPath"

# Quick overview of changed files;
printf "\n---CHANGED FILES---\n"
cat "$changedFilesPath"

# Copy each SRC-changed file into a separate folder preserving folders hierarchy;
grep "$srcFilePrefix" "$changedFilesPath" | while read -r filepath; do
  if [ -f $filepath ]; then
    rsync -R "$filepath" "$buildFolderName"
  fi
done

printf "\n---BUILD FOLDER TREE---\n"
rm $changedFilesPath
tree $buildFolderName

if ! [ "$(ls $copiedSrcFolderPath)" ]; then
  printf "No changed files detected in [$copiedSrcFolderPath] folder!\n"
  exit 0
fi

# Invoke prettier;
printf "prettier version = $(prettier --version)\n"
printf "which prettier = $(which prettier)\n"
printf "pwd = $(pwd)\n"
prettier --check "$copiedSrcFolderPath/**"

# Capture the exit code
prettier_exit_code=$?
if [ $prettier_exit_code -eq 2 ]; then
  echo "Override Prettier exit code!"
  exit 0
else
  exit $prettier_exit_code
fi
