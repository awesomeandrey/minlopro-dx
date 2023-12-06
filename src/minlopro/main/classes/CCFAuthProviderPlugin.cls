/**
 * @description This Apex class functions as an authentication plugin tailored for Auth. Providers,
 * enabling seamless authentication to external systems that implement Client Credentials OAuth Flow.
 * Used together with Auth. Provider and Named Credential.
 */

public class CCFAuthProviderPlugin extends Auth.AuthProviderPluginClass {
    public String getCustomMetadataType() {
        return CCF_Configurations__mdt.SObjectType.getDescribe().getName();
    }

    public PageReference initiate(Map<String, String> authProviderConfiguration, String stateToPropagate) {
        String callbackUrl = authProviderConfiguration.get('CallbackUrl__c');
        callbackUrl += '?state=' + stateToPropagate;
        return new PageReference(callbackUrl);
    }

    public Auth.AuthProviderTokenResponse handleCallback(
        Map<String, String> authProviderConfiguration,
        Auth.AuthProviderCallbackState state
    ) {
        String authProviderName = authProviderConfiguration.get('CallbackUrl__c').substringAfterLast('/');
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
        final String tokenEndpointUrl = authProviderConfiguration.get('TokenEndpointUrl__c');
        final String clientId = authProviderConfiguration.get('ClientId__c');
        final String clientSecret = authProviderConfiguration.get('ClientSecret__c');
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
            new List<String>{ clientId, clientSecret, grant_type }
        );
        request.setBody(body);
        HttpResponse response = http.send(request);

        // If request is not successful, then throw an exception
        if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
            throw new Auth.AuthProviderPluginException(generateErrorMessage(response.getBody()));
        }

        return (OAuthResponsePayload) JSON.deserialize(response.getBody(), OAuthResponsePayload.class);
    }

    private String generateErrorMessage(String responseBody) {
        // TODO - add logging;
        Map<String, String> responseMap = (Map<String, String>) JSON.deserialize(responseBody, Map<String, String>.class);
        return String.format(
            'Authentication error occurred in "CCFAuthProviderPlugin"! Code:{0}, Error:{1}.',
            new List<String>{ responseMap.get('ErrorCode'), responseMap.get('Error') }
        );
    }

    public class OAuthResponsePayload {
        public String access_token;
    }
}
