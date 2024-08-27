public without sharing class OptInVfController {
    @AuraEnabled
    public static String markAccountAsOptIn(Id accountId) {
        try {
            Account foundAccount = findAccount(accountId);
            Database.SaveResult saveResult = Database.update(
                new Account(Id = foundAccount.Id, AnnualRevenue = foundAccount.AnnualRevenue + 1),
                false,
                AccessLevel.SYSTEM_MODE
            );
            // Database.rollback(sp);
            if (saveResult.isSuccess()) {
                return JSON.serialize(new Map<String, String>{ 'success' => 'true' });
            } else {
                return JSON.serialize(
                    new Map<String, String>{ 'success' => 'false', 'errorMessage' => saveResult.getErrors().toString() }
                );
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static Account findAccount(Id accountId) {
        List<Account> foundAccounts = [SELECT Id, Name, AnnualRevenue FROM Account WHERE Id = :accountId];
        if (foundAccounts.isEmpty()) {
            throw new IllegalArgumentException('Account was not found!');
        }
        return foundAccounts[0];
    }
}
