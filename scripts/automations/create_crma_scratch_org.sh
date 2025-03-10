#!/usr/bin/env bash

# How to use:
# - bash ./scripts/automations/create_crma_scratch_org.sh
# - bash ./scripts/automations/create_crma_scratch_org.sh "$DEV_HUB_ALIAS" "$SCRATCH_ORG_ALIAS" "$ADMIN_EMAIL"
# - echo $TXT_WITH_INPUTS | bash ./scripts/automations/create_crma_scratch_org.sh

# Enable errexit option to exit on command failure
set -e

DEV_HUB_ALIAS=$1
SCRATCH_ORG_ALIAS=$2
ADMIN_EMAIL=$3

if [ -z "$DEV_HUB_ALIAS" ] || [ -z "$SCRATCH_ORG_ALIAS" ] || [ -z "$ADMIN_EMAIL" ]; then
  read -r -p "🔶 Enter CRM Analytics DevHub Alias: " DEV_HUB_ALIAS
  read -r -p "🔶 Enter Scratch Org Alias: " SCRATCH_ORG_ALIAS
  read -r -p "🔶 Enter Admin Email Address: " ADMIN_EMAIL
fi

echo "🔵 Spinning up CRMA scratch org [$SCRATCH_ORG_ALIAS] for [$ADMIN_EMAIL] under [$DEV_HUB_ALIAS] dev hub org..."

# Create a brand new scratch org AND set it as a DEFAULT ORG!
sf org create scratch \
    --target-dev-hub "$DEV_HUB_ALIAS" \
    --alias "$SCRATCH_ORG_ALIAS" \
    --definition-file "config/crma-scratch-def.json" \
    --admin-email "$ADMIN_EMAIL" \
    --set-default \
    --duration-days 30 \
    --wait 10
sf config list

# Reset Admin User password
sf org generate password --target-org "$SCRATCH_ORG_ALIAS"

# Capture scratch org credentials
mkdir -p "build"
orgCredentialsFile="build/$ADMIN_EMAIL-CRMA-SO.json"
touch "$orgCredentialsFile"
echo "📜 CRMA Scratch Org Credentials"
sf org display --target-org "$SCRATCH_ORG_ALIAS" --verbose --json > "$orgCredentialsFile"
cat "$orgCredentialsFile"

# Resolve ".env" file for the scratch org (this properly resolves 'SF_USERNAME' & 'SF_INSTANCE_URL' variables)
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/deploy/pre/custom/resolve_env_variables.sh

# Deploy 'minlopro-crma' folder content
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/crm-analytics/deploy.sh

# Set up admin user
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/crm-analytics/util/set_up_admin_user.sh

# Deactivate all duplicate rules
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/util/duplicates-mgmt/deactivate_all_duplicate_rules.sh

# Import sample data
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/util/data-seeding/import_sample_data.sh

# Set up standard user
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/crm-analytics/util/set_up_std_user.sh

# Reset Metadata Tracking
npm run sf:tracking:reset
