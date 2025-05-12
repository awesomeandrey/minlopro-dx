#!/usr/bin/env bash

# - bash ./scripts/deploy/deploy.sh
# - bash ./scripts/deploy/deploy.sh "ORG_ALIAS" "hard"
# - bash ./scripts/deploy/deploy.sh "ORG_ALIAS" "hard" "RunLocalTests"
# - bash ./scripts/deploy/deploy.sh "ORG_ALIAS" "dry-run" "NoTestRun"

TARGET_ORG_ALIAS="$1"
MODE="$2"
TEST_LEVEL="$3"
if [ -z "$TARGET_ORG_ALIAS" ]; then
  echo "🔴 Target org alias must be specified!"
  exit 1
fi
MODE=${MODE:-dry-run}
TEST_LEVEL=${TEST_LEVEL:-NoTestRun}

FLAGS_DIR=$(mktemp -d) && trap 'rm -rf $FLAGS_DIR' EXIT
MODE=$(echo "$MODE" | awk '{print tolower($0)}')
case $MODE in
  hard)
    echo "🔵 Running Hard Deploy ($TEST_LEVEL) to [$TARGET_ORG_ALIAS] organization..."
    touch "$FLAGS_DIR/verbose"
    ;;
  dry-run)
    echo "🔵 Running Dry-Run Deploy ($TEST_LEVEL) against [$TARGET_ORG_ALIAS] organization..."
    touch "$FLAGS_DIR/dry-run"
    touch "$FLAGS_DIR/concise"
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
  --test-level "$TEST_LEVEL" \
  --wait 30 \
  --flags-dir "$FLAGS_DIR"
