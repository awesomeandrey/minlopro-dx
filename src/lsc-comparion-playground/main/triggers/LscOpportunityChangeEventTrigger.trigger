trigger LscOpportunityChangeEventTrigger on OpportunityChangeEvent(after insert) {
    Logger.debug('Opp Change Event Trigger');
    List<OpportunityChangeEvent> changes = Trigger.new;

    Set<String> totalOppIds = new Set<String>();
    Set<String> createdOppIds = new Set<String>();
    Logger.debug('Change Events = ' + changes.size());

    for (OpportunityChangeEvent change : changes) {
        Logger.debug('Change Event Type = ' + change.ChangeEventHeader.getChangeType());
        if (change.ChangeEventHeader.getChangeType().equalsIgnoreCase('CREATE')) {
            createdOppIds.addAll(change.ChangeEventHeader.getRecordIds());
        }
        totalOppIds.addAll(change.ChangeEventHeader.getRecordIds());
    }

    try {
        Logger.debug('Total Opps Count = ' + totalOppIds.size());
        Logger.debug('Created Opps Count = ' + createdOppIds.size());
        if (!createdOppIds.isEmpty()) {
            List<List<Id>> createdOppIdsInChunks = LscOpportunityBatch.splitIdList(Lists.of(createdOppIds), 100);
            for (List<Id> oppIds : createdOppIdsInChunks) {
                Logger.debug('Enqueued Job to process {0} opps', Lists.of(oppIds.size().toString()));
                System.enqueueJob(new LscOpportunityQueueable(oppIds));
            }
        }
    } catch (Exception ex) {
        Logger.error(ex);
    }
}
