@SuppressWarnings('PMD')
public with sharing class ApexRat implements Queueable, Schedulable {
    private final Map<String, String> params;

    public ApexRat() {
    }

    public ApexRat(Map<String, String> params) {
        this.params = params;
    }

    public void execute(QueueableContext context) {
        Logger.debug(this.params?.toString());
        Account sampleAccount = TestDataFactory.createAccounts(1)[0];
        sampleAccount.Name = sampleAccount.Name + ' (Apex Rat!)';
        insert sampleAccount;
        Logger.debug(sampleAccount.Id);
    }

    public void execute(SchedulableContext context) {
        Logger.debug(this.params);
    }
}
