public with sharing class NamedCredentialsPlayground {
    private final static String API_VERSION = '58.0';

    /**
     * Authentication is handled by custom Auth. Provider plugins.
     */
    public void runAll() {
        // Legacy Named Credential(s);
        this.runClientCredentialsFlow();
        this.runWedServerWithPkceFlow();
        this.runJwtFlow();
        this.runPerUserNamedCredentials();
        // Secured Endpoint Named Credential(s);
        this.runSecuredEndpoint();
        this.runSecuredEndpointWithEAIP();
        Logger.debug(
            'Total HTTP callouts consumed: {0}/{1}.',
            Lists.of(Limits.getCallouts().toString(), Limits.getLimitCallouts().toString())
        );
    }

    public void runClientCredentialsFlow() {
        this.run('OAuth 2.0 Client Credentials Flow', 'SalesforceRestApi1');
    }

    public void runWedServerWithPkceFlow() {
        this.run('OAuth 2.0 Web Server With PKCE Flow', 'SalesforceRestApi2');
    }

    public void runJwtFlow() {
        this.run('OAuth 2.0 JWT Bearer Flow', 'SalesforceRestApi3');
    }

    public void runPerUserNamedCredentials() {
        this.run('Named Credential (Per-User)', 'SalesforceRestApiPerUser');
    }

    public void runSecuredEndpoint() {
        this.run('Secured Endpoint', 'SalesforceRestApi');
    }

    public void runSecuredEndpointWithEAIP() {
        this.run('Secured Endpoint (EAIP)', 'SalesforceRestApiEAIP');
    }

    private void run(String oauthFlowToTest, String namedCredentialApiName) {
        Integer currentCalloutsConsumed = Limits.getCallouts();
        try {
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
            if (resp.getStatusCode() != 200) {
                Logger.error('Response Body: {0}', Lists.of(resp.getBody()));
                throw new IllegalArgumentException('Unsuccessful status code returned: ' + resp.getStatusCode().toString());
            }
            Logger.debug('{0} ({1}) > HTTP Status = {2}', Lists.of(namedCredentialApiName, oauthFlowToTest, resp.getStatus()));
            OrganizationsPayload responsePayload = (OrganizationsPayload) JSON.deserialize(
                resp.getBody(),
                OrganizationsPayload.class
            );
            if (responsePayload.records.isEmpty()) {
                throw new IllegalArgumentException('Empty payload returned: ' + responsePayload.toString());
            }
            Logger.debug('Consumed {0} HTTP callout(s).', Lists.of((Limits.getCallouts() - currentCalloutsConsumed).toString()));
        } catch (Exception ex) {
            Logger.error('{0} ({1}) : FAILED', Lists.of(oauthFlowToTest, namedCredentialApiName));
            Logger.error(ex);
        }
    }

    public class OrganizationsPayload {
        public Integer totalSize;
        public Boolean done;
        public List<Organization> records;
    }
}
