public inherited sharing class TH_Account_CDC_Sample1 extends BasicTriggerHandler {
    @TestVisible
    private static String DATETIME_STAMP_FORMAT = 'mm/dd/yyyy, HH:MM';

    public override void afterInsert(List<SObject> newRecords) {
        /**
         * Logic - updates 'Account.Description' field value with timestamp.
         */
        List<Id> createdAccountIds = this.collectInsertedAccounts((List<AccountChangeEvent>) newRecords);
        List<Account> createdAccounts = [SELECT Id, Name, Description FROM Account WHERE Id IN :createdAccountIds];
        if (!createdAccounts.isEmpty()) {
            Logger.debug('CDC - Captured {0} Accounts inserted.', Lists.of(createdAccounts.size().toString()));
            String datetimeStamp = Datetime.now().format(DATETIME_STAMP_FORMAT);
            for (Account accountRecord : createdAccounts) {
                accountRecord.Description = String.format('Update from CDC trigger: {0}', Lists.of(datetimeStamp)).abbreviate(55);
            }
            Logger.debug('CDC - Updated "Description" on {0} Accounts.', Lists.of(createdAccounts.size().toString()));
            update createdAccounts;
        }
    }

    private List<Id> collectInsertedAccounts(List<AccountChangeEvent> changeEvents) {
        List<Id> createdAccountIds = new List<Id>();
        for (AccountChangeEvent changeEvt : changeEvents) {
            EventBus.ChangeEventHeader evtHeader = changeEvt.ChangeEventHeader;
            if (evtHeader.getChangeType().equalsIgnoreCase('CREATE')) {
                createdAccountIds.addAll(evtHeader.getRecordIds());
            }
        }
        return Lists.of(Sets.of(createdAccountIds));
    }
}
