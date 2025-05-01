#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/deploy.sh
# - bash ./scripts/deploy/deploy.sh "ORG_ALIAS" "hard"
# - bash ./scripts/deploy/deploy.sh "ORG_ALIAS" "dry-run"

TARGET_ORG_ALIAS=$1
MODE=$2
if [ -z "$TARGET_ORG_ALIAS" ] || [ -z "$MODE" ]; then
  read -r -p "🔶 Enter target org alias to deploy against: " TARGET_ORG_ALIAS
  read -r -p "🔶 Specify deployment mode (default: dry-run): " MODE
  MODE=${MODE:-dry-run}
fi
MODE=$(echo "$MODE" | awk '{print tolower($0)}')

FLAGS_DIR=$(mktemp -d) && trap 'rm -rf $FLAGS_DIR' EXIT

case $MODE in
  hard)
    echo "🔵 Deploying to [$TARGET_ORG_ALIAS] organization..."
    touch "$FLAGS_DIR/concise" # --concise
    ;;
  dry-run)
    echo "🔵 Validating deployment against [$TARGET_ORG_ALIAS] organization..."
    touch "$FLAGS_DIR/verbose" # --verbose
    touch "$FLAGS_DIR/dry-run" # --dry-run
    touch "$FLAGS_DIR/test-level"; echo "NoTestRun" > "$FLAGS_DIR/test-level" # --test-level "NoTestRun"
    ;;
  *)
    echo "🔴 Invalid deployment mode specified. Allowed values are: hard, dry-run."
    exit 1
    ;;
esac

# Define constants;
manifestsFolder="manifests"
packageXml="$manifestsFolder/package.xml"
preDestructiveChangesXml="$manifestsFolder/destructiveChangesPre.xml"
postDestructiveChangesXml="$manifestsFolder/destructiveChangesPost.xml"

# Verify that all 3 manifests exist and are valid;
if ! xmllint --noout "$packageXml" "$preDestructiveChangesXml" "$postDestructiveChangesXml"; then
  echo "🔴 'manifests' folder must contain 3 manifest files: package.xml, destructiveChangesPre.xml & destructiveChangesPost.xml."
  exit 1
fi

# Check there are no metadata references in manifest files;
if ! grep -q '<members>' "$packageXml" && ! grep -q '<members>' "$preDestructiveChangesXml" && ! grep -q '<members>' "$postDestructiveChangesXml"; then
  echo "⚪ There are no metadata changes detected!"
  exit 0
fi

npx dotenv -e ".env" -- sf project deploy start \
  --target-org "$TARGET_ORG_ALIAS" \
  --manifest "$packageXml" \
  --pre-destructive-changes "$preDestructiveChangesXml" \
  --post-destructive-changes "$postDestructiveChangesXml" \
  --ignore-conflicts \
  --ignore-warnings \
  --wait 10 \
  --flags-dir "$FLAGS_DIR"
