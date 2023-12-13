#!/bin/bash

# How to use:
# - bash ./scripts/deploy/replace_variables.sh

echo "🔵 Replacing variables with secrets/values..."

# Step 1 - Load all environment variables into 'build/.env' file;
mkdir -p "build"
fileWithEnvVariables="build/.env"

# Create or clear the file;
> $fileWithEnvVariables

# Calculate dynamic variables;
export SF_USERNAME=$(bash ./scripts/util/get_target_org_username.sh)
export SF_INSTANCE_URL=$(bash ./scripts/util/get_target_org_instance_url.sh)

# Load overridden environment variables from 'application.properties' file (if present);
PROPERTIES_FILE="application.properties"
if [ -f "$PROPERTIES_FILE" ]; then
  # Read and export each entry as an environment variable
  while IFS='=' read -r key value; do
      # Ignore empty lines and lines starting with #
      if [[ -n "$key" && ! $key =~ ^\s*# ]]; then
          # Export variable (removing any leading/trailing whitespaces from key and value)
          export "$(echo $key | xargs)"="$(echo $value | xargs)"
      fi
  done < "$PROPERTIES_FILE"
fi

# Loop through all environment variables with "SF_" prefix;
printenv | grep '^SF_' | while read -r line; do
    # Write each matched variable to the file;
    echo "$line" >> $fileWithEnvVariables
done

# Step 2 - Install "replace-in-files-cli" utility package;
npm install --save-dev "replace-in-files-cli"
cliExec="./node_modules/.bin/replace-in-files"

# Step 3 - Iterate through each entry in '.env' file;
cat "$fileWithEnvVariables" | sed -e '$a\' | while IFS='=' read -r key value; do
    # Ignore empty lines and lines starting with #
    if [ -n "$key" ] && [[ ! $key =~ ^# ]]; then
        echo "Replacing [$key] variable with [$value] value..."
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
done < "$fileWithEnvVariables"
git status --porcelain
