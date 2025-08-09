/**
 * Example usage:
 *
 * Executes a Tooling API query to retrieve `ExternalCredentialParameter` records
 * for the `SalesforceRestApi` Named Credential where `ParameterType` contains "principal".
 *
 * ```
 * String soqlQuery = 'SELECT \n' +
 *     '    Id, ParameterName, ParameterGroup, ParameterType, ExternalCredentialId \n' +
 *     'FROM ExternalCredentialParameter\n' +
 *     'WHERE ExternalCredentialId IN (\n' +
 *     '    SELECT ExternalCredentialId\n' +
 *     '    FROM NamedCredentialParameter\n' +
 *     '    WHERE NamedCredential.DeveloperName = \'SalesforceRestApi\'\n' +
 *     ')\n' +
 *     'AND ParameterType LIKE \'%principal%\'';
 *
 * List<ToolingApi.ExternalCredentialParameter> res =
 *     (List<ToolingApi.ExternalCredentialParameter>)
 *         ToolingApi.query(soqlQuery, List<ToolingApi.ExternalCredentialParameter>.class);
 * Logger.debug(res.toString());
 * ```
 */
@SuppressWarnings('PMD')
public inherited sharing class ToolingApi {
    public static List<Object> query(String soqlQuery, Type toolingApiObjectDto) {
        String encodedSoqlQuery = EncodingUtil.urlEncode(soqlQuery, 'UTF-8');
        HttpRequest req = new HttpRequest();
        req.setEndpoint(
            String.format(
                'callout:{0}/services/data/v{1}/tooling/query?q={2}',
                Lists.of(Constants.NamedCredential.Loopback, Constants.Org.ApiVersion, encodedSoqlQuery)
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
        String serializedRecords = JSON.serialize(rawMap.get('records'));
        return (List<Object>) JSON.deserialize(serializedRecords, toolingApiObjectDto);
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
