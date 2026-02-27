#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/validations/run_code_analyzer.sh
# - git diff --name-only develop HEAD | grep -iE "^src" | bash ./scripts/deploy/validations/run_code_analyzer.sh

BUILD_DIR="build"
SRC_DIR="src"
RESULT_FILENAME="code-scan-result"

mkdir -p "$BUILD_DIR"

# Build command flags
CMD_FLAGS=(
  --severity-threshold 2
  --output-file "$BUILD_DIR/$RESULT_FILENAME.csv"
  --output-file "$BUILD_DIR/$RESULT_FILENAME.html"
  --output-file "$BUILD_DIR/$RESULT_FILENAME.json"
  --output-file "$BUILD_DIR/$RESULT_FILENAME.sarif"
  --rule-selector "all:1"
  --rule-selector "all:2"
  --rule-selector "all:3"
  --rule-selector "all:4"
  --rule-selector "all:5"
)

# Check if stdin has data (-t 0 stands for empty stdin)
if [[ -t 0 ]]; then
  # Scan whole codebase selecting narrow set of metadata types
  CMD_FLAGS+=(
    --target "$SRC_DIR/**/aura/**"
    --target "$SRC_DIR/**/classes/**"
    --target "$SRC_DIR/**/flows/**"
    --target "$SRC_DIR/**/lwc/**"
    --target "$SRC_DIR/**/triggers/**"
  )
else
  # Scan passed files only (covering all metadata types within the list)
  while IFS= read -r filepath; do
    if [[ -f "$filepath" ]]; then
      CMD_FLAGS+=(--target "$filepath")
    else
      echo "Skipping unknown file: $filepath"
    fi
  done
fi

sf code-analyzer run "${CMD_FLAGS[@]}"
