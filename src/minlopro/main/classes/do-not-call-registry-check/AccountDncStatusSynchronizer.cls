@SuppressWarnings('PMD')
public inherited sharing class AccountDncStatusSynchronizer implements Queueable, Database.AllowsCallouts {
    private List<Account> accounts = new List<Account>();

    public AccountDncStatusSynchronizer(List<Account> accounts) {
        this.accounts = accounts;
    }

    public void execute(QueueableContext context) {
    }
}
