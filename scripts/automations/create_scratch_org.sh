#!/usr/bin/env bash

# How to use:
# - bash ./scripts/automations/create_scratch_org.sh
# - bash ./scripts/automations/create_scratch_org.sh "$DEV_HUB_ALIAS" "$SCRATCH_ORG_ALIAS" "$ADMIN_EMAIL"
# - echo $TXT_WITH_INPUTS | bash ./scripts/automations/create_scratch_org.sh

# Enable errexit option to exit on command failure
set -e

DEV_HUB_ALIAS=$1
SCRATCH_ORG_ALIAS=$2
ADMIN_EMAIL=$3

if [ -z "$DEV_HUB_ALIAS" ] || [ -z "$SCRATCH_ORG_ALIAS" ] || [ -z "$ADMIN_EMAIL" ]; then
  read -r -p "🔶 Enter DevHub Alias: " DEV_HUB_ALIAS
  read -r -p "🔶 Enter Scratch Org Alias: " SCRATCH_ORG_ALIAS
  read -r -p "🔶 Enter Admin Email Address: " ADMIN_EMAIL
fi

echo "🔵 Spinning up scratch org [$SCRATCH_ORG_ALIAS] for [$ADMIN_EMAIL] under [$DEV_HUB_ALIAS] dev hub org..."

# Create a brand new scratch org AND set it as a DEFAULT ORG!
sf org create scratch \
    --target-dev-hub "$DEV_HUB_ALIAS" \
    --alias "$SCRATCH_ORG_ALIAS" \
    --definition-file "config/project-scratch-def.json" \
    --admin-email "$ADMIN_EMAIL" \
    --set-default \
    --duration-days 30 \
    --wait 10
sf config list
sf org enable tracking --target-org "$SCRATCH_ORG_ALIAS"

# Reset Admin User password
sf org generate password --target-org "$SCRATCH_ORG_ALIAS"

# Capture scratch org credentials
mkdir -p "build"
orgCredentialsFile="build/$ADMIN_EMAIL-SO.json"
touch "$orgCredentialsFile"
echo "📜 Scratch Org Credentials"
sf org display --target-org "$SCRATCH_ORG_ALIAS" --verbose --json > "$orgCredentialsFile"
sf org display --target-org "$SCRATCH_ORG_ALIAS"

# Install packages from DevHub
inputsFile="build/inputs.txt"; touch $inputsFile; echo "$DEV_HUB_ALIAS" > $inputsFile; echo "$SCRATCH_ORG_ALIAS" >> $inputsFile
bash ./scripts/automations/install_packages.sh < $inputsFile

# Run PRE-deploy scripts
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/deploy/pre/run_pre.sh

# Generate project manifest and initiate full deploy to scratch org (this automatically creates Digital Experience Site)
npm run sf:manifest:create:full
bash ./scripts/deploy/deploy.sh "$SCRATCH_ORG_ALIAS" "hard"

# Create QA user
echo "$ADMIN_EMAIL" | bash ./scripts/util/data-seeding/create_qa_user.sh

# Run POST-deploy scripts
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/deploy/post/run_post.sh

# Import sample data
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/util/data-seeding/import_sample_data.sh

# Publish 'DigEx' Experience Site
sf community publish --name "DigEx" --target-org "$SCRATCH_ORG_ALIAS" || true

# Publish Experience Site for Enhanced Messaging for In-App & Web Experience
sf community publish --name "ESW_Minlopro_DigExMessaging" --target-org "$SCRATCH_ORG_ALIAS" || true

# Import & publish Knowledge Articles from DevHub org (leveraging SFDMU plugin)
inputsFile="build/inputs.txt"; touch $inputsFile; echo "$DEV_HUB_ALIAS" > $inputsFile; echo "$SCRATCH_ORG_ALIAS" >> $inputsFile
bash ./scripts/util/data-seeding/migrate_knowledge_articles.sh < $inputsFile

# List CRM Analytics assets via Salesforce CLI plugin
sf analytics app list --target-org "$SCRATCH_ORG_ALIAS"; echo
sf analytics dashboard list --target-org "$SCRATCH_ORG_ALIAS"; echo
sf analytics dataflow list --target-org "$SCRATCH_ORG_ALIAS"; echo
sf analytics dataset list --target-org "$SCRATCH_ORG_ALIAS"; echo
sf analytics lens list --target-org "$SCRATCH_ORG_ALIAS"; echo
sf analytics recipe list --target-org "$SCRATCH_ORG_ALIAS"

# Invoke CRM Analytics recipes
invoke_recipes(){
  local json_input="$1"
  if echo "$json_input" | jq -e ".result" > /dev/null; then
    array_length=$(echo "$json_input" | jq ".result | length")
    if (( array_length > 0 )); then
      echo "$json_input" | jq -c ".result[]" | while read -r record; do
        recipe_id=$(echo "$record" | jq -r '.recipeid')
        sf analytics recipe start -i "$recipe_id" -o "$SCRATCH_ORG_ALIAS"
      done
    fi
  fi
}
invoke_recipes "$(sf analytics recipe list --target-org "$SCRATCH_ORG_ALIAS" --json)"

echo "✅ Done!"
