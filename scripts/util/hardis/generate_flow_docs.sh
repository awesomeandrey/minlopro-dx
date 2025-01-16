#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/hardis/generate_flow_docs.sh

docs_dir="assets/docs/hardis/flow2markdown/flows"

if [[ -d "$docs_dir" ]]; then
  rm -rf "$docs_dir"
fi
mkdir -p "$docs_dir"

flows_file=$(mktemp)
find "src" -type f -name "*.flow*" > "$flows_file"
flows_count=$(wc -l < "$flows_file" | xargs)

if ! [[ "$flows_count" -gt 0 ]]; then
  echo "$flows_count flows found."
  exit 0
fi

echo "Found $flows_count flows."

while read -r flow_file; do
  output_flow_doc="$docs_dir/$(basename "$flow_file" | awk -F'.' '{print $1}').md"
  echo "[*] Detected flow file: $flow_file"
  echo "Output file is $output_flow_doc"
  sf hardis:doc:flow2markdown \
    --inputfile "$flow_file" \
    --outputfile "$output_flow_doc" &> /dev/null
done < "$flows_file"

rm -rf "$flows_file"

echo "Done!"
