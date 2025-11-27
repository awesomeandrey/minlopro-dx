#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

source ./scripts/util/progress_bar.sh

# ------------------------------------------------------------------------------
# Script: elf.sh
# Purpose: Handle Salesforce Event Log File workflows via named flags
# ------------------------------------------------------------------------------

log() { printf '[%(%Y-%m-%dT%H:%M:%S%z)T] %s\n' -1 "$*" >&2; }

die() { log "ERROR: $*"; exit 1; }

usage() {
  cat <<'EOF'
ELF toolkit

Required:
  -o, --source-org-alias STR  Source Salesforce org alias to pull ELFs from
  -e, --event-type STR        Event type API name (e.g., LightningPageView)
  -M, --mode STR              One of: download | download-and-upload-to-dataset

Optional:
  -l, --elf-limit INT         Limit of EventLogFile records to process (default: 90)
  -v, --api-version NUM       Salesforce API version (default: 65.0)
  -t, --target-org-alias STR  Target Salesforce org alias to upload dataset to (defaults to --org-alias parameter)
  -f, --folder STR            Target CRM Analytics folder (Id or Name) to upload dataset to
  -m, --metadata PATH         Path to metadata JSON file specifying uploaded dataset schema
  -h, --help                  Show this help and exit
EOF
}

# ---- Defaults ----
SOURCE_ORG_ALIAS=""
EVENT_TYPE=""
ELF_LIMIT="90"
API_VERSION="65.0"
TARGET_ORG_ALIAS=""
FOLDER_ID_OR_NAME=""
METADATA_JSON_FILE=""
MODE=""

# ---- Parse named args ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--source-org-alias)
      SOURCE_ORG_ALIAS="${2-}"; shift 2 ;;
    -e|--event-type)
      EVENT_TYPE="${2-}"; shift 2 ;;
    -l|--elf-limit)
      ELF_LIMIT="${2-}"; shift 2 ;;
    -v|--api-version)
      API_VERSION="${2-}"; shift 2 ;;
    -t|--target-org-alias)
      TARGET_ORG_ALIAS="${2-}"; shift 2 ;;
    -f|--folder)
      FOLDER_ID_OR_NAME="${2-}"; shift 2 ;;
    -m|--metadata)
      METADATA_JSON_FILE="${2-}"; shift 2 ;;
    -M|--mode)
      MODE="${2-}"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    --) # end of options
      shift; break ;;
    -*)
      die "Unknown option: $1 (use --help)";;
    *)
      die "Unexpected positional argument: $1 (use --help)";;
  esac
done

# Resolve target org alias
TARGET_ORG_ALIAS=${TARGET_ORG_ALIAS:-$SOURCE_ORG_ALIAS}

# ---- Parameters Validation ----
ALLOWED_MODES=("download" "download-and-upload-to-dataset")
is_allowed_mode=false
for m in "${ALLOWED_MODES[@]}"; do
  [[ "$MODE" == "$m" ]] && is_allowed_mode=true && break
done

[[ -n "$SOURCE_ORG_ALIAS" ]] || { usage; die "--source-org-alias is required"; }
[[ -n "$EVENT_TYPE" ]] || { usage; die "--event-type is required"; }
[[ -n "$MODE" ]] || { usage; die "--mode is required"; }
"$is_allowed_mode" || { usage; die "--mode must be one of: ${ALLOWED_MODES[*]}"; }

# Numeric checks
[[ "$ELF_LIMIT" =~ ^[0-9]+$ ]] \
  || die "--elf-limit must be an integer (got: '$ELF_LIMIT')"
[[ "$API_VERSION" =~ ^[0-9]+(\.[0-9]+)?$ ]] \
  || die "--api-version must be a number like 65 or 65.0 (got: '$API_VERSION')"

# Metadata JSON file check (only if provided and not empty)
if [[ -n "$METADATA_JSON_FILE" ]]; then
  [[ -f "$METADATA_JSON_FILE" ]] || die "Metadata JSON file not found: $METADATA_JSON_FILE"
fi

# ---- Echo effective configuration
log "SOURCE_ORG_ALIAS:   $SOURCE_ORG_ALIAS"
log "EVENT_TYPE:         $EVENT_TYPE"
log "ELF_LIMIT:          $ELF_LIMIT"
log "API_VERSION:        $API_VERSION"
log "TARGET_ORG_ALIAS:   $TARGET_ORG_ALIAS"
log "FOLDER_ID_OR_NAME:  ${FOLDER_ID_OR_NAME:-<empty>}"
log "METADATA_JSON_FILE: ${METADATA_JSON_FILE:-<empty>}"
log "MODE:               $MODE"

