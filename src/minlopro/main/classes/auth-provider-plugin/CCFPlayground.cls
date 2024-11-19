public with sharing class CCFPlayground {
    private final static String API_VERSION = '58.0';
    private final static String NAMED_CREDENTIAL_API_NAME = 'SalesforceRestApi';

    /**
     * Authentication is handled by custom Auth. Provider plugin ('CCFAuthProviderPlugin.cls').
     */
    public void run() {
        // Prepare HTTP request;
        HttpRequest req = new HttpRequest();
        String encodedQuery = EncodingUtil.urlEncode('SELECT Id, Name, InstanceName FROM Organization', 'UTF-8');
        String endpoint = String.format(
            'callout:{0}/services/data/v{1}/query?q={2}',
            Lists.of(NAMED_CREDENTIAL_API_NAME, API_VERSION, encodedQuery)
        );
        Logger.debug(endpoint);
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        // Invoke callout and parse response;
        HttpResponse resp = new Http().send(req);
        Logger.debug('HTTP Response Status Code = {0}', Lists.of(String.valueOf(resp.getStatusCode())));
        Assert.areEqual(200, resp.getStatusCode());
        OrganizationsPayload responsePayload = (OrganizationsPayload) JSON.deserialize(
            resp.getBody(),
            OrganizationsPayload.class
        );
        Logger.debug(responsePayload.records[0].Name);
        Assert.areEqual(1, responsePayload.totalSize);
        Assert.areEqual(1, responsePayload.records.size());
        Assert.isFalse(String.isBlank(responsePayload.records[0].Name));
    }

    public class OrganizationsPayload {
        public Integer totalSize;
        public Boolean done;
        public List<Organization> records;
    }
}
