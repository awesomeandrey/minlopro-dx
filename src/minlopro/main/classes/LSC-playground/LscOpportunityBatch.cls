public without sharing class LscOpportunityBatch implements Database.Batchable<Opportunity> {
    public Iterable<Opportunity> start(Database.BatchableContext context) {
        Logger.debug('Batch Start');
        return [SELECT Id, Name, OwnerId, Owner.Name FROM Opportunity];
    }

    public void execute(Database.BatchableContext context, List<Opportunity> records) {
        Logger.debug('Batch Execute');
        Assert.isTrue(records.size() > 1);

        // Update twice - this should entails limit exception;

        Opportunity opp1 = records[0];
        opp1.Name = ('UPD1 - ' + opp1.Name).abbreviate(15);
        update opp1;
        //        Logger.debug(Limits.getLimitQueueableJobs());
        //        Logger.debug(Limits.getQueueableJobs());

        Opportunity opp2 = records[1];
        opp2.Name = ('UPD2 - ' + opp2.Name).abbreviate(15);
        update opp2;
    }

    public void finish(Database.BatchableContext context) {
        Logger.debug('Batch Finish');
    }
}
