#!/bin/bash

# How to use:
# - bash ./scripts/deploy/post/custom/publish_experience_sites.sh

# Capture target org alias;
read -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

echo "🔵 Publishing Experience Sites in [$TARGET_ORG_ALIAS] organization..."

# Publish Digital Experience Site
sf community publish --name "DigEx" --target-org "$TARGET_ORG_ALIAS"

# Publish Experience Site for Enhanced Messaging for In-App & Web Experience
sf community publish --name "ESW_Minlopro_DigExMessaging" --target-org "$TARGET_ORG_ALIAS"
