# Declarative Lookup Rollup Summaries (DLRS)

This folder contains metadata related to [Declarative Lookup Rollup Relationships (DLRS)](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries) **managed** package.

Package ID: `04t5p000001E8vdAAC`.

## Configuration Guide

Here is sophisticated guide of DLRS package functionality - https://sfdo-community-sprints.github.io/DLRS-Documentation.
Make sure to assign the following permission sets to Admin user(s):

- `dlrs__LookupRollupSummariesFull`
- `dlrs__LookupRollupSummariesReadOnly`

## Trigger Handler Framework Compatibility

DLRS rollup settings leverage `Developer` Calculation Mode.
See `DlrsDeveloperModeTriggerHandler.cls` apex class for mode details on how to invoke DLRS API directly from trigger handler.
