/**
 * @description - the main class where implemented the logic of querying, syncing updating, creating of Toggl Time Entries
 *
 * Salesforce Connect or OData Connector can be enabled in Developer edition org.
 * See SF docs - https://help.salesforce.com/s/articleView?id=000387779&type=1.
 *
 * Originally inspired by https://vimera.io/tpost/huuxhen2l1-show-and-update-external-data-in-salesfo
 * Another source of inspiration - https://github.com/lmcalpin/custom_adapter_demo/blob/master/CrossOrgDataSourceConnection.apex
 *
 * Baseline implementation is taken from https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_connector_example_loopback.htm
 */
global class MinloproContactsConnection extends DataSource.Connection {
    private static final String CONTACTS_TABLE_NAME = 'SalesforceContact';
    private DataSource.ConnectionParams connectionParams;

    global MinloproContactsConnection() {
    }

    global MinloproContactsConnection(DataSource.ConnectionParams connectionParams) {
        this.connectionParams = connectionParams;
        // Sample output: {"username":null,"repository":null,"protocol":"NONE","principalType":"ANONYMOUS","password":null,"oauthToken":null,"endpoint":null,"certificateName":null}
        // Logger.debug(JSON.serialize(connectionParams));
    }

    override global List<DataSource.Table> sync() {
        Logger.debug('sync()');

        // Table creation;
        DataSource.Table tbl = new DataSource.Table();
        tbl.labelSingular = 'Salesforce Contact';
        tbl.labelPlural = 'Salesforce Contacts';
        tbl.name = CONTACTS_TABLE_NAME;
        tbl.description = 'Salesforce Contacts via Apex Connector';
        tbl.nameColumn = 'Name';

        // Columns creation;
        List<DataSource.Column> columns = new List<DataSource.Column>();
        columns.add(DataSource.Column.text('ExternalId', 18));
        columns.add(DataSource.Column.url('DisplayUrl', 1000));
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
                'Salesforce Owner ID',
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
        tbl.columns = columns;

        return new List<DataSource.Table>{ tbl };
    }

    override global DataSource.TableResult query(DataSource.QueryContext context) {
        Logger.debug('query()');
        String targetTableName = context.tableSelection.tableSelected;
        Logger.debug('Target Table Name = {0}', Lists.of(targetTableName));
        if (!targetTableName.equalsIgnoreCase(CONTACTS_TABLE_NAME)) {
            throw new IllegalArgumentException('Only "SalesforceContact" table can be queried!');
        }
        Integer limitValue = context.maxResults;
        Integer offsetValue = context.offset;
        Logger.debug('Limit = {0} Offset = {1}', new List<Object>{ limitValue, offsetValue });
        if (
            context.tableSelection.columnsSelected.size() == 1 &&
            context.tableSelection.columnsSelected.get(0).aggregation == DataSource.QueryAggregation.COUNT
        ) {
            Integer count = this.execCount(this.getCountQuery(context));
            List<Map<String, Object>> countResponse = new List<Map<String, Object>>();
            Map<String, Object> countRow = new Map<String, Object>();
            countRow.put(context.tableSelection.columnsSelected.get(0).columnName, count);
            countResponse.add(countRow);
            return DataSource.TableResult.get(context, countResponse);
        } else {
            List<Map<String, Object>> rows = this.execQuery(this.getSoqlQuery(context));
            return DataSource.TableResult.get(context, rows);
        }
    }

    override global List<DataSource.TableResult> search(DataSource.SearchContext context) {
        return DataSource.SearchUtils.searchByName(context, this);
    }

    // Service Methods

    private List<Map<String, Object>> execQuery(String soqlQuery) {
        return this.fetchContacts(soqlQuery);
    }

    private Integer execCount(String soqlQuery) {
        return this.fetchContactsResultSet(soqlQuery).totalSize;
    }

    private String getCountQuery(DataSource.QueryContext context) {
        String baseQuery = 'SELECT COUNT() FROM Contact';
        String filter = this.getSoqlFilter('', context.tableSelection.filter);
        if (filter.length() > 0) {
            return baseQuery + ' WHERE ' + filter;
        }
        return baseQuery;
    }

    private String getSoqlQuery(DataSource.QueryContext context) {
        fflib_QueryFactory factory = new fflib_QueryFactory(Contact.SObjectType);
        factory.selectField(Contact.Id);
        factory.selectField(Contact.Name);
        factory.selectField(Contact.OwnerId);
        factory.selectField('Owner.Name');
        factory.selectField('Owner.Username');
        if (context.maxResults != 0) {
            factory.setLimit(Math.min(context.maxResults, 1000));
        }
        if (context.offset != 0) {
            factory.setOffset(context.offset);
        }
        String filter = this.getSoqlFilter('', context.tableSelection.filter);
        if (String.isNotBlank(filter)) {
            factory.setCondition(filter);
        }
        return factory.toSOQL();
    }

    private String getSoqlFilter(String query, DataSource.Filter filter) {
        if (filter == null) {
            return query;
        }
        String append;
        DataSource.FilterType type = filter.type;
        if (type == DataSource.FilterType.NOT_) {
            DataSource.Filter subfilter = filter.subfilters.get(0);
            append = this.getSoqlFilter('NOT', subfilter);
        } else if (type == DataSource.FilterType.AND_) {
            append = this.getSoqlFilterCompound('AND', filter.subfilters);
        } else if (type == DataSource.FilterType.OR_) {
            append = this.getSoqlFilterCompound('OR', filter.subfilters);
        } else {
            append = this.getSoqlFilterExpression(filter);
        }
        return query + ' ' + append;
    }

    private String getSoqlFilterCompound(String operator, List<DataSource.Filter> subfilters) {
        String expression = ' (';
        Boolean first = true;
        for (DataSource.Filter subfilter : subfilters) {
            if (first) {
                first = false;
            } else {
                expression += ' ' + operator + ' ';
            }
            expression += this.getSoqlFilter('', subfilter);
        }
        expression += ') ';
        return expression;
    }

    private String getSoqlFilterExpression(DataSource.Filter filter) {
        String columnName = filter.columnName;
        String operator;
        Object expectedValue = filter.columnValue;
        if (filter.type == DataSource.FilterType.EQUALS) {
            operator = '=';
        } else if (filter.type == DataSource.FilterType.NOT_EQUALS) {
            operator = '<>';
        } else if (filter.type == DataSource.FilterType.LESS_THAN) {
            operator = '<';
        } else if (filter.type == DataSource.FilterType.GREATER_THAN) {
            operator = '>';
        } else if (filter.type == DataSource.FilterType.LESS_THAN_OR_EQUAL_TO) {
            operator = '<=';
        } else if (filter.type == DataSource.FilterType.GREATER_THAN_OR_EQUAL_TO) {
            operator = '>=';
        } else if (filter.type == DataSource.FilterType.STARTS_WITH) {
            return this.mapColumnName(columnName) + ' LIKE \'' + String.valueOf(expectedValue) + '%\'';
        } else if (filter.type == DataSource.FilterType.ENDS_WITH) {
            return this.mapColumnName(columnName) + ' LIKE \'%' + String.valueOf(expectedValue) + '\'';
        } else if (filter.type == DataSource.FilterType.LIKE_) {
            return this.mapColumnName(columnName) + ' LIKE \'' + String.valueOf(expectedValue) + '\'';
        } else {
            throwException('Implementing other filter types is left as an exercise for the reader: ' + filter.type);
        }
        return this.mapColumnName(columnName) + ' ' + operator + ' ' + this.wrapValue(expectedValue);
    }

    private String mapColumnName(String apexName) {
        if (apexName.equalsIgnoreCase('ExternalId')) {
            return 'Id';
        } else if (apexName.equalsIgnoreCase('DisplayUrl')) {
            return 'Id';
        }
        return apexName;
    }

    private String wrapValue(Object foundValue) {
        if (foundValue instanceof String) {
            return '\'' + String.valueOf(foundValue) + '\'';
        }
        return String.valueOf(foundValue);
    }

    private ContactsResult fetchContactsResultSet(String soqlQuery) {
        Logger.debug(soqlQuery);
        String encodedQuery = EncodingUtil.urlEncode(soqlQuery, 'UTF-8');
        String endpoint = String.format(
            'callout:{0}/services/data/v{1}/query?q={2}',
            Lists.of(Constants.NamedCredential.Loopback, Constants.Org.ApiVersion, encodedQuery)
        );
        Logger.debug(endpoint);
        // Prepare HTTP request;
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        try {
            // Invoke callout and parse response;
            HttpResponse resp = new Http().send(req);
            Logger.debug('Response Status Code = {0}', Lists.of(String.valueOf(resp.getStatusCode())));
            Logger.debug(String.valueOf(resp.getBody().abbreviate(500)));
            return (ContactsResult) JSON.deserialize(resp.getBody(), ContactsResult.class);
        } catch (Exception ex) {
            Logger.error(JSON.serialize(Exceptions.getDetails(ex)));
            throw new IllegalArgumentException(ex.getMessage());
        }
    }

    private List<Map<String, Object>> fetchContacts(String soqlQuery) {
        try {
            ContactsResult responsePayload = this.fetchContactsResultSet(soqlQuery);
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
        public String Name;
        public String Username;
    }
}
