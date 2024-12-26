#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/diagnose_components_api_version.sh

# Capture inputs
currentApiVersion=$(bash ./scripts/util/get_project_api_version.sh)
read -r -p "🔶 Enter base API version [default: $currentApiVersion]: " baseApiVersion
baseApiVersion=${baseApiVersion:-$currentApiVersion}

read -r -p "🔶 Provide folder path to sources [default: 'src']: " baseSourcesFolderPath
sourcesFolder=${baseSourcesFolderPath:-"src"}

read -r -p "🔶 Do you want to update files with a lower API version? (y/n) [default: n]: " doUpdateFiles
doUpdateFiles=${doUpdateFiles:-n}

echo "🔵 Checking sources with API version lower than $baseApiVersion in '$sourcesFolder' folder..."

# Initialize output
outputAsTable="Filename\tCurrentVersion\tNewVersion\tStatus"
csvOutputFile="build/components_api_version_result.csv"

# Find and process all XML files in the specified directory recursively
while IFS= read -r file; do
  # Check if the file contains <apiVersion>NN.0</apiVersion>
  if grep -q "<apiVersion>[0-9]\+\.0</apiVersion>" "$file"; then
    # Check if the file is valid XML
    if xmlstarlet val -q "$file"; then
      # Extract the current API version
      currentVersion=$(xmlstarlet sel -t -v "//*[local-name()='apiVersion']" "$file" 2>/dev/null)

      # Check if the API version exists and is less than baseApiVersion
      if [[ -n "$currentVersion" ]]; then
        if (( $(echo "$currentVersion < $baseApiVersion" | bc -l) )); then
          # Update files if the user chose to do so
          if [[ "$doUpdateFiles" == "y" ]]; then
            xmlstarlet ed -L -u "//*[local-name()='apiVersion']" -v "$baseApiVersion" "$file"
            outputAsTable+="\n$file\t$currentVersion\t$baseApiVersion\tUpdated"
          else
            outputAsTable+="\n$file\t$currentVersion\tn/a\tNeeds_Update"
          fi
        else
          outputAsTable+="\n$file\t$currentVersion\t$currentVersion\tGood"
        fi
      fi
    fi
  fi
done < <(find "$sourcesFolder" -type f -name "*.xml")

# Save the result to a CSV file
mkdir -p "build"
echo -e "$outputAsTable" | tr '\t' ',' > "$csvOutputFile"

# Display the table in the terminal
echo -e "$outputAsTable" | column -t

# Print success message and CSV location
echo "Analysis complete. Results saved to '$csvOutputFile'."
