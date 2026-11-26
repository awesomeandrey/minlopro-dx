public inherited sharing class TH_CarSaleEvent_ProcessSale extends BasicTriggerHandler {
    public override void afterInsert(List<SObject> newRecords) {
        List<CarSaleEvent__e> carSaleEvents = (List<CarSaleEvent__e>) newRecords;
        Logger.debug('Got {0} sale events to process.', Lists.of(carSaleEvents.size().toString()));
    }
}
