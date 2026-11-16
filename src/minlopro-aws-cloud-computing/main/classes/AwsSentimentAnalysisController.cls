public with sharing class AwsSentimentAnalysisController {
    @AuraEnabled
    public static CalloutResponse detectSentiment(String text) {
        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(String.format('callout:{0}/{1}', Lists.of('AwsMinloproServicesApi', 'v1/detect-sentiment')));
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(new Map<String, String>{ 'text' => text }));
            HttpResponse resp = new Http().send(req);
            Logger.debug(resp);
            return new CalloutResponse(resp);
        } catch (Exception rootException) {
            Logger.error(rootException);
            AuraHandledException auraEx = new AuraHandledException(rootException.getMessage());
            auraEx.initCause(rootException);
            throw auraEx;
        }
    }

    public class CalloutResponse {
        private final HttpResponse response;
        @AuraEnabled
        public String body {
            get {
                return this.response?.getBody();
            }
        }
        @AuraEnabled
        public String status {
            get {
                return this.response?.getStatus();
            }
        }
        @AuraEnabled
        public Integer statusCode {
            get {
                return this.response?.getStatusCode();
            }
        }
        @AuraEnabled
        public Boolean success {
            get {
                return this.statusCode == 200 || this.statusCode == 201;
            }
        }

        public CalloutResponse(HttpResponse response) {
            this.response = response;
        }
    }
}
