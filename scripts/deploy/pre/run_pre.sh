#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/pre/run_pre.sh
# - echo "ORG_ALIAS" | bash ./scripts/deploy/pre/run_pre.sh

set -e

read -r -p "🔶 Enter target org alias: " TARGET_ORG_ALIAS
npx cowsay -W 100 "📗 Running PRE-Deploy Scripts against [$TARGET_ORG_ALIAS] organization..."

# Step 1: Run Custom Shell Scripts;
customScriptsDir="./scripts/deploy/pre/custom"
if [ -d "$customScriptsDir" ]; then
    for file in "$customScriptsDir"/*.sh; do
        if [ -f "$file" ]; then
            echo "$TARGET_ORG_ALIAS" | bash "$file"
        fi
    done
fi
