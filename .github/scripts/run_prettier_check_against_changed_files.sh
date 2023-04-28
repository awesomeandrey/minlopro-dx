#!/bin/bash

# Define constants;
baseRef=$1 #Mandatory parameter!
buildFolderName="./build"
srcFolderName="src"
srcFolderPath="$buildFolderName/$srcFolderName"
srcFilePrefix="$srcFolderName/"
changedFiles="changedFiles.txt"
changedFilesPath="$buildFolderName/$changedFiles"

echo "baseRef is $baseRef"

# Create 'build' folder;
mkdir -p "$buildFolderName"
# Create 'build/src' folder;
mkdir -p "$srcFolderPath"

# Grab HEAD commit SHA from source branch;
BASE=$(git merge-base $baseRef HEAD)

echo "BASE is $BASE"

# Extract changed files and save those names into the text file;
touch "$changedFilesPath"
git diff --name-only $BASE HEAD > "$changedFilesPath"

# Quick overview of changed files;
echo "<<< CHANGED FILES >>>"
cat "$changedFilesPath"

# Copy each changed file into a separate folder preserving folders hierarchy;
grep "$srcFilePrefix" "$changedFilesPath" | while read -r filepath; do
  if [ -f $filepath ]; then
    rsync -R "$filepath" "$buildFolderName"
  fi
done

echo "<<< SRC FOLDER TREE >>>"
tree $buildFolderName

# Invoke prettier;
npm install -g prettier
echo "prettier version is $(prettier --version)"
echo "pwd is $(pwd)"
prettier --check "$srcFolderPath/**/*.{cmp,component,css,html,js,json,md,page,trigger,yaml,yml}"
