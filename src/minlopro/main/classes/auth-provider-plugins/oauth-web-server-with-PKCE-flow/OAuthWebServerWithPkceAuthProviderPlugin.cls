/**
 * @description This Apex class functions as an authentication plugin tailored for Auth. Providers,
 * enabling seamless authentication to external systems that implement "OAuth 2.0 Web Server With PKCE Flow".
 * Used together with Auth. Provider and Named Credential.
 *
 * See https://help.salesforce.com/s/articleView?id=xcloud.remoteaccess_oauth_web_server_flow.htm&type=5
 */
public class OAuthWebServerWithPkceAuthProviderPlugin extends Auth.AuthProviderPluginClass {
    @TestVisible
    private final static String PKCE_CACHE_KEY = 'minloproPKCE';

    public String getCustomMetadataType() {
        return AuthProviderSetting__mdt.SObjectType.getDescribe().getName();
    }

    public PageReference initiate(Map<String, String> authProviderConfiguration, String stateToPropagate) {
        try {
            AuthProviderSettingParser authSettings = AuthProviderSettingParser.build(authProviderConfiguration);
            PKCE.State pkceState = PKCE.generate(PKCE_CACHE_KEY);
            String authorizeUrl = authSettings.authorize_url + '?';
            authorizeUrl += String.format('{0}={1}&', Lists.of('client_id', authSettings.client_id));
            authorizeUrl += String.format('{0}={1}&', Lists.of('redirect_uri', authSettings.redirect_uri)); // Match with the one in Connected App;
            authorizeUrl += String.format('{0}={1}&', Lists.of('response_type', 'code'));
            authorizeUrl += String.format('{0}={1}&', Lists.of('code_challenge', pkceState.code_challenge));
            authorizeUrl += String.format('{0}={1}', Lists.of('state', stateToPropagate));
            return new PageReference(authorizeUrl);
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
            String code = state?.queryParameters?.get('code');
            AuthProviderSettingParser authSettings = AuthProviderSettingParser.build(authProviderConfiguration);
            PKCE.State pkceState = PKCE.get(PKCE_CACHE_KEY);
            // Exchange code for access token;
            String body = String.format('{0}={1}&', Lists.of('grant_type', 'authorization_code'));
            body += String.format('{0}={1}&', Lists.of('code', code));
            body += String.format('{0}={1}&', Lists.of('client_id', authSettings.client_id));
            body += String.format('{0}={1}&', Lists.of('client_secret', authSettings.client_secret));
            body += String.format('{0}={1}&', Lists.of('redirect_uri', authSettings.redirect_uri)); // Match with the one in Connected App;
            body += String.format('{0}={1}', Lists.of('code_verifier', pkceState?.code_verifier));
            HttpRequest request = new HttpRequest();
            request.setEndpoint(authSettings.token_url);
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=UTF-8');
            request.setMethod('POST');
            request.setBody(body);
            HttpResponse response = new Http().send(request);
            this.validateResponse(response);
            OAuthTokenResponsePayload responsePayload = (OAuthTokenResponsePayload) JSON.deserialize(
                response.getBody(),
                OAuthTokenResponsePayload.class
            );
            return new Auth.AuthProviderTokenResponse(
                authSettings.auth_provider_name,
                responsePayload.access_token,
                responsePayload.refresh_token,
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
            String body = String.format('{0}={1}&', Lists.of('grant_type', 'refresh_token'));
            body += String.format('{0}={1}&', Lists.of('client_id', authSettings.client_id));
            body += String.format('{0}={1}&', Lists.of('client_secret', authSettings.client_secret));
            body += String.format('{0}={1}', Lists.of('refresh_token', refreshToken));
            HttpRequest request = new HttpRequest();
            request.setEndpoint(authSettings.token_url);
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=UTF-8');
            request.setMethod('POST');
            request.setBody(body);
            HttpResponse response = new Http().send(request);
            this.validateResponse(response);
            OAuthTokenResponsePayload responsePayload = (OAuthTokenResponsePayload) JSON.deserialize(
                response.getBody(),
                OAuthTokenResponsePayload.class
            );
            return new Auth.OAuthRefreshResult(responsePayload.access_token, responsePayload.refresh_token);
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

    private void validateResponse(HttpResponse response) {
        final Set<Integer> allowedStatusCodes = new Set<Integer>{ 200, 201 };
        if (!allowedStatusCodes.contains(response.getStatusCode())) {
            String errorMessage = String.format('Authentication error occurred: {0}', Lists.of(response.getBody()));
            Logger.error(errorMessage);
            throw new Auth.AuthProviderPluginException(errorMessage);
        }
    }
}
