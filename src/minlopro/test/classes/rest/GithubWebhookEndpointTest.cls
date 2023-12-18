@IsTest
private class GithubWebhookEndpointTest {
    private static final String TEST_WEBHOOK_SECRET = 'test_secret';

    static {
        // Set the test secret for validation;
        GithubWebhookEndpoint.GITHUB_WEBHOOK_SECRET = TEST_WEBHOOK_SECRET;
    }

    @IsTest
    static void processRequestWithInvalidSignature() {
        RestContext.request = createRequest(false, false);
        RestContext.response = new RestResponse();
        Test.startTest();
        GithubWebhookEndpoint.doPost();
        Test.stopTest();
        System.assertEquals(
            403,
            RestContext.response.statusCode,
            'Request with mismatched signature should have failed with 403 HTTP status code.'
        );
    }

    @IsTest
    static void processRequestWithValidSignatureAndUnsubscribedEvent() {
        RestContext.request = createRequest(false, true);
        RestContext.response = new RestResponse();
        Test.startTest();
        GithubWebhookEndpoint.doPost();
        Test.stopTest();
        System.assertEquals(
            400,
            RestContext.response.statusCode,
            'Request with valid signature but unsubscribed event should have failed with 400 HTTP status code.'
        );
    }

    @IsTest
    static void processRequestWithValidSignatureAndSubscribedEvent() {
        RestContext.request = createRequest(true, true);
        RestContext.response = new RestResponse();
        Test.startTest();
        GithubWebhookEndpoint.doPost();
        Test.stopTest();
        System.assertEquals(
            200,
            RestContext.response.statusCode,
            'Request with valid signature & subscribed event should have succeeded with 200 HTTP status code.'
        );
    }

    private static RestRequest createRequest(Boolean subscribed, Boolean signed) {
        RestRequest req = new RestRequest();
        // Put event info into request;
        GithubWebhookEndpoint.Event event = createEvent(subscribed);
        req.requestBody = Blob.valueOf(JSON.serialize(event));
        // Calculate signature;
        String signature = String.format(
            '{0}={1}',
            Lists.of(
                GithubWebhookEndpoint.GITHUB_SIGNATURE_PREFIX,
                GithubWebhookEndpoint.generateHmacSHA256(req.requestBody.toString(), TEST_WEBHOOK_SECRET)
            )
        );
        req.addHeader(GithubWebhookEndpoint.GITHUB_SIGNATURE_HEADER, signed ? signature : 'invalid_signature');
        return req;
    }

    private static GithubWebhookEndpoint.Event createEvent(Boolean subscribed) {
        GithubWebhookEndpoint.WorkflowRun workflowRun = new GithubWebhookEndpoint.WorkflowRun();
        workflowRun.id = '123456';
        workflowRun.name = 'Deploy Source';
        workflowRun.status = 'completed';
        workflowRun.conclusion = 'success';
        workflowRun.html_url = String.format(
            'https://github.com/awesomeandrey/minlopro-dx/actions/runs/{0}',
            Lists.of(workflowRun.id)
        );
        GithubWebhookEndpoint.Event event = new GithubWebhookEndpoint.Event();
        event.action = subscribed ? 'completed' : 'unknown';
        event.workflow_run = workflowRun;
        return event;
    }
}
