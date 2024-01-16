#!/bin/bash

# How to use:
# - bash ./scripts/deploy/pre/custom/resolve_env_variables.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/pre/custom/resolve_env_variables.sh

# Enable errexit option to exit on command failure
set -e

# Capture target org alias;
read -p "🔶 Enter target org alias to generate '.env' file for: " TARGET_ORG_ALIAS
echo "🔵 Resolving environment variables..."

# Copy content of '.env.manifest' file to '.env' in repository root (force overwrite);
ENV_FILEPATH=".env"
cp -f "scripts/.env.manifest" "$ENV_FILEPATH"

# Determine OS and define 'sed' command based on OS
OS="$(uname)"
if [[ "$OS" == "Darwin" ]]; then
    # macOS
    echo "SED command is adapted for MacOS."
    SED_COMMAND="sed -i '' "
else
    # Linux
    echo "SED command is adapted for Linux."
    SED_COMMAND="sed -i "
fi

# Function that manipulates with the content of '.env' file;
add_or_update_env_var() {
    local var_name=$1
    local var_value=$2
    echo "Processing [$var_name] variable..."
    # Check if the variable exists in the file
    if grep -q "^$var_name=" "$ENV_FILEPATH"; then
        # Variable found; update it
        $SED_COMMAND "s|^$var_name=.*$|$var_name=$var_value|" "$ENV_FILEPATH"
    else
        # Variable not found; add it
        echo "$var_name=$var_value" >> "$ENV_FILEPATH"
    fi
}

# Calculate & set static variables;
targetOrgUsername=$(sf org display user --json --target-org="$TARGET_ORG_ALIAS" | jq -r '.result.username')
add_or_update_env_var "SF_USERNAME" "$targetOrgUsername"
targetOrgInstanceUrl=$(sf org display --json --target-org="$TARGET_ORG_ALIAS" | jq -r '.result.instanceUrl')
add_or_update_env_var "SF_INSTANCE_URL" "$targetOrgInstanceUrl"

# Capture environment variables in current shell and upsert them to '.env' file (used within GitHub actions);
for var in $(printenv | grep '^SF_'); do
    # Extract the variable name
    var_name="${var%%=*}"
    # Extract the value of the variable
    var_value="${!var_name}"
    # Upsert SF-like variable to '.env' file
    add_or_update_env_var "$var_name" "$var_value"
done

echo "Done!"
