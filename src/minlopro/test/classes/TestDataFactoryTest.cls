@IsTest
private class TestDataFactoryTest {
    @IsTest
    static void testCreateUser() {
        // Set up test data
        String firstName = 'Test';
        String lastName = 'User';
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;

        // Call the method to test
        User testUser = TestDataFactory.createUser(firstName, lastName, profileId);

        // Assert that the user has been correctly set up
        System.assertNotEquals(null, testUser, 'User should not be null');
        System.assertEquals(firstName, testUser.FirstName, 'First name should match');
        System.assertEquals(lastName, testUser.LastName, 'Last name should match');
        System.assertNotEquals(null, testUser.Username, 'Username should not be null');
        System.assertEquals(profileId, testUser.ProfileId, 'Profile ID should match');
        System.assertEquals('9999999999', testUser.Phone, 'Phone should match');
        System.assertEquals('9999999999', testUser.MobilePhone, 'Mobile phone should match');
    }
}
