/**
 * @description - the main class where implemented the logic of querying, syncing updating, creating of Toggl Time Entries
 */
//global class MinloproContactsConnection extends DataSource.Connection {
global class MinloproContactsConnection {
    //    private DataSource.ConnectionParams conParams;
    //
    //    private static Map<String, String> FIELD_MAP = new Map<String, String>{
    //        'Id' => 'id',
    //        'ExternalId' => 'id',
    //        'DisplayUrl' => 'id',
    //        'ProjectId' => 'project_id',
    //        'TaskId' => 'task_id',
    //        'UserId' => 'user_id',
    //        'WorkspaceId' => 'workspace_id',
    //        'At' => 'at',
    //        'Billable' => 'billable',
    //        'Description' => 'description',
    //        'Duration' => 'duration',
    //        'Start' => 'start',
    //        'Stop' => 'stop'
    //    };
    //
    //    global MinloproContactsConnection(DataSource.ConnectionParams connectionParams) {
    //        this.conParams = connectionParams;
    //    }
    //
    //    global MinloproContactsConnection() {
    //    }
    //
    //    /**
    //     * Below method is invoked if global search is used or SOSL issued
    //     * */
    //    //    override global List<DataSource.TableResult> search(DataSource.SearchContext context) {
    //    //        List<DataSource.TableResult> results = new List<DataSource.TableResult>();
    //    //        for (DataSource.TableSelection tableSelection : context.tableSelections) {
    //    //            results.add(DataSource.TableResult.get(tableSelection, getRows()));
    //    //        }
    //    //        return results;
    //    //    }
    //
    //    /**
    //     * Below method is invoked if global search is used or SOSL issued
    //     * */
    //    override global List<DataSource.TableResult> search(DataSource.SearchContext c) {
    //        return DataSource.SearchUtils.searchByName(c, new MinloproContactsConnection(this.conParams));
    //    }
    //
    //    /**
    //     * Abstract Method sync() must be implemented as part of DataSource.Connection class
    //     * This method would define Schema of External Object
    //     *
    //     * NOTE : ExternalId and DisplayURL are mandatory column
    //     * */
    //    override global List<DataSource.Table> sync() {
    //        List<DataSource.Table> tables = new List<DataSource.Table>();
    //        List<DataSource.Column> columns = new List<DataSource.Column>();
    //
    //        //Standard fields
    //        columns.add(DataSource.Column.text('ExternalId', 18));
    //        columns.add(DataSource.Column.url('DisplayUrl', 1000));
    //
    //        //Custom fields
    //        columns.add(
    //            DataSource.Column.get(
    //                'Name',
    //                'Name',
    //                'Name Field for the table',
    //                true,
    //                true,
    //                DataSource.DataType.STRING_SHORT_TYPE,
    //                10,
    //                0
    //            )
    //        );
    //        columns.add(DataSource.Column.get('ProjectId', 'Project Id', '', true, true, DataSource.DataType.NUMBER_TYPE, 18, 0));
    //        columns.add(DataSource.Column.get('TaskId', 'Task Id', '', true, true, DataSource.DataType.NUMBER_TYPE, 18, 0));
    //        columns.add(
    //            DataSource.Column.get(
    //                'UserId',
    //                'User Id',
    //                '',
    //                true,
    //                true,
    //                DataSource.DataType.INDIRECT_LOOKUP_TYPE,
    //                18,
    //                0,
    //                'User',
    //                'TogglUserId__c'
    //            )
    //        );
    //        columns.add(
    //            DataSource.Column.get('WorkspaceId', 'WorkspaceId Id', '', true, true, DataSource.DataType.NUMBER_TYPE, 18, 0)
    //        );
    //        columns.add(
    //            DataSource.Column.get(
    //                'At',
    //                'At',
    //                'Timestamp that is sent in the response, ' + 'indicates the time item was last updated',
    //                false,
    //                false,
    //                DataSource.DataType.STRING_SHORT_TYPE,
    //                18,
    //                0
    //            )
    //        );
    //        columns.add(DataSource.Column.get('Billable', 'Billable', '', true, true, DataSource.DataType.BOOLEAN_TYPE, 255, 0));
    //        columns.add(
    //            DataSource.Column.get('Description', 'Description', '', true, true, DataSource.DataType.STRING_LONG_TYPE, 255, 0)
    //        );
    //        columns.add(
    //            DataSource.Column.get(
    //                'Duration',
    //                'Duration',
    //                'Time entry duration in seconds. ' +
    //                    'If the time entry is currently running, the duration attribute contains a negative value, ' +
    //                    'denoting the start of the time entry in seconds since epoch (Jan 1 1970). ' +
    //                    'The correct duration can be calculated as current_time + duration, ' +
    //                    'where current_time is the current time in seconds since epoch. (integer, required)',
    //                true,
    //                true,
    //                DataSource.DataType.NUMBER_TYPE,
    //                18,
    //                0
    //            )
    //        );
    //
    //        columns.add(
    //            DataSource.Column.get('Start', 'Start Datetime', '', true, true, DataSource.DataType.STRING_SHORT_TYPE, 20, 0)
    //        );
    //        columns.add(DataSource.Column.get('Stop', 'Stop Datetime', '', true, true, DataSource.DataType.STRING_SHORT_TYPE, 20, 0));
    //
    //        //Table creation
    //        DataSource.Table newTable = new DataSource.Table();
    //        newTable.labelSingular = 'Toggl Time Entry';
    //        newTable.labelPlural = 'Toggl Time Entries';
    //        newTable.name = 'TogglTimeEntry';
    //        newTable.description = 'Toggl Time Entry via Apex Connector';
    //        newTable.nameColumn = 'Name';
    //        newTable.columns = columns;
    //
    //        tables.add(newTable);
    //        /*
    //        Field ref: https://github.com/toggl/toggl_api_docs/blob/master/chapters/time_entries.md
    //        Time entry has the following properties
    //
    //        description: (string, strongly suggested to be used)
    //        wid: workspace ID (integer, required if pid or tid not supplied)
    //        pid: project ID (integer, not required)
    //        tid: task ID (integer, not required)
    //        billable: (boolean, not required, default false, available for pro workspaces)
    //        start: time entry start time (string, required, ISO 8601 date and time)
    //        stop: time entry stop time (string, not required, ISO 8601 date and time)
    //        duration: time entry duration in seconds. If the time entry is currently running, the duration attribute contains a negative value, denoting the start of the time entry in seconds since epoch (Jan 1 1970). The correct duration can be calculated as current_time + duration, where current_time is the current time in seconds since epoch. (integer, required)
    //        created_with: the name of your client app (string, required)
    //        tags: a list of tag names (array of strings, not required)
    //        duronly: should Toggl show the start and stop time of this time entry? (boolean, not required)
    //        at: timestamp that is sent in the response, indicates the time item was last updated
    //         */
    //        //        tables.add(DataSource.Table.get('TimeEntry', 'ExternalId', columns));
    //        return tables;
    //    }
    //
    //    override global DataSource.TableResult query(DataSource.QueryContext c) {
    //        return DataSource.TableResult.get(c, DataSource.QueryUtils.process(c, getRows()));
    //    }
    //
    //    /**
    //     * This method is called everytime when SOQL is issued against external Object
    //     * or while using list view or viewing detail page.
    //     *
    //     * Note : Ideally searching should be done at server side however for sake of
    //     * simplicity, we would be using "DataSource.QueryUtils" class provided by
    //     * Salesforce. In this case, filtering and sorting would be done in Salesforce
    //     * once response returned by external REST API
    //     * */
    //    //    override global DataSource.TableResult query(DataSource.QueryContext context) {
    //    //        if (context.tableSelection.columnsSelected.size() == 1 && context.tableSelection.columnsSelected.get(0).aggregation == DataSource.QueryAggregation.COUNT) {
    //    //            List<Map<String, Object>> response = DataSource.QueryUtils.filter(context, getRows());
    //    //            List<Map<String, Object>> countResponse = new List<Map<String, Object>>();
    //    //            Map<String, Object> countRow = new Map<String, Object>();
    //    //            countRow.put(context.tableSelection.columnsSelected.get(0).columnName, response.size());
    //    //            countResponse.add(countRow);
    //    //            return DataSource.TableResult.get(context, countResponse);
    //    //        } else {
    //    //            List<Map<String, Object>> filteredRows = DataSource.QueryUtils.filter(context, getRows());
    //    //            List<Map<String, Object>> sortedRows = DataSource.QueryUtils.sort(context, filteredRows);
    //    //            List<Map<String, Object>> limitedRows = DataSource.QueryUtils.applyLimitAndOffset(context, sortedRows);
    //    //            return DataSource.TableResult.get(context, limitedRows);
    //    //        }
    //    //    }
    //
    //    global override List<DataSource.UpsertResult> upsertRows(DataSource.UpsertContext context) {
    //        List<DataSource.UpsertResult> results = new List<DataSource.UpsertResult>();
    //        List<Map<String, Object>> rows = context.rows;
    //        Http h = new Http();
    //
    //        for (Integer i = 0; i < rows.size(); i++) {
    //            Map<String, Object> row = rows[i];
    //            HttpRequest request = new HttpRequest();
    //            request.setHeader('Content-Type', 'application/json');
    //            request.setTimeout(120000);
    //
    //            Map<String, Object> timeEntry = new Map<String, Object>();
    //            //If there is no External ID, than mean it's a new record
    //            if (String.isBlank((String) row.get('ExternalId'))) {
    //                request.setMethod('POST');
    //                request.setEndPoint('callout:Toggl' + '/api/v9/workspaces/' + row.get('WorkspaceId') + '/time_entries');
    //            } else {
    //                request.setMethod('PUT');
    //                request.setEndpoint(
    //                    'callout:Toggl' + '/api/v9/workspaces/' + row.get('WorkspaceId') + '/time_entries/' + row.get('ExternalId')
    //                );
    //            }
    //
    //            timeEntry.put('billable', row.get('Billable'));
    //            timeEntry.put('created_with', 'Salesforce');
    //            timeEntry.put('description', row.get('Description'));
    //            timeEntry.put('project_id', row.get('ProjectId'));
    //            timeEntry.put('start', String.valueOf(row.get('Start')).replace('+00:00', 'Z'));
    //            timeEntry.put('stop', String.valueOf(row.get('Stop')).replace('+00:00', 'Z'));
    //            timeEntry.put('task_id', row.get('TaskId'));
    //            timeEntry.put('user_id', Integer.valueOf(row.get('UserId')));
    //            timeEntry.put('workspace_id', row.get('WorkspaceId'));
    //            String jsonBody = JSON.serialize(timeEntry);
    //            request.setBody(jsonBody);
    //            HttpResponse response = h.send(request);
    //
    //            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    //            if (response.getStatusCode() == 200) {
    //                String objId = String.valueOf(responseBody.get('id'));
    //                if (String.isBlank(objId)) {
    //                    objId = String.valueOf(row.get('ExternalId'));
    //                }
    //                results.add(DataSource.UpsertResult.success(objId));
    //            } else {
    //                results.add(
    //                    DataSource.UpsertResult.failure(
    //                        String.valueOf(row.get('ExternalId')),
    //                        'The callout resulted in an error: ' + response.getStatusCode() + ' - ' + response.getBody()
    //                    )
    //                );
    //            }
    //        }
    //        return results;
    //    }
    //    /**
    //     * Make REST callout to external system and parse the result in required format
    //     * */
    //    private List<Map<String, Object>> getRows() {
    //        List<Map<String, Object>> returnDataset = new List<Map<String, Object>>();
    //        String urlParams = '/api/v9/me/time_entries';
    //        HttpRequest req = new HttpRequest();
    //        req.setEndPoint('callout:Toggl' + urlParams); //uses the Toggl_Reports Named Credential
    //        req.setMethod('GET');
    //        HttpResponse res = new Http().send(req);
    //
    //        List<Object> responseData = (List<Object>) JSON.deserializeUntyped(res.getBody());
    //        Integer counter = responseData.size();
    //        for (Object detail : responseData) {
    //            Map<String, Object> detailMap = (Map<String, Object>) detail;
    //            Map<String, Object> currentRow = new Map<String, Object>();
    //
    //            currentRow.put('ExternalId', detailMap.get('id'));
    //            currentRow.put('DisplayUrl', 'https://api.track.toggl.com/api/v9/me/time_entries/' + detailMap.get('id'));
    //            currentRow.put('Name', 'TTE-00000' + counter);
    //            currentRow.put('ProjectId', Integer.valueOf(detailMap.get('project_id')));
    //            currentRow.put('TaskId', Integer.valueOf(detailMap.get('task_id')));
    //            currentRow.put('UserId', Integer.valueOf(detailMap.get('user_id')));
    //            currentRow.put('WorkspaceId', Integer.valueOf(detailMap.get('workspace_id')));
    //            currentRow.put('At', detailMap.get('at'));
    //            currentRow.put('Billable', detailMap.get('billable'));
    //            currentRow.put('Description', detailMap.get('description'));
    //            currentRow.put('Duration', detailMap.get('duration'));
    //            currentRow.put('Start', detailMap.get('start'));
    //            currentRow.put('Stop', detailMap.get('stop'));
    //            returnDataset.add(currentRow);
    //            counter--;
    //        }
    //        return returnDataset;
    //    }
}
