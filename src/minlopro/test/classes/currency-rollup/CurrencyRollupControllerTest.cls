@IsTest
private class CurrencyRollupControllerTest {
    @TestSetup
    static void testSetup() {
        Assert.isTrue(UserInfo.isMultiCurrencyOrganization(), 'The org must enable multi-currency feature!');
    }

    @IsTest
    static void testRollupOpportunitiesByAccountId() {
        Account testAccount = TestDataFactory.createAccounts(1)[0];
        insert testAccount;
        Opportunity testOpportunity = TestDataFactory.createOpportunities(1, testAccount.Id)[0];
        Assert.areEqual(TestDataFactory.CORPORATE_CURRENCY_TYPE.IsoCode, testOpportunity.CurrencyIsoCode);
        insert testOpportunity;
        Assert.isTrue(testOpportunity.Amount > 100);
        Decimal totalAmount = CurrencyRollupController.rollupOpportunitiesByAccountId(testAccount.Id);
        Assert.areEqual(testOpportunity.Amount, totalAmount);
    }

    @IsTest
    static void testGetOrgCurrencyTypes() {
        List<CurrencyType> currencyTypes = CurrencyRollupController.getOrgCurrencyTypes();
        Assert.isFalse(currencyTypes.isEmpty());
    }

    @IsTest
    static void testFetchOpportunitiesByAccountId() {
        Account testAccount = TestDataFactory.createAccounts(1)[0];
        insert testAccount;
        List<Opportunity> testOpportunities = TestDataFactory.createOpportunities(7, testAccount.Id);
        insert testOpportunities;
        List<Opportunity> fetchedOpportunities = CurrencyRollupController.fetchOpportunitiesByAccountId(testAccount.Id);
        Assert.areEqual(testOpportunities.size(), fetchedOpportunities.size());
    }
}
