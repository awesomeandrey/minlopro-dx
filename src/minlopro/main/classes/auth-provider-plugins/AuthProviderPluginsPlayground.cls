public with sharing class AuthProviderPluginsPlayground {
    private final static String API_VERSION = '58.0';

    /**
     * Authentication is handled by custom Auth. Provider plugins.
     */
    public void runAll() {
        this.runClientCredentialsFlow();
        this.runWedServerWithPkceFlow();
        this.runJwtFlow();
    }

    public void runClientCredentialsFlow() {
        this.run('SalesforceRestApi');
    }

    public void runWedServerWithPkceFlow() {
        this.run('SalesforceRestApi2');
    }

    public void runJwtFlow() {
        this.run('SalesforceRestApi3');
    }

    private void run(String namedCredentialApiName) {
        // Prepare HTTP request;
        HttpRequest req = new HttpRequest();
        String encodedQuery = EncodingUtil.urlEncode('SELECT Id, Name, InstanceName FROM Organization', 'UTF-8');
        String endpoint = String.format(
            'callout:{0}/services/data/v{1}/query?q={2}',
            Lists.of(namedCredentialApiName, API_VERSION, encodedQuery)
        );
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        // Invoke callout and parse response;
        HttpResponse resp = new Http().send(req);
        Logger.debug(
            '{0} > HTTP Response Status Code = {1}',
            Lists.of(namedCredentialApiName, String.valueOf(resp.getStatusCode()))
        );
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
