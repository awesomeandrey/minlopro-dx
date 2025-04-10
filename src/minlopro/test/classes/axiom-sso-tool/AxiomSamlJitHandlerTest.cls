@IsTest
private class AxiomSamlJitHandlerTest {
    @IsTest
    static void testCreateUser() {
        // Prepare test data
        Id samlSsoProviderId = null;
        Id communityId = null;
        Id portalId = null;
        String federationIdentifier = TestDataFactory.generateRandomString(10);
        Map<String, String> attributes = new Map<String, String>{
            AxiomSamlJitHandler.CLAIM_FIRSTNAME => 'f_name',
            AxiomSamlJitHandler.CLAIM_LASTNAME => 'l_name'
        };
        String assertion = EncodingUtil.base64Encode(Blob.valueOf(attributes.toString()));
        User adminUser = TestDataFactory.createAdmin();
        System.runAs(adminUser) {
            AxiomSamlJitHandler jitHandler = new AxiomSamlJitHandler();
            Test.startTest();
            User digExPartnerUser = jitHandler.createUser(
                samlSsoProviderId,
                communityId,
                portalId,
                federationIdentifier,
                attributes,
                assertion
            );
            Test.stopTest();
            digExPartnerUser = [
                SELECT Id, FederationIdentifier, Profile.UserLicense.Name, UserType
                FROM User
                WHERE Id = :digExPartnerUser.Id
                LIMIT 1
            ][0];
            Assert.areEqual(federationIdentifier, digExPartnerUser.FederationIdentifier, 'Federation Identifiers should match');
            Assert.areEqual(AxiomSamlJitHandler.DIGEX_PARTNER_PROFILE.Id, digExPartnerUser.ProfileId);
            Assert.isFalse(
                [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :digExPartnerUser.Id].isEmpty(),
                'PSG should have been assigned to newly created user'
            );
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
