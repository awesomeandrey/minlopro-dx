#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/post/run_post.sh
# - echo "ORG_ALIAS" | bash ./scripts/deploy/post/run_post.sh

read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS
npx cowsay -W 100 "📗 Running POST-Deploy Scripts against [$TARGET_ORG_ALIAS] organization..."

# Step 1: Run Custom Apex Scripts;
apexFilesDir="./scripts/deploy/post/apex"
if [ -d "$apexFilesDir" ]; then
    for file in "$apexFilesDir"/*.apex; do
        if [ -f "$file" ]; then
            echo "🔵 Running Apex Script [$file] against [$TARGET_ORG_ALIAS] organization..."
            echo
            sf apex run --target-org "$TARGET_ORG_ALIAS" --file "$file"
        fi
    done
fi

# Step 2: Run Custom Shell Scripts;
customScriptsDir="./scripts/deploy/post/custom"
if [ -d "$customScriptsDir" ]; then
    for file in "$customScriptsDir"/*.sh; do
        if [ -f "$file" ]; then
            echo "$TARGET_ORG_ALIAS" | bash "$file"
        fi
    done
fi
