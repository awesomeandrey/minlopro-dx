#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/pre/custom/2_resolve_env_variables.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/pre/custom/2_resolve_env_variables.sh

set -e

# Color themes
BlueColor='\033[38;2;158;169;241m'
NoColor='\033[0m'

# Capture target org alias
read -r -p "🔶 Enter target org alias to generate '.env' file for: " TARGET_ORG_ALIAS
echo "🔵 Resolving environment variables for [$TARGET_ORG_ALIAS] organization..."

# Copy content of '.env.manifest' file to '.env' in repository root (force overwrite)
ENV_FILEPATH=".env"
if ! [ -f "$ENV_FILEPATH" ]; then
  # Create new '.env' file excluding empty & comment lines
  grep -v "^#" "scripts/.env.manifest" | grep -v '^$' | sort > "$ENV_FILEPATH"
fi

# Function that manipulates with the content of '.env' file
add_or_update_env_var() {
    local var_name="$1"
    local var_value="$2"
    local content

    content=$(cat "$ENV_FILEPATH")
    # Remove variable from .env file
    echo "$content" | grep -v "^$var_name=" > "$ENV_FILEPATH"
    # Append variable with value
    echo "$var_name=$var_value" >> "$ENV_FILEPATH"
    # echo -e "- ${BlueColor}$var_name${NoColor} variable was set to ${BlueColor}$var_value${NoColor}"
    content=$(cat "$ENV_FILEPATH"); echo "$content" | sort > "$ENV_FILEPATH"
}

# Calculate & set static variables
orgInfoJson=$(sf org display --json --target-org="$TARGET_ORG_ALIAS")
add_or_update_env_var "SF_INSTANCE_ID" "$(echo "$orgInfoJson" | jq -r '.result.id')"
add_or_update_env_var "SF_INSTANCE_URL" "$(echo "$orgInfoJson" | jq -r '.result.instanceUrl')"
add_or_update_env_var "SF_MESSAGING_SERVICE_CHANNEL_ID" "$(echo "$TARGET_ORG_ALIAS" | bash ./scripts/deploy/pre/env-var-scripts/get_messaging_service_channel_id.sh)"
add_or_update_env_var "SF_MINLOPRO_CERT_ID" "$(echo "$TARGET_ORG_ALIAS" | bash ./scripts/deploy/pre/env-var-scripts/get_minlopro_cert_id.sh)"
add_or_update_env_var "SF_MINLOPRO_CERT_BASE64_VALUE" "$(echo "$TARGET_ORG_ALIAS" | bash ./scripts/deploy/pre/env-var-scripts/get_minlopro_cert_base64_value.sh)"
add_or_update_env_var "SF_SITE_DOMAIN_NAME" "$(echo "$TARGET_ORG_ALIAS" | bash ./scripts/deploy/pre/env-var-scripts/get_site_domain_name.sh)"
add_or_update_env_var "SF_SITE_URL" "$(echo "$TARGET_ORG_ALIAS" | bash ./scripts/deploy/pre/env-var-scripts/get_site_url.sh)"
add_or_update_env_var "SF_USERNAME" "$(echo "$orgInfoJson" | jq -r '.result.username')"

# Capture environment variables in current shell and upsert them to '.env' file (used within GitHub actions)
for var in $(printenv | grep '^SF_'); do
    # Extract the variable name
    var_name="${var%%=*}"
    # Extract the value of the variable
    var_value="${!var_name}"
    # Upsert SF-like variable to '.env' file
    add_or_update_env_var "$var_name" "$var_value"
done

# Display variables
echo -e "${BlueColor}Environment Variables:${NoColor}"
grep -v "^#" "$ENV_FILEPATH" | grep -v '^$' | \
awk -F '=' '{
    key=$1
    val=substr($0, index($0,"=")+1)
    if (length(val) > 250) val = substr(val, 1, 30) "..." substr(val, length(val)-29, 30)
    print key "=" val
}' | column -t -s '='

# Copy '.env' file to 'build' folder
mkdir -p "build"
cp -f "$ENV_FILEPATH" "build/$ENV_FILEPATH"

echo "Done!"
