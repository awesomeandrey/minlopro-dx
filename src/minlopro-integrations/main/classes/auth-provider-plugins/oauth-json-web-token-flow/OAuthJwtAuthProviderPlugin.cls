/**
 * @description This Apex class functions as an authentication plugin tailored for Auth. Providers,
 * enabling seamless authentication to external systems that implement "OAuth 2.0 JWT Bearer Flow".
 * Used together with Auth. Provider and Named Credential.
 *
 * See https://help.salesforce.com/s/articleView?id=xcloud.remoteaccess_oauth_jwt_flow.htm&type=5
 *
 */
public class OAuthJwtAuthProviderPlugin extends Auth.AuthProviderPluginClass {
    public String getCustomMetadataType() {
        return AuthProviderSetting__mdt.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName();
    }

    public PageReference initiate(Map<String, String> authProviderConfiguration, String stateToPropagate) {
        try {
            AuthProviderSettings authSettings = AuthProviderSettings.build(authProviderConfiguration);
            String redirectUri = String.format('{0}?state={1}', Lists.of(authSettings.redirect_uri, stateToPropagate));
            return new PageReference(redirectUri);
        } catch (Exception rootException) {
            Logger.error(rootException);
            Auth.AuthProviderPluginException ex = new Auth.AuthProviderPluginException(rootException.getMessage());
            ex.initCause(rootException);
            throw ex;
        }
    }

    public Auth.AuthProviderTokenResponse handleCallback(
        Map<String, String> authProviderConfiguration,
        Auth.AuthProviderCallbackState state
    ) {
        try {
            AuthProviderSettings authSettings = AuthProviderSettings.build(authProviderConfiguration);
            OAuthTokenResponsePayload responsePayload = this.fetchAccessToken(authSettings);
            return new Auth.AuthProviderTokenResponse(
                authSettings.auth_provider_name,
                responsePayload.access_token,
                responsePayload.access_token, // Override 'refresh_token' with actual 'access_token';
                state.queryParameters.get('state')
            );
        } catch (Exception rootException) {
            Logger.error(rootException);
            Auth.AuthProviderPluginException ex = new Auth.AuthProviderPluginException(rootException.getMessage());
            ex.initCause(rootException);
            throw ex;
        }
    }

    public override Auth.OAuthRefreshResult refresh(Map<String, String> authProviderConfiguration, String refreshToken) {
        try {
            AuthProviderSettings authSettings = AuthProviderSettings.build(authProviderConfiguration);
            OAuthTokenResponsePayload responsePayload = this.fetchAccessToken(authSettings);
            return new Auth.OAuthRefreshResult(
                responsePayload.access_token,
                responsePayload.access_token // Override 'refresh_token' with actual 'access_token';
            );
        } catch (Exception rootException) {
            Logger.error(rootException);
            Auth.AuthProviderPluginException ex = new Auth.AuthProviderPluginException(rootException.getMessage());
            ex.initCause(rootException);
            throw ex;
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

    private OAuthTokenResponsePayload fetchAccessToken(AuthProviderSettings authSettings) {
        /**
         * Make sure self-signed 'Minlopro' certificate is generated/deployed via 'Certificate and Key Management' Setup menu.
         * On top of it, manually add this certificate to 'MinloproSalesforceLoopback' connected app.
         */
        final String SUBJECT = UserInfo.getUserName();
        final String AUDIENCE = SystemInfoController.isSandbox() ? 'https://test.salesforce.com' : 'https://login.salesforce.com';
        // Generate JSON Web Signature;
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(SUBJECT);
        jwt.setAud(AUDIENCE);
        jwt.setIss(authSettings.client_id);
        jwt.setValidityLength(60 * 10);
        Auth.JWS jws = new Auth.JWS(jwt, authSettings.certificate_name);
        // Request access token by JWT OAuth Flow;
        Auth.JWTBearerTokenExchange tokenExchange = new Auth.JWTBearerTokenExchange(authSettings.token_url, jws);
        HttpResponse response = tokenExchange.getHttpResponse();
        final Set<Integer> allowedStatusCodes = new Set<Integer>{ 200, 201 };
        if (!allowedStatusCodes.contains(response.getStatusCode())) {
            String errorMessage = String.format(
                'Authentication error occurred: {0} {1}',
                Lists.of(response.getStatusCode().toString(), response.getBody())
            );
            throw new Auth.AuthProviderPluginException(errorMessage);
        }
        return (OAuthTokenResponsePayload) JSON.deserialize(response.getBody(), OAuthTokenResponsePayload.class);
    }
}
