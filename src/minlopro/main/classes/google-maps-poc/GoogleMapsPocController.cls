public with sharing class GoogleMapsPocController {
    public String getApiKey() {
        final String mdtRecordName = 'GoogleMapsApi';
        return ApiKey__mdt.getInstance(mdtRecordName).Key__c;
    }

    public GoogleMapsPocController() {
    }
}
