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

    @IsTest
    static void testDataGeneration() {
        Integer accountsAmount = 5;
        Integer contactsAmount = 20;
        Integer oppAmount = 17;
        Integer leadsAmount = 5;
        // Test Accounts generation;
        List<Account> testAccounts = TestDataFactory.createAccounts(accountsAmount);
        Assert.areEqual(accountsAmount, testAccounts.size());
        // Test Contacts generation;
        Account testAccount = testAccounts[0];
        List<Contact> testContacts = TestDataFactory.createContacts(contactsAmount);
        Assert.areEqual(contactsAmount, testContacts.size());
        for (Contact ct : testContacts) {
            Assert.areEqual(null, ct.AccountId);
        }
        List<Contact> contactsWithAccount = TestDataFactory.createContacts(contactsAmount, testAccount.Id);
        Assert.areEqual(contactsAmount, contactsWithAccount.size());
        for (Contact ct : contactsWithAccount) {
            Assert.areEqual(testAccount.Id, ct.AccountId);
        }
        // Test Opportunities generation;
        List<Opportunity> oppsWithAccount = TestDataFactory.createOpportunities(oppAmount, testAccount.Id);
        Assert.areEqual(oppAmount, oppsWithAccount.size());
        for (Opportunity opp : oppsWithAccount) {
            Assert.areEqual(testAccount.Id, opp.AccountId);
        }
        // Test Leads generation;
        List<Lead> testLeads = TestDataFactory.createLeads(leadsAmount);
        Assert.areEqual(leadsAmount, testLeads.size());
    }
}
