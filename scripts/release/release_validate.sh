#!/usr/bin/env bash

# How to use:
# - bash ./scripts/release/release_validate.sh
# - echo 'ORG_ALIAS' | bash ./scripts/release/release_validate.sh

# Capture target org alias;
read -r -p "🔶 Enter target org alias to run QUICK VALIDATION against: " TARGET_ORG_ALIAS
echo "🔵 Running quick validation against [$TARGET_ORG_ALIAS] organization..."
echo

# Define constants;
buildFolder="build"
manifestsFolder="manifests"
packageXml="$manifestsFolder/package.xml"
preDestructiveChangesXml="$manifestsFolder/destructiveChangesPre.xml"
postDestructiveChangesXml="$manifestsFolder/destructiveChangesPost.xml"
deploymentJobIdFile="$buildFolder/release_job_id.txt"

# Verify that all 3 manifests exist and are valid;
if ! xmllint --noout "$packageXml" "$preDestructiveChangesXml" "$postDestructiveChangesXml"; then
  echo "🔴 'manifests' folder must contain 3 manifest files: package.xml, destructiveChangesPre.xml & destructiveChangesPost.xml."
  exit 1
fi

# Collect Apex Test Class names to run;
testClassNamesArray=()

while IFS= read -r line; do
  className="${line#*<members>}"
  className="${className%</members>}"
  testClassNamesArray+=("$className")
done < <(grep '<members>.*Test<\/members>' "$packageXml")

if [ -z "${testClassNamesArray[*]}" ]; then
  # Default Apex Test class name - this one MUST be existing class (otherwise the resulting Job Id won't be eligible for quick deploys);
  echo "No updates detected in Apex Test classes. Applying stub/mock keyword."
  testClassNamesArray+=("TestDataFactoryTest")
fi

echo "Apex Test Class Names: ${testClassNamesArray[*]}"

# Initiate deployment validation;
jobInfoJson=$(npx dotenv -e '.env' -- sf project deploy validate \
  --target-org "$TARGET_ORG_ALIAS" \
  --manifest "$packageXml" \
  --pre-destructive-changes "$preDestructiveChangesXml" \
  --post-destructive-changes "$postDestructiveChangesXml" \
  --test-level "RunSpecifiedTests" \
  --tests "${testClassNamesArray[@]}" \
  --verbose \
  --async \
  --ignore-warnings \
  --json \
  --wait 10)

# Uncomment for debugging purposes;
# echo "Job Info: $jobInfoJson"

jobStatusCode=$(echo "$jobInfoJson" | jq '.status')
if [ "$jobStatusCode" != 0 ]; then
  echo "🔴 Validation Deployment Failed: [$(echo "$jobInfoJson" | jq '.message')]"
  exit 1
fi

# Extract and parse Job ID;
jobIdWithQuotes=$(echo "$jobInfoJson" | jq '.result.id')
jobId="${jobIdWithQuotes//\"/}"

# Resume deployment watching/polling by Job ID;
echo "Polling [$jobId] validation job..."
sf project deploy resume --job-id "$jobId"
validation_deployment_exit_code=$?

# Capture validated Job ID in a dedicated file;
touch "$deploymentJobIdFile"
echo "$jobId" > "$deploymentJobIdFile"
echo
tree "$buildFolder"

# Exit with error code if validation failed;
if ! [ $validation_deployment_exit_code == 0 ]; then
  echo "🔴 Validation Deployment Failed!"
  exit 1
fi
