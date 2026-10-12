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

# Temporarily drop 'post-deploy' exclusions from .forceignore so these files
# are deployable in place (under their original src/ path).
trap 'git restore .forceignore' EXIT
grep -v 'post-deploy' .forceignore > .forceignore.tmp && mv .forceignore.tmp .forceignore

# Build one --source-dir flag per discovered file, keeping original src/ paths
# intact so sfdx-project.json's "src/**" replacement globs still match them
sourceDirArgs=()
while IFS= read -r file; do
    sourceDirArgs+=(--source-dir "$file")
done <<< "$postDeployFiles"

# Deploy all post-deploy metadata directly from its original location, with
# .env loaded so sfdx replacements have values to substitute
npx dotenv -e ".env" -- sf project deploy start \
    --target-org "$TARGET_ORG_ALIAS" \
    "${sourceDirArgs[@]}" \
    --wait 10
