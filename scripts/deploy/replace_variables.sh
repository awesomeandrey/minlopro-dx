#!/bin/bash

# How to use:
# - bash ./scripts/deploy/replace_variables.sh

# Step 1 - Load all environment variables into '.env' file;
fileName=".env"
# Create or clear the file;
> $fileName
# Loop through all environment variables with "SF_" prefix;
printenv | grep '^SF_' | while read -r line; do
    # Write each matched variable to the file;
    echo "$line" >> $fileName
done
# Print extracted variables to console;
cat "$fileName"

# Step 2 - Install "replace-in-files-cli" utility package;
npm install --save-dev "replace-in-files-cli"
cliExec="./node_modules/.bin/replace-in-files"

# Step 3 - Iterate through each entry in '.env' file;
cat "$fileName" | sed -e '$a\' | while IFS='=' read -r key value; do
    # Ignore empty lines and lines starting with #
    if [ -n "$key" ] && [[ ! $key =~ ^# ]]; then
        echo "🔵Replacing [$key] variable with [$value] value..."
        # Note: variables should be referenced with "@" sign in order to be replaced!
        $cliExec \
          --ignore-case \
          --string "@$key" \
          --replacement "$value" \
           "**/authproviders/**" \
           "**/namedCredentials/**" \
           "**/customMetadata/**" \
           "**/connectedApps/**"
    fi
done < "$fileName"
git status --porcelain
