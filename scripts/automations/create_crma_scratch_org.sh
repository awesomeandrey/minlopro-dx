#!/bin/bash

# How to use:
# - bash ./scripts/automations/create_crma_scratch_org.sh
# - echo $TXT_WITH_INPUTS | bash ./scripts/automations/create_crma_scratch_org.sh

# Enable errexit option to exit on command failure
set -e

# Capture DevHub org alias;
read -p "🔶 Enter CRM Analytics DevHub Alias: " DEV_HUB_ALIAS
# Capture Scratch Org alias;
read -p "🔶 Enter Scratch Org Alias: " SCRATCH_ORG_ALIAS
# Capture Admin email address alias;
read -p "🔶 Enter Admin Email Address: " ADMIN_EMAIL

echo "🔵 Spinning up scratch org [$SCRATCH_ORG_ALIAS] for [$ADMIN_EMAIL] under [$DEV_HUB_ALIAS] dev hub org..."

# Pre-configure Salesforce CLI
sf config set org-capitalize-record-types=true

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
sf org display --target-org "$SCRATCH_ORG_ALIAS" --verbose --json >> "$orgCredentialsFile"
cat "$orgCredentialsFile"

# Resolve ".env" file for the scratch org (this properly resolves 'SF_USERNAME' & 'SF_INSTANCE_URL' variables)
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/deploy/pre/custom/resolve_env_variables.sh

# Grab newly created scratch org username
SF_USERNAME=$(bash ./scripts/util/get_target_org_username.sh)
echo "CRMA username: $SF_USERNAME"

# Set custom user name
sf data update record \
    --sobject "User" \
    --where "Username='$SF_USERNAME'" \
    --values "FirstName='Admin' LastName='CRMA' Country='United States'" \
    --target-org "$SCRATCH_ORG_ALIAS"

# Deploy 'minlopro-crma' folder content
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/crm-analytics/deploy.sh

# Assign remaining permission sets
sf org assign permset \
    --name "CRMA_ObjectsAccess" \
    --target-org "$SCRATCH_ORG_ALIAS" \
    --on-behalf-of "$SF_USERNAME"

# Deactivate all duplicate rules
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/automations/deactivate_all_duplicate_rules.sh

# Import sample data
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/util/import_sample_data.sh

# Create sample user (manual action -> add CRMA PSL & PS + add to public group)
sf org create user \
  --target-org "crma-so-5" \
  --definition-file "config/users/std-user-def.json"
