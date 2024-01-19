#!/bin/bash

# How to use:
# - bash ./scripts/util/create_qa_user.sh
# - echo '$QA_EMAIL' | bash ./scripts/util/create_qa_user.sh

# Capture QA user email address;
read -p "🔶 Enter QA User Email Address: " QA_EMAIL

# Extract default target org;
ORG_ALIAS=$(bash ./scripts/util/get_target_org_alias.sh)

echo "🔵 Creating QA User at [$ORG_ALIAS] organization with [$QA_EMAIL] email..."

# Create QA User;
qaUserDefFile="config/users/qa-user-def.json"
profileName="Minlopro User"

sf org create user \
  --target-org "$ORG_ALIAS" \
  --definition-file "$qaUserDefFile" \
  email="$QA_EMAIL" profileName="$profileName"
