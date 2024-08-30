public without sharing class DeactivatorSchedulable implements Schedulable, Database.RaisesPlatformEvents {
    @ReadOnly
    public void execute(SchedulableContext context) {
        Logger.debug('SchedulableContext');
        this.run();
    }

    private void run() {
        try {
            Database.executeBatch(new DeactivatorBatch());
        } catch (Exception ex) {
            Logger.error(ex);
        }
    }
}
