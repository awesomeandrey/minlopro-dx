@IsTest
private class CurrencyRollupControllerTest {
    @IsTest
    static void testRollupOpportunitiesByAccountId() {
        // Set up test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 1000,
            AccountId = testAccount.Id
        );
        insert testOpportunity;

        // Test rollupOpportunitiesByAccountId method
        Test.startTest();
        Decimal totalAmount = CurrencyRollupController.rollupOpportunitiesByAccountId(testAccount.Id);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1000, totalAmount, 'The total amount should be equal to the sum of the Opportunity Amounts.');
    }

    @IsTest
    static void testGetOrgCurrencyTypes() {
        // Test getOrgCurrencyTypes method
        Test.startTest();
        List<CurrencyType> currencyTypes = CurrencyRollupController.getOrgCurrencyTypes();
        Test.stopTest();

        // Assuming multi-currency is enabled and there are active currency types
        System.assertNotEquals(0, currencyTypes.size(), 'There should be at least one active currency type.');
    }

    @IsTest
    static void testFetchOpportunitiesByAccountId() {
        // Set up test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 1000,
            AccountId = testAccount.Id
        );
        insert testOpportunity;

        // Test fetchOpportunitiesByAccountId method
        Test.startTest();
        List<Opportunity> opportunities = CurrencyRollupController.fetchOpportunitiesByAccountId(testAccount.Id);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1, opportunities.size(), 'There should be one opportunity related to the test account.');
        System.assertEquals('Test Opportunity', opportunities[0].Name, 'The opportunity name should match.');
    }
}
