public without sharing class LscOpportunityBatch implements Database.Batchable<Opportunity> {
    public Iterable<Opportunity> start(Database.BatchableContext context) {
        Logger.debug('Batch Start');
        return [SELECT Id, Name, OwnerId, Owner.Name FROM Opportunity];
    }

    public void execute(Database.BatchableContext context, List<Opportunity> records) {
        Logger.debug('Batch Execute');
        Assert.isTrue(records.size() > 1);

        // Update twice - this should entails limit exception;

        List<Opportunity> firstChunk = new List<Schema.Opportunity>();
        List<Opportunity> secondChunk = new List<Schema.Opportunity>();
        for (Integer i = 0; i < records.size(); i++) {
            Opportunity opp = records[i];
            if (Math.mod(i, 2) == 0) {
                opp.Name = ('UPD_even - ' + opp.Name).abbreviate(15);
                firstChunk.add(opp);
            } else {
                opp.Name = ('UPD_odd - ' + opp.Name).abbreviate(15);
                secondChunk.add(opp);
            }
        }
        Logger.debug('First chunk size = ' + firstChunk.size());
        update firstChunk;
        Logger.debug('Second chunk size = ' + firstChunk.size());
        update secondChunk;
    }

    public void finish(Database.BatchableContext context) {
        Logger.debug('Batch Finish');
    }
}
