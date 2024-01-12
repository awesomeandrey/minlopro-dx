/**
 * @description - the main class where implemented the logic of querying, syncing updating, creating of Toggl Time Entries
 *
 * Salesforce Connect or OData Connector can be enabled in Developer edition org.
 * See SF docs - https://help.salesforce.com/s/articleView?id=000387779&type=1.
 *
 * Originally inspired by https://vimera.io/tpost/huuxhen2l1-show-and-update-external-data-in-salesfo
 * Another source of inspiration - https://github.com/lmcalpin/custom_adapter_demo/blob/master/CrossOrgDataSourceConnection.apex
 */
global class MinloproContactsConnection extends DataSource.Connection {
    private static final String API_VERSION = '58.0';
    private static final String NAMED_CREDENTIAL_API_NAME = 'SalesforceRestApi';
    private DataSource.ConnectionParams connectionParams;

    global MinloproContactsConnection() {
    }

    global MinloproContactsConnection(DataSource.ConnectionParams connectionParams) {
        this.connectionParams = connectionParams;
        // Sample output: {"username":null,"repository":null,"protocol":"NONE","principalType":"ANONYMOUS","password":null,"oauthToken":null,"endpoint":null,"certificateName":null}
        Logger.debug(JSON.serialize(connectionParams));
    }

    override global List<DataSource.Table> sync() {
        Logger.debug('sync()');
        DataSource.Table contactsTable = this.initContactsTableDefinition();
        return new List<DataSource.Table>{ contactsTable };
    }

    override global DataSource.TableResult query(DataSource.QueryContext cx) {
        Logger.debug('query()');
        Logger.debug(JSON.serialize(cx.queryMoreToken));
        Logger.debug(JSON.serialize(cx.tableSelection));
        if (cx.tableSelection.tableSelected.equalsIgnoreCase('SalesforceContacts')) {
            throw new IllegalArgumentException('Only "SalesforceContacts" table can be queried!');
        }
        return DataSource.TableResult.get(cx, DataSource.QueryUtils.process(cx, this.fetchContacts(0, 100)));
    }

    /**
     * This method is called everytime when SOQL is issued against external Object
     * or while using list view or viewing detail page.
     *
     * Note : Ideally searching should be done at server side however for sake of
     * simplicity, we would be using "DataSource.QueryUtils" class provided by
     * Salesforce. In this case, filtering and sorting would be done in Salesforce
     * once response returned by external REST API
     * */
    //    override global DataSource.TableResult query(DataSource.QueryContext context) {
    //        if (context.tableSelection.columnsSelected.size() == 1 && context.tableSelection.columnsSelected.get(0).aggregation == DataSource.QueryAggregation.COUNT) {
    //            List<Map<String, Object>> response = DataSource.QueryUtils.filter(context, getRows());
    //            List<Map<String, Object>> countResponse = new List<Map<String, Object>>();
    //            Map<String, Object> countRow = new Map<String, Object>();
    //            countRow.put(context.tableSelection.columnsSelected.get(0).columnName, response.size());
    //            countResponse.add(countRow);
    //            return DataSource.TableResult.get(context, countResponse);
    //        } else {
    //            List<Map<String, Object>> filteredRows = DataSource.QueryUtils.filter(context, getRows());
    //            List<Map<String, Object>> sortedRows = DataSource.QueryUtils.sort(context, filteredRows);
    //            List<Map<String, Object>> limitedRows = DataSource.QueryUtils.applyLimitAndOffset(context, sortedRows);
    //            return DataSource.TableResult.get(context, limitedRows);
    //        }
    //    }

    // Service Methods;

    private List<Map<String, Object>> fetchContacts(Integer offsetValue, Integer limitValue) {
        // Prepare SOQL query;
        String query = String.format(
            'SELECT {0} FROM Contact LIMIT {1} OFFSET {2} ',
            new List<String>{
                'Id, Name, Owner.Username',
                String.valueOf(Math.min(limitValue, 1000)),
                String.valueOf(Math.min(offsetValue, 1000))
            }
        );
        Logger.debug(query);
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        String endpoint = String.format(
            'callout:{0}/services/data/v{1}/query?q={2}',
            Lists.of(NAMED_CREDENTIAL_API_NAME, API_VERSION, encodedQuery)
        );
        Logger.debug(endpoint);
        // Prepare HTTP request;
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        try {
            // Invoke callout and parse response;
            HttpResponse resp = new Http().send(req);
            Logger.debug(String.valueOf(resp.getStatusCode()));
            Logger.debug(String.valueOf(resp.getBody()));
            ContactsResult responsePayload = (ContactsResult) JSON.deserialize(resp.getBody(), ContactsResult.class);
            Logger.debug(responsePayload.totalSize);
            List<Map<String, Object>> returnDataset = new List<Map<String, Object>>();
            for (ContactResult c : responsePayload.records) {
                returnDataset.add(c.toRow());
            }
            return returnDataset;
        } catch (Exception ex) {
            Logger.error(JSON.serialize(Exceptions.getDetails(ex)));
            throw new IllegalArgumentException(ex.getMessage());
        }
    }

    private DataSource.Table initContactsTableDefinition() {
        List<DataSource.Column> columns = new List<DataSource.Column>();
        // Standard fields (mandatory ones);
        columns.add(DataSource.Column.text('ExternalId', 18));
        columns.add(DataSource.Column.url('DisplayUrl', 1000));
        // Custom fields
        columns.add(
            DataSource.Column.get(
                'Name',
                'Contact Name',
                'Compound Contact name',
                true,
                true,
                DataSource.DataType.STRING_SHORT_TYPE,
                100,
                0
            )
        );
        columns.add(
            DataSource.Column.get(
                'SalesforceOwnerId',
                'Salesforce Owner Id',
                '',
                true,
                true,
                DataSource.DataType.INDIRECT_LOOKUP_TYPE,
                18,
                0,
                'User',
                'ExternalId__c'
            )
        );
        // Table creation;
        DataSource.Table tbl = new DataSource.Table();
        tbl.labelSingular = 'Salesforce Contact';
        tbl.labelPlural = 'Salesforce Contacts';
        tbl.name = 'SalesforceContact';
        tbl.description = 'Salesforce Contacts via Apex Connector';
        tbl.nameColumn = 'Name';
        tbl.columns = columns;
        return tbl;
    }

    // Salesforce REST API Payloads;

    public class ContactsResult {
        public Integer totalSize;
        public Boolean done;
        public List<ContactResult> records;
    }

    public class ContactResult {
        public Map<String, String> attributes;
        public String Id;
        public String Name;
        public ContactOwner Owner;

        public String recordUrl {
            get {
                if (this.attributes != null && this.attributes.containsKey('url')) {
                    return this.attributes.get('url');
                }
                return null;
            }
        }

        public String ownerUsername {
            get {
                return this.Owner.Username;
            }
        }

        public Map<String, Object> toRow() {
            return new Map<String, Object>{
                'ExternalId' => this.Id,
                'DisplayUrl' => this.recordUrl,
                'Name' => this.Name,
                'SalesforceOwnerId' => this.ownerUsername
            };
        }
    }

    public class ContactOwner {
        public String Id;
        public String Username;
    }
}
