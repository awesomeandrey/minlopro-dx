public with sharing class LoggerDemo implements Database.Batchable<Integer> {
    public void run() {
        // Invoke this method ot generate logs from different contexts;
        Logger.debug('before');
        futureMethod();
        Logger.error('after 1={0} 2={1}', Lists.of('str1', 'str2'));
    }

    @Future
    public static void futureMethod() {
        Logger.debug('before');
        System.enqueueJob(new AQueueable());
        Logger.debug('after');
    }

    public List<Integer> start(Database.BatchableContext ctx) {
        Logger.debug();
        return new List<Integer>{ 1, 2, 3, 4 };
    }

    public void execute(Database.BatchableContext ctx, List<Integer> scope) {
        Logger.debug('first');
        Logger.error('second');
    }

    public void finish(Database.BatchableContext ctx) {
        Logger.debug('first');
        Logger.error('second');
    }

    public with sharing class AQueueable implements Queueable {
        public void execute(QueueableContext ctx) {
            Logger.debug('before');
            Database.executeBatch(new LoggerDemo(), 1);
            Logger.debug('after');
        }
    }
}
