#!/bin/bash

# How to use:
# - bash ./scripts/util/create_scratch_org.sh
# - echo $TXT_FILE_WITH_DEV_HUB_AND_SO_ALIASES | bash ./scripts/util/create_scratch_org.sh

# Enable errexit option to exit on command failure
set -e

# Capture DevHub org alias;
printf "Enter DevHub org alias:\n"
read DEV_HUB_ALIAS

# Capture Scratch Org alias;
printf "Enter Scratch Org alias:\n"
read SCRATCH_ORG_ALIAS

echo "Spinning up scratch org [$SCRATCH_ORG_ALIAS] under [$DEV_HUB_ALIAS] dev hub org..."

# Create a brand new scratch org ans set it as a default org
sf org create scratch \
    --target-dev-hub $DEV_HUB_ALIAS \
    --alias $SCRATCH_ORG_ALIAS \
    --definition-file "config/project-scratch-def.json" \
    --set-default \
    --edition enterprise \
    --duration-days 30 \
    --wait 10

# Optional: install packages here.

# Generate project manifest
sf project generate manifest \
    --source-dir "src" \
    --name "manifests/package.xml"

# Initiate full deploy to scratch org (this automatically creates Digital Experience Site)
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/deploy/deploy.sh

# Enable debug mode in scratch org by default
bash ./scripts/util/run_apex_script.sh "$SCRATCH_ORG_ALIAS" set_up_org_admin

# Publish Digital Experience Site
sf community publish \
  --name "DigEx" \
  --target-org "$SCRATCH_ORG_ALIAS"

# TODO: import sample data here.

# Reset Admin user password and display it to console
sf org generate password --target-org $SCRATCH_ORG_ALIAS
printf "\n----- Scratch Org Credentials -----\n"
sf org display user --target-org $SCRATCH_ORG_ALIAS

echo "Done!"
