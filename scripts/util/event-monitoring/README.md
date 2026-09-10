# How to generate a Metadata JSON schema file for a given Event Log type?

Why: A Metadata JSON file is required for the CSV files to be uploaded into a CRM Analytics Dataset.

## Steps

1. Identify the valid event type tracked by Event Monitoring (the list is available at
   https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_eventlogfile_supportedeventtypes.htm).

2. Generate the Metadata JSON file that describes the log structure for that event type.

    There are two ways to approach this:

    ### 2.1 Event type already included in the CRM Analytics Event Monitoring app

    Applies when your target event type is already included in the CRM Analytics Event
    Monitoring application (e.g. `ApexCallout`).

    To get the Metadata JSON file, run a SOQL query against the `InsightsExternalData`
    object, querying the `MetadataJson` field. This field contains Base64-encoded JSON
    content representing the schema. Decode it into a file via:

    ```bash
    echo "$MetadataJson_FieldValue" | base64 -d > EventType.json
    ```

    ### 2.2 Compose the file manually

    Open the documentation for the given event log object and compose the Metadata JSON file, deriving the structure from existing files.

## Known Gaps

- The Metadata JSON file must include columns in the valid order. The order can be
  looked up via the `LogFileFieldNames` field using the SOQL query below:

    ```
    SELECT Id, EventType, ApiVersion, LogFileFieldNames
    FROM EventLogFile
    WHERE EventType IN ('YourType')
    LIMIT 10
    ```

- Metadata JSON files can/will vary from one Salesforce API version to another. Always
  verify whether the Metadata JSON schema differs between your target versions. Otherwise the Dataset upload will fail.
