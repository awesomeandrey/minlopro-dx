#!/usr/bin/env bash

set -e

# How to use
print_usage() {
  echo "Usage:"
  echo "  $0 --mode <full|delta> [--target-org <alias>] [--from-ref <ref>] [--to-ref <ref>] [--interactive]"
  echo "Parameters:"
  echo "  --mode         (required)  Must be either 'full' or 'delta'"
  echo "  --target-org   (optional)  Alias of target Salesforce org (defaults to authenticated default)"
  echo "  --from-ref     (required if --mode=delta) Git ref (branch or commit) to diff FROM"
  echo "  --to-ref       (required if --mode=delta) Git ref (branch or commit) to diff TO"
  echo "  --interactive  (optional)  If set, allows prompting for from/to refs interactively"
  echo "Examples:"
  echo "  $0 --mode full"
  echo "  $0 --mode delta --from-ref main --to-ref feature/branch"
  echo "  $0 --mode delta --interactive"
}

# Initialize parameters
MODE=""
TARGET_ORG=""
FROM_REF=""
TO_REF=""
INTERACTIVE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --mode)
      MODE="$2"
      shift 2
      ;;
    --target-org)
      TARGET_ORG="$2"
      shift 2
      ;;
    --from-ref)
      FROM_REF="$2"
      shift 2
      ;;
    --to-ref)
      TO_REF="$2"
      shift 2
      ;;
    --interactive)
      INTERACTIVE=true
      shift
      ;;
    -h|--help)
      print_usage
      exit 1
      ;;
    *)
      echo "❌ Unknown argument: $1"
      print_usage
      exit 1
      ;;
  esac
done

# Validate required --mode
if [[ -z "$MODE" ]]; then
  echo "❌ Error: --mode is required"
  print_usage
  exit 1
fi

# Validate mode value
if [[ "$MODE" != "full" && "$MODE" != "delta" ]]; then
  echo "❌ Error: --mode must be 'full' or 'delta'"
  print_usage
  exit 1
fi

# Prompt for refs if interactive mode is on and values are missing
if [[ "$MODE" == "delta" ]]; then
  if [[ "$INTERACTIVE" == true ]]; then
    if [[ -z "$FROM_REF" ]]; then
      read -r -p "🔶 Enter branch name / commit SHA to capture changes FROM: " FROM_REF
    fi
    if [[ -z "$TO_REF" ]]; then
      read -r -p "🔶 Enter branch name / commit SHA to capture changes UP TO: " TO_REF
    fi
  fi

  # Final validation for delta mode
  if [[ -z "$FROM_REF" || -z "$TO_REF" ]]; then
    echo "❌ Error: --from-ref and --to-ref are required when --mode is 'delta'"
    print_usage
    exit 1
  fi
fi

# Resolve target org only if not provided
if [[ -z "$TARGET_ORG" ]]; then
  TARGET_ORG=$(bash ./scripts/util/get_target_org_alias.sh)
  if [[ -z "$TARGET_ORG" || "$TARGET_ORG" == null ]]; then
    echo "❌ Error: --target-org is undefined or null."
    print_usage
    exit 1
  fi
fi

# Define constants
SRC_FOLDER="src"
PACKAGE_XML="manifests/package.xml"
FORCEIGNORE=".forceignore"

# Debug output
echo "🔵 Generating [$PACKAGE_XML] deployment manifest..."
{
  echo "MODE: $MODE"
  echo "TARGET_ORG: $TARGET_ORG"
  if [[ "$MODE" == "delta" ]]; then
    echo "FROM_REF: $FROM_REF"
    echo "TO_REF: $TO_REF"
  fi
} | column -t -s ':'

# Exclude CRM Analytics metadata if target Salesforce org is not CRMA-eligible
soqlQuery="SELECT COUNT(Id) FROM PermissionSetLicense WHERE DeveloperName = 'EinsteinAnalyticsPlusPsl'"
crmAnalyticsLicensesCount=$(sf data query --target-org "$TARGET_ORG" --query "$soqlQuery" --json | jq -r '.result.records[0].expr0')
echo "CRM Analytics Licenses Count = $crmAnalyticsLicensesCount"
trap 'git restore .forceignore' EXIT
if [ "$crmAnalyticsLicensesCount" -eq 0 ]; then
  {
    echo
    echo "# CRM Analytics"
    echo "**/minlopro-crm-analytics"
  } >> "$FORCEIGNORE"
  echo "Excluded CRM Analytics metadata from deployment bundle."
else
  echo "[$TARGET_ORG] organization is CRM Analytics eligible."
fi

generate_manifest_full() {
  sf project generate manifest --name "$PACKAGE_XML" --source-dir "$SRC_FOLDER"
}

generate_manifest_delta() {
  local sgdFolder="build/sgd"
  local sgdPackageXml="$sgdFolder/package/package.xml"
  local sgdDestructiveChangesXml="$sgdFolder/destructiveChanges/destructiveChanges.xml"

  # Create SGD folder
  mkdir -p "$sgdFolder"

  # Invoke SGD plugin and generate manifests
  sf sgd source delta \
    --from "$FROM_REF" \
    --to "$TO_REF" \
    --output-dir "$sgdFolder" \
    --source-dir "src" \
    --ignore-file "$FORCEIGNORE"

  # Output results
  echo "📜 SGD DIRECTORY"
  tree "$sgdFolder"
  echo "📜 SGD PACKAGE.XML"
  cat "$sgdPackageXml"
  echo "📜 SGD DESTRUCTIVE_CHANGES.XML"
  cat "$sgdDestructiveChangesXml"
  echo

  # Copy 'package.xml' manifest to 'manifests' folder
  cp -f "$sgdPackageXml" "$PACKAGE_XML"
}

if [[ "$MODE" == "delta" ]]; then
  generate_manifest_delta
else
  generate_manifest_full
fi
