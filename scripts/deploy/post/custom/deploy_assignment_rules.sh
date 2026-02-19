#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/post/custom/deploy_assignment_rules.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/post/custom/deploy_assignment_rules.sh

set -e

# Capture target org alias
read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS
echo "🔵 Deploying Assignment Rules to [$TARGET_ORG_ALIAS] organization..."

# Detect ignored assignment rule files via '*/assignmentRules/*' glob pattern
assignmentRuleFiles=$(
    sf project list ignored --source-dir "src" --json \
        | jq -r '.result.ignoredFiles[] | select(test(".*/assignmentRules/.*"))'
)

if [ -z "$assignmentRuleFiles" ]; then
    echo "⚠️  No ignored assignment rule files detected. Skipping."
    exit 0
fi

echo "Detected assignment rule file(s):"
echo "$assignmentRuleFiles"
echo

# Copy detected files into build staging directory
STAGING_DIR="build/assignment_rules_deploy/assignmentRules"
rm -rf "$(dirname "$STAGING_DIR")"
mkdir -p "$STAGING_DIR"
while IFS= read -r file; do
    cp "$file" "$STAGING_DIR/"
done <<< "$assignmentRuleFiles"

# Deploy all assignment rules from staging directory
sf project deploy start \
    --target-org "$TARGET_ORG_ALIAS" \
    --source-dir "$STAGING_DIR" \
    --wait 10
