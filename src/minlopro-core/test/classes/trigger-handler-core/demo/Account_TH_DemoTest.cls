@IsTest
private class Account_TH_DemoTest {
    private static final Decimal RANDOM_ACCOUNT_REVENUE = TestDataFactory.generateRandomDecimal(500, 1500);

    @TestSetup
    static void setup() {
        // Assert that sample Account trigger handlers exist;
        List<String> handlerApexClassNames = Lists.of(TH_Account_Sample1.class.getName(), TH_Account_Sample2.class.getName());
        List<TriggerHandler__mdt> accountHandlers = [
            SELECT Id, ApexClassName__c, Active__c
            FROM TriggerHandler__mdt
            WHERE ApexClassName__c IN :handlerApexClassNames AND Active__c = TRUE
        ];
        Assert.areEqual(2, accountHandlers.size(), 'Sample Account trigger handlers should exist and be active!');
    }

    @IsTest
    static void testBypassHandlers() {
        // Enable 'debug' mode within trigger module;
        TriggerDispatcher.debugModeEnabled = true;
        // Generate and verify test data;
        List<Account> testAccounts = createAccountsWithEmptyAnnualRevenue(5);
        Assert.isFalse(testAccounts.isEmpty());
        for (Account accountItem : testAccounts) {
            Assert.isTrue(accountItem.AnnualRevenue < TH_Account_Sample1.DEFAULT_ANNUAL_REVENUE);
        }
        TriggerDispatcher.bypass(Account.SObjectType, TH_Account_Sample1.class.getName());
        Savepoint sp = Database.setSavepoint();
        insert testAccounts;
        // Verify that the AnnualRevenue field was NOT updated!;
        for (Account accountItem : [SELECT Id, Name, AnnualRevenue FROM Account WHERE Id IN :testAccounts]) {
            Assert.isTrue(accountItem.AnnualRevenue < TH_Account_Sample1.DEFAULT_ANNUAL_REVENUE);
        }
        // Clear bypass and rollback test Accounts;
        TriggerDispatcher.clearBypass(Account.SObjectType, TH_Account_Sample1.class.getName());
        TriggerDispatcher.clearAllBypass();
        Database.rollback(sp);
        // Re-generate tests Accounts and re-insert them;
        testAccounts = createAccountsWithEmptyAnnualRevenue(5);
        insert testAccounts;
        Assert.isFalse(testAccounts.isEmpty());
        for (Account accountItem : [SELECT Id, Name, AnnualRevenue FROM Account WHERE Id IN :testAccounts]) {
            Assert.areEqual(TH_Account_Sample1.DEFAULT_ANNUAL_REVENUE, accountItem.AnnualRevenue);
        }
    }

    @IsTest
    static void testInsertAndUpdateHandlers() {
        // Enable 'debug' mode within trigger module;
        TriggerDispatcher.debugModeEnabled = true;
        // Generate and verify test data;
        List<Account> testAccounts = createAccountsWithEmptyAnnualRevenue(5);
        Assert.isFalse(testAccounts.isEmpty());
        for (Account accountItem : testAccounts) {
            Assert.isTrue(accountItem.AnnualRevenue < TH_Account_Sample1.DEFAULT_ANNUAL_REVENUE);
        }
        // Insert test Accounts and verify that 'AnnualRevenue' field was increased due to 'TH_Account_Sample1' handler;
        insert testAccounts;
        for (Account accountItem : [SELECT Id, Name, AnnualRevenue FROM Account WHERE Id IN :testAccounts]) {
            Assert.areEqual(TH_Account_Sample1.DEFAULT_ANNUAL_REVENUE, accountItem.AnnualRevenue);
        }
        Assert.areEqual(1, Limits.getDmlStatements()); // insert = 1;
        // Update test Accounts with new 'AnnualRevenue' field value in order to trigger 'TH_Account_Sample2' handler;
        List<Account> accountsToUpdate = new List<Account>();
        for (Account accountItem : [SELECT Id, Name, AnnualRevenue FROM Account WHERE Id IN :testAccounts]) {
            accountItem.AnnualRevenue = 15;
            accountsToUpdate.add(accountItem);
        }
        Assert.isTrue(TH_Account_Sample1.DEFAULT_ANNUAL_REVENUE < TH_Account_Sample2.MAX_ANNUAL_REVENUE_THRESHOLD);
        update accountsToUpdate;
        // This DML should launch recursive handler invocation 3 times (until 'AnnualRevenue' becomes > 100);
        for (Account accountItem : [SELECT Id, Name, AnnualRevenue FROM Account WHERE Id IN :testAccounts]) {
            Assert.isTrue(accountItem.AnnualRevenue >= TH_Account_Sample2.MAX_ANNUAL_REVENUE_THRESHOLD);
        }
        Assert.areEqual(1 + 1 + 3, Limits.getDmlStatements()); // insert (1) + update_original (1) + update_recursive (3);
    }

