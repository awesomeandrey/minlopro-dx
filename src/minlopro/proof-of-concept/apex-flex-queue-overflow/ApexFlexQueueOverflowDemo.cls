@SuppressWarnings('PMD')
public without sharing class ApexFlexQueueOverflowDemo implements Database.Batchable<Integer>, Database.Stateful, Database.RaisesPlatformEvents {
    private Integer batches = 100;
    private Long msDelay = 2000;

    // Database.executeBatch(new ApexFlexQueueOverflowDemo(200, 9000), 1);

    public ApexFlexQueueOverflowDemo(Integer batches, Long msDelay) {
        this.batches = Math.max(100, batches);
        this.msDelay = Math.max(2000, msDelay);
    }

    public Iterable<Integer> start(Database.BatchableContext context) {
        Logger.debug('Batches = {0} and msDelay = {1}', Lists.of(this.batches.toString(), this.msDelay.toString()));
        List<Integer> numbers = new List<Integer>();
        for (Integer i = 0; i <= this.batches; i++) {
            numbers.add(i);
        }
        return numbers;
    }

    public void execute(Database.BatchableContext context, List<Integer> numbers) {
        try {
            System.enqueueJob(new ApexQueueable(this.msDelay));
        } catch (Exception ex) {
            Logger.error(ex);
        }
    }

    public void finish(Database.BatchableContext context) {
        Logger.debug('Batch Done!');
    }

    public class ApexQueueable implements Queueable, Finalizer {
        private Long msDelay = 2000;

        public ApexQueueable(Long msDelay) {
            this.msDelay = msDelay;
        }

        public void execute(QueueableContext context) {
            System.attachFinalizer(this);
            Runtime.sleep(this.msDelay);
        }

        public void execute(FinalizerContext context) {
            if (context.getResult() == ParentJobResult.UNHANDLED_EXCEPTION) {
                Logger.error(context.getException());
            }
        }
    }
}
