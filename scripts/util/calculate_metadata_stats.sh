#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/calculate_metadata_stats.sh
# - bash ./scripts/util/calculate_metadata_stats.sh "force-app"

ROOT_FOLDER=$1

if [ -z "$ROOT_FOLDER" ]; then
  read -r -p "🔶 Provide metadata root folder [default: 'src']: " ROOT_FOLDER
  ROOT_FOLDER=${ROOT_FOLDER:-src}
fi

if ! [ -d "$ROOT_FOLDER" ]; then
  echo "Directory does not exist."
  exit 1
fi

echo -e "There are $(find "$ROOT_FOLDER" -type f | wc -l | xargs) files in total in '$ROOT_FOLDER' directory.\n"

mkdir -p "build"
STATS_FILE="build/metadata-stats.txt"
touch "$STATS_FILE"

{
  echo "Apex Classes: $(find "$ROOT_FOLDER" -type f -name "*.cls" | wc -l )"
  echo "Flows: $(find "$ROOT_FOLDER" -type f -name "*.flow-*" | wc -l )"
  echo "Custom Objects: $(find "$ROOT_FOLDER" -type f -name "*.object-*" | wc -l )"
  echo "Custom Fields: $(find "$ROOT_FOLDER" -type f -name "*.field-*" | wc -l )"
  echo "Reports: $(find "$ROOT_FOLDER" -type f -name "*.report-*" | wc -l )"
  echo "Dashboards: $(find "$ROOT_FOLDER" -type f -name "*.dashboard-*" | wc -l )"
  echo "Flexipages: $(find "$ROOT_FOLDER" -type f -name "*.flexipage-*" | wc -l )"
  echo "Aura Components: $(find "$ROOT_FOLDER" -type f -name "*.cmp-*" | wc -l )"
  echo "LWCs: $(find "$ROOT_FOLDER" -type f -name "*.js-*" | wc -l )"
} | column -t -s ":" | sort | tee "$STATS_FILE"

echo
