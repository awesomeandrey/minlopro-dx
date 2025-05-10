#!/usr/bin/env bash

# How to use:
# - bash ./scripts/util/parse_apex_test_results.sh

#testResultsDir="temp/waaaa"
#testResultsDir="temp/testresults/failure"
#testResultsDir="temp/testresults/success"

testResultsDir="testresults"

if [ ! -d "$testResultsDir" ]; then
  echo "[$testResultsDir] directory does not exist."
  exit 1
fi

resultsFilepath=$(find "$testResultsDir" -type f -name '*.json' -exec grep -l 'summary' {} + | head -n 1)
if [ ! -f "$resultsFilepath" ]; then
  tree "$testResultsDir"
  echo -e "Could not find JSON file with Apex Test results.\n[$resultsFilepath] does not exit."
  exit 1
fi

_outcome=$(jq -r '.summary.outcome' "$resultsFilepath")
_total=$(jq -r '.summary.testsRan' "$resultsFilepath")
_passing=$(jq -r '.summary.passing' "$resultsFilepath")
_failing=$(jq -r '.summary.failing' "$resultsFilepath")

_success="true"
_outcomeColor="brightgreen"
_failedTests="[]"

if [ "Passed" != "$_outcome" ]; then
  _success="false"
  _outcomeColor="red"
  _failedTests=$(jq -c '[.tests[] | select(.Outcome != "Pass") | {name: .FullName, errorMessage: .Message, stackTrace: .StackTrace}]' "$resultsFilepath")
fi

# -c compacts JSON into single line
jq -n -c \
  --argjson success "$_success" \
  --arg outcome "$_outcome" \
  --arg outcomeColor "$_outcomeColor" \
  --argjson total "$_total" \
  --argjson passing "$_passing" \
  --argjson failing "$_failing" \
  --argjson failedTests "$_failedTests" \
  '{success: $success, outcome: $outcome, outcomeColor: $outcomeColor, total: $total, passing: $passing, failing: $failing, failedTests: $failedTests}'
