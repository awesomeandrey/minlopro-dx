public inherited sharing class SfmcSwitcherFinalizerDemo implements Queueable, Finalizer {
    private List<Id> opportunityIds = new List<Id>();
    private Action flagAction = Action.ENABLE;
    private Schema.SObjectField fieldToUpdate = Schema.Opportunity.StageName;

    /**
     * How to launch:
     * List<Id> oppIds = new List<Id>( new Map<Id, Opportunity>([SELECT Id FROM Opportunity LIMIT 3]).keySet());
     * System.enqueueJob(new SfmcSwitcherFinalizerDemo(oppIds, Opportunity.IsPrivate));
     */

    public SfmcSwitcherFinalizerDemo(List<Id> opportunityIds, Schema.SObjectField fieldToUpdate) {
        this.opportunityIds = opportunityIds;
        this.fieldToUpdate = fieldToUpdate;
    }

    private SfmcSwitcherFinalizerDemo(List<Id> opportunityIds, Action flagAction, Schema.SObjectField fieldToUpdate) {
        this.opportunityIds = opportunityIds;
        this.flagAction = flagAction;
        this.fieldToUpdate = fieldToUpdate;
    }

    public void execute(QueueableContext context) {
        Logger.debug('queueable');
        Logger.debug(this.fieldToUpdate.toString());

        System.attachFinalizer(this);
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Opportunity opp : [SELECT Id FROM Opportunity WHERE Id IN :this.opportunityIds]) {
            opp.put(this.fieldToUpdate, (this.flagAction == Action.ENABLE));
            oppsToUpdate.add(opp);
        }
        Logger.debug(oppsToUpdate);
    }

    public void execute(FinalizerContext context) {
        Logger.debug('finalizer');
        Logger.debug(this.fieldToUpdate);
        if (this.flagAction == Action.ENABLE) {
            System.enqueueJob(new SfmcSwitcherFinalizerDemo(this.opportunityIds, Action.DISABLE, this.fieldToUpdate), 1);
        }
    }

    public enum Action {
        ENABLE,
        DISABLE
    }
}
