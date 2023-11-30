@IsTest
private class MockedCalloutsFactoryTest {
    private static final String HTTP_METHOD_GET = 'GET';
    private static final String HTTP_METHOD_POST = 'POST';
    private static final String HTTP_REQUEST_URL = 'https://test.salesforce.com';

    @IsTest
    static void verifyCalloutMocks() {
        // Parameter for the 1st callout;
        Integer expectedResponseStatusCode1 = 200;
        // Parameters for the 2nd callout;
        Integer expectedResponseStatusCode2 = 500;
        String expectedResponseStatus2 = 'Server Error';
        String requestBody = '{"message": "<sample request body>"}';
        String expectedResponseBody = '{"message": ">sample response body<"}';

        // Mock HTTP responses for 2 callouts;
        MockedCalloutsFactory factory = MockedCalloutsFactory.getInstance();
        factory.mockRequestTo(HTTP_METHOD_GET, HTTP_REQUEST_URL).withResponseStatusCode(expectedResponseStatusCode1);
        factory.mockRequestTo(HTTP_METHOD_POST, HTTP_REQUEST_URL, requestBody)
            .withResponseStatusCode(expectedResponseStatusCode2)
            .withResponseStatus(expectedResponseStatus2)
            .withResponseBody(expectedResponseBody);
        factory.mock();

        // Invoke 2 unique HTTP callouts;
        Test.startTest();
        HttpRequest request1 = new HttpRequest();
        request1.setMethod(HTTP_METHOD_GET); // GET request;
        request1.setEndpoint(HTTP_REQUEST_URL);
        HttpResponse response1 = new Http().send(request1);

        HttpRequest request2 = new HttpRequest();
        request2.setMethod(HTTP_METHOD_POST); // POST request;
        request2.setEndpoint(HTTP_REQUEST_URL);
        request2.setBody(requestBody);
        HttpResponse response2 = new Http().send(request2);
        Test.stopTest();

        // Assert that callouts were mocked;
        Assert.areEqual(expectedResponseStatusCode1, response1.getStatusCode());
        Assert.areEqual(expectedResponseStatusCode2, response2.getStatusCode());
        Assert.areEqual(expectedResponseStatus2, response2.getStatus());
        Assert.areEqual(expectedResponseBody, response2.getBody());
    }

    @IsTest
    static void verifyUnknownCalloutMock() {
        Integer expectedResponseStatusCode1 = 200;
        Integer expectedResponseStatusCode2 = 500;
        String expectedResponseBody2 = '{"message": "echo"}';

        // Mock HTTP responses for 2 callouts;
        MockedCalloutsFactory factory = MockedCalloutsFactory.getInstance();
        factory.mockRequestTo(HTTP_METHOD_GET, HTTP_REQUEST_URL).withResponseStatusCode(expectedResponseStatusCode1);
        factory.mockUnknownRequest().withResponseStatusCode(expectedResponseStatusCode2).withResponseBody(expectedResponseBody2);
        factory.mock();

        // Invoke 2 unique HTTP callouts;
        Test.startTest();
        HttpRequest request1 = new HttpRequest();
        request1.setMethod(HTTP_METHOD_GET); // GET request;
        request1.setEndpoint(HTTP_REQUEST_URL); // Known Endpoint;
        HttpResponse response1 = new Http().send(request1);

        HttpRequest request2 = new HttpRequest();
        request2.setMethod(HTTP_METHOD_POST); // POST request;
        request2.setEndpoint('https://unknown.site.com'); // Unknown Endpoint;
        request2.setBody('[1, 2, 3]'); // Empty Payload;
        HttpResponse response2 = new Http().send(request2);
        Test.stopTest();

        // Assert that callouts were mocked;
        Assert.areEqual(expectedResponseStatusCode1, response1.getStatusCode());
        Assert.areEqual(expectedResponseStatusCode2, response2.getStatusCode());
        Assert.areEqual(expectedResponseBody2, response2.getBody());
    }

    @IsTest
    static void verifyCalloutWithoutMock() {
        Integer expectedResponseStatusCode1 = 200;

        // Mock HTTP responses for one callout (method = 'GET');
        MockedCalloutsFactory factory = MockedCalloutsFactory.getInstance();
        factory.mockRequestTo(HTTP_METHOD_GET, HTTP_REQUEST_URL).withResponseStatusCode(expectedResponseStatusCode1);
        factory.mock();

        // Invoke HTTP callout to another endpoint (method = 'POST');
        Test.startTest();
        HttpRequest request1 = new HttpRequest();
        request1.setMethod(HTTP_METHOD_POST); // POST request;
        request1.setEndpoint(HTTP_REQUEST_URL);
        Boolean exceptionCaught = false;
        try {
            new Http().send(request1);
        } catch (Exception ex) {
            exceptionCaught = true;
            Assert.isInstanceOfType(ex, IllegalArgumentException.class);
            Assert.isTrue(ex.getMessage().containsIgnoreCase(request1.toString()));
        } finally {
            Test.stopTest();
        }
        Assert.isTrue(exceptionCaught, 'Exception should have been caught since the Http Request was not mocked!');
    }

    @IsTest
    static void verifyDuplicateCalloutMock() {
        String duplicateRequestMethod = HTTP_METHOD_GET;
        String duplicateRequestUrl = HTTP_REQUEST_URL;
        // Mock HTTP response for one callout (method = 'GET');
        MockedCalloutsFactory factory = MockedCalloutsFactory.getInstance();
        factory.mockRequestTo(duplicateRequestMethod, duplicateRequestUrl, '').withResponseStatusCode(400);
        Boolean exceptionCaught = false;
        try {
            // Mock HTTP response for IDENTICAL callout (method = 'GET' too);
            factory.mockRequestTo(duplicateRequestMethod, duplicateRequestUrl, '').withResponseStatusCode(401);
        } catch (Exception ex) {
            exceptionCaught = true;
            Assert.isInstanceOfType(ex, IllegalArgumentException.class);
            Assert.isTrue(ex.getMessage().containsIgnoreCase(duplicateRequestMethod));
            Assert.isTrue(ex.getMessage().containsIgnoreCase(duplicateRequestUrl));
        }
        Assert.isTrue(exceptionCaught, 'Attempt to mock identical Http Request should have caused exception!');
    }
}
