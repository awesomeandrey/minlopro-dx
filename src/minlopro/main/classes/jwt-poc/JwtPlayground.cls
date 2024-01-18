public with sharing class JwtPlayground {
    /**
     * Read https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_jwt_flow.htm&type=5 for more.
     */
    private final String cliend_id = '3MVG9OjW2TAjFKUts4gHxvJ5MTJnX37xCLa_fc6P7BRVBwLNXEKgm0fZjqtHiXo3p5EN2ZoDMFBq4_bbptUGD';
    private final String cert_name = 'JwtEchoCert';

    public JwtPlayground() {
    }

    public void play() {
        Auth.JWS jws = this.generateJws();
        // Set the token endpoint that the JWT bearer token is posted to
        String tokenEndpoint = 'https://test.salesforce.com/services/oauth2/token';
        // POST the JWT bearer token
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
        // Get the access token
        String accessToken = bearer.getAccessToken();
        System.debug('\n\n String.isBlank(accessToken) => ' + String.isBlank(accessToken) + '\n');
        System.debug('\n\n accessToken => ' + accessToken + '\n');
    }

    public Auth.JWS generateJws() {
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(UserInfo.getUserName());
        jwt.setAud('https://test.salesforce.com');
        jwt.setIss(this.cliend_id);

        // Additional claims to set scope
        // Map<String, Object> claims = new Map<String, Object>();
        // claims.put('scope', 'scope name');
        // jwt.setAdditionalClaims(claims);

        // Create the object that signs the JWT bearer token
        Auth.JWS jws = new Auth.JWS(jwt, this.cert_name);

        // Get the resulting JWS in case debugging is required
        String token = jws.getCompactSerialization();
        System.debug('\n\n token => ' + token + '\n');
        return jws;
    }

    public String base64UrlEncode(Blob input) {
        String output = EncodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while (output.endsWith('=')) {
            output = output.substring(0, output.length() - 1);
        }
        //output = output.replaceAll('=','');
        return output;
    }

    /**
     * Anonymous Apex Playground
     */
    public void run() {
        final JwtPlayground jwtPlayground = new JwtPlayground();
        final String jws = jwtPlayground.generateJws().getCompactSerialization();
        final String certName = 'JwtEchoCert';
        //
        final String clientId = '3MVG9OjW2TAjFKUts4gHxvJ5MTJnX37xCLa_fc6P7BRVBwLNXEKgm0fZjqtHiXo3p5EN2ZoDMFBq4_bbptUGD';
        final String aud = 'https://test.salesforce.com';
        final String sub = UserInfo.getUserName();

        String jwtHeader = '{"typ":"JWT","alg":"RS256","kid":"JwtEchoCert"}';
        String encodedJwtHeader = jwtPlayground.base64UrlEncode(Blob.valueOf(jwtHeader));
        Map<String, String> claimsMap = new Map<String, String>{
            'sub' => sub,
            'aud' => aud,
            'iss' => clientId,
            'exp' => String.valueOf(Datetime.now().addDays(30).getTime())
        };
        String jwtClaims = JSON.serialize(claimsMap);
        System.debug('\n\n jwtClaims => ' + jwtClaims + '\n');
        String encodedJwtClaims = jwtPlayground.base64UrlEncode(Blob.valueOf(jwtClaims));
        String encodedHeaderAndClaims = String.format('{0}.{1}', Lists.of(encodedJwtHeader, encodedJwtClaims));
        Blob jwtSignature = Crypto.signWithCertificate('RSA-SHA256', Blob.valueOf(encodedHeaderAndClaims), certName);
        String encodedJwtSignature = jwtPlayground.base64UrlEncode(jwtSignature);
        String customCraftedJwt = String.format('{0}.{1}', Lists.of(encodedHeaderAndClaims, encodedJwtSignature));

        System.debug('\n\n CUSTOM => ' + customCraftedJwt + '\n');
        System.debug('\n\n AUTH   => ' + jws + '\n');
        System.debug('\n\n jws.equalsIgnoreCase(customCraftedJwt) => ' + jws.equalsIgnoreCase(customCraftedJwt) + '\n');

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('https://test.salesforce.com/services/oauth2/token');
        request.setBody(
            String.format(
                'grant_type={0}&assertion={1}',
                Lists.of('urn:ietf:params:oauth:grant-type:jwt-bearer', customCraftedJwt)
            )
        );

        HttpResponse response = new Http().send(request);
        String requestState = String.format(
            'Status: {0} \n Status Code: {1}',
            Lists.of(response.getStatus(), String.valueOf(response.getStatusCode()))
        );
        System.debug('\n\n requestState => ' + requestState + '\n');
        System.debug('\n\n response.getBody() => ' + response.getBody() + '\n');
    }
}
