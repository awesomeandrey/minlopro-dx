public with sharing class DataWeaveScriptDemo {
    public static void cast() {
        String fileName = 'Twilio_Response_Deactivated_Phones';
        ContentVersion cv = [
            SELECT VersionData
            FROM ContentVersion
            WHERE ContentDocument.Title = :fileName AND IsLatest = TRUE
            LIMIT 1
        ];
        System.debug('\n\n cv => ' + cv + '\n');

        String inputCsv = cv.VersionData.toString();
        DataWeave.Script dwscript = new DataWeaveScriptResource.castPhonesToSet(); // API name of DataWeave script;
        DataWeave.Result dwresult = dwscript.execute(new Map<String, Object>{ 'phoneNumbersAsTxt' => inputCsv });
        List<Object> results = (List<Object>) dwresult.getValue();
        String firstPhone = results[0].toString();
        System.debug('\n\n firstPhone => ' + firstPhone + '\n');
        System.debug('\n\n limits.getLimitHeapSize() => ' + Limits.getLimitHeapSize() + '\n');
        System.debug('\n\n limits.getHeapSize() => ' + Limits.getHeapSize() + '\n');
        // System.debug('\n\n dwresult.getValueAsString() => ' + dwresult.getValueAsString() + '\n');
        // System.debug('\n\n results.size() => ' + results.size() + '\n');
    }
}
