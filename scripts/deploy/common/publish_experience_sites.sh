#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/common/publish_experience_sites.sh

set -euo pipefail

TARGET_ORG_ALIAS="${1:-}"
if [ -z "$TARGET_ORG_ALIAS" ]; then
  read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS
fi

if [ -z "$TARGET_ORG_ALIAS" ]; then
  echo "❌ Error: target org alias is required"
  exit 1
fi

echo "🔵 Publishing Experience Sites in [$TARGET_ORG_ALIAS] organization..."

# Experience Sites to publish, in order
EXPERIENCE_SITES=(
  "DigEx"                       # Sample 'DigEx' Experience Site
  "ESW_Minlopro_DigExMessaging" # Enhanced Messaging for In-App & Web (MIAW)
  "ESW_Minlopro_BotMessaging"   # Einstein Bot
)

for site in "${EXPERIENCE_SITES[@]}"; do
  sf community publish --name "$site" --target-org "$TARGET_ORG_ALIAS" || true
done
