@SuppressWarnings('PMD')
public without sharing class LoggerCleanupBatch implements Schedulable, Database.Batchable<LogEntry__c>, Database.RaisesPlatformEvents {
    private static final String JOB_NAME = 'Minlopro - Logger Cleanup Batch';
    private static final String CRON_EXP = '0 0 10 * * ?'; // Runs everyday at 10 AM;

    private final Integer maxLogsThreshold;

    public LoggerCleanupBatch() {
        this.maxLogsThreshold = 1000;
    }

    public LoggerCleanupBatch(Integer maxLogsThreshold) {
        this.maxLogsThreshold = Math.max(100, Math.min(1000, maxLogsThreshold));
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
            Database.executeBatch(this, 250);
        }
    }

    public List<LogEntry__c> start(Database.BatchableContext ctx) {
        // SOQL OFFSET clause is not supported in Batch Apex;
        List<LogEntry__c> logEntriesToKeep = [
            SELECT Id, CreatedDate
            FROM LogEntry__c
            ORDER BY CreatedDate DESC
            LIMIT :this.maxLogsThreshold
        ];
        if (logEntriesToKeep.isEmpty()) {
            return new List<LogEntry__c>();
        }
        return [SELECT Id FROM LogEntry__c WHERE Id NOT IN :logEntriesToKeep];
    }

    public void execute(Database.BatchableContext ctx, List<LogEntry__c> logEntriesToDelete) {
        if (!logEntriesToDelete.isEmpty()) {
            delete logEntriesToDelete;
            Database.emptyRecycleBin(logEntriesToDelete);
        }
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
