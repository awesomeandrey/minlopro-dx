#!/usr/bin/env bash

# Redeploys local Python Lambda code to an EXISTING Lambda function (code only -
# runtime/handler/role/timeout/env vars are left untouched). Does not create functions.
#
# Staging happens visibly under the project-level 'build/lambda/<function-name>/' folder
# (created if missing): source .py files are copied there, zipped, pushed to the cloud, then
# the zip is deleted - the copied .py files stay so you can inspect exactly what was deployed.
#
# How to use:
# - bash ./scripts/deploy/aws/deploy_lambda_code.sh "FUNCTION_NAME" "SOURCE_DIR"
# - bash ./scripts/deploy/aws/deploy_lambda_code.sh "FUNCTION_NAME" "SOURCE_DIR" "AWS_PROFILE"
#
# Example:
# - bash ./src/minlopro-aws-cloud-computing/scripts/deploy_lambda_code.sh "minlopro-detect-sentiment" "src/minlopro-aws-cloud-computing/aws-lambdas/minlopro-detect-sentiment"
# - bash ./src/minlopro-aws-cloud-computing/scripts/deploy_lambda_code.sh "minlopro-echo"             "src/minlopro-aws-cloud-computing/aws-lambdas/minlopro-echo"

set -e

FUNCTION_NAME="$1"
SOURCE_DIR="$2"
AWS_PROFILE="${3:-${AWS_PROFILE:-minlopro-admin}}"

if [ -z "$FUNCTION_NAME" ] || [ -z "$SOURCE_DIR" ]; then
  echo "🔴 Function name and source dir must be specified! Usage: $0 \"FUNCTION_NAME\" \"SOURCE_DIR\" [\"AWS_PROFILE\"]"
  exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
  echo "🔴 Source dir [$SOURCE_DIR] does not exist."
  exit 1
fi

# Everything happens under the project-level 'build' folder, in its own
# <function-name> subfolder (per-function, so deploying one Lambda never touches another's
# staged files) - inspect it after a run to see exactly what got zipped.
BUILD_DIR="build/lambda/$FUNCTION_NAME"
ZIP_FILE="$BUILD_DIR.zip"

echo "🔵 Staging [$SOURCE_DIR] into [$BUILD_DIR]..."
rm -rf "$BUILD_DIR" && mkdir -p "$BUILD_DIR"
cp "$SOURCE_DIR"/*.py "$BUILD_DIR/"

echo "🔵 Zipping [$BUILD_DIR] into [$ZIP_FILE]..."
rm -f "$ZIP_FILE"
# '-j' junks the staged subfolder path so each .py file sits at the zip root - Lambda won't
# find the handler otherwise. Extend this if/when the function grows third-party dependencies
# (pip install --target "$BUILD_DIR" + zip, or a Lambda layer).
zip -j "$ZIP_FILE" "$BUILD_DIR"/*.py > /dev/null

echo "🔵 Deploying [$SOURCE_DIR] to Lambda function [$FUNCTION_NAME] (profile: $AWS_PROFILE)..."
aws lambda update-function-code \
  --function-name "$FUNCTION_NAME" \
  --zip-file "fileb://$ZIP_FILE" \
  --profile "$AWS_PROFILE" \
  --query '{FunctionName:FunctionName,LastModified:LastModified,CodeSha256:CodeSha256,State:State}'

echo "🔵 Waiting for [$FUNCTION_NAME] update to finish..."
aws lambda wait function-updated --function-name "$FUNCTION_NAME" --profile "$AWS_PROFILE"

rm -f "$ZIP_FILE"
echo "✅ [$FUNCTION_NAME] redeployed. Staged source kept at [$BUILD_DIR] for inspection; zip removed."
