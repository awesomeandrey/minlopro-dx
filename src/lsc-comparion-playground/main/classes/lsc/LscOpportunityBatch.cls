public without sharing class LscOpportunityBatch implements Database.Batchable<Opportunity> {
    public Iterable<Opportunity> start(Database.BatchableContext context) {
        Logger.debug('Batch Start');
        return [SELECT Id, Name, OwnerId, Owner.Name, StageName, CloseDate FROM Opportunity LIMIT 5000];
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
        Logger.debug('Second chunk size = ' + secondChunk.size());
        update secondChunk;

        List<Opportunity> clonedOpps = firstChunk.deepClone(false);
        Logger.debug('Opps created from batch (FC) = ' + clonedOpps.size());
        insert clonedOpps;

        List<Opportunity> clonedOpps2 = secondChunk.deepClone(false);
        Logger.debug('Opps created from batch (SC) = ' + clonedOpps2.size());
        insert clonedOpps2;
    }

    public void finish(Database.BatchableContext context) {
        Logger.debug('Batch Finish');
    }

    // Method to split the list of Ids into smaller lists based on the given size
    public static List<List<Id>> splitIdList(List<Id> originalList, Integer chunkSize) {
        // Resultant list that will hold the smaller lists
        List<List<Id>> splitLists = new List<List<Id>>();

        // Check for valid input
        if (originalList == null || originalList.isEmpty() || chunkSize <= 0) {
            return splitLists; // Return an empty list if input is invalid
        }

        // Temporary list to store each chunk
        List<Id> currentChunk = new List<Id>();

        // Loop through the original list and split it into smaller lists
        for (Integer i = 0; i < originalList.size(); i++) {
            currentChunk.add(originalList[i]); // Add the current element to the chunk

            // Once the chunk reaches the specified size, add it to the result list and start a new chunk
            if (currentChunk.size() == chunkSize || i == originalList.size() - 1) {
                splitLists.add(currentChunk);
                currentChunk = new List<Id>(); // Reset for the next chunk
            }
        }

        return splitLists;
    }
}
