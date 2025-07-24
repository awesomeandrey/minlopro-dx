@IsTest
private class OAuthWebServerWithPkceAuthProvPluginTest {
    private static final String MOCKED_AUTH_STATE = 'done';
    private static final String MOCKED_AUTH_CODE = '123456';
    private static final String MOCKED_ACCESS_TOKEN = 'at1234567890@!minlopro';
    private static final String MOCKED_REFRESH_TOKEN = 'at999999999@!refresh';

    @IsTest
    static void getCustomMetadataType() {
        OAuthWebServerWithPkceAuthProviderPlugin plugin = new OAuthWebServerWithPkceAuthProviderPlugin();
        String cmtObjectName = AuthProviderSetting__mdt.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName();
        Assert.areEqual(cmtObjectName, plugin.getCustomMetadataType());
    }

    @IsTest
    static void initiate() {
        Map<String, String> authProviderConfig = AuthProviderSettings.mock();
        AuthProviderSettings authSettings = AuthProviderSettings.build(authProviderConfig);
        OAuthWebServerWithPkceAuthProviderPlugin plugin = new OAuthWebServerWithPkceAuthProviderPlugin();
        String actualUrl = plugin.initiate(authProviderConfig, MOCKED_AUTH_STATE).getUrl();
        PKCE.State pkceState = PKCE.get(OAuthWebServerWithPkceAuthProviderPlugin.PKCE_CACHE_KEY);
        Assert.isTrue(actualUrl.startsWith(authSettings.authorize_url));
        Assert.isTrue(actualUrl.containsIgnoreCase(authSettings.client_id));
        Assert.isTrue(actualUrl.containsIgnoreCase(pkceState.code_challenge));
        Assert.isTrue(actualUrl.endsWithIgnoreCase(MOCKED_AUTH_STATE));
    }

    @IsTest
    static void handleCallback() {
        Map<String, String> authProviderConfig = AuthProviderSettings.mock();
        OAuthTokenResponsePayload responsePayload = new OAuthTokenResponsePayload(MOCKED_ACCESS_TOKEN, MOCKED_REFRESH_TOKEN);
        MockedCalloutsFactory factory = MockedCalloutsFactory.getInstance();
        factory.mockDefaultRequest().withResponseStatusCode(200).withResponseBody(JSON.serialize(responsePayload));
        factory.mock();
        OAuthWebServerWithPkceAuthProviderPlugin plugin = new OAuthWebServerWithPkceAuthProviderPlugin();
        Auth.AuthProviderTokenResponse tokenResponse = plugin.handleCallback(
            authProviderConfig,
            new Auth.AuthProviderCallbackState(
                null,
                null,
                new Map<String, String>{ 'state' => MOCKED_AUTH_STATE, 'code' => MOCKED_AUTH_CODE }
            )
        );
        Assert.areEqual(MOCKED_ACCESS_TOKEN, tokenResponse.oauthToken);
        Assert.areEqual(MOCKED_REFRESH_TOKEN, tokenResponse.oauthSecretOrRefreshToken);
    }

    @IsTest
    static void handleCallbackWithException() {
        final String errorResponse = '{"errorMessage": "Bad Request"}';
        Map<String, String> authProviderConfig = AuthProviderSettings.mock();
        MockedCalloutsFactory factory = MockedCalloutsFactory.getInstance();
        factory.mockDefaultRequest().withResponseStatusCode(400).withResponseBody(errorResponse);
        factory.mock();
        try {
            OAuthWebServerWithPkceAuthProviderPlugin plugin = new OAuthWebServerWithPkceAuthProviderPlugin();
            Auth.AuthProviderTokenResponse tokenResponse = plugin.handleCallback(authProviderConfig, null);
            Assert.areEqual(null, tokenResponse, 'Plugin should have thrown exception!');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, Auth.AuthProviderPluginException.class);
            Assert.isTrue(ex.getMessage().containsIgnoreCase(errorResponse));
        }
    }

    @IsTest
    static void handleRefresh() {
        Map<String, String> authProviderConfig = AuthProviderSettings.mock();
        OAuthTokenResponsePayload responsePayload = new OAuthTokenResponsePayload(MOCKED_ACCESS_TOKEN, MOCKED_REFRESH_TOKEN);
        MockedCalloutsFactory factory = MockedCalloutsFactory.getInstance();
        factory.mockDefaultRequest().withResponseStatusCode(200).withResponseBody(JSON.serialize(responsePayload));
        factory.mock();
        OAuthWebServerWithPkceAuthProviderPlugin plugin = new OAuthWebServerWithPkceAuthProviderPlugin();
        Auth.OAuthRefreshResult refreshResult = plugin.refresh(authProviderConfig, MOCKED_REFRESH_TOKEN);
        Assert.areEqual(MOCKED_ACCESS_TOKEN, refreshResult.accessToken);
        Assert.areEqual(MOCKED_REFRESH_TOKEN, refreshResult.refreshToken);
    }

    @IsTest
    static void getUserInfo() {
        Map<String, String> authProviderConfiguration = AuthProviderSettings.mock();
        OAuthWebServerWithPkceAuthProviderPlugin plugin = new OAuthWebServerWithPkceAuthProviderPlugin();
        Auth.UserData actualUserData = plugin.getUserInfo(authProviderConfiguration, null);
        Assert.areEqual(UserInfo.getUserName(), actualUserData.username);
    }
}
