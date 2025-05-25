public class OAuthTokenResponsePayload {
    public String access_token;
    public String refresh_token;

    public OAuthTokenResponsePayload() {
    }

    public OAuthTokenResponsePayload(String accessToken) {
        this();
        this.access_token = accessToken;
    }

    public OAuthTokenResponsePayload(String accessToken, String refreshToken) {
        this();
        this.access_token = accessToken;
        this.refresh_token = refreshToken;
    }
}
