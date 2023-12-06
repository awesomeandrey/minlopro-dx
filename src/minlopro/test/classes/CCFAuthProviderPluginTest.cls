@IsTest
private class CCFAuthProviderPluginTest {
    private static final String OAUTH_TOKEN = 'testToken';
    private static final String STATE = 'mocktestState';
    private static final String PROVIDER = 'TestProvider';
    private static final String REDIRECT_URL = 'http://localhost/services/authcallback/orgId/TestProvider';
    private static final String KEY = 'testKey';
    private static final String SECRET = 'testSecret';
    private static final String STATE_TO_PROPOGATE = 'testState';
    private static final String ACCESS_TOKEN_URL = 'http://www.dummyhost.com/accessTokenUri';
    private static final String INVALID_CLIENT_ERR_CODE = 'invalid_client';
    private static final String INVALID_CLIENT_ERR_MESSAGE = 'Client credentials are invalid';

    private static Map<String, String> setupAuthProviderConfig() {
        Map<String, String> authProviderConfiguration = new Map<String, String>();
        authProviderConfiguration.put('CallbackUrl__c', REDIRECT_URL);
        authProviderConfiguration.put('ClientId__c', KEY);
        authProviderConfiguration.put('ClientSecret__c', SECRET);
        authProviderConfiguration.put('TokenEndpointUrl__c', ACCESS_TOKEN_URL);
        return authProviderConfiguration;
    }

    // TODO - review tests implementation;

    @IsTest
    static void testGetCustomMetadataType() {
        CCFAuthProviderPlugin plugin = new CCFAuthProviderPlugin();
        String expectedMetadataName = CCF_Configurations__mdt.SObjectType.getDescribe().getName();

        Test.startTest();
        String actualMetadataName = plugin.getCustomMetadataType();
        Test.stopTest();

        Assert.areEqual(expectedMetadataName, actualMetadataName);
    }

    @IsTest
    static void testInitiateMethod() {
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
        CCFAuthProviderPlugin plugin = new CCFAuthProviderPlugin();

        PageReference expectedUrl = new PageReference(
            authProviderConfiguration.get('CallbackUrl__c') + '?state=' + STATE_TO_PROPOGATE
        );

        Test.startTest();
        PageReference actualUrl = plugin.initiate(authProviderConfiguration, STATE_TO_PROPOGATE);
        Test.stopTest();

        Assert.areEqual(expectedUrl.getUrl(), actualUrl.getUrl());
    }

    @IsTest
    static void testHandleCallback() {
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
        CCFAuthProviderPlugin plugin = new CCFAuthProviderPlugin();

        Test.setMock(HttpCalloutMock.class, new ProviderMockHttpResponseGenerator());

        Map<String, String> queryParams = new Map<String, String>();
        queryParams.put('state', STATE);
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null, null, queryParams);

        Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse(
            'TestProvider',
            OAUTH_TOKEN,
            OAUTH_TOKEN,
            STATE
        );

        Test.startTest();
        Auth.AuthProviderTokenResponse actualAuthProvResponse = plugin.handleCallback(authProviderConfiguration, cbState);
        Test.stopTest();

        Assert.areEqual(expectedAuthProvResponse.provider, actualAuthProvResponse.provider);
        Assert.areEqual(expectedAuthProvResponse.oauthToken, actualAuthProvResponse.oauthToken);
        Assert.areEqual(expectedAuthProvResponse.oauthSecretOrRefreshToken, actualAuthProvResponse.oauthSecretOrRefreshToken);
        Assert.areEqual(expectedAuthProvResponse.state, actualAuthProvResponse.state);
    }

    @IsTest
    static void testHandleCallbackWithErrorInResponse() {
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
        CCFAuthProviderPlugin plugin = new CCFAuthProviderPlugin();

        Test.setMock(HttpCalloutMock.class, new ProviderMockHttpErrorResponseGenerator());

        Map<String, String> queryParams = new Map<String, String>();
        queryParams.put('state', STATE);
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null, null, queryParams);

        Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse(
            'TestProvider',
            OAUTH_TOKEN,
            OAUTH_TOKEN,
            STATE
        );

        Test.startTest();
        Exception expectecException;
        try {
            Auth.AuthProviderTokenResponse actualAuthProvResponse = plugin.handleCallback(authProviderConfiguration, cbState);
        } catch (Exception ex) {
            expectecException = ex;
        }
        Test.stopTest();

        Assert.isNotNull(expectecException);
        Assert.isTrue(expectecException.getMessage().contains(INVALID_CLIENT_ERR_CODE));
        Assert.isTrue(expectecException.getMessage().contains(INVALID_CLIENT_ERR_MESSAGE));
    }

    @IsTest
    static void testRefresh() {
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
        CCFAuthProviderPlugin plugin = new CCFAuthProviderPlugin();

        Test.setMock(HttpCalloutMock.class, new ProviderMockHttpResponseGenerator());

        Map<String, String> queryParams = new Map<String, String>();
        queryParams.put('state', STATE);
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null, null, queryParams);

        Auth.OAuthRefreshResult expectedRefreshResult = new Auth.OAuthRefreshResult(OAUTH_TOKEN, OAUTH_TOKEN);

        Test.startTest();
        Auth.OAuthRefreshResult actualRefreshResult = plugin.refresh(authProviderConfiguration, OAUTH_TOKEN);
        Test.stopTest();

        Assert.areEqual(expectedRefreshResult.accessToken, actualRefreshResult.accessToken);
        Assert.areEqual(expectedRefreshResult.refreshToken, actualRefreshResult.refreshToken);
    }

    @IsTest
    static void testGetUserInfo() {
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
        CCFAuthProviderPlugin plugin = new CCFAuthProviderPlugin();

        Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(PROVIDER, OAUTH_TOKEN, OAUTH_TOKEN, STATE);

        Auth.UserData expectedUserData = new Auth.UserData(
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

        Test.startTest();
        Auth.UserData actualUserData = plugin.getUserInfo(authProviderConfiguration, response);
        Test.stopTest();

        Assert.areNotEqual(expectedUserData, null);
        Assert.areEqual(expectedUserData.firstName, actualUserData.firstName);
        Assert.areEqual(expectedUserData.lastName, actualUserData.lastName);
        Assert.areEqual(expectedUserData.fullName, actualUserData.fullName);
        Assert.areEqual(expectedUserData.email, actualUserData.email);
        Assert.areEqual(expectedUserData.username, actualUserData.username);
    }

    public class ProviderMockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            Map<String, String> responseMap = new Map<String, String>{ 'access_token' => OAUTH_TOKEN };
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(responseMap));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ProviderMockHttpErrorResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            Map<String, String> responseMap = new Map<String, String>{
                'ErrorCode' => 'invalid_client',
                'Error' => 'Client credentials are invalid'
            };
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(responseMap));
            res.setStatusCode(401);
            return res;
        }
    }
}
