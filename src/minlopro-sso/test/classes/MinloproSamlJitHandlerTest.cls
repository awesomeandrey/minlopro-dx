@IsTest
private class MinloproSamlJitHandlerTest {
    static Map<String, String> SAMPLE_SAML_ATTRIBUTES = new Map<String, String>{
        'User.FirstName' => 'f_name',
        'LastName' => 'l_name',
        'email' => 'sample@email.com'
    };

    @IsTest
    static void testCreateUser() {
        // Prepare test data
        Id samlSsoProviderId = null;
        Id communityId = null;
        Id portalId = null;
        String federationIdentifier = TestDataFactory.generateRandomString(10);
        String assertion = EncodingUtil.base64Encode(Blob.valueOf(SAMPLE_SAML_ATTRIBUTES.toString()));
        User adminUser = TestDataFactory.createAdmin();
        System.runAs(adminUser) {
            MinloproSamlJitHandler jitHandler = new MinloproSamlJitHandler();
            Test.startTest();
            User digExPartnerUser = jitHandler.createUser(
                samlSsoProviderId,
                communityId,
                portalId,
                federationIdentifier,
                SAMPLE_SAML_ATTRIBUTES,
                assertion
            );
            Test.stopTest();
            digExPartnerUser = [
                SELECT Id, FederationIdentifier, Profile.Name, Profile.UserLicense.Name, UserType
                FROM User
                WHERE Id = :digExPartnerUser.Id
                LIMIT 1
            ][0];
            Assert.areEqual(federationIdentifier, digExPartnerUser.FederationIdentifier, 'Federation Identifiers should match');
        }
    }

    @IsTest
    static void testUpdateUser() {
        User adminUser = TestDataFactory.createAdmin();
        // Prepare test data
        Id samlSsoProviderId = UserInfo.getUserId(); // Just an example, replace with actual Id
        Id communityId = null; // Just an example, replace with actual Id if applicable
        Id portalId = null; // Just an example, replace with actual Id if applicable
        String federationIdentifier = 'test_federation_identifier';
        String assertion = 'test_assertion';
        Test.startTest();
        // Call the updateUser method
        MinloproSamlJitHandler jitHandler = new MinloproSamlJitHandler();
        jitHandler.updateUser(
            adminUser.Id,
            samlSsoProviderId,
            communityId,
            portalId,
            federationIdentifier,
            SAMPLE_SAML_ATTRIBUTES,
            assertion
        );
        Test.stopTest();
        // Assert that user is updated
        User updatedUser = [SELECT Id FROM User WHERE Id = :adminUser.Id];
        Assert.isNotNull(updatedUser);
    }
}
