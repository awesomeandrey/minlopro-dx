#!/bin/bash

# Sample Execution:
# bash ./scripts/sgd_generate_manifests.sh "SOURCE_BRANCH_NAME" "CURRENT_BRANCH_NAME"

# Define constants;
fromRef=$1 #Mandatory parameter!
toRef=$2   #Mandatory parameter!
sgdFolder="manifests/sgd"
packageXml="$sgdFolder/package/package.xml"
destructiveChangesXml="$sgdFolder/destructiveChanges/destructiveChanges.xml"

# Create SGD folder;
mkdir -p "$sgdFolder"

# Invoke SGD plugin and generate manifests;
printf "\nGenerating XML manifests from [$fromRef] to [$toRef]\n"
npm run sfdx:manifest:delta -- --from "$fromRef" --to "$toRef"

# Output results;
tree "$sgdFolder"
printf "\n<----- PACKAGE.XML ----->\n" && cat "$packageXml"
printf "\n<----- DESTRUCTIVE_CHANGES.XML ----->\n" && cat "$destructiveChangesXml"
