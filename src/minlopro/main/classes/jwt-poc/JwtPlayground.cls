/**
 * Read https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_jwt_flow.htm&type=5 for more.
 *
 * Demo Steps:
 *
 * 1. Download certificate file (with '.crt' extension) from "Certificate and Key Management" setup page
 * 2. Update "SFDC_JWT_Echo" connect app by uploading certificate from the previous step
 * 3. Capture "Consumer Key" generated at connected app details page
 * 4. Invoke "fetchAccessToken()" method in Anonymous Apex in order to retrieve access token
 */
public with sharing class JwtPlayground {
    private final String certDevName = 'Minlopro'; // See 'minlopro/main/certs' folder;
    private final String clientId = null;

    private String audience {
        get {
            if (String.isBlank(this.audience)) {
                this.audience = SystemInfoController.isSandbox() ? 'https://test.salesforce.com' : 'https://login.salesforce.com';
            }
            return this.audience;
        }
        set;
    }

    public JwtPlayground(String clientId) {
        this.clientId = clientId;
    }

    public String fetchAccessToken() {
        final String tokenEndpoint = String.format('{0}/services/oauth2/token', Lists.of(this.audience));
        Auth.JWS jwSignature = this.generateJsonWebSignature();
        // Request access token by JWT OAuth Flow;
        Auth.JWTBearerTokenExchange tokenExchange = new Auth.JWTBearerTokenExchange(tokenEndpoint, jwSignature);
        String accessToken = tokenExchange.getAccessToken();
        Assert.isTrue(String.isNotBlank(accessToken), 'Access Token was not retrieved!');
        HttpResponse response = tokenExchange.getHttpResponse();
        Logger.debug('Response Status Code = {0}', Lists.of(String.valueOf(response.getStatusCode())));
        Logger.debug('Response Status = {0}', Lists.of(response.getStatus()));
        Logger.debug('Response Body = {0}', Lists.of(response.getBody()));
        return accessToken;
    }

    private Auth.JWS generateJsonWebSignature() {
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(UserInfo.getUserName());
        jwt.setAud(this.audience);
        jwt.setIss(this.clientId);
        jwt.setValidityLength(60 * 10);
        // Additional claims to set scope
        // Map<String, Object> claims = new Map<String, Object>();
        // claims.put('scope', 'scope name');
        // jwt.setAdditionalClaims(claims);
        return new Auth.JWS(jwt, this.certDevName);
    }
}
