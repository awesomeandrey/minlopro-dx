/**
 * @description This Apex class functions as an authentication plugin tailored for Auth. Providers,
 * enabling seamless authentication to external systems that implement Client Credentials OAuth Flow.
 * Used together with Auth. Provider and Named Credential.
 */
public class CCFAuthProviderPlugin extends Auth.AuthProviderPluginClass {
    @TestVisible
    private final static String CALLBACK_URL = CCF_Configurations__mdt.CallbackUrl__c.getDescribe().getName();
    @TestVisible
    private final static String TOKEN_ENDPOINT_URL = CCF_Configurations__mdt.TokenEndpointUrl__c.getDescribe().getName();
    @TestVisible
    private final static String CLIENT_ID = CCF_Configurations__mdt.ClientId__c.getDescribe().getName();
    @TestVisible
    private final static String CLIENT_SECRET = CCF_Configurations__mdt.ClientSecret__c.getDescribe().getName();

    public String getCustomMetadataType() {
        return CCF_Configurations__mdt.SObjectType.getDescribe().getName();
    }

    public PageReference initiate(Map<String, String> authProviderConfiguration, String stateToPropagate) {
        String callbackUrl = authProviderConfiguration.get(CALLBACK_URL);
        callbackUrl += '?state=' + stateToPropagate;
        return new PageReference(callbackUrl);
    }

    public Auth.AuthProviderTokenResponse handleCallback(
        Map<String, String> authProviderConfiguration,
        Auth.AuthProviderCallbackState state
    ) {
        String authProviderName = authProviderConfiguration.get(CALLBACK_URL).substringAfterLast('/');
        OAuthResponsePayload responsePayload = this.fetchAccessToken(authProviderConfiguration);
        return new Auth.AuthProviderTokenResponse(
            authProviderName,
            responsePayload.access_token,
            responsePayload.access_token, // Override 'refresh_token' with actual 'access_token';
            state.queryParameters.get('state')
        );
    }

    public override Auth.OAuthRefreshResult refresh(Map<String, String> authProviderConfiguration, String refreshToken) {
        OAuthResponsePayload responsePayload = this.fetchAccessToken(authProviderConfiguration);
        return new Auth.OAuthRefreshResult(
            responsePayload.access_token,
            responsePayload.access_token // Override 'refresh_token' with actual 'access_token';
        );
    }

    public Auth.UserData getUserInfo(Map<String, String> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {
        // Simply return running user details;
        return new Auth.UserData(
            UserInfo.getUserName(),
            UserInfo.getFirstName(),
            UserInfo.getLastName(),
            UserInfo.getName(),
            UserInfo.getUserEmail(),
            null,
            UserInfo.getUserName(),
            null,
            null,
            null,
            null
        );
    }

    private OAuthResponsePayload fetchAccessToken(Map<String, String> authProviderConfiguration) {
        // Extract app credentials;
        final String tokenEndpointUrl = authProviderConfiguration.get(TOKEN_ENDPOINT_URL);
        final String clientId = authProviderConfiguration.get(CLIENT_ID);
        final String clientSecret = authProviderConfiguration.get(CLIENT_SECRET);
        final String httpMethod = 'POST';
        final String grant_type = 'client_credentials';
        // Request access token according to OAuth Client Credentials Flow;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(tokenEndpointUrl);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=UTF-8');
        request.setMethod(httpMethod);
        String body = String.format(
            'client_id={0}&client_secret={1}&grant_type={2}',
            Lists.of(clientId, clientSecret, grant_type)
        );
        request.setBody(body);
        HttpResponse response = http.send(request);
        final Set<Integer> allowedStatusCodes = new Set<Integer>{ 200, 201 };
        if (!allowedStatusCodes.contains(response.getStatusCode())) {
            String errorTemplate = 'Authentication error occurred in "CCFAuthProviderPlugin.cls" | {0}';
            String errorMessage = String.format(errorTemplate, Lists.of(response.getBody()));
            Logger.error(errorTemplate, Lists.of(response.getBody()));
            throw new Auth.AuthProviderPluginException(errorMessage);
        }
        return (OAuthResponsePayload) JSON.deserialize(response.getBody(), OAuthResponsePayload.class);
    }

    public class OAuthResponsePayload {
        public String access_token;

        public OAuthResponsePayload() {
        }

        public OAuthResponsePayload(String accessToken) {
            this.access_token = accessToken;
        }
    }
}
