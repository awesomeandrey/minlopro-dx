#!/bin/bash

# How to use:
# - bash ./scripts/deploy/run_prettier_check_against_changed_files.sh TARGET_BRANCH_NAME

# Define constants;
baseRef=$1 #Mandatory parameter!
buildFolderName="./build"
srcFolderName="src"
srcFolderPath="$buildFolderName/$srcFolderName"
srcFilePrefix="$srcFolderName/"
changedFiles="changedFiles.txt"
changedFilesPath="$buildFolderName/$changedFiles"

printf "\nbaseRef is [$baseRef]\n"

# Create 'build' folder;
mkdir -p "$buildFolderName"
# Create 'build/src' folder;
mkdir -p "$srcFolderPath"

# Grab HEAD commit SHA from source branch;
BASE=$(git merge-base $baseRef HEAD)

printf "\nBASE commit in [$baseRef] is [$BASE]\n"

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

if ! [ "$(ls $srcFolderPath)" ]; then
  printf "\nNo changed files detected in [$srcFolderPath] folder!\n"
  exit 0
fi

# Invoke prettier;
printf "\n prettier version is $(./node_modules/.bin/prettier --version)\n"
printf "\n pwd is $(pwd)\n"
./node_modules/.bin/prettier --check "$srcFolderPath/**/*.{cmp,cls,component,css,html,js,json,md,page,trigger,yaml,yml}"
# Capture the exit code
prettier_exit_code=$?
if [ $prettier_exit_code -eq 2 ]; then
  echo "Override Prettier exit code!"
  exit 0
else
  exit $prettier_exit_code
fi
