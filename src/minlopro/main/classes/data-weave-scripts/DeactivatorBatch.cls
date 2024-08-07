public without sharing class DeactivatorBatch implements Database.Batchable<String>, Database.RaisesPlatformEvents, Database.Stateful {
    private Integer currentPageNumber = 0;

    public DeactivatorBatch() {
        this.currentPageNumber = 1;
    }

    public DeactivatorBatch(Integer currentPageNumber) {
        this.currentPageNumber = currentPageNumber;
    }

    public Iterable<String> start(Database.BatchableContext context) {
        Logger.debug('START');
        Logger.debug('Processing Page Number = {0}', Lists.of(this.currentPageNumber.toString()));
        return new List<String>{ 'Minlopro', 'is', 'awesome!' };
    }

    public void execute(Database.BatchableContext context, List<String> records) {
        Logger.debug('EXECUTE ({0})', Lists.of(records.toString()));
    }

    public void finish(Database.BatchableContext context) {
        Logger.debug('FINISH');
        Integer nextPage = this.currentPageNumber - 1;
        if (nextPage > 0) {
            Logger.debug('Chaining Batch. Next Page Number = {0}', Lists.of(nextPage.toString()));
            Database.executeBatch(new DeactivatorBatch(nextPage), 5);
        }
    }
}
