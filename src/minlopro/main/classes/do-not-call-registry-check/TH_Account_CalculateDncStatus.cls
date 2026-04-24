@SuppressWarnings('PMD')
public inherited sharing class TH_Account_CalculateDncStatus extends BasicTriggerHandler {
    public override void beforeInsert(List<SObject> newRecords) {
        for (SObject record : newRecords) {
            Account accountRec = (Account) record;
            if (String.isBlank(accountRec.Phone)) {
                accountRec.DncRegistryStatus__c = 'Unknown';
            }
        }
    }

    public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        for (SObject record : newMap.values()) {
            Account accountRec = (Account) record;
            if (String.isBlank(accountRec.Phone)) {
                accountRec.DncRegistryStatus__c = 'Unknown';
            }
        }
    }

    public override void afterInsert(List<SObject> newRecords) {
        List<Account> accountsToCheck = new List<Account>();
        for (SObject record : newRecords) {
            Account accountRec = (Account) record;
            if (String.isNotBlank(accountRec.Phone)) {
                accountsToCheck.add(accountRec);
            }
        }
        if (!accountsToCheck.isEmpty() && AccountDncUtils.isFeatureEnabled()) {
            Logger.debug('Enqueued {0} accounts to check for DNC status.', Lists.of(accountsToCheck.size().toString()));
            System.enqueueJob(new AccountDncStatusSynchronizer(accountsToCheck));
        }
    }

    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        List<Account> accountsToCheck = new List<Account>();
        for (Id recordId : oldMap.keySet()) {
            Account oldAccount = (Account) oldMap.get(recordId);
            Account newAccount = (Account) newMap.get(recordId);
            if (String.isNotBlank(newAccount.Phone) && oldAccount?.Phone != newAccount?.Phone) {
                accountsToCheck.add(newAccount);
            }
        }
        if (!accountsToCheck.isEmpty() && AccountDncUtils.isFeatureEnabled()) {
            Logger.debug('Enqueued {0} accounts to check for DNC status.', Lists.of(accountsToCheck.size().toString()));
            System.enqueueJob(new AccountDncStatusSynchronizer(accountsToCheck));
        }
    }
}
