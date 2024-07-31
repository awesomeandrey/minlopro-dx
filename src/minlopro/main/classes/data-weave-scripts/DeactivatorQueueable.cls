public without sharing class DeactivatorQueueable implements Queueable {
    public void execute(QueueableContext context) {
        Logger.debug('QueueableContext');
        this.run();
    }

    private void run() {
        try {
            Database.executeBatch(new DeactivatorBatch(5), 5);
        } catch (Exception ex) {
            Logger.error(ex);
        }
    }
}
