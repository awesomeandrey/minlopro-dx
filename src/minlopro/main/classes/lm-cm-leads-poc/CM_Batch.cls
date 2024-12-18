public without sharing class CM_Batch implements Database.Batchable<CM_DTO>, Database.Stateful, Database.RaisesPlatformEvents, Database.AllowsCallouts {
    private Integer processedCounter = 0;

    // Same as queueable approach -- limits are the same; Apex Batch is the entry point for the whole process;
    public Iterable<CM_DTO> start(Database.BatchableContext context) {
        // Imitate callout that fetches multiple service URLs;
        List<Integer> offsetValues = this.getOffsets();
        CM_Iterable iterableObj = new CM_Iterable();
        for (Integer offsetP : offsetValues) {
            // Imitate callout that retrieves data by service URL;
            iterableObj.add(this.fetchContactsByOffset(offsetP));
        }
        return iterableObj;
    }

    public void execute(Database.BatchableContext context, List<CM_DTO> records) {
        Logger.debug('Processing {0} records.', Lists.of(records.size().toString()));
        this.processedCounter += records.size();
    }

    public void finish(Database.BatchableContext context) {
        Logger.debug('{0} records were processed in total.', Lists.of(this.processedCounter.toString()));
    }

    // **********

    private List<Integer> getOffsets() {
        Logger.debug('Fetched offset values');
        return new List<Integer>{ 0, 5, 10, 15, 20, 25, 30 };
    }

    private List<Contact> fetchContactsByOffset(Integer offsetP) {
        // This method should consume callout limits;
        Logger.debug('Fetching Contact records by offset: {0}', Lists.of(offsetP.toString()));
        HttpRequest req = new HttpRequest();
        String encodedQuery = EncodingUtil.urlEncode(
            String.format('SELECT Id, GenderIdentity, Name FROM Contact LIMIT 5 OFFSET {0}', Lists.of(offsetP.toString())),
            'UTF-8'
        );
        String endpoint = String.format(
            'callout:{0}/services/data/v{1}/query?q={2}',
            Lists.of('SalesforceRestApi', '60.0', encodedQuery)
        );
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        HttpResponse resp = new Http().send(req);
        Logger.debug(resp.getStatus());
        Logger.debug(resp.getStatusCode().toString());
        ResponsePayload responsePayload = (ResponsePayload) JSON.deserialize(resp.getBody(), ResponsePayload.class);
        return responsePayload.records;
    }

    public class ResponsePayload {
        public Boolean done;
        public List<Contact> records;
    }
}
