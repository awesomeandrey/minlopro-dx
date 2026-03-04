@IsTest
private class DigExReCaptchaControllerTest {
    @IsTest
    static void testVerifyUserToken() {
        System.runAs(TestDataFactory.createDigExGuestUser()) {
            DigExReCaptchaController.ReCaptchaResponse mockedResponse = new DigExReCaptchaController.ReCaptchaResponse();
            mockedResponse.success = true;
            mockedResponse.hostname = 'sample_hostname';
            mockedResponse.errorCodes = Lists.of('missing-input-response', 'invalid-input-response');
            MockedCalloutsFactory factory = MockedCalloutsFactory.getInstance();
            factory.mockDefaultRequest().withResponseStatusCode(200).withResponseBody(mockedResponse.toJson());
            factory.mock();
            Test.startTest();
            DigExReCaptchaController.ReCaptchaResponse reCaptchaResponse = DigExReCaptchaController.verifyUserToken(
                'sample_recaptcha_token'
            );
            Test.stopTest();
            Assert.areEqual(mockedResponse.success, reCaptchaResponse.success);
            Assert.areEqual(mockedResponse.hostname, reCaptchaResponse.hostname);
            Assert.areEqual(2, reCaptchaResponse.errorCodes.size());
            Assert.areEqual(mockedResponse.errorCodes, reCaptchaResponse.errorCodes);
        }
    }

    @IsTest
    static void testVerifyUserTokenError() {
        System.runAs(TestDataFactory.createDigExGuestUser()) {
            MockedCalloutsFactory factory = MockedCalloutsFactory.getInstance();
            factory.mockDefaultRequest().withResponseStatusCode(400);
            factory.mock();
            Test.startTest();
            try {
                DigExReCaptchaController.verifyUserToken('sample_recaptcha_token');
                Assert.fail();
            } catch (Exception ex) {
                Assert.isInstanceOfType(ex, AuraHandledException.class);
            }
            Test.stopTest();
        }
    }
}