    @IsTest
    static void testLoopCount() {
        // Enable 'debug' mode within trigger module;
        TriggerDispatcher.debugModeEnabled = true;
        // Synthetically enforce max loop count for trigger handler;
        TH_Account_Sample2.MAX_LOOP_COUNT = 2;
        // Insert test Accounts and run 'update' DML;
        List<Account> testAccounts = createAccountsWithEmptyAnnualRevenue(5);
        insert testAccounts;
        List<Account> accountsToUpdate = new List<Account>();
        for (Account accountItem : [SELECT Id, Name, AnnualRevenue FROM Account WHERE Id IN :testAccounts]) {
            accountItem.AnnualRevenue = 15;
            accountsToUpdate.add(accountItem);
        }
        try {
            /**
             * This DML is expected to be run recursively 3 times (until 'AnnualRevenue' becomes > 100).
             * But due to re-enforced max loop count limit, it should fail upon 3rd attempt.
             */
            update accountsToUpdate;
            throw new IllegalArgumentException('Update operation should have failed due to enforced max loop count!');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, System.DmlException.class);
            Assert.isTrue(ex.getMessage().containsIgnoreCase('max loop count reached'));
        }
    }

    @IsTest
    static void testSelectiveMode() {
        // Configure dispatcher to invoke specific handler only;
        Assert.isFalse(TriggerDispatcher.isSelectiveMode());
        TriggerDispatcher.enableObjectHandler(Account.SObjectType, TH_Account_Sample3.class.getName());
        Assert.isTrue(TriggerDispatcher.isSelectiveMode());
        // Enable 'debug' mode within trigger module;
        TriggerDispatcher.debugModeEnabled = true;
        // Generate and verify test data;
        List<Account> testAccounts = createAccountsWithEmptyAnnualRevenue(5);
        for (Account accountItem : testAccounts) {
            Assert.areNotEqual(RANDOM_ACCOUNT_REVENUE, accountItem.AnnualRevenue);
        }
        // Insert test Accounts and verify that 'AnnualRevenue' field was set to 'RANDOM_ACCOUNT_REVENUE';
        insert testAccounts;
        for (Account accountItem : [SELECT Id, Name, AnnualRevenue FROM Account WHERE Id IN :testAccounts]) {
            Assert.areEqual(RANDOM_ACCOUNT_REVENUE, accountItem.AnnualRevenue);
        }
    }

    @IsTest
    static void testInvalidHandlerImplementation() {
        // Configure dispatcher to invoke specific handler only;
        Assert.isFalse(TriggerDispatcher.isSelectiveMode());
        // "TH_Account_Sample4" apex class does not exist!
        TriggerDispatcher.enableObjectHandler(Account.SObjectType, 'TH_Account_Sample4');
        Assert.isTrue(TriggerDispatcher.isSelectiveMode());
        // Enable 'debug' mode within trigger module;
        TriggerDispatcher.debugModeEnabled = true;
        // Generate and verify test data;
        try {
            insert createAccountsWithEmptyAnnualRevenue(5);
            throw new IllegalArgumentException('Trigger handler MUST exist and extend "BasicTriggerHandler" class!');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, System.DmlException.class);
            Assert.isTrue(ex.getMessage().containsIgnoreCase('invalid handler implementation detected'));
        }
        List<Account> testAccounts = [SELECT Id, Name, AnnualRevenue FROM Account];
        Assert.isTrue(testAccounts.isEmpty());
    }

    static List<Account> createAccountsWithEmptyAnnualRevenue(Integer count) {
        List<Account> accounts = TestDataFactory.createAccounts(count);
        for (Account record : accounts) {
            record.AnnualRevenue = 0;
        }
        return accounts;
    }

    // Note: this class should be 'public' in order to let 'TriggerDispatcher' to instantiate it;
    public class TH_Account_Sample3 extends BasicTriggerHandler {
        public override void beforeInsert(List<SObject> newRecords) {
            List<Account> newAccounts = (List<Account>) newRecords;
            for (Account accountItem : newAccounts) {
                accountItem.AnnualRevenue = RANDOM_ACCOUNT_REVENUE;
            }
        }
    }
}
