public inherited sharing class LscOpportunityQueueable implements Queueable, Finalizer {
    private List<Id> opportunityIds = new List<Id>();
    private Action flagAction = Action.ENABLE;

    public LscOpportunityQueueable(List<Id> opportunityIds) {
        this.opportunityIds = opportunityIds;
    }

    private LscOpportunityQueueable(List<Id> opportunityIds, Action flagAction) {
        this.opportunityIds = opportunityIds;
        this.flagAction = flagAction;
    }

    public void execute(QueueableContext context) {
        Logger.debug('Queueable - Execute: {0} flag', Lists.of(this.flagAction == Action.ENABLE ? 'enabling' : 'disabling'));
        System.attachFinalizer(this);
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Opportunity opp : [SELECT Id FROM Opportunity WHERE Id IN :this.opportunityIds]) {
            opp.IsDrcSfmcJourney__c = (this.flagAction == Action.ENABLE);
            oppsToUpdate.add(opp);
        }
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }

    public void execute(FinalizerContext context) {
        Logger.debug('Queueable - Finalizer');
        if (context.getException() != null) {
            Logger.error(context.getException());
        }

        // Reset flag to FALSE in 10 minutes;
        if (this.flagAction == Action.ENABLE) {
            System.enqueueJob(new LscOpportunityQueueable(this.opportunityIds, Action.DISABLE));
        }
    }

    public enum Action {
        ENABLE,
        DISABLE
    }
}
