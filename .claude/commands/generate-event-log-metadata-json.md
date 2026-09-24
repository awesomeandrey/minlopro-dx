# Generate Event Log Metadata JSON

Generate (or refresh) a CRM Analytics Metadata JSON schema file for a given Event Log object, so its CSV columns land in a dataset as typed fields instead of plain text.

## Why

A Metadata JSON file is required by `scripts/util/event-monitoring/elf.sh` (`--metadata` flag) when uploading Event Log File CSVs into a CRM Analytics Dataset via the [External Data API](https://developer.salesforce.com/docs/analytics/bi-dev-guide-ext-data/guide/bi-ext-data-object-externaldata.html). Skipping it loads every column as text, which makes the dataset useless for lenses/charts.

Existing files live under `scripts/util/event-monitoring/event-metadata-json/` — always use them as the format reference, and always write this command's output into that same directory.

## Steps

1.  **Collect inputs** — Ask the user for the Event Log object API name and the Salesforce API version (`NN.N`, e.g. `67.0`) if not already given. The full list of valid event types tracked by Event Monitoring is documented at [Supported Event Types](https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_eventlogfile_supportedeventtypes.htm). Resolve the target org via the `sf-get-username` MCP tool (default target org) unless the user names a specific alias.

2.  **Validate against the org** — Run this SOQL via the `sf-query-org` MCP tool:

```sql
SELECT
    Id,
    EventType,
    ApiVersion,
    LogFileFieldNames
FROM
    EventLogFile
WHERE
    EventType = '<EventType>'
    AND ApiVersion = < Version >
ORDER BY
    LogDate DESC
LIMIT
    5
```

    - If this returns 0 rows, re-run without the `ApiVersion` filter to report which versions/dates _are_ available for that EventType. Stop and ask the user to confirm the type name or pick an available version — do not fabricate a schema for a type with no log data in this org.
    - Take `LogFileFieldNames` from the newest matching record — this comma-separated list is the **authoritative column order**. Never alphabetize columns or guess order from documentation.
    - Metadata JSON schemas can and do differ between API versions for the same event type (confirmed: `Login-v64.0.json` vs `Login-v65.0.json` differ by 3 fields), so always regenerate fresh for the requested version rather than reusing a file generated for a different one.

3.  **Fast path — reuse an existing CRMA schema** — Applies when the target event type is already included in the CRM Analytics Event Monitoring app (e.g. `ApexCallout`). Query `InsightsExternalData` (via `sf-query-org`) for a record whose `EdgemartLabel` or `EdgemartAlias` references this EventType. If found, base64-decode its `MetadataJson` field:

    ```bash
    echo "$MetadataJson_FieldValue" | base64 -d > EventType.json
    ```

    Re-point `objects[0]`'s `description`/`fullyQualifiedName`/`label`/`name` at `<EventType>` if they differ, then skip to step 5.

4.  **Manual compose path** (used when step 3 finds nothing):

    a. Download exactly one sample `EventLogFile` CSV for the matched record, using the same REST call pattern as `download_elf()` in `scripts/util/event-monitoring/elf.sh` (lines 161-171): fetch the org's `instanceUrl` and access token, then `curl` `${instanceUrl}${attributes.url}/LogFile`. Save the CSV to the scratchpad directory — never into the repo.

    b. Sample the header plus up to ~20 data rows, and infer each column's type: - **Date** — every sampled value matches `yyyy-MM-ddTHH:mm:ss.SSSZ`. - **Numeric** — every non-blank sampled value parses as a number _and_ the column is a genuine measure (duration, count, size, status code — e.g. `RUN_TIME`, `CPU_TIME`, `STATUS_CODE`). Use `scale: 3` if any value has a decimal point, otherwise `scale: 0`. - **Text** — otherwise, including any numeric-looking value that is actually an identifier, version string, raw timestamp, or boolean flag (e.g. `TIMESTAMP`, `API_VERSION`, `*_ID`, `SUCCESS`, `IS_*`, `COUNTS_AGAINST_*`) — cross-check the existing files for this naming pattern before typing a field Numeric. Use `precision: 4000` if any sampled value exceeds 255 characters, otherwise `precision: 255`.

    c. Build the full JSON in `LogFileFieldNames` order, copying the `fileFormat` block verbatim from an existing file (e.g. `ApexCallout-v67.0.json`):

        ```json
        {
            "fileFormat": {
                "charsetName": "UTF-8",
                "fieldsEnclosedBy": "\"",
                "fieldsDelimitedBy": ",",
                "linesTerminatedBy": "\n",
                "numberOfLinesToIgnore": 1
            },
            "objects": [
                {
                    "connector": "API",
                    "description": "<EventType>",
                    "fullyQualifiedName": "<EventType>",
                    "label": "<EventType>",
                    "name": "<EventType>",
                    "fields": []
                }
            ]
        }
        ```

        Each field entry always has `description`/`fullyQualifiedName`/`label` equal to `name`, and `isSystemField`/`isUniqueId`/`isMultiValue` set to `false`. Then, by inferred type (key order matters — match it exactly):
        - **Text**: `type, name, description, fullyQualifiedName, label, isSystemField, isUniqueId, precision (255|4000), defaultValue (""), isMultiValue`
        - **Numeric**: `type, name, description, fullyQualifiedName, label, isSystemField, isUniqueId, scale (0|3), precision (18), defaultValue ("0"), isMultiValue`
        - **Date**: `type, name, description, fullyQualifiedName, label, isSystemField, isUniqueId, defaultValue (""), isMultiValue, format ("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")`

    d. Delete the temporary downloaded CSV.

5.  **Write & validate** — Target path: `scripts/util/event-monitoring/event-metadata-json/<EventType>-v<Version>.json` (always include the `.0`, matching the majority naming convention already in that folder). If a file already exists at that exact path, overwrite it in place with the freshly regenerated schema rather than erroring or skipping — treat this command as the single source of truth for that file. Use 4-space indentation to match existing files, and validate with `jq empty <file>` before reporting success.

6.  **Report** — Print a field-name → inferred-type table, and flag any column whose sample was entirely blank (it defaults to Text and deserves a manual look) before the user runs `elf.sh` against this file.

## Notes

- This command only generates/refreshes the schema file; it does not run `elf.sh` or touch any CRM Analytics dataset.
- Always write into `scripts/util/event-monitoring/event-metadata-json/` — never anywhere else in the repo.
