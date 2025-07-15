#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/post/custom/publish_sites.sh

# Capture target org alias;
read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS

echo "🔵 Publishing sites in [$TARGET_ORG_ALIAS] organization..."

# Publish Digital Experience Site
sf community publish --name "DigEx" --target-org "$TARGET_ORG_ALIAS" || true

# Publish Experience Site for Enhanced Messaging for In-App & Web Experience
sf community publish --name "ESW_Minlopro_DigExMessaging" --target-org "$TARGET_ORG_ALIAS" || true
