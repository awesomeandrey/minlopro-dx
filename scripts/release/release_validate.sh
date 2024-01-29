#!/bin/bash

# How to use:
# - bash ./scripts/release/release_validate.sh
# - echo 'ORG_ALIAS' | bash ./scripts/release/release_validate.sh

# Capture target org alias;
read -p "🔶 Enter target org alias to run QUICK VALIDATION against: " TARGET_ORG_ALIAS
echo "🔵 Running quick validation against [$TARGET_ORG_ALIAS] organization..."
echo

# Define constants;
buildFolder="build"
manifestsFolder="manifests"
packageXml="$manifestsFolder/package.xml"
preDestructiveChangesXml="$manifestsFolder/destructiveChangesPre.xml"
postDestructiveChangesXml="$manifestsFolder/destructiveChangesPost.xml"
deploymentJobIdFile="$buildFolder/release_job_id.txt"

# Verify that all 3 manifests exist;
if ! [[ -f "$packageXml" && -f "$preDestructiveChangesXml" && -f "$postDestructiveChangesXml" ]]; then
  echo "🔴 'manifests' folder must contain 3 manifest files: package.xml, destructiveChangesPre.xml & destructiveChangesPost.xml."
  exit 1
fi

# Extract Apex Test class names (NOTE: extra spaces/quotes in Apex Test class names will lead to failed validation!);
testClassNamesArray=()
while IFS= read -r line; do
    className="${line#*<members>}"
    className="${className%</members>}"
    testClassNamesArray+=("$className")
done < <(grep '<members>.*Test<\/members>' "$packageXml")
testClassNames="${testClassNamesArray[*]}"
if [ -z "$testClassNames" ]; then
    # Default Apex Test class name;
    echo "No updates detected in Apex Test classes. Applying default Apex Test class name."
    testClassNames="DatatableControllerTest"
fi
echo "Apex Test Class Names: [$testClassNames]"

# Initiate deployment validation;
jobInfoJson=$(npx dotenv -e '.env' -- sf project deploy validate \
  --target-org "$TARGET_ORG_ALIAS" \
  --manifest "$packageXml" \
  --pre-destructive-changes "$preDestructiveChangesXml" \
  --post-destructive-changes "$postDestructiveChangesXml" \
  --test-level "RunSpecifiedTests" \
  --tests $testClassNames \
  --verbose \
  --async \
  --ignore-warnings \
  --json --wait 20)

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
