#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/event-monitoring/download-event-log-files.sh "ORG_ALIAS" "ApexCallout"

set -e

ORG_ALIAS="$1"
EVENT_TYPE="$2"

if [ -z "$ORG_ALIAS" ] || [ -z "$EVENT_TYPE" ]; then
    echo "Error: some parameters were not provided."
    echo "Usage: $0 OrgAlias EventType"
    exit 1
fi

SOQL_QUERY=$(cat <<< "SELECT Id, EventType, LogDate
FROM EventLogFile
WHERE EventType = '$EVENT_TYPE'
AND Interval = 'Daily'
AND LogFileLength > 0
AND CreatedDate = LAST_N_DAYS:180
ORDER BY LogDate
LIMIT 150")

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

echo "Found $LOG_FILES_SIZE event log files! Starting data fetching..."

ORG_INFO_AS_JSON=$(sf org display --target-org "$ORG_ALIAS" --json)
ORG_ID=$(echo "$ORG_INFO_AS_JSON" | jq -r '.result.id')
ORG_INSTANCE_URL=$(echo "$ORG_INFO_AS_JSON" | jq -r '.result.instanceUrl')
ORG_ACCESS_TOKEN=$(echo "$ORG_INFO_AS_JSON" | jq -r '.result.accessToken')

ROOT_DIR_NAME="build/elf-$ORG_ID-$EVENT_TYPE"
rm -rf "$ROOT_DIR_NAME"
mkdir -p "$ROOT_DIR_NAME"

echo "Saving files to $(pwd -P)/$ROOT_DIR_NAME..."

download_and_save(){
  local relativeUrl
  relativeUrl="$1"
  local csvFilename
  csvFilename="$2"
  # https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_event_log_file_download.htm
  echo "Downloading: ${relativeUrl}"
  curl "${ORG_INSTANCE_URL}${relativeUrl}/LogFile" -s \
    -H "Authorization: Bearer $ORG_ACCESS_TOKEN" \
    -H "X-PrettyPrint:1" \
    -o "$ROOT_DIR_NAME/$csvFilename" 2> /dev/null
}

echo "$LOG_FILES_AS_JSON" | jq -c '.result.records[]' | while read -r elf_sobject; do
  log_id="$(echo "$elf_sobject" | jq -r ".Id")"
  log_date_as_utc="$(echo "$elf_sobject" | jq -r ".LogDate")"
  download_and_save \
    "$(echo "$elf_sobject" | jq -r ".attributes.url")" \
    "${log_date_as_utc:0:10}-${log_id}.csv"
done
tree "$ROOT_DIR_NAME"

echo "Done! Hint: use [grep -ir -m 10 SEARCH_STRING $ROOT_DIR_NAME] to search for patterns in event log files."
