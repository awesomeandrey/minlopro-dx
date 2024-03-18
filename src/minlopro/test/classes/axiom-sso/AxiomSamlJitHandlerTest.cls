@IsTest
private class AxiomSamlJitHandlerTest {
    @IsTest
    static void testCreateUser() {
        // Prepare test data
        Id samlSsoProviderId = UserInfo.getUserId(); // Just an example, replace with actual Id
        Id communityId = null; // Just an example, replace with actual Id if applicable
        Id portalId = null; // Just an example, replace with actual Id if applicable
        String federationIdentifier = 'test_federation_identifier';
        Map<String, String> attributes = new Map<String, String>{ 'Attribute1' => 'Value1', 'Attribute2' => 'Value2' };
        String assertion = 'test_assertion';
        // Call the createUser method
        AxiomSamlJitHandler jitHandler = new AxiomSamlJitHandler();
        User createdUser = jitHandler.createUser(
            samlSsoProviderId,
            communityId,
            portalId,
            federationIdentifier,
            attributes,
            assertion
        );
        // Assert that a user object is returned
        Assert.isNotNull(createdUser);
    }

    @IsTest
    static void testUpdateUser() {
        User adminUser = TestDataFactory.createAdmin();
        insert adminUser;
        // Prepare test data
        Id samlSsoProviderId = UserInfo.getUserId(); // Just an example, replace with actual Id
        Id communityId = null; // Just an example, replace with actual Id if applicable
        Id portalId = null; // Just an example, replace with actual Id if applicable
        String federationIdentifier = 'test_federation_identifier';
        Map<String, String> attributes = new Map<String, String>{ 'Attribute1' => 'Value1', 'Attribute2' => 'Value2' };
        String assertion = 'test_assertion';
        Test.startTest();
        // Call the updateUser method
        AxiomSamlJitHandler jitHandler = new AxiomSamlJitHandler();
        jitHandler.updateUser(
            adminUser.Id,
            samlSsoProviderId,
            communityId,
            portalId,
            federationIdentifier,
            attributes,
            assertion
        );
        Test.stopTest();
        // Assert that user is updated
        User updatedUser = [SELECT Id FROM User WHERE Id = :adminUser.Id];
        Assert.isNotNull(updatedUser);
    }
}
