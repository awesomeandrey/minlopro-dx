public with sharing class NamedCredentialsController {
    @AuraEnabled(Cacheable=true)
    public static List<NamedCredentialInfo> getNamedCredentials() {
        return selectNamedCredentialsByApiName().values();
    }

    @AuraEnabled(Cacheable=true)
    public static ConnectApi.ExternalCredential getExternalCredential(Id recordId) {
        try {
            for (ConnectApi.ExternalCredential ec : ConnectApi.NamedCredentials.getExternalCredentials().externalCredentials) {
                if (ec.id.equals(recordId)) {
                    return ec;
                }
            }
            throw new IllegalArgumentException('Invalid External Credential ID provided.');
        } catch (Exception rootException) {
            Logger.error(rootException);
            AuraHandledException auraEx = new AuraHandledException(rootException.getMessage());
            auraEx.initCause(rootException);
            throw auraEx;
        }
    }

    @AuraEnabled
    public static String getExternalCredentialAuthUrl(String externalCredentialName, String principalType, String principalName) {
        try {
            ConnectApi.OAuthCredentialAuthUrlInput input = new ConnectApi.OAuthCredentialAuthUrlInput();
            input.externalCredential = externalCredentialName;
            input.principalType = ConnectApi.CredentialPrincipalType.valueOf(principalType);
            input.principalName = principalName;
            return ConnectApi.NamedCredentials.getOAuthCredentialAuthUrl(input).authenticationUrl;
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
                Lists.of(namedCredentialApiName, Constants.Org.ApiVersion, encodedQuery)
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

    private static Map<String, NamedCredentialInfo> selectNamedCredentialsByApiName() {
        Map<String, NamedCredentialInfo> resultMap = new Map<String, NamedCredentialInfo>();
        for (NamedCredential nc : [
            SELECT Id, MasterLabel, DeveloperName, PrincipalType
            FROM NamedCredential
            ORDER BY PrincipalType ASC, MasterLabel ASC
            LIMIT 10
        ]) {
            NamedCredentialInfo ncDto = new NamedCredentialInfo(nc);
            if (!ncDto.isLegacy) {
                ncDto = new NamedCredentialInfo(ConnectApi.NamedCredentials.getNamedCredential(nc.DeveloperName));
            }
            resultMap.put(nc.DeveloperName, ncDto);
        }
        return resultMap;
    }

    public class NamedCredentialInfo {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String apiName;
        @AuraEnabled
        public String principalType;
        @AuraEnabled
        public String type {
            get {
                return this.isLegacy ? String.format('Legacy ({0})', Lists.of(this.principalType)) : 'Secured Endpoint';
            }
            private set;
        }
        @AuraEnabled
        public Boolean isLegacy {
            get {
                // Only Legacy named credentials have 'PrincipalType' field populated;
                return String.isNotBlank(this.principalType);
            }
            set;
        }
        @AuraEnabled
        public Boolean isLegacyPerUser {
            get {
                return this.isLegacy && this.principalType.equalsIgnoreCase('PerUser');
            }
            set;
        }
        @AuraEnabled
        public String authenticationUrl {
            get {
                if (this.isLegacy) {
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
                            AND ExternalDataSourceId IN (SELECT Id FROM NamedCredential WHERE DeveloperName = :this.apiName)
                        LIMIT 1
                    ];
                    if (!existingDataUserAuths.isEmpty()) {
                        return String.format('/{0}/e', Lists.of(existingDataUserAuths[0].Id));
                    }
                    String prefix = ExternalDataUserAuth.getSObjectType().getDescribe().getKeyPrefix();
                    return String.format('/{0}/e', Lists.of(prefix));
                } else {
                    // Personal User Setting page in Lightning Experience;
                    return '/lightning/settings/personal/ExternalCredentials/home';
                }
            }
        }
        @AuraEnabled
        public Id externalCredentialId;

        public NamedCredentialInfo(Schema.NamedCredential nc) {
            this.id = nc.Id;
            this.label = nc.MasterLabel;
            this.apiName = nc.DeveloperName;
            this.principalType = nc.PrincipalType;
        }

        public NamedCredentialInfo(ConnectApi.NamedCredential nc) {
            this.id = nc.id;
            this.label = nc.masterLabel;
            this.apiName = nc.developerName;
            this.externalCredentialId = nc.externalCredentials?.get(0)?.id;
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
