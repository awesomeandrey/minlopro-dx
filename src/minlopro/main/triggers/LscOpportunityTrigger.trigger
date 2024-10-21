trigger LscOpportunityTrigger on Opportunity(after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        Logger.debug('Opp Trigger - Launch Queueable');
        try {
            List<Id> oppIds = Lists.of(Trigger.newMap.keySet());
            // System.enqueueJob(new LscOpportunityQueueable(oppIds));

            LscOpportunityQueueable.launchAsFuture(oppIds);
        } catch (Exception ex) {
            Logger.error(ex);
        }
    }
}
