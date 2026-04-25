@SuppressWarnings('PMD')
public inherited sharing class AccountDncStatusSynchronizer implements Queueable, Database.AllowsCallouts {
    private static final Integer CHUNK_SIZE = 45;
    private final List<Account> remainingAccounts;

    public AccountDncStatusSynchronizer(List<Account> accounts) {
        this.remainingAccounts = accounts;
    }

    public void execute(QueueableContext context) {
        Logger.debug('{0} | Queueable job started', Lists.of(context.getJobId()));

        if (!AccountDncUtils.isFeatureEnabled() || AccountDncUtils.hasExceededRateLimit() || this.remainingAccounts.isEmpty()) {
            return;
        }

        // Slice the current chunk
        Integer chunkEnd = Math.min(CHUNK_SIZE, this.remainingAccounts.size());
        List<Account> currentChunk = new List<Account>();
        for (Integer i = 0; i < chunkEnd; i++) {
            currentChunk.add(this.remainingAccounts[i]);
        }

        // Process the chunk
        this.processChunk(currentChunk);

        // Capture consumed callouts
        AccountDncUtils.appendRateConsumption(Limits.getCallouts());

        Logger.debug(
            '{0} | Current Rate Consumption = {1}',
            Lists.of(context.getJobId(), AccountDncUtils.getCurrentRateConsumption().toString())
        );

        // Check if rate limit is reached
        if (AccountDncUtils.hasExceededRateLimit()) {
            SystemAlert.Builder alert = new SystemAlert.Builder()
                .withTitle('DNC Rate Limit Reached ⚠️')
                .withBody(
                    String.format('Current consumption: {0} ', Lists.of(AccountDncUtils.getCurrentRateConsumption().toString()))
                )
                .withRecipients(SystemInfoController.getAdminIds());
            SystemAlert.send(alert);
            return;
        }

        // Build the tail (records not yet processed)
        List<Account> tail = new List<Account>();
        for (Integer i = chunkEnd; i < this.remainingAccounts.size(); i++) {
            tail.add(this.remainingAccounts[i]);
        }

        // Self-chain only if there is remaining work
        if (!tail.isEmpty() && !Test.isRunningTest()) {
            Id jobId = System.enqueueJob(new AccountDncStatusSynchronizer(tail));
            Logger.debug('Next Job ID = {0} | Enqueued next chunk with {1} records.', Lists.of(jobId, tail.size().toString()));
        }
    }

    private void processChunk(List<Account> accounts) {
        List<Account> accountsToUpdate = new List<Account>();
        for (Account accountToCheck : [SELECT Id FROM Account WHERE Id IN :accounts AND IsDeleted = FALSE]) {
            // Simulate API call to external DNC service
            HttpRequest dncRequest = new HttpRequest();
            dncRequest.setMethod('GET');
            dncRequest.setEndpoint(String.format('{0}/{1}', Lists.of('${SF_INSTANCE_URL}', '/services/apexrest/echo')));
            if (!Test.isRunningTest()) {
                // Overcome 'Methods defined as TestMethod do not support web service callouts' issue
                new Http().send(dncRequest);
            }

            // Set 'DncRegistryStatus__c' on Account
            accountsToUpdate.add(
                new Account(
                    Id = accountToCheck.Id,
                    DncRegistryStatus__c = Lists.getRandomString(Lists.of('EligibleToCall', 'DoNotCall', 'Unknown'))
                )
            );
        }
        update accountsToUpdate;
    }
}