create_insights_external_data_record(){
  ied_flags_dir=$(mktemp -d) && trap 'rm -rf $ied_flags_dir' EXIT
  touch "$ied_flags_dir/values"; fieldValues=""
  fieldValues+="EdgemartLabel='ELF - $EVENT_TYPE (v$API_VERSION)' "
  fieldValues+="EdgemartAlias='elf_${EVENT_TYPE}_v${API_VERSION%.0}' "
  fieldValues+="Format=Csv "
  fieldValues+="Operation=Overwrite "
  fieldValues+="Action=None "
  if [ -n "$FOLDER_ID_OR_NAME" ]; then
    fieldValues+="EdgemartContainer=$FOLDER_ID_OR_NAME "
  fi
  if [ -n "$METADATA_JSON_FILE" ]; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      fieldValues+="MetadataJson=$(base64 -w 0 "$METADATA_JSON_FILE") "
    else
      fieldValues+="MetadataJson=$(base64 -i "$METADATA_JSON_FILE") "
    fi
  fi
  echo "$fieldValues" > "$ied_flags_dir/values"
  echo "Creating InsightsExternalData record: ${fieldValues:0:200}..."
  ied_record_info=$(sf data create record --sobject "InsightsExternalData" --target-org "$TARGET_ORG_ALIAS" --flags-dir "$ied_flags_dir" --json)
  IED_RECORD_ID=$(echo "$ied_record_info" | jq -r '.result.id')
  echo "InsightsExternalData ID = $IED_RECORD_ID"
}

update_insights_external_data_record(){
  sf data update record \
    --sobject "InsightsExternalData" \
    --record-id "$IED_RECORD_ID" \
    --values "Action=Process" \
    --target-org "$TARGET_ORG_ALIAS"
}

reset_elf_folder(){
  rm -rf "$ELF_DIR"
  mkdir -p "$ELF_DIR"
}

compose_elf_filename(){
  local elf_sobject_json
  elf_sobject_json="$1"
  log_id="$(echo "$elf_sobject_json" | jq -r ".Id")"
  log_date_as_utc="$(echo "$elf_sobject_json" | jq -r ".LogDate")"
  echo "$ELF_DIR/${log_date_as_utc:0:10}-${log_id}.csv"
}

download_elf(){
  local elf_sobject_json
  elf_sobject_json="$1"
  csv_filename="$(compose_elf_filename "$elf_sobject_json")"
  log_relative_url="$(echo "$elf_sobject_json" | jq -r ".attributes.url")"
  # https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_event_log_file_download.htm
  curl -s "${SOURCE_ORG_INSTANCE_URL}${log_relative_url}/LogFile" \
    -H "Authorization: Bearer $SOURCE_ORG_ACCESS_TOKEN" \
    -H "X-PrettyPrint:1" \
    -o "$csv_filename"
}

upload_elf_to_dataset(){
  local csv_filename
  csv_filename="$1"

  # Remove header row from CSV file if not the 1st chunk
  if [[ $DATA_PART_COUNTER -ne 1 ]]; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sed -i '1d' "$csv_filename"
    else
      sed -i '' '1d' "$csv_filename"
    fi
  fi

  # Compress CSV file
  gzip --keep "$csv_filename"

  # Split into chunks 9MB each with 2-digits suffix
  split -b 9M -d -a 2 "$csv_filename.gz" "$csv_filename.gz-"

  # Iterate through chunks and upload each as 'InsightsExternalDataPart' record
  for gz_csv_filename in "$csv_filename".gz-*; do
    # See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_insert_update_blob.htm
    auth_header="Authorization: Bearer $TARGET_ORG_ACCESS_TOKEN"
    curl \
      -H "${auth_header}" \
      -F "entity_document={\"InsightsExternalDataId\": \"$IED_RECORD_ID\", \"PartNumber\": $DATA_PART_COUNTER};type=application/json" \
      -F "DataFile=@$(pwd)/${gz_csv_filename}" \
      "$TARGET_ORG_INSTANCE_URL/services/data/v$API_VERSION/sobjects/InsightsExternalDataPart/" &> /dev/null
    ((DATA_PART_COUNTER++))
  done
  echo
}

