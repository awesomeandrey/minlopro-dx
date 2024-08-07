/**
 * Custom Apex controller available to DigEx Guest user for capturing Email Opt-In.
 */
public without sharing class DigExOptInController {
    private static final AccountSelector accountSelector = (AccountSelector) Application.Selector.newInstance(
        Account.SObjectType
    );
    private static final OptInEmailService optInService = (OptInEmailService) Application.Service.newInstance(
        OptInEmailService.class
    );

    @AuraEnabled
    public static String markAccountAsOptIn(Id accountId, String signature) {
        try {
            if (!optInService.verifySignature(Blob.valueOf(accountId), signature)) {
                throw new IllegalArgumentException('Invalid signature!');
            }
            Logger.debug('Opt-In Account ID = {0}', Lists.of(accountId));
            Account foundAccount = findAccount(accountId);
            Logger.debug('Found Account Name = {0}', Lists.of(foundAccount.Name));
            Savepoint sp = Database.setSavepoint();
            Database.SaveResult saveResult = Database.update(
                new Account(Id = foundAccount.Id, AnnualRevenue = foundAccount.AnnualRevenue + 1),
                false,
                AccessLevel.SYSTEM_MODE
            );
            // Database.rollback(sp);
            Logger.debug(JSON.serialize(saveResult));
            if (saveResult.isSuccess()) {
                return JSON.serialize(new Map<String, String>{ 'success' => 'true' });
            } else {
                return JSON.serialize(
                    new Map<String, String>{ 'success' => 'false', 'errorMessage' => saveResult.getErrors().toString() }
                );
            }
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static Account findAccount(Id accountId) {
        List<Account> foundAccounts = (List<Account>) accountSelector.selectByIdWithMode(
            Lists.of(accountId),
            AccessLevel.SYSTEM_MODE
        );
        if (foundAccounts.isEmpty()) {
            throw new IllegalArgumentException('Account was not found!');
        }
        return foundAccounts[0];
    }
}
