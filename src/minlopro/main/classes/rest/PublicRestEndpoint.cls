@RestResource(UrlMapping='/echo/*')
global without sharing class PublicRestEndpoint {
    /**
     * This class acts as a global/public REST URL endpoint.
     * This endpoint becomes available when the site (Digital Experience site) exists and is activated.
     * The Apex transaction gets instantiated on behalf of Guest user of the site, therefore
     * the Guest user should be given access to this Apex class (e.g. through permission set OR site guest user profile).
     *
     * NOTE: use [***.my.site.com] path!
     * Alternatively, use bash script "scripts/util/get_digex_site_url.sh" in order to get valid site URL.
     *
     * cURL command to use: [curl https://[your-site-domain]/services/apexrest/echo | jq .]
     * e.g. curl https://energy-nosoftware-598.scratch.my.site.com/services/apexrest/echo | jq .
     * Note 'jq' utility usage - it simply prettifies output value to the console.
     *
     * @return Transaction information.
     */
    @HttpGet
    global static Map<String, String> doGet() {
        Logger.debug('Entering Public REST Endpoint (GET)');
        Map<String, String> transactionData = new Map<String, String>();
        transactionData.put('message', 'echo');
        transactionData.put('transactionId', Request.getCurrent().getRequestId());
        transactionData.put('quiddity', Request.getCurrent().getQuiddity().name());
        transactionData.put('orgName', UserInfo.getOrganizationName());
        User runningUser = [
            SELECT Id, Name, Profile.Name, UserType
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ][0];
        transactionData.put('userId', runningUser.Id);
        transactionData.put('userName', runningUser.Name);
        transactionData.put('userProfileId', runningUser.ProfileId);
        transactionData.put('userProfileName', runningUser.Profile.Name);
        transactionData.put('userType', runningUser.UserType);
        Network currentNetwork = [
            SELECT Name, UrlPathPrefix
            FROM Network
            WHERE Id = :Network.getNetworkId()
            LIMIT 1
        ][0];
        transactionData.put('networkId', currentNetwork.Id);
        transactionData.put('networkName', currentNetwork.Name);
        transactionData.put('networkUrlPathPrefix', currentNetwork.UrlPathPrefix);
        transactionData.put('requestParameters', JSON.serialize(RestContext.request.params));
        Logger.debug('Transaction Data: {0}', Lists.of(JSON.serialize(transactionData)));
        return transactionData;
    }

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            Logger.debug('Entering Public REST Endpoint (POST)');

            // Process request;
            Logger.debug('Request Body = {0}', Lists.of(req.requestBody.toString()));
            Logger.debug('Request Params = {0}', Lists.of(req.params.toString()));

            // Verify request by key;
            String verificationKey = req.params.get('verificationKey');
            Logger.debug('Verifications Key = {0}', Lists.of(verificationKey));
            if (String.isBlank(verificationKey) || !verificationKey.equals('wow_ooha')) {
                res.statusCode = 401;
                res.responseBody = Blob.valueOf('Verification Key is not confirmed!');
                return;
            }

            // Redirect to the new URL;
            res.addHeader('Location', 'https://www.google.com');
            res.addHeader('http-equiv', 'refresh');
            res.statusCode = 301;
        } catch (Exception ex) {
            Logger.error(ex);
            res.statusCode = 500;
        }
    }
}
