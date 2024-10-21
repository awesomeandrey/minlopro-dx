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
            Logger.debug('Enqueued Job!');
            System.enqueueJob(new LscOpportunityQueueable(Lists.of(createdOppIds)));
        }
    } catch (Exception ex) {
        Logger.error(ex);
    }
}
