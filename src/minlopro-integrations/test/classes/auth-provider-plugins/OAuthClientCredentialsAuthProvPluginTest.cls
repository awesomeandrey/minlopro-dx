@IsTest
private class OAuthClientCredentialsAuthProvPluginTest {
    private static final String MOCKED_AUTH_STATE = 'done';
    private static final String MOCKED_ACCESS_TOKEN = 'at1234567890@!minlopro';

    @IsTest
    static void getCustomMetadataType() {
        OAuthClientCredentialsAuthProviderPlugin plugin = new OAuthClientCredentialsAuthProviderPlugin();
        String cmtObjectName = AuthProviderSetting__mdt.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName();
        Assert.areEqual(cmtObjectName, plugin.getCustomMetadataType());
    }

    @IsTest
    static void initiate() {
        Map<String, String> authProviderConfig = AuthProviderSettings.mock();
        String redirectUriFieldName = AuthProviderSetting__mdt.RedirectUri__c.getDescribe().getName();
        PageReference expectedUrl = new PageReference(
            String.format('{0}?state={1}', Lists.of(authProviderConfig.get(redirectUriFieldName), MOCKED_AUTH_STATE))
        );
        OAuthClientCredentialsAuthProviderPlugin plugin = new OAuthClientCredentialsAuthProviderPlugin();
        PageReference actualUrl = plugin.initiate(authProviderConfig, MOCKED_AUTH_STATE);
        Assert.areEqual(expectedUrl.getUrl(), actualUrl.getUrl());
    }

    @IsTest
    static void handleCallbackAndRefresh() {
        Map<String, String> authProviderConfig = AuthProviderSettings.mock();
        OAuthTokenResponsePayload responsePayload = new OAuthTokenResponsePayload(MOCKED_ACCESS_TOKEN);
        MockedCalloutsFactory factory = MockedCalloutsFactory.getInstance();
        factory.mockDefaultRequest().withResponseStatusCode(200).withResponseBody(JSON.serialize(responsePayload));
        factory.mock();
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(
            null,
            null,
            new Map<String, String>{ 'state' => MOCKED_AUTH_STATE }
        );
        OAuthClientCredentialsAuthProviderPlugin plugin = new OAuthClientCredentialsAuthProviderPlugin();
        Auth.AuthProviderTokenResponse tokenResponse = plugin.handleCallback(authProviderConfig, cbState);
        Assert.areEqual(MOCKED_ACCESS_TOKEN, tokenResponse.oauthToken);
        Assert.areEqual(MOCKED_ACCESS_TOKEN, tokenResponse.oauthSecretOrRefreshToken);
        Auth.OAuthRefreshResult refreshResult = plugin.refresh(authProviderConfig, null);
        Assert.areEqual(MOCKED_ACCESS_TOKEN, refreshResult.accessToken);
        Assert.areEqual(MOCKED_ACCESS_TOKEN, refreshResult.refreshToken);
    }

    @IsTest
    static void handleCallbackWithException() {
        final String errorResponse = '{"errorMessage": "Bad Request"}';
        Map<String, String> authProviderConfig = AuthProviderSettings.mock();
        MockedCalloutsFactory factory = MockedCalloutsFactory.getInstance();
        factory.mockDefaultRequest().withResponseStatusCode(400).withResponseBody(errorResponse);
        factory.mock();
        try {
            OAuthClientCredentialsAuthProviderPlugin plugin = new OAuthClientCredentialsAuthProviderPlugin();
            Auth.AuthProviderTokenResponse tokenResponse = plugin.handleCallback(authProviderConfig, null);
            Assert.areEqual(null, tokenResponse, 'Plugin should have thrown exception!');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, Auth.AuthProviderPluginException.class);
            Assert.isTrue(ex.getMessage().containsIgnoreCase(errorResponse));
        }
    }

    @IsTest
    static void getUserInfo() {
        Map<String, String> authProviderConfiguration = AuthProviderSettings.mock();
        OAuthClientCredentialsAuthProviderPlugin plugin = new OAuthClientCredentialsAuthProviderPlugin();
        Auth.UserData actualUserData = plugin.getUserInfo(authProviderConfiguration, null);
        Assert.areEqual(UserInfo.getUserName(), actualUserData.username);
    }
}
