@IsTest
private class AccountChangeEvent_TH_DemoTest {
    @TestSetup
    static void setup() {
        // Assert that sample Account trigger handler exist;
        String handlerName = TH_Account_CDC_Sample1.class.getName();
        List<TriggerHandler__mdt> accountHandlers = [
            SELECT Id, ApexClassName__c, Active__c
            FROM TriggerHandler__mdt
            WHERE ApexClassName__c = :handlerName AND Active__c = TRUE
        ];
        Assert.areEqual(1, accountHandlers.size(), 'Sample CDC Account trigger handler should exist and be active!');
    }

    @IsTest
    static void testChangeDataCaptureTriggerHandler() {
        // Configure dispatcher to invoke specific handler only;
        Assert.isFalse(TriggerDispatcher.isSelectiveMode());
        TriggerDispatcher.enableObjectHandler(AccountChangeEvent.SObjectType, TH_Account_CDC_Sample1.class.getName());
        Assert.isTrue(TriggerDispatcher.isSelectiveMode());
        // Enable 'debug' mode within trigger module;
        TriggerDispatcher.debugModeEnabled = true;
        // Generate and verify test data;
        List<Account> testAccounts = TestDataFactory.createAccounts(50);
        Assert.isFalse(testAccounts.isEmpty());
        for (Account accountItem : testAccounts) {
            Assert.isTrue(String.isBlank(accountItem.Description), 'Account Description field should be blank');
        }
        // Override datetime stamp to verify field change in test;
        final String datetimeFormat = 'mm-dd-YYYY';
        TH_Account_CDC_Sample1.DATETIME_STAMP_FORMAT = datetimeFormat;
        String datetimeStamp = Datetime.now().format(TH_Account_CDC_Sample1.DATETIME_STAMP_FORMAT);
        // Enable CDC in test context;
        Test.enableChangeDataCapture();
        Test.startTest();
        insert testAccounts;
        Test.stopTest();
        // Verify that the AnnualRevenue field was NOT updated!;
        for (Account accountItem : [SELECT Id, Name, Description FROM Account WHERE Id IN :testAccounts]) {
            Assert.isTrue(String.isNotBlank(accountItem.Description), 'Account Description field should have been populated');
            Assert.isTrue(
                accountItem.Description.contains(datetimeStamp),
                'Account Description field should contain datetime stamp in this format: ' + datetimeFormat
            );
        }
    }
}
