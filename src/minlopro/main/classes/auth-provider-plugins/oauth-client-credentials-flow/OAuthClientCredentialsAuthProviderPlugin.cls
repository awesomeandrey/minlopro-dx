/**
 * @description This Apex class functions as an authentication plugin tailored for Auth. Providers,
 * enabling seamless authentication to external systems that implement "OAuth 2.0 Client Credentials Flow".
 * Used together with Auth. Provider and Named Credential.
 *
 * See https://help.salesforce.com/s/articleView?id=xcloud.remoteaccess_oauth_client_credentials_flow.htm&type=5
 *
 */
public class OAuthClientCredentialsAuthProviderPlugin extends Auth.AuthProviderPluginClass {
    public String getCustomMetadataType() {
        return AuthProviderSetting__mdt.SObjectType.getDescribe().getName();
    }

    public PageReference initiate(Map<String, String> authProviderConfiguration, String stateToPropagate) {
        try {
            AuthProviderSettingParser authSettings = AuthProviderSettingParser.build(authProviderConfiguration);
            String redirectUri = String.format('{0}?state={1}', Lists.of(authSettings.redirect_uri, stateToPropagate));
            return new PageReference(redirectUri);
        } catch (Exception ex) {
            Logger.error(ex);
            throw new Auth.AuthProviderPluginException(ex.getMessage());
        }
    }

    public Auth.AuthProviderTokenResponse handleCallback(
        Map<String, String> authProviderConfiguration,
        Auth.AuthProviderCallbackState state
    ) {
        try {
            AuthProviderSettingParser authSettings = AuthProviderSettingParser.build(authProviderConfiguration);
            OAuthTokenResponsePayload responsePayload = this.fetchAccessToken(authSettings);
            return new Auth.AuthProviderTokenResponse(
                authSettings.authProviderName,
                responsePayload.access_token,
                responsePayload.access_token, // Override 'refresh_token' with actual 'access_token';
                state.queryParameters.get('state')
            );
        } catch (Exception ex) {
            Logger.error(ex);
            throw new Auth.AuthProviderPluginException(ex.getMessage());
        }
    }

    public override Auth.OAuthRefreshResult refresh(Map<String, String> authProviderConfiguration, String refreshToken) {
        try {
            AuthProviderSettingParser authSettings = AuthProviderSettingParser.build(authProviderConfiguration);
            OAuthTokenResponsePayload responsePayload = this.fetchAccessToken(authSettings);
            return new Auth.OAuthRefreshResult(
                responsePayload.access_token,
                responsePayload.access_token // Override 'refresh_token' with actual 'access_token';
            );
        } catch (Exception ex) {
            Logger.error(ex);
            throw new Auth.AuthProviderPluginException(ex.getMessage());
        }
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

    private OAuthTokenResponsePayload fetchAccessToken(AuthProviderSettingParser authSettings) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(authSettings.token_url);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=UTF-8');
        request.setMethod('POST');
        String body = String.format(
            'client_id={0}&client_secret={1}&grant_type=client_credentials',
            Lists.of(authSettings.client_id, authSettings.client_secret)
        );
        request.setBody(body);
        HttpResponse response = new Http().send(request);
        final Set<Integer> allowedStatusCodes = new Set<Integer>{ 200, 201 };
        if (!allowedStatusCodes.contains(response.getStatusCode())) {
            String errorMessage = String.format('Authentication error occurred: {0}', Lists.of(response.getBody()));
            Logger.error(errorMessage);
            throw new Auth.AuthProviderPluginException(errorMessage);
        }
        return (OAuthTokenResponsePayload) JSON.deserialize(response.getBody(), OAuthTokenResponsePayload.class);
    }
}
