public with sharing class PerUserNamedCredentialController {
    @AuraEnabled(Cacheable=true)
    public static List<NamedCredential> getNamedCredentials() {
        return [
            SELECT Id, MasterLabel, DeveloperName, PrincipalType
            FROM NamedCredential
            WHERE PrincipalType != NULL
            LIMIT 5
        ];
    }

    @AuraEnabled
    public static String getDataUserAuthUrl(String namedCredentialApiName) {
        // Inspired by https://salesforce.stackexchange.com/questions/214981/is-it-possible-to-set-per-user-named-credentials-via-apex
        try {
            List<ExternalDataUserAuth> existingDataUserAuths = [
                SELECT Id
                FROM ExternalDataUserAuth
                WHERE
                    ExternalDataSourceId IN (SELECT Id FROM NamedCredential WHERE DeveloperName = :namedCredentialApiName)
                    AND UserId = :UserInfo.getUserId()
                LIMIT 1
            ];
            if (!existingDataUserAuths.isEmpty()) {
                return String.format('/{0}/e', Lists.of(existingDataUserAuths[0].Id));
            }
            String prefix = ExternalDataUserAuth.getSObjectType().getDescribe().getKeyPrefix();
            return String.format('/{0}/e', Lists.of(prefix));
        } catch (Exception rootException) {
            Logger.error(rootException);
            AuraHandledException auraEx = new AuraHandledException(rootException.getMessage());
            auraEx.initCause(rootException);
            throw new AuraHandledException(rootException.getMessage());
        }
    }

    @AuraEnabled
    public static CalloutResponse invoke(String namedCredentialApiName) {
        try {
            HttpRequest req = new HttpRequest();
            String encodedQuery = EncodingUtil.urlEncode('SELECT Id, Name, InstanceName FROM Organization', 'UTF-8');
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
            throw new AuraHandledException(rootException.getMessage());
        }
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
}
