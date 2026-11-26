trigger CarSaleEventTrigger on CarSaleEvent__e(after insert) {
    TriggerDispatcher.setContext(CarSaleEvent__e.SObjectType).run();
}
