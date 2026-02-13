/**
 * @description Server-side controller for the Web-to-Lead form.
 * Verifies user tokens using the Google reCAPTCHA v2 (checkbox) flow.
 */
public with sharing class DigExWebToLeadController {
    private static final String ERROR_CODES_KEY = 'error-codes';

    @AuraEnabled
    public static ReCaptchaResponse verifyUserToken(String userToken) {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
            request.setMethod('POST');
            request.setBody(String.format('secret={0}&response={1}', Lists.of('${SF_GOOGLE_RECAPTCHA_SITE_SECRET}', userToken)));
            HttpResponse response = http.send(request);
            if (!response.getStatusCode().equals(200)) {
                throw new AuraHandledException(
                    String.format('Token verification failed: [{0}] {1}', Lists.of(response.getStatus(), response.getBody()))
                );
            }
            Map<String, Object> responseAsMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            ReCaptchaResponse responseAsDto = (ReCaptchaResponse) JSON.deserialize(response.getBody(), ReCaptchaResponse.class);
            responseAsDto.errorCodes = new List<String>();
            if (responseAsMap.containsKey(ERROR_CODES_KEY)) {
                List<Object> codesAsObjects = (List<Object>) responseAsMap.get(ERROR_CODES_KEY);
                for (Object code : codesAsObjects) {
                    responseAsDto.errorCodes.add((String) code);
                }
            }
            return responseAsDto;
        } catch (Exception rootException) {
            Logger.error(rootException);
            AuraHandledException ex = new AuraHandledException(rootException.getMessage());
            ex.initCause(rootException);
            throw ex;
        }
    }

    public class ReCaptchaResponse {
        @AuraEnabled
        public Boolean success { get; set; }
        @AuraEnabled
        public String hostname { get; set; }
        @AuraEnabled
        public List<String> errorCodes { get; set; }

        @TestVisible
        private String toJson() {
            Map<String, Object> dtoMap = new Map<String, Object>{
                'success' => this.success,
                'hostname' => this.hostname,
                ERROR_CODES_KEY => this.errorCodes
            };
            return JSON.serialize(dtoMap);
        }
    }
}
