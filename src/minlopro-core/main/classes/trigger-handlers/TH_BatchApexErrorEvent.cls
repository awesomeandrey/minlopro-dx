public without sharing class TH_BatchApexErrorEvent extends BasicTriggerHandler {
    public override void afterInsert(List<SObject> records) {
        for (SObject record : records) {
            BatchApexErrorEvent errorEvent = (BatchApexErrorEvent) record;
            Map<String, String> errorPayload = new Map<String, String>{
                'DoesExceedJobScopeMaxLength' => errorEvent.DoesExceedJobScopeMaxLength.toString(),
                'ExceptionType' => errorEvent.ExceptionType,
                'Phase' => errorEvent.Phase,
                'JobScope' => errorEvent.JobScope?.abbreviate(5),
                'StackTrace' => errorEvent.StackTrace?.abbreviate(100),
                'Message' => errorEvent.Message?.abbreviate(150)
            };
            Logger.error(JSON.serialize(errorPayload));
        }
    }
}
