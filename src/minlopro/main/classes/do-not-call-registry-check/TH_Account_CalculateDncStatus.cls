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
        for (SObject newRecord : newMap.values()) {
            Account accountRec = (Account) newRecord;
            if (String.isBlank(accountRec.Phone)) {
                accountRec.DncRegistryStatus__c = 'Unknown';
            }
        }
    }

    public override void afterInsert(List<SObject> newRecords) {
        if (!AccountDncUtils.isFeatureEnabled() || AccountDncUtils.hasExceededRateLimit()) {
            Logger.debug('DNC feature is disabled/suspended.');
            return;
        }
        List<Account> accountsToCheck = new List<Account>();
        for (SObject record : newRecords) {
            Account accountRec = (Account) record;
            if (String.isNotBlank(accountRec.Phone)) {
                accountsToCheck.add(accountRec);
            }
        }
        if (!accountsToCheck.isEmpty()) {
            Id jobId = System.enqueueJob(new AccountDncStatusSynchronizer(accountsToCheck));
            Logger.debug(
                '{0} | Enqueued {1} accounts to check for DNC status.',
                Lists.of(jobId, accountsToCheck.size().toString())
            );
        }
    }

    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        if (!AccountDncUtils.isFeatureEnabled() || AccountDncUtils.hasExceededRateLimit()) {
            Logger.debug('DNC feature is disabled/suspended.');
            return;
        }
        List<Account> accountsToCheck = new List<Account>();
        for (Id recordId : oldMap.keySet()) {
            Account oldAccount = (Account) oldMap.get(recordId);
            Account newAccount = (Account) newMap.get(recordId);
            if (String.isNotBlank(newAccount.Phone) && oldAccount?.Phone != newAccount?.Phone) {
                accountsToCheck.add(newAccount);
            }
        }
        if (!accountsToCheck.isEmpty()) {
            Id jobId = System.enqueueJob(new AccountDncStatusSynchronizer(accountsToCheck));
            Logger.debug(
                '{0} | Enqueued {1} accounts to check for DNC status.',
                Lists.of(jobId, accountsToCheck.size().toString())
            );
        }
    }
}
