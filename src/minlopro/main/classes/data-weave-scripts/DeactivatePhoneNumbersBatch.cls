/**
 * Pre-requisites:
 * - Download deactivated phone numbers from Twilio API endpoint (https://www.twilio.com/docs/messaging/api/deactivations-resource)
 * - Upload text file to Salesforce
 * - Invoke a batch (`Database.executeBatch(new DeactivatePhoneNumbersBatch(), 90000);`)
 */
public without sharing class DeactivatePhoneNumbersBatch implements Database.Batchable<String>, Database.RaisesPlatformEvents {
    private static final String DW_SCRIPT_NAME = 'parseTxtPhones';

    public List<String> start(Database.BatchableContext context) {
        Logger.debug('Running START method');

        // Step #1 - Fetch deactivated phones numbers from Twilio (add 'Database.AllowsCallouts' interface);
        // ... moved to private method!

        // Step #2 - Invoke Data Weave script to parse huuuuge amount of phones;
        // ... moved to private method;
        List<String> phoneNumbers = this.fetchAndCastPhoneNumbers();

        // Step #3 - Capture results;
        Logger.debug('Parsed Phones Amount = {0}', Lists.of(phoneNumbers.size().toString()));
        String firstPhone = phoneNumbers[0];
        Logger.debug('First Phone = {0}', Lists.of(firstPhone));
        String lastPhone = phoneNumbers[phoneNumbers.size() - 1];
        Logger.debug('Last Phone = {0}', Lists.of(lastPhone));

        return phoneNumbers;
    }

    public void execute(Database.BatchableContext context, List<String> phoneNumbersToCheck) {
        Logger.debug('Running EXECUTE method');
        Logger.debug('Phones Chunk = {0}', Lists.of(phoneNumbersToCheck.size().toString()));
    }

    public void finish(Database.BatchableContext context) {
        Logger.debug('Running FINISH method');
    }

    private String fetchTxtContent() {
        // This is where a callout occurs;
        String fileName = 'Twilio_Response_Deactivated_Phones';
        ContentVersion cv = [
            SELECT VersionData
            FROM ContentVersion
            WHERE ContentDocument.Title = :fileName AND IsLatest = TRUE
            LIMIT 1
        ];
        Logger.debug(cv.toString());
        return cv.VersionData.toString();
    }

    private List<String> fetchAndCastPhoneNumbers() {
        DataWeave.Script dwScript = DataWeave.Script.createScript(DW_SCRIPT_NAME);
        DataWeave.Result dwResult = dwScript.execute(new Map<String, Object>{ 'phoneNumbersAsTxt' => this.fetchTxtContent() });
        Logger.debug('Completed DataWeave script execution!');
        final List<String> phoneNumbers = new List<String>();
        for (Object phoneAsObj : (List<Object>) dwResult.getValue()) {
            String rawPhone = (String) phoneAsObj;
            if (String.isNotBlank(rawPhone)) {
                phoneNumbers.add(rawPhone);
            }
        }
        return phoneNumbers;
    }
}
