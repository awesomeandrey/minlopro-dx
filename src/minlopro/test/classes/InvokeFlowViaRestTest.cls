@IsTest
private class InvokeFlowViaRestTest {
    /**
     * Useful links:
     * - https://help.salesforce.com/s/articleView?id=sf.flow_distribute_system_rest.htm&type=5
     * - https://salesforcetime.com/2023/03/07/how-to-launch-a-flow-from-the-rest-api/
     * - https://help.salesforce.com/s/articleView?id=sf.flow_distribute_system_apex.htm&type=5
     *
     * Invoke custom Auto-Launched Flow from Salesforce REST API:
     * - URL format: https://***.my.salesforce.com/services/data/v58.0/actions/custom/flow/***FLOW_API_NAME***
     * - Headers: Authorization Bearer Flow
     * - HTTP Method: POST
     * - Payload:
     * {
     *   "inputs": [{
     *       "parentAccount": {"Name": "Test Account #1"},
     *       "childContacts": [{"LastName": "Test Contact #1"}, {"LastName": "Test Contact #2"}]
     *   }]
     * }
     */
    @IsTest
    static void run() {
        final String flowApiName = 'Minlopro_Create_Account_With_Contacts';
        // Prepare the Flow variables;
        Map<String, Object> inputParametersMap = new Map<String, Object>();
        Account testAccount = new Account(Name = 'Test Account #1');
        inputParametersMap.put('parentAccount', testAccount);
        Contact testContact1 = new Contact(LastName = 'Test Contact #1');
        Contact testContact2 = new Contact(LastName = 'Test Contact #2');
        inputParametersMap.put('childContacts', Lists.of(testContact1, testContact2));
        // Invoke Flow;
        Flow.Interview yourFlow = Flow.Interview.createInterview(flowApiName, inputParametersMap);
        yourFlow.start();
        // Assert statements;
        List<Account> createdAccounts = [SELECT Id FROM Account WHERE CreatedDate = TODAY];
        Assert.isFalse(createdAccounts.isEmpty());
        Assert.areEqual(1, createdAccounts.size());
        Account createdAccount = createdAccounts[0];
        List<Contact> createdAndLinkedContacts = [
            SELECT Id
            FROM Contact
            WHERE CreatedDate = TODAY AND AccountId = :createdAccount.Id
        ];
        Assert.areEqual(2, createdAndLinkedContacts.size());
    }
}
