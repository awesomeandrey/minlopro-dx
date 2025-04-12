public inherited sharing class TH_Account_CDC_Sample1 extends BasicTriggerHandler {
    @TestVisible
    private static String DATETIME_STAMP_FORMAT = 'mm/dd/yyyy, HH:MM';

    public override void afterInsert(List<SObject> eventRecords) {
        /**
         * Logic - updates 'Account.Description' field value with timestamp.
         */
        List<Id> createdAccountIds = this.collectAccountIdsByChangeType((List<AccountChangeEvent>) eventRecords, 'CREATE');
        List<Account> createdAccounts = [SELECT Id, Name, Description FROM Account WHERE Id IN :createdAccountIds];
        if (!createdAccounts.isEmpty()) {
            Logger.debug('CDC - Captured {0} Accounts CREATED.', Lists.of(createdAccounts.size().toString()));
            String datetimeStamp = Datetime.now().format(DATETIME_STAMP_FORMAT);
            for (Account accountRecord : createdAccounts) {
                accountRecord.Description = String.format('Update from CDC trigger: {0}', Lists.of(datetimeStamp)).abbreviate(55);
            }
            Logger.debug('CDC - Updated "Description" on {0} Accounts.', Lists.of(createdAccounts.size().toString()));
            update createdAccounts;
        }
        /**
         * Logic - just log event payload for updated records.
         */
        List<Id> updatedAccountIds = this.collectAccountIdsByChangeType((List<AccountChangeEvent>) eventRecords, 'UPDATE');
        if (!updatedAccountIds.isEmpty()) {
            Logger.debug('CDC - Captured {0} Accounts UPDATED.', Lists.of(updatedAccountIds.size().toString()));
            Logger.debug(eventRecords);
        }
    }

    private List<Id> collectAccountIdsByChangeType(List<AccountChangeEvent> changeEvents, String changeType) {
        List<Id> createdAccountIds = new List<Id>();
        for (AccountChangeEvent changeEvt : changeEvents) {
            EventBus.ChangeEventHeader evtHeader = changeEvt.ChangeEventHeader;
            if (evtHeader.getChangeType().equalsIgnoreCase(changeType)) {
                createdAccountIds.addAll(evtHeader.getRecordIds());
            }
        }
        return Lists.of(Sets.of(createdAccountIds));
    }
}
