public inherited sharing class TH_Account_Sample1 extends BasicTriggerHandler {
    public static Integer DEFAULT_ANNUAL_REVENUE = 10;

    public override void beforeInsert(List<SObject> newRecords) {
        /**
         * Logic - sets 'AnnualRevenue' field value to 10.
         */
        List<Account> newAccounts = (List<Account>) newRecords;
        for (Account accountItem : newAccounts) {
            if (accountItem.AnnualRevenue == null || accountItem.AnnualRevenue <= 0) {
                accountItem.AnnualRevenue = DEFAULT_ANNUAL_REVENUE;
            }
        }
    }
}
