#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/event-monitoring/download-elf-and-upload-as-dataset.sh "so-oct-1" "LightningPageView" 10
# - bash ./scripts/util/event-monitoring/download-elf-and-upload-as-dataset.sh "so-oct-1" "LightningPageView" 10 65.0 "Minlopro"

# Hint: use `bash -x ./script_name.sh` to troubleshoot the script

source ./scripts/util/progress_bar.sh

set -e

ORG_ALIAS="$1"
EVENT_TYPE="$2"
ELF_LIMIT="$3"
ELF_LIMIT=${ELF_LIMIT:-90}
API_VERSION="$4"
API_VERSION=${API_VERSION:-"65.0"}
FOLDER_ID_OR_NAME="$5"

if [ -z "$ORG_ALIAS" ] || [ -z "$EVENT_TYPE" ]; then
    echo "Error: some parameters were not provided."
    echo "Usage: $0 OrgAlias EventType"
    exit 1
fi

SOQL_QUERY=$(cat <<< "SELECT Id, EventType, LogDate
FROM EventLogFile
WHERE EventType = '${EVENT_TYPE}'
AND Interval = 'Daily'
AND LogFileLength > 0
AND CreatedDate = LAST_N_DAYS:365
AND ApiVersion = $API_VERSION
ORDER BY LogFileLength DESC
LIMIT ${ELF_LIMIT}")

echo "Fetching EventLogFiles from [$ORG_ALIAS] with [$EVENT_TYPE] event type..."
echo "---"
echo "$SOQL_QUERY"
echo "---"

LOG_FILES_AS_JSON=$(sf data query --target-org "$ORG_ALIAS" --query "$SOQL_QUERY" --json)
LOG_FILES_SIZE=$(echo "$LOG_FILES_AS_JSON" | jq '.result.totalSize')

if [ "$LOG_FILES_SIZE" -eq 0 ]; then
  echo "SOQL query did not return any results."
  exit 0
fi
echo "Found $LOG_FILES_SIZE event log files! Starting data fetching & uploading..."

ORG_INFO_AS_JSON=$(sf org display --target-org "$ORG_ALIAS" --json)
ORG_ID=$(echo "$ORG_INFO_AS_JSON" | jq -r '.result.id')
ORG_INSTANCE_URL=$(echo "$ORG_INFO_AS_JSON" | jq -r '.result.instanceUrl')
ORG_ACCESS_TOKEN=$(echo "$ORG_INFO_AS_JSON" | jq -r '.result.accessToken')
ROOT_DIR_NAME="build/elf-$ORG_ID-$EVENT_TYPE-v$API_VERSION"
DATA_PART_COUNTER=1
PROGRESS_COUNTER=1
IED_RECORD_ID=""

create_insights_external_data_record(){
  ied_flags_dir=$(mktemp -d) && trap 'rm -rf $ied_flags_dir' EXIT
  touch "$ied_flags_dir/values"; fieldValues=""
  fieldValues+="EdgemartLabel='ELF - $EVENT_TYPE (v$API_VERSION)' "
  fieldValues+="EdgemartAlias='elf_${EVENT_TYPE}_v${API_VERSION%.0}' "
  fieldValues+="Format=Csv "
  fieldValues+="Operation=Overwrite "
  fieldValues+="Action=None "
  fieldValues+="EdgemartContainer=$FOLDER_ID_OR_NAME"
  echo "$fieldValues" > "$ied_flags_dir/values"
  echo "Creating InsightsExternalData record: $fieldValues ..."
  ied_record_info=$(sf data create record --sobject "InsightsExternalData" --target-org "$ORG_ALIAS" --flags-dir "$ied_flags_dir" --json)
  IED_RECORD_ID=$(echo "$ied_record_info" | jq -r '.result.id')
  echo "InsightsExternalData ID = $IED_RECORD_ID"
}

create_insights_external_data_record

reset_elf_folder(){
  rm -rf "$ROOT_DIR_NAME"
  mkdir -p "$ROOT_DIR_NAME"
}

reset_elf_folder

download_elf(){
  local relativeUrl
  relativeUrl="$1"
  local csvFilename
  csvFilename="$2"
  # https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_event_log_file_download.htm
  # echo "Downloading: ${relativeUrl}"
  curl -s "${ORG_INSTANCE_URL}${relativeUrl}/LogFile" \
    -H "Authorization: Bearer $ORG_ACCESS_TOKEN" \
    -H "X-PrettyPrint:1" \
    -o "$csvFilename"
}

upload_elf_to_dataset(){
  local csvFilename
  csvFilename="$1"

  # Remove header row from csv file if not the 1st chunk
  if [[ $DATA_PART_COUNTER -ne 1 ]]; then
    sed -i '' '1d' "$csvFilename"
  fi

  # Compress & delete original csv file (use --keep to preserve)
  #  du -sh -- "$csvFilename"
  gzip --keep "$csvFilename"
  #  du -sh -- "$csvFilename.gz"

  # Split into chunks 9MB each
  split -b 9M -d -a 2 "$csvFilename.gz" "$csvFilename.gz-"

  # Iterate through chunks and upload each as 'InsightsExternalDataPart' record
  for gzCsvFilename in "$csvFilename".gz-*; do
    # See https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_insert_update_blob.htm
    auth_header="Authorization: Bearer $ORG_ACCESS_TOKEN"
    curl \
      -H "${auth_header}" \
      -F "entity_document={\"InsightsExternalDataId\": \"$IED_RECORD_ID\", \"PartNumber\": $DATA_PART_COUNTER};type=application/json" \
      -F "DataFile=@$(pwd)/${gzCsvFilename}" \
      "$ORG_INSTANCE_URL/services/data/v$API_VERSION/sobjects/InsightsExternalDataPart/" &> /dev/null
    ((DATA_PART_COUNTER++))
  done
  echo
}

echo "$LOG_FILES_AS_JSON" | jq -c '.result.records[]' | while read -r elf_sobject; do
  log_id="$(echo "$elf_sobject" | jq -r ".Id")"
  log_relative_url="$(echo "$elf_sobject" | jq -r ".attributes.url")"
  log_date_as_utc="$(echo "$elf_sobject" | jq -r ".LogDate")"
  csv_filename="$ROOT_DIR_NAME/${log_date_as_utc:0:10}-${log_id}.csv"

  progress_bar "$PROGRESS_COUNTER" "$LOG_FILES_SIZE"

  download_elf "$log_relative_url" "$csv_filename"

  upload_elf_to_dataset "$csv_filename"

  raw_elf_size=$(du -sh -- "$csv_filename" | awk '{print $1}')
  compressed_elf_size=$(du -sh -- "$csv_filename.gz" | awk '{print $1}')
  progress_bar "$PROGRESS_COUNTER" "$LOG_FILES_SIZE" "Raw $raw_elf_size & Compressed $compressed_elf_size"

  reset_elf_folder

  ((PROGRESS_COUNTER++))
done

 # Update 'InsightsExternalData' record to kick off the dataset upload process
sf data update record \
    --sobject "InsightsExternalData" \
    --record-id "$IED_RECORD_ID" \
    --values "Action=Process" \
    --target-org "$ORG_ALIAS"
echo "Done!"
