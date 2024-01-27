@IsTest
private class TestDataFactoryTest {
    @IsTest
    static void testCreateUser() {
        // Set up test data
        String firstName = 'Test';
        String lastName = 'User';

        Profile adminProfile = TestDataFactory.selectSystemAdminProfile();
        Assert.isNotNull(adminProfile);
        Profile minloproUserProfile = TestDataFactory.selectMinloproUserProfile();
        Assert.isNotNull(minloproUserProfile);

        // Call the method to test
        User testUser = TestDataFactory.createUser(firstName, lastName, adminProfile.Id);

        // Assert that the user has been correctly set up
        System.assertNotEquals(null, testUser, 'User should not be null');
        System.assertEquals(firstName, testUser.FirstName, 'First name should match');
        System.assertEquals(lastName, testUser.LastName, 'Last name should match');
        System.assertNotEquals(null, testUser.Username, 'Username should not be null');
        System.assertEquals(adminProfile.Id, testUser.ProfileId, 'Profile ID should match');
        System.assertEquals('9999999999', testUser.Phone, 'Phone should match');
        System.assertEquals('9999999999', testUser.MobilePhone, 'Mobile phone should match');
    }
}
