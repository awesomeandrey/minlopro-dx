@IsTest
private class TestDataFactoryTest {
    @IsTest
    static void testCreateAdmin() {
        Profile adminProfile = TestDataFactory.selectSystemAdminProfile();
        User adminUser = TestDataFactory.createAdmin();
        // Assert that the user has been correctly set up;
        Assert.isNotNull(adminUser.Id);
        Assert.isNotNull(adminUser.UserRoleId);
        Assert.areEqual(adminProfile.Id, adminUser.ProfileId);
        Assert.isNotNull(adminUser.Username);
        // Verify that Admin user was added to corresponding Public Group;
        List<GroupMember> membership = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :adminUser.Id];
        Assert.isFalse(membership.isEmpty(), 'Admin user was not added to any public group.');
        // Verify that Admin user was assigned valid PSGs / permission sets;
        List<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :adminUser.Id];
        Assert.isFalse(assignments.isEmpty(), 'Admin user was not assigned any PSGs / permission sets.');
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
