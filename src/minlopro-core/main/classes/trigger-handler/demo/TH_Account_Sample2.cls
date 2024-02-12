public inherited sharing class TH_Account_Sample2 extends BasicTriggerHandler {
    public static Integer MAX_ANNUAL_REVENUE_THRESHOLD = 100;
    public static Integer MAX_LOOP_COUNT = 10;

    public override Integer getMaxLoopCount() {
        return MAX_LOOP_COUNT;
    }

    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        /**
         * Logic - upon Account update, doubles 'AnnualRevenue' field value until it reaches 100.
         */
        List<Account> accountsToReUpdate = new List<Account>();
        for (Id accountId : newMap.keySet()) {
            Account newAccount = (Account) newMap.get(accountId);
            if (newAccount.AnnualRevenue <= MAX_ANNUAL_REVENUE_THRESHOLD) {
                Decimal rev = newAccount.AnnualRevenue <= 0 ? 10 : newAccount.AnnualRevenue * 2;
                accountsToReUpdate.add(new Account(Id = newAccount.Id, AnnualRevenue = rev));
            }
        }
        if (!accountsToReUpdate.isEmpty()) {
            update accountsToReUpdate;
        }
    }
}
