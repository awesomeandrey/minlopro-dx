public with sharing class AuthProviderPluginsPlayground {
    private final static String API_VERSION = '58.0';

    /**
     * Authentication is handled by custom Auth. Provider plugins.
     */
    public void run() {
        this.runCCF();
        this.runWSPKCE();
    }

    private void runCCF() {
        this.run('SalesforceRestApi');
    }

    private void runWSPKCE() {
        this.run('SalesforceRestApi2');
    }

    private void run(String namedCredentialApiName) {
        // Prepare HTTP request;
        HttpRequest req = new HttpRequest();
        String encodedQuery = EncodingUtil.urlEncode('SELECT Id, Name, InstanceName FROM Organization', 'UTF-8');
        String endpoint = String.format(
            'callout:{0}/services/data/v{1}/query?q={2}',
            Lists.of(namedCredentialApiName, API_VERSION, encodedQuery)
        );
        Logger.debug(endpoint);
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
