AsyncApexJob jobInfo = new LoggerCleanupBatch().run();
DebugTableFormatter formatter = new DebugTableFormatter(
    new List<String>{ 'Id', 'ApexClass.Name', 'JobType', 'Status', 'CronTrigger.CronJobDetail.Name', 'CronTrigger.NextFireTime' },
    Lists.of(jobInfo)
);
formatter.log('⚪ Logger Cleanup Batch Job:\n');
