@IsTest
private class StaticResourceDataLoadTest {
    @IsTest
    static void loadTestDataFromStaticResource() {
        // `Test.loadData()` commits records immediately and fires trigger handlers.
        final String SAMPLE_ACCOUNTS_CSV_FILE = 'SampleData_Accounts_500';
        List<Account> testAccounts = (List<Account>) Test.loadData(Account.SObjectType, SAMPLE_ACCOUNTS_CSV_FILE);
        Assert.areEqual(500, testAccounts.size(), 'There should be 500 test Account records loaded');
        for (Account record : testAccounts) {
            Assert.isNotNull(record.Id, 'Test Account record should be inserted and have ID value');
        }
    }
}
