public with sharing class LoggerDemo implements Database.Batchable<Integer> {
    @AuraEnabled
    public static void run() {
        // Invoke this method to generate logs from different contexts;
        Logger.debug('This is INFO log.');
        Logger.error('This is ERROR log.');
        futureMethod();
    }

    @Future
    public static void futureMethod() {
        Logger.debug('Invoking Queueable Job...');
        System.enqueueJob(new AQueueable());
    }

    public List<Integer> start(Database.BatchableContext context) {
        Logger.debug(context.toString());
        return new List<Integer>{ 1, 2, 3, 4, 5 };
    }

    public void execute(Database.BatchableContext context, List<Integer> scope) {
        Logger.debug('Batch Scope = {0}', Lists.of(scope.toString()));
    }

    public void finish(Database.BatchableContext context) {
        Logger.debug(context.toString());
    }

    // The Queueable job and the Finalizer run in separate Apex and Database transactions.
    public with sharing class AQueueable implements Queueable, System.Finalizer {
        private String customMessage = 'Minlopro Rocks!';

        public void execute(QueueableContext ctx) {
            // Leverage finalizer;
            System.attachFinalizer(this);
            // Change queueable instance state;
            Logger.debug('Custom Message Before = {0}', Lists.of(this.customMessage));
            this.customMessage = this.customMessage.reverse();
            Logger.debug('Custom Message After = {0}', Lists.of(this.customMessage));
            // Enqueue Apex Batch;
            Database.executeBatch(new LoggerDemo(), 2);
        }

        public void execute(FinalizerContext context) {
            Logger.debug(context.toString());
            // Note: the instance state is preserved and passed to finalizer!
            Logger.debug('Custom Message State = {0}', Lists.of(this.customMessage));
        }
    }
}
