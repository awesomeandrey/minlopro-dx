@IsTest
private class DlrsAccountRollupsTest {
    @TestSetup
    static void setup() {
        final List<String> rollupConfigsNames = Lists.of('Account_AvgOfOpportunitiesAmount', 'Account_CountOfContacts');
        List<dlrs__LookupRollupSummary2__mdt> rollupConfigs = [
            SELECT Id, DeveloperName, MasterLabel, dlrs__Active__c
            FROM dlrs__LookupRollupSummary2__mdt
            WHERE DeveloperName IN :rollupConfigsNames
        ];
        Assert.isFalse(rollupConfigs.isEmpty(), 'The sample DLRS configs should exist and be deployed');
        for (dlrs__LookupRollupSummary2__mdt rollupConfig : rollupConfigs) {
            Assert.isTrue(
                rollupConfig.dlrs__Active__c,
                String.format('[{0}] DLRS rollup config should be active', Lists.of(rollupConfig.DeveloperName))
            );
        }
    }

    @IsTest
    static void testCalculateAvgOfChildOpportunitiesAmountOnParentAccount() {
        // Enable Trigger Handlers 'selective mode'
        TriggerDispatcher.enableObjectHandler(Account.SObjectType, TH_Account_DLRS_Rollups.class.getName());
        TriggerDispatcher.enableObjectHandler(Opportunity.SObjectType, TH_Opportunity_DLRS_Rollups.class.getName());
        System.runAs(TestDataFactory.createRegularUser()) {
            Account testAccount = TestDataFactory.createAccounts(1)[0];
            insert testAccount;
            List<Opportunity> testChildOpportunities = TestDataFactory.createOpportunities(15, testAccount.Id);
            insert testChildOpportunities;
            testAccount = selectAccountWithDlrsFieldsById(testAccount.Id);
            Assert.areEqual(
                calculateAverageOfAmount(testChildOpportunities),
                testAccount.AvgOpportunitiesAmount__c.setScale(2, RoundingMode.HALF_UP),
                'Rolled-up Opportunities Amount average is wrong'
            );
            Opportunity testLastOpportunity = testChildOpportunities.remove(testChildOpportunities.size() - 1);
            delete testLastOpportunity;
            testAccount = selectAccountWithDlrsFieldsById(testAccount.Id);
            Assert.areEqual(
                calculateAverageOfAmount(testChildOpportunities),
                testAccount.AvgOpportunitiesAmount__c.setScale(2, RoundingMode.HALF_UP),
                'Rolled-up Opportunities Amount average is wrong'
            );
        }
    }

    @IsTest
    static void testCalculateCountOfChildContactsOnParentAccount() {
        // Enable Trigger Handlers 'selective mode'
        TriggerDispatcher.enableObjectHandler(Account.SObjectType, TH_Account_DLRS_Rollups.class.getName());
        TriggerDispatcher.enableObjectHandler(Contact.SObjectType, TH_Contact_DLRS_Rollups.class.getName());
        final Integer childContactsCount = 50;
        System.runAs(TestDataFactory.createRegularUser()) {
            Account testAccount = TestDataFactory.createAccounts(1)[0];
            insert testAccount;
            List<Contact> testChildContacts = TestDataFactory.createContacts(childContactsCount, testAccount.Id);
            insert testChildContacts;
            testAccount = selectAccountWithDlrsFieldsById(testAccount.Id);
            Assert.areEqual(childContactsCount, testAccount.CountOfContacts__c, 'Rolled-up Contacts count did not match');
            delete testChildContacts[testChildContacts.size() - 1];
            testAccount = selectAccountWithDlrsFieldsById(testAccount.Id);
            Assert.areEqual(childContactsCount - 1, testAccount.CountOfContacts__c, 'Rolled-up Contacts count did not match');
        }
    }

    static Account selectAccountWithDlrsFieldsById(Id accountId) {
        return [SELECT Id, Name, AvgOpportunitiesAmount__c, CountOfContacts__c FROM Account WHERE Id = :accountId LIMIT 1];
    }

    static Decimal calculateAverageOfAmount(List<Opportunity> opportunities) {
        Decimal totalAmount = 0;
        for (Opportunity opp : opportunities) {
            totalAmount += (opp.Amount != null) ? opp.Amount : 0;
        }
        return (totalAmount / opportunities.size()).setScale(2, RoundingMode.HALF_UP);
    }
}
