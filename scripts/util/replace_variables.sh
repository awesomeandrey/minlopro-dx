#!/bin/bash

# TODO - to decommission!

# How to use:
# - bash ./scripts/deploy/pre/custom/replace_variables.sh

echo "🔵 Replacing variables with secrets/values..."

# Step 1 - Load all environment variables into NEW 'build/.env' file;
mkdir -p "build"
BUILD_ENV_FILE="build/.env"

# Create or clear the file;
> $BUILD_ENV_FILE

# Calculate dynamic variables;
export SF_USERNAME=$(bash ./scripts/util/get_target_org_username.sh)
export SF_INSTANCE_URL=$(bash ./scripts/util/get_target_org_instance_url.sh)

# Load overridden environment variables from local '.env' file (if present);
LOCAL_ENV_FILE=".env"
if [ -f "$LOCAL_ENV_FILE" ]; then
  # Read and export each entry as an environment variable
  while IFS='=' read -r key value; do
      # Ignore empty lines and lines starting with #
      if [[ -n "$key" && ! $key =~ ^\s*# ]]; then
          # Export variable (removing any leading/trailing whitespaces from key and value)
          export "$(echo $key | xargs)"="$(echo $value | xargs)"
      fi
  done < "$LOCAL_ENV_FILE"
fi

# Loop through all environment variables with "SF_" prefix;
printenv | grep '^SF_' | while read -r line; do
    # Write each matched variable to the file;
    echo "$line" >> $BUILD_ENV_FILE
done

# Step 2 - Iterate through each entry in 'build/.env' file;
cat "$BUILD_ENV_FILE" | sed -e '$a\' | while IFS='=' read -r key value; do
    # Ignore empty lines and lines starting with #
    if [ -n "$key" ] && [[ ! $key =~ ^# ]]; then
        echo "Replacing [$key] variable with [$value] value..."
        # Note: variables should be referenced with "@" sign in order to be replaced!
        npx replace-in-files \
          --ignore-case \
          --string "@$key" \
          --replacement "$value" \
           "**/authproviders/**" \
           "**/classes/rest/**" \
           "**/connectedApps/**" \
           "**/customMetadata/**" \
           "**/externalCredentials/**" \
           "**/namedCredentials/**" \
           "**/remoteSiteSettings/**"
    fi
done < "$BUILD_ENV_FILE"
git status --porcelain