# ---- Script Execution
SOQL_QUERY=$(cat <<< "SELECT Id, EventType, LogDate
FROM EventLogFile
WHERE EventType = '${EVENT_TYPE}'
AND Interval = 'Daily'
AND LogFileLength > 0
AND CreatedDate = LAST_N_DAYS:365
AND ApiVersion = $API_VERSION
ORDER BY LogDate DESC
LIMIT ${ELF_LIMIT}")

echo "Fetching EventLogFiles from [$SOURCE_ORG_ALIAS] source org with [$EVENT_TYPE] event type..."
echo "---"
echo "$SOQL_QUERY"
echo "---"

LOG_FILES_AS_JSON=$(sf data query --target-org "$SOURCE_ORG_ALIAS" --query "$SOQL_QUERY" --json)
LOG_FILES_SIZE=$(echo "$LOG_FILES_AS_JSON" | jq '.result.totalSize')

if [ "$LOG_FILES_SIZE" -eq 0 ]; then
  log "SOQL query did not return any results. Nothing to download."
  exit 0
fi
echo "Found $LOG_FILES_SIZE event log files!"

SOURCE_ORG_INFO_AS_JSON=$(sf org display --target-org "$SOURCE_ORG_ALIAS" --json)
SOURCE_ORG_ID=$(echo "$SOURCE_ORG_INFO_AS_JSON" | jq -r '.result.id')
SOURCE_ORG_INSTANCE_URL=$(echo "$SOURCE_ORG_INFO_AS_JSON" | jq -r '.result.instanceUrl')
SOURCE_ORG_ACCESS_TOKEN=$(echo "$SOURCE_ORG_INFO_AS_JSON" | jq -r '.result.accessToken')

TARGET_ORG_INFO_AS_JSON=$(sf org display --target-org "$TARGET_ORG_ALIAS" --json)
TARGET_ORG_ID=$(echo "$TARGET_ORG_INFO_AS_JSON" | jq -r '.result.id')
TARGET_ORG_INSTANCE_URL=$(echo "$TARGET_ORG_INFO_AS_JSON" | jq -r '.result.instanceUrl')
TARGET_ORG_ACCESS_TOKEN=$(echo "$TARGET_ORG_INFO_AS_JSON" | jq -r '.result.accessToken')

ELF_DIR="build/elf-$SOURCE_ORG_ID-$EVENT_TYPE-v$API_VERSION"
DATA_PART_COUNTER=1
PROGRESS_COUNTER=1
IED_RECORD_ID=""

# ---- Mode switch
case "$MODE" in
  download)
    echo "Starting data fetching from [$SOURCE_ORG_ALIAS:$SOURCE_ORG_ID] source org..."

    reset_elf_folder

    echo "$LOG_FILES_AS_JSON" | jq -c '.result.records[]' | while read -r elf_sobject_json; do

      progress_bar "$PROGRESS_COUNTER" "$LOG_FILES_SIZE"

      download_elf "$elf_sobject_json"

      csv_filename="$(compose_elf_filename "$elf_sobject_json")"
      raw_elf_size=$(du -sh -- "$csv_filename" | awk '{print $1}')
      progress_bar "$PROGRESS_COUNTER" "$LOG_FILES_SIZE" "Raw $raw_elf_size"

      ((PROGRESS_COUNTER++))
    done

    echo
    ;;

  download-and-upload-to-dataset)
    echo "Starting data fetching from [$SOURCE_ORG_ALIAS:$SOURCE_ORG_ID] source org & upload to [$TARGET_ORG_ALIAS:$TARGET_ORG_ID] target org..."

    create_insights_external_data_record

    reset_elf_folder

    echo "$LOG_FILES_AS_JSON" | jq -c '.result.records[]' | while read -r elf_sobject_json; do
      csv_filename="$(compose_elf_filename "$elf_sobject_json")"

      progress_bar "$PROGRESS_COUNTER" "$LOG_FILES_SIZE"

      download_elf "$elf_sobject_json"

      upload_elf_to_dataset "$csv_filename"

      raw_elf_size=$(du -sh -- "$csv_filename" | awk '{print $1}')
      compressed_elf_size=$(du -sh -- "$csv_filename.gz" | awk '{print $1}')
      progress_bar "$PROGRESS_COUNTER" "$LOG_FILES_SIZE" "Raw $raw_elf_size & Compressed $compressed_elf_size"

      reset_elf_folder

      ((PROGRESS_COUNTER++))
    done

    update_insights_external_data_record
    ;;

  *) die "Unknown mode (should not happen): $MODE" ;;
esac

log "Done."
