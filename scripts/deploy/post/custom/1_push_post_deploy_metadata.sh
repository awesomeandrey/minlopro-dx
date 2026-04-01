#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/post/custom/1_push_post_deploy_metadata.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/post/custom/1_push_post_deploy_metadata.sh

set -e

# Capture target org alias
read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS
echo "🔵 Pushing POST-DEPLOY metadata to [$TARGET_ORG_ALIAS] organization..."

# Detect ignored metadata files via glob pattern
postDeployFiles=$(
    sf project list ignored --source-dir "src" --json \
        | jq -r '.result.ignoredFiles[] | select(test(".*/post-deploy/.*"))'
)

if [ -z "$postDeployFiles" ]; then
    echo "⚠️ No post-deploy files detected. Skipping."
    exit 0
fi

echo "$postDeployFiles"
echo

# Copy detected files into build staging directory
STAGING_DIR="build/post-deploy"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
while IFS= read -r file; do
    cp "$file" "$STAGING_DIR/"
done <<< "$postDeployFiles"

# Deploy all assignment rules from staging directory
sf project deploy start \
    --target-org "$TARGET_ORG_ALIAS" \
    --source-dir "$STAGING_DIR" \
    --wait 10
