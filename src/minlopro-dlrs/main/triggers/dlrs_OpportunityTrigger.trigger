/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_OpportunityTrigger on Opportunity(
    before delete,
    before insert,
    before update,
    after delete,
    after insert,
    after undelete,
    after update
) {
    dlrs.RollupService.triggerHandler(Opportunity.SObjectType);
}
