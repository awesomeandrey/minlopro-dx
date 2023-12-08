@IsTest
private class CCFAuthProviderPluginTest {
    private static final String TEST_AUTH_STATE = 'test_auth_state';
    private static final String TEST_ACCESS_TOKEN = 'test_access_token';

    private static Map<String, String> getAuthProviderConfigMock() {
        Map<String, String> configs = new Map<String, String>();
        configs.put(CCFAuthProviderPlugin.CALLBACK_URL, 'https://salesforce.com/authcallback/CustomAuthProvider');
        configs.put(CCFAuthProviderPlugin.CLIENT_ID, '***client_id***');
        configs.put(CCFAuthProviderPlugin.CLIENT_SECRET, '***client_secret***');
        configs.put(CCFAuthProviderPlugin.TOKEN_ENDPOINT_URL, 'https://org.com/oauth/token');
        return configs;
    }

    @IsTest
    static void getCustomMetadataType() {
        CCFAuthProviderPlugin plugin = new CCFAuthProviderPlugin();
        String cmtObjectName = CCF_Configurations__mdt.SObjectType.getDescribe().getName();
        Assert.areEqual(cmtObjectName, plugin.getCustomMetadataType());
    }

    @IsTest
    static void initiate() {
        Map<String, String> authProviderConfig = getAuthProviderConfigMock();
        String callbackUrlFieldName = CCF_Configurations__mdt.CallbackUrl__c.getDescribe().getName();
        PageReference expectedUrl = new PageReference(
            String.format('{0}?state={1}', Lists.of(authProviderConfig.get(callbackUrlFieldName), TEST_AUTH_STATE))
        );
        CCFAuthProviderPlugin plugin = new CCFAuthProviderPlugin();
        PageReference actualUrl = plugin.initiate(authProviderConfig, TEST_AUTH_STATE);
        Assert.areEqual(expectedUrl.getUrl(), actualUrl.getUrl());
    }

    @IsTest
    static void handleCallbackAndRefresh() {
        Map<String, String> authProviderConfig = getAuthProviderConfigMock();
        CCFAuthProviderPlugin.OAuthResponsePayload responsePayload = new CCFAuthProviderPlugin.OAuthResponsePayload(
            TEST_ACCESS_TOKEN
        );
        MockedCalloutsFactory factory = MockedCalloutsFactory.getInstance();
        factory.mockUnknownRequest().withResponseStatusCode(200).withResponseBody(JSON.serialize(responsePayload));
        factory.mock();
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(
            null,
            null,
            new Map<String, String>{ 'state' => TEST_AUTH_STATE }
        );
        CCFAuthProviderPlugin plugin = new CCFAuthProviderPlugin();
        Auth.AuthProviderTokenResponse tokenResponse = plugin.handleCallback(authProviderConfig, cbState);
        Assert.areEqual(TEST_ACCESS_TOKEN, tokenResponse.oauthToken);
        Assert.areEqual(TEST_ACCESS_TOKEN, tokenResponse.oauthSecretOrRefreshToken);
        Auth.OAuthRefreshResult refreshResult = plugin.refresh(authProviderConfig, null);
        Assert.areEqual(TEST_ACCESS_TOKEN, refreshResult.accessToken);
        Assert.areEqual(TEST_ACCESS_TOKEN, refreshResult.refreshToken);
    }

    @IsTest
    static void handleCallbackWithException() {
        final String errorResponse = '{"errorMessage": "Bad Request"}';
        Map<String, String> authProviderConfig = getAuthProviderConfigMock();
        MockedCalloutsFactory factory = MockedCalloutsFactory.getInstance();
        factory.mockUnknownRequest().withResponseStatusCode(400).withResponseBody(errorResponse);
        factory.mock();
        try {
            CCFAuthProviderPlugin plugin = new CCFAuthProviderPlugin();
            Auth.AuthProviderTokenResponse tokenResponse = plugin.handleCallback(authProviderConfig, null);
            Assert.areEqual(null, tokenResponse, 'Plugin should have thrown exception!');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, Auth.AuthProviderPluginException.class);
            Assert.isTrue(ex.getMessage().containsIgnoreCase(errorResponse));
        }
    }

    @IsTest
    static void getUserInfo() {
        Map<String, String> authProviderConfiguration = getAuthProviderConfigMock();
        CCFAuthProviderPlugin plugin = new CCFAuthProviderPlugin();
        Auth.UserData actualUserData = plugin.getUserInfo(authProviderConfiguration, null);
        Assert.areEqual(UserInfo.getUserName(), actualUserData.username);
    }
}
