public without sharing class ToolingApi {
    private static final String NAMED_CREDENTIAL_API_NAME = 'SalesforceRestApi';
    private static final String API_VERSION = '63.0';

    public static List<Object> query(String soqlQuery, Type toolingApiObjectDto) {
        String encodedSoqlQuery = EncodingUtil.urlEncode(soqlQuery, 'UTF-8');
        HttpRequest req = new HttpRequest();
        req.setEndpoint(
            String.format(
                'callout:{0}/services/data/v{1}/tooling/query?q={2}',
                Lists.of(NAMED_CREDENTIAL_API_NAME, API_VERSION, encodedSoqlQuery)
            )
        );
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() != 200) {
            throw new CalloutException('Tooling API query failed: ' + res.getStatusCode() + ' ' + res.getBody());
        }
        Map<String, Object> rawMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String serRecords = JSON.serialize(rawMap.get('records'));
        return (List<Object>) JSON.deserialize(serRecords, toolingApiObjectDto);
    }

    public class ExternalCredential {
        public String AuthenticationProtocol;
        public String Description;
        public String DeveloperName;
        public String FullName;
        public Id Id;
        public String ManageableState;
        public String MasterLabel;
        public String NamespacePrefix;
    }

    public class ExternalCredentialParameter {
        public Id Id;
        public Id ExternalCredentialId;
        public String ParameterGroup;
        public String ParameterName;
        public String ParameterType;
        public String ParameterValue;
        public Integer SequenceNumber;
    }

    public class NamedCredentialParameter {
        public String Description;
        public ExternalCredential ExternalCredential;
        public Id ExternalCredentialId;
        public Id Id;
        public NamedCredential NamedCredential;
        public Id NamedCredentialId;
        public String ParameterName;
        public String ParameterType;
        public String ParameterValue;
        public Integer SequenceNumber;
    }
}
