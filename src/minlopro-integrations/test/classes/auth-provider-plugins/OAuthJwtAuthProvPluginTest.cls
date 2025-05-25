@IsTest
private class OAuthJwtAuthProvPluginTest {
    @IsTest
    static void getCustomMetadataType() {
        OAuthJwtAuthProviderPlugin plugin = new OAuthJwtAuthProviderPlugin();
        String cmtObjectName = AuthProviderSetting__mdt.SObjectType.getDescribe().getName();
        Assert.areEqual(cmtObjectName, plugin.getCustomMetadataType());
    }

    @IsTest
    static void initiate() {
        final String MOCKED_AUTH_STATE = 'done';
        Map<String, String> authProviderConfig = AuthProviderSettings.mock();
        String redirectUriFieldName = AuthProviderSetting__mdt.RedirectUri__c.getDescribe().getName();
        PageReference expectedUrl = new PageReference(
            String.format('{0}?state={1}', Lists.of(authProviderConfig.get(redirectUriFieldName), MOCKED_AUTH_STATE))
        );
        OAuthJwtAuthProviderPlugin plugin = new OAuthJwtAuthProviderPlugin();
        PageReference actualUrl = plugin.initiate(authProviderConfig, MOCKED_AUTH_STATE);
        Assert.areEqual(expectedUrl.getUrl(), actualUrl.getUrl());
    }

    @IsTest
    static void handleCallbackAndRefreshWithException() {
        Map<String, String> authProviderConfig = AuthProviderSettings.mock();
        OAuthJwtAuthProviderPlugin plugin = new OAuthJwtAuthProviderPlugin();
        String errorMessageSubstring = 'Data Not Available';
        try {
            Auth.AuthProviderTokenResponse tokenResponse = plugin.handleCallback(authProviderConfig, null);
            Assert.areEqual(null, tokenResponse, 'Plugin should have thrown exception!');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, Auth.AuthProviderPluginException.class);
            Assert.isInstanceOfType(ex.getCause(), System.NoDataFoundException.class);
            Assert.isTrue(ex.getMessage().containsIgnoreCase(errorMessageSubstring));
        }
        try {
            Auth.AuthProviderTokenResponse tokenResponse = plugin.handleCallback(authProviderConfig, null);
            Assert.areEqual(null, tokenResponse, 'Plugin should have thrown exception!');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, Auth.AuthProviderPluginException.class);
            Assert.isInstanceOfType(ex.getCause(), System.NoDataFoundException.class);
            Assert.isTrue(ex.getMessage().containsIgnoreCase(errorMessageSubstring));
        }
    }

    @IsTest
    static void getUserInfo() {
        Map<String, String> authProviderConfiguration = AuthProviderSettings.mock();
        OAuthJwtAuthProviderPlugin plugin = new OAuthJwtAuthProviderPlugin();
        Auth.UserData actualUserData = plugin.getUserInfo(authProviderConfiguration, null);
        Assert.areEqual(UserInfo.getUserName(), actualUserData.username);
    }
}
