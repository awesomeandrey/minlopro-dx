public without sharing class AuthProviderSettingParser {
    public String auth_provider_name { get; private set; }
    public String client_id { get; private set; }
    public String client_secret { get; private set; }
    public String token_url { get; private set; }
    public String authorize_url { get; private set; }
    public String redirect_uri { get; private set; }
    public String certificate_name { get; private set; }

    private AuthProviderSettingParser() {
    }

    public static AuthProviderSettingParser build(Map<String, String> configsMap) {
        AuthProviderSettingParser authSettings = new AuthProviderSettingParser();
        authSettings.auth_provider_name = configsMap.get(
            AuthProviderSetting__mdt.SalesforceAuthProviderName__c.getDescribe().getName()
        );
        authSettings.client_id = configsMap.get(AuthProviderSetting__mdt.ClientId__c.getDescribe().getName());
        authSettings.client_secret = configsMap.get(AuthProviderSetting__mdt.ClientSecret__c.getDescribe().getName());
        authSettings.token_url = configsMap.get(AuthProviderSetting__mdt.TokenUrl__c.getDescribe().getName());
        authSettings.redirect_uri = configsMap.get(AuthProviderSetting__mdt.RedirectUri__c.getDescribe().getName());
        authSettings.authorize_url = configsMap.get(AuthProviderSetting__mdt.AuthorizeUrl__c.getDescribe().getName());
        authSettings.certificate_name = configsMap.get(AuthProviderSetting__mdt.CertificateName__c.getDescribe().getName());
        return authSettings;
    }

    public static Map<String, String> mock() {
        return new Map<String, String>{
            AuthProviderSetting__mdt.SalesforceAuthProviderName__c.getDescribe().getName() => 'LOOPBACK',
            AuthProviderSetting__mdt.ClientId__c.getDescribe().getName() => '***client_id***',
            AuthProviderSetting__mdt.ClientSecret__c.getDescribe().getName() => '***client_secret***',
            AuthProviderSetting__mdt.TokenUrl__c.getDescribe().getName() => 'https://org.com/oauth/token',
            AuthProviderSetting__mdt.RedirectUri__c.getDescribe().getName() => 'https://org.com/callback',
            AuthProviderSetting__mdt.AuthorizeUrl__c.getDescribe().getName() => 'https://org.com/oauth/authorize',
            AuthProviderSetting__mdt.CertificateName__c.getDescribe().getName() => 'Certificate1'
        };
    }
}
