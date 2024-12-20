/**
 * A factory class for creating mocked HTTP callouts for testing purposes in Salesforce.
 * This class allows the creation of predefined responses to specific HTTP requests
 * to facilitate unit testing of callout logic without making actual HTTP calls.
 *
 * Usage:
 * - Instantiate the factory using the singleton pattern via `getInstance()`.
 * - Use `mockRequestTo()` to set up expected responses for specific HTTP requests.
 * - Utilize `mockDefaultRequest()` to set a default response for any unmocked requests.
 * - Call `mock()` to set the factory as the mock provider for HTTP callouts in test context.
 * - The `respond()` method is used internally to provide responses to the mocked requests.
 *
 * See `MockedCalloutsFactoryTest.cls` for usage samples.
 */
public class MockedCalloutsFactory implements HttpCalloutMock {
    private static MockedCalloutsFactory instance = null;
    private final Map<String, HttpCalloutMockBuilder> mockedResponsesByRequestKeysMap = null;
    private final String DEFAULT_REQUEST_KEY = 'default_request';

    private MockedCalloutsFactory() {
        this.mockedResponsesByRequestKeysMap = new Map<String, HttpCalloutMockBuilder>();
    }

    public static MockedCalloutsFactory getInstance() {
        if (instance == null) {
            instance = new MockedCalloutsFactory();
        }
        return instance;
    }

    public HttpCalloutMockBuilder mockDefaultRequest() {
        HttpCalloutMockBuilder builderInstance = new HttpCalloutMockBuilder();
        this.mockedResponsesByRequestKeysMap.put(this.DEFAULT_REQUEST_KEY, builderInstance);
        return builderInstance;
    }

    public HttpCalloutMockBuilder mockRequestTo(String requestMethod, String requestEndpoint) {
        return this.mockRequestTo(requestMethod, requestEndpoint, '');
    }

    public HttpCalloutMockBuilder mockRequestTo(String requestMethod, String requestEndpoint, String requestBody) {
        HttpCalloutMockBuilder builderInstance = new HttpCalloutMockBuilder(requestMethod, requestEndpoint, requestBody);
        String uniqueRequestKey = this.computeRequestKey(requestMethod, requestEndpoint, requestBody);
        if (this.mockedResponsesByRequestKeysMap.containsKey(uniqueRequestKey)) {
            throw new IllegalArgumentException(
                String.format('This request has already been mocked by key: [{0}]', Lists.of(uniqueRequestKey))
            );
        }
        this.mockedResponsesByRequestKeysMap.put(uniqueRequestKey, builderInstance);
        return builderInstance;
    }

    public HttpResponse respond(HttpRequest request) {
        String requestKey = this.computeRequestKey(request);
        if (this.mockedResponsesByRequestKeysMap.containsKey(requestKey)) {
            return this.mockedResponsesByRequestKeysMap.get(requestKey).buildHttpResponse();
        } else if (this.mockedResponsesByRequestKeysMap.containsKey(DEFAULT_REQUEST_KEY)) {
            return this.mockedResponsesByRequestKeysMap.get(DEFAULT_REQUEST_KEY).buildHttpResponse();
        }
        throw new IllegalArgumentException(String.format('Http Request was not mocked: [{0}]', Lists.of(request.toString())));
    }

    public void mock() {
        Test.setMock(HttpCalloutMock.class, instance);
    }

    private String computeRequestKey(HttpRequest request) {
        return this.computeRequestKey(request.getMethod(), request.getEndpoint(), request.getBody());
    }

    private String computeRequestKey(String requestMethod, String requestEndpoint, String requestBody) {
        return String.format('{0}:{1}:{2}', Lists.of(requestMethod, requestEndpoint, requestBody)).toLowerCase();
    }

    public class HttpCalloutMockBuilder {
        // Http Request attributes;
        private final String requestMethod;
        private final String requestEndpoint;
        private final String requestBody;
        // Http Response attributes;
        private String responseStatus = null;
        private Integer responseStatusCode = 200;
        private String responseBody = null;

        private HttpCalloutMockBuilder() {
            // Default values;
            this.responseStatus = 'OK';
            this.responseStatusCode = 200;
            this.responseBody = '{"success": true}';
        }

        private HttpCalloutMockBuilder(String requestMethod, String requestEndpoint, String requestBody) {
            this();
            this.requestMethod = requestMethod;
            this.requestEndpoint = requestEndpoint;
            this.requestBody = requestBody;
        }

        public HttpCalloutMockBuilder withResponseStatus(String status) {
            this.responseStatus = status;
            return this;
        }

        public HttpCalloutMockBuilder withResponseStatusCode(Integer statusCode) {
            this.responseStatusCode = statusCode;
            return this;
        }

        public HttpCalloutMockBuilder withResponseBody(String body) {
            this.responseBody = body;
            return this;
        }

        private HttpResponse buildHttpResponse() {
            HttpResponse mockedResponse = new HttpResponse();
            mockedResponse.setStatus(this.responseStatus);
            mockedResponse.setStatusCode(this.responseStatusCode);
            mockedResponse.setBody(this.responseBody);
            return mockedResponse;
        }
    }
}
