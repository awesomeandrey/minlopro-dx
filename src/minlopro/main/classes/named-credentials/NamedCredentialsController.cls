public with sharing class NamedCredentialsController {
    @AuraEnabled(Cacheable=true)
    public static List<NamedCredential> getNamedCredentials() {
        return selectedNamedCredentialsByDeveloperName().values();
    }

    @AuraEnabled
    public static String getAuthenticationUrl(String namedCredentialApiName) {
        try {
            NamedCredential nc = selectedNamedCredentialsByDeveloperName().get(namedCredentialApiName);
            NAMED_CREDENTIAL_TYPE ncType = computeType(nc);
            switch on ncType {
                when SECURED_ENDPOINT {
                    return getSecuredEndpointNamedCredentialAuthUrl(nc);
                }
                when LEGACY {
                    return getLegacyNamedCredentialAuthUrl(nc);
                }
                when else {
                    throw new IllegalArgumentException(
                        String.format('Undefined Named Credential Type: {0}', Lists.of(namedCredentialApiName))
                    );
                }
            }
        } catch (Exception rootException) {
            Logger.error(rootException);
            AuraHandledException auraEx = new AuraHandledException(rootException.getMessage());
            auraEx.initCause(rootException);
            throw auraEx;
        }
    }

    @AuraEnabled
    public static CalloutResponse invoke(String namedCredentialApiName) {
        try {
            HttpRequest req = new HttpRequest();
            String encodedQuery = EncodingUtil.urlEncode('SELECT Id, Name, Owner.Name FROM Account LIMIT 1', 'UTF-8');
            String endpoint = String.format(
                'callout:{0}/services/data/v{1}/query?q={2}',
                Lists.of(namedCredentialApiName, '60.0', encodedQuery)
            );
            req.setMethod('GET');
            req.setEndpoint(endpoint);
            HttpResponse resp = new Http().send(req);
            return new CalloutResponse(resp);
        } catch (Exception rootException) {
            Logger.error(rootException);
            AuraHandledException auraEx = new AuraHandledException(rootException.getMessage());
            auraEx.initCause(rootException);
            throw auraEx;
        }
    }

    private static Map<String, NamedCredential> selectedNamedCredentialsByDeveloperName() {
        Map<String, NamedCredential> resultMap = new Map<String, NamedCredential>();
        for (NamedCredential nc : [
            SELECT Id, MasterLabel, DeveloperName, PrincipalType
            FROM NamedCredential
            ORDER BY PrincipalType ASC, MasterLabel ASC
        ]) {
            resultMap.put(nc.DeveloperName, nc);
        }
        return resultMap;
    }

    private static NAMED_CREDENTIAL_TYPE computeType(NamedCredential nc) {
        return String.isBlank(nc.PrincipalType) ? NAMED_CREDENTIAL_TYPE.SECURED_ENDPOINT : NAMED_CREDENTIAL_TYPE.LEGACY;
    }

    private static String getLegacyNamedCredentialAuthUrl(NamedCredential nc) {
        // Inspired by https://salesforce.stackexchange.com/questions/214981/is-it-possible-to-set-per-user-named-credentials-via-apex
        /**
         * As another option, the user can be navigated by static Lightning Experience link:
         * "/lightning/settings/personal/ExternalObjectUserSettings/home"
         */
        List<ExternalDataUserAuth> existingDataUserAuths = [
            SELECT Id
            FROM ExternalDataUserAuth
            WHERE
                UserId = :UserInfo.getUserId()
                AND ExternalDataSourceId IN (SELECT Id FROM NamedCredential WHERE DeveloperName = :nc.DeveloperName)
            LIMIT 1
        ];
        if (!existingDataUserAuths.isEmpty()) {
            return String.format('/{0}/e', Lists.of(existingDataUserAuths[0].Id));
        }
        String prefix = ExternalDataUserAuth.getSObjectType().getDescribe().getKeyPrefix();
        return String.format('/{0}/e', Lists.of(prefix));
    }

    private static String getSecuredEndpointNamedCredentialAuthUrl(NamedCredential nc) {
        // Personal User Setting page in Lightning Experience;
        return '/lightning/settings/personal/ExternalCredentials/home';
    }

    public class CalloutResponse {
        private final HttpResponse response;
        @AuraEnabled
        public String body {
            get {
                return this.response?.getBody();
            }
        }
        @AuraEnabled
        public String status {
            get {
                return this.response?.getStatus();
            }
        }
        @AuraEnabled
        public Integer statusCode {
            get {
                return this.response?.getStatusCode();
            }
        }
        @AuraEnabled
        public Boolean success {
            get {
                return this.statusCode == 200 || this.statusCode == 201;
            }
        }

        public CalloutResponse(HttpResponse response) {
            this.response = response;
        }
    }

    public enum NAMED_CREDENTIAL_TYPE {
        SECURED_ENDPOINT,
        LEGACY
    }
}
