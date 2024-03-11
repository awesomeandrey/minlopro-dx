@IsTest
private class LeadsManagementControllerTest {
    @IsTest
    static void testQueryLeads() {
        Assert.isTrue(LeadsManagementController.getMineConvertedLeads().isEmpty());
        Assert.isTrue(LeadsManagementController.getMineNonConvertedLeads().isEmpty());
    }

    @IsTest
    static void testConvertLead() {
        Lead testLead = TestDataFactory.createLeads(1).get(0);
        insert testLead;
        testLead = [
            SELECT Id, Name, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId
            FROM Lead
            WHERE Id = :testLead.Id
            LIMIT 1
        ][0];
        Assert.isNull(testLead.ConvertedAccountId);
        Assert.isNull(testLead.ConvertedContactId);
        Assert.isNull(testLead.ConvertedOpportunityId);
        // Create conversion config;
        LeadsManagementController.ConvertConfig config = new LeadsManagementController.ConvertConfig();
        config.leadId = testLead.Id;
        config.accountId = null;
        config.contactId = null;
        config.doNotCreateOpportunity = false;
        config.sendNotificationEmail = false;
        config.allowSaveOnDuplicateRules = true;
        // Convert Lead;
        String convertResult = LeadsManagementController.convertLead(JSON.serialize(config), false);
        Assert.isNotNull(convertResult);
        // Re-query Lead;
        testLead = [
            SELECT Id, Name, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId
            FROM Lead
            WHERE Id = :testLead.Id
            LIMIT 1
        ][0];
        Assert.isNotNull(testLead.ConvertedAccountId);
        Assert.isNotNull(testLead.ConvertedContactId);
        Assert.isNotNull(testLead.ConvertedOpportunityId);
    }
}
