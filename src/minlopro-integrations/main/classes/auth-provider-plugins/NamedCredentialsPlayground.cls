@SuppressWarnings('PMD')
public with sharing class NamedCredentialsPlayground {
    public void runAll() {
        for (NamedCredential credential : [
            SELECT DeveloperName
            FROM NamedCredential
            WHERE DeveloperName LIKE 'SalesforceRestApi%'
            ORDER BY DeveloperName ASC
        ]) {
            this.run(credential.DeveloperName);
        }
        Logger.debug(
            'Total HTTP callouts consumed: {0}/{1}.',
            Lists.of(Limits.getCallouts().toString(), Limits.getLimitCallouts().toString())
        );
    }

    private void run(String namedCredentialApiName) {
        Integer totalCalloutsConsumed = Limits.getCallouts();
        try {
            // Prepare HTTP request;
            HttpRequest req = new HttpRequest();
            String encodedQuery = EncodingUtil.urlEncode('SELECT Id, Name, InstanceName FROM Organization', 'UTF-8');
            String endpoint = String.format(
                'callout:{0}/services/data/v{1}/query?q={2}',
                Lists.of(namedCredentialApiName, Constants.Org.ApiVersion, encodedQuery)
            );
            req.setMethod('GET');
            req.setEndpoint(endpoint);
            // Invoke callout and parse response;
            HttpResponse resp = new Http().send(req);
            if (resp.getStatusCode() != 200) {
                Logger.error('Response Body: {0}', Lists.of(resp.getBody()));
                throw new IllegalArgumentException('Unsuccessful status code returned: ' + resp.getStatusCode().toString());
            }
            Integer currentCalloutsConsumed = Limits.getCallouts() - totalCalloutsConsumed;
            Logger.debug(
                '{0} > HTTP Status = {1} (callouts consumed = {2})',
                Lists.of(namedCredentialApiName, resp.getStatus(), currentCalloutsConsumed.toString())
            );
        } catch (Exception ex) {
            Logger.error('{0} : FAILED', Lists.of(namedCredentialApiName));
            Logger.error(ex);
        }
    }
}
