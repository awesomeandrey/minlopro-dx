/**
 * This test class assumes that custom 'Contact.DeduplicateContacts' duplicate rule is active!
 */
@IsTest
private class DuplicatesManagerControllerTest {
    static final String RULE_NAME = 'DeduplicateContacts';

    @TestSetup
    static void setup() {
        // Verify that custom duplicate rule is active;
        List<DuplicateRule> rules = [
            SELECT Id
            FROM DuplicateRule
            WHERE DeveloperName = :RULE_NAME AND IsActive = TRUE AND SobjectType = 'Contact'
            LIMIT 1
        ];
        Assert.isFalse(rules.isEmpty(), String.format('{0} rule must be active!', Lists.of(RULE_NAME)));
        // Make sure that NEW & UNIQUE Contacts have different values;
        Contact c1 = createUniqueContact();
        Contact c2 = createNewContact();
        Assert.areNotEqual(c1.FirstName, c2.FirstName);
        Assert.areNotEqual(c1.LastName, c2.LastName);
        Assert.areNotEqual(c1.Phone, c2.Phone);
        // Create Contacts;
        User adminUser = createAdmin();
        insert adminUser;
        System.runAs(adminUser) {
            List<Contact> testContacts = TestDataFactory.createContacts(10);
            // Insert unique Contact!
            Contact uniqueContact = createUniqueContact();
            testContacts.add(uniqueContact);
            insert testContacts;
            Assert.areEqual(testContacts.size(), [SELECT COUNT() FROM Contact]);
        }
    }

    @IsTest
    static void testFindDuplicates() {
        User adminUser = createAdmin();
        insert adminUser;
        System.runAs(adminUser) {
            Contact newContact = createNewContact();
            List<Contact> newContactDuplicates = DuplicatesManagerController.findDuplicates(newContact);
            Assert.areEqual(0, newContactDuplicates.size(), 'There should NOT be any duplicates found for NEW Contact record.');
            Contact uniqueContact = createUniqueContact();
            List<Contact> uniqueContactDuplicates = DuplicatesManagerController.findDuplicates(uniqueContact);
            Assert.isFalse(
                uniqueContactDuplicates.isEmpty(),
                'There should be some duplicates found for UNIQUE Contact record. '
            );
            Assert.areEqual(1, uniqueContactDuplicates.size());
        }
    }

    @IsTest
    static void testUpsertContact() {
        User adminUser = createAdmin();
        insert adminUser;
        System.runAs(adminUser) {
            // Case #1;
            Contact newContact = createNewContact();
            Id newContactId = DuplicatesManagerController.upsertContact(newContact);
            Assert.isTrue(String.isNotBlank(newContactId), 'NEW Contact should have been created.');
            // Case #2;
            Exception ex = null;
            Contact uniqueContact = createUniqueContact();
            try {
                DuplicatesManagerController.upsertContact(uniqueContact);
            } catch (Exception dmlEx) {
                ex = dmlEx;
            }
            Assert.isTrue(ex != null, 'Exception should have happened.');
            // Case #3;
            Database.DMLOptions options = new Database.DMLOptions();
            options.duplicateRuleHeader.allowSave = true;
            options.optAllOrNone = false;
            Database.SaveResult saveResult = Database.insert(uniqueContact, options);
            /**
             * If the rule is marked with 'Block' policy, then Apex cannot overwrite
             * this setting during transaction level!
             */
            Assert.isFalse(saveResult.isSuccess());
            Database.Error errorItem = saveResult.getErrors()[0];
            Assert.areEqual(StatusCode.DUPLICATES_DETECTED, errorItem.getStatusCode());
        }
    }

    static Contact createUniqueContact() {
        Contact uniqueContact = TestDataFactory.createContacts(1)[0];
        uniqueContact.FirstName = 'Micheal';
        uniqueContact.LastName = 'Born';
        uniqueContact.Phone = '2223334444';
        uniqueContact.CheckIfDuplicate__c = true;
        return uniqueContact;
    }

    static Contact createNewContact() {
        Contact uniqueContact = TestDataFactory.createContacts(1)[0];
        uniqueContact.FirstName = 'William';
        uniqueContact.LastName = 'Cruel';
        uniqueContact.Phone = '7778886666';
        uniqueContact.CheckIfDuplicate__c = true;
        return uniqueContact;
    }

    static User createAdmin() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        return TestDataFactory.createUser('Admin', 'Minlopro', profileId);
    }
}
