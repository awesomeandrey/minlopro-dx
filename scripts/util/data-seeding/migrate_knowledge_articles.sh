#!/bin/bash

# How to use:
# - bash ./scripts/util/data-seeding/migrate_knowledge_articles.sh

read -p "🔶 Enter source org alias to fetch KAVs from: " SOURCE_ORG_ALIAS
read -p "🔶 Enter target org alias to import KAVs to: " TARGET_ORG_ALIAS

echo "🔵 Exporting knowledge articles from [$SOURCE_ORG_ALIAS] and importing them into [$TARGET_ORG_ALIAS] via SFDMU CLI..."

# Step 1 - purge all KAVs in the target org
sf apex run --target-org "$TARGET_ORG_ALIAS" --file "scripts/util/apex/delete_all_knowledge_articles.apex"

# Step 2 - migrate KAVs via SFDMU plugin
mkdir -p "build"
cp -r "config/data/sfdmu/knowledge-articles-export-config" "build"
configFolder="build/knowledge-articles-export-config"
# Use '--simulation' to run a migration process without actually performing any data changes in the Salesforce org
sf sfdmu run \
  --sourceusername "$SOURCE_ORG_ALIAS" \
  --targetusername "$TARGET_ORG_ALIAS" \
  --path "$configFolder" \
  --canmodify \
  --noprompt \
  --verbose \
  --usesf "true"

# Step 3 - publish all migrated KAVs
sf apex run --target-org "$TARGET_ORG_ALIAS" --file "scripts/util/apex/publish_all_knowledge_articles.apex"
