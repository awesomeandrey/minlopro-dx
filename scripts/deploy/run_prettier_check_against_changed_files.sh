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

# Delete 'build' folder if it exists;
if [ -d "$buildFolderName" ]; then
  rm -rf "$buildFolderName"
fi

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
prettierExec="./node_modules/.bin/prettier"
printf "prettier version = $("$prettierExec" --version)\n"
printf "which prettier = $(which "$prettierExec")\n"
printf "pwd = $(pwd)\n"
"$prettierExec" --check "$copiedSrcFolderPath/**"

# Capture the exit code
prettier_exit_code=$?
if [ $prettier_exit_code -eq 2 ]; then
  echo "Override Prettier exit code!"
  exit 0
else
  exit $prettier_exit_code
fi
