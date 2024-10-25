public without sharing class LoggerCleanupBatch implements Schedulable, Database.Batchable<LogEntry__c>, Database.RaisesPlatformEvents {
    private static final String JOB_NAME = 'Minlopro - Logger Cleanup Batch';
    private static final String CRON_EXP = '0 0 10 * * ?'; // Runs everyday at 10 AM;

    private final Date deleteBeforeDate;

    public LoggerCleanupBatch() {
        this.deleteBeforeDate = Date.today().addDays(-5);
    }

    public LoggerCleanupBatch(Date deleteBeforeDate) {
        this.deleteBeforeDate = deleteBeforeDate;
    }

    public AsyncApexJob run() {
        AsyncApexJob nextJob = this.selectNextJob();
        if (nextJob == null) {
            String jobName = Test.isRunningTest() ? JOB_NAME + System.now() : JOB_NAME;
            System.schedule(jobName, CRON_EXP, this);
            return this.selectNextJob(); // Should return newly enqueued job;
        }
        return nextJob;
    }

    public void execute(SchedulableContext ctx) {
        if (this.isAlreadyScheduled(ctx)) {
            System.abortJob(ctx.getTriggerId());
        } else {
            Database.executeBatch(this, 50);
        }
    }

    public List<LogEntry__c> start(Database.BatchableContext ctx) {
        return [SELECT Id FROM LogEntry__c WHERE CreatedDate < :this.deleteBeforeDate];
    }

    public void execute(Database.BatchableContext ctx, List<LogEntry__c> logEntriesToDelete) {
        delete logEntriesToDelete;
        Database.emptyRecycleBin(logEntriesToDelete);
    }

    public void finish(Database.BatchableContext ctx) {
    }

    private Boolean isAlreadyScheduled(SchedulableContext ctx) {
        List<AsyncApexJob> jobs = [
            SELECT Id, JobType, Status, ApexClass.Name
            FROM AsyncApexJob
            WHERE
                JobType = 'ScheduledApex'
                AND ApexClass.Name = 'LoggerCleanupBatch'
                AND Status IN ('Queued', 'Preparing', 'Processing')
                AND CronTriggerId != :ctx.getTriggerId()
        ];
        return !jobs.isEmpty();
    }

    private AsyncApexJob selectNextJob() {
        List<AsyncApexJob> jobs = [
            SELECT Id, ApexClass.Name, JobType, Status, CronTriggerId, CronTrigger.CronJobDetail.Name, CronTrigger.NextFireTime
            FROM AsyncApexJob
            WHERE
                JobType = 'ScheduledApex'
                AND ApexClass.Name = 'LoggerCleanupBatch'
                AND Status IN ('Queued', 'Preparing', 'Processing')
                AND CronTrigger.NextFireTime != NULL
            ORDER BY CronTrigger.NextFireTime DESC
            LIMIT 1
        ];
        return jobs.isEmpty() ? null : jobs[0];
    }
}
