#!/bin/bash

# How to use:
# - bash ./scripts/automations/create_scratch_org.sh
# - echo $TXT_WITH_INPUTS | bash ./scripts/automations/create_scratch_org.sh

# Enable errexit option to exit on command failure
set -e

# Capture DevHub org alias;
echo "🔶 Enter DevHub org alias:"
read DEV_HUB_ALIAS

# Capture Scratch Org alias;
echo "🔶 Enter Scratch Org alias:"
read SCRATCH_ORG_ALIAS

# Capture Admin email address alias;
echo "🔶 Enter Admin Email Address:"
read ADMIN_EMAIL

echo "🔵 Spinning up scratch org [$SCRATCH_ORG_ALIAS] for [$ADMIN_EMAIL] under [$DEV_HUB_ALIAS] dev hub org..."

# Create a brand new scratch org ans set it as a default org
sf org create scratch \
    --target-dev-hub $DEV_HUB_ALIAS \
    --alias $SCRATCH_ORG_ALIAS \
    --definition-file "config/project-scratch-def.json" \
    --admin-email $ADMIN_EMAIL \
    --set-default \
    --edition enterprise \
    --duration-days 30 \
    --wait 10

# TODO - replace multiple env variables!
# Replace environment variables
username=$(bash ./scripts/util/get_target_org_username.sh)
export SF_USERNAME="$username"
bash ./scripts/deploy/replace_variables.sh

# Reset Admin user password and display it to console
sf org generate password --target-org $SCRATCH_ORG_ALIAS
orgCredentialsFile="build/$ADMIN_EMAIL-scratch-org-credentials.txt"
mkdir -p "build"
touch $orgCredentialsFile
echo "📜 Scratch Org Credentials"
sf org display user --target-org $SCRATCH_ORG_ALIAS >> $orgCredentialsFile
sf org display --target-org $SCRATCH_ORG_ALIAS --verbose >> $orgCredentialsFile
cat $orgCredentialsFile

# Optional: install packages here.

# Generate project manifest
sf project generate manifest \
    --source-dir "src" \
    --name "manifests/package.xml"

# Initiate full deploy to scratch org (this automatically creates Digital Experience Site)
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/deploy/deploy.sh

# Sets up admin user
bash ./scripts/util/run_apex_script.sh "$SCRATCH_ORG_ALIAS" set_up_org_admin
# Sets up DigEx guest user
bash ./scripts/util/run_apex_script.sh "$SCRATCH_ORG_ALIAS" set_up_digex_guest_user

# Publish Digital Experience Site
sf community publish \
  --name "DigEx" \
  --target-org "$SCRATCH_ORG_ALIAS"

# Import sample data
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/util/import_sample_data.sh
