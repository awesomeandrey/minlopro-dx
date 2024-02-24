/**
 * This test class assumes that custom 'Contact.DeduplicateContacts' duplicate rule is present & active!
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
    static void testInsertDuplicateContact() {
        User adminUser = createAdmin();
        insert adminUser;
        System.runAs(adminUser) {
            // Case #1 - Create brand new contacts record (no matching duplicates expected);
            Contact newContact = createNewContact();
            Id newContactId = DuplicatesManagerController.upsertContact(newContact);
            Assert.isTrue(String.isNotBlank(newContactId), 'NEW Contact should have been created.');
            // Case #2 - Trying to INSERT another contact which matches duplicate rule should result into exception;
            Exception ex = null;
            Contact uniqueContact = createUniqueContact();
            try {
                DuplicatesManagerController.upsertContact(uniqueContact);
            } catch (Exception dmlEx) {
                ex = dmlEx;
            }
            Assert.isTrue(ex != null, 'Exception should have happened.');
            // Case #3 - Since duplicate rule has 'Allow On Insert' policy enabled, we can force contact insertion;
            Database.DMLOptions options = new Database.DMLOptions();
            options.duplicateRuleHeader.allowSave = true;
            options.optAllOrNone = false;
            Database.SaveResult saveResult = Database.insert(uniqueContact, options);
            Assert.isTrue(saveResult.isSuccess(), 'The duplicated contact should have been inserted successfully.');
        }
    }

    @IsTest
    static void testUpdateDuplicateContact() {
        User adminUser = createAdmin();
        insert adminUser;
        System.runAs(adminUser) {
            // Query existing Contact;
            Contact uniqueContactTemplate = createUniqueContact();
            Contact existingUniqueContact = [
                SELECT Id, FirstName, LastName, CheckIfDuplicate__c, Phone
                FROM Contact
                WHERE
                    FirstName = :uniqueContactTemplate.FirstName
                    AND LastName = :uniqueContactTemplate.LastName
                    AND Phone = :uniqueContactTemplate.Phone
                LIMIT 1
            ][0];
            Assert.isTrue(existingUniqueContact != null, 'Unique contact should exist in database.');
            // Find another existing & non-unique contact;
            Contact contactToUpdate = [SELECT Id FROM Contact WHERE Id != :existingUniqueContact.Id LIMIT 1][0];
            Assert.isTrue(contactToUpdate != null);
            // Derive field values from unique contact;
            contactToUpdate.FirstName = existingUniqueContact.FirstName;
            contactToUpdate.LastName = existingUniqueContact.LastName;
            contactToUpdate.Phone = existingUniqueContact.Phone;
            contactToUpdate.CheckIfDuplicate__c = existingUniqueContact.CheckIfDuplicate__c;
            // Case #1 - Since duplicate rule has 'Block On Update' policy enabled, the update DML should fail;
            Exception ex = null;
            try {
                DuplicatesManagerController.upsertContact(contactToUpdate);
            } catch (Exception dmlEx) {
                ex = dmlEx;
            }
            Assert.isTrue(ex != null, 'Exception should have happened.');
            // Case #2: If the rule is marked with 'Block' policy, then Apex cannot overwrite this setting at transaction level!
            Database.DMLOptions options = new Database.DMLOptions();
            options.duplicateRuleHeader.allowSave = true;
            options.optAllOrNone = false;
            Database.SaveResult saveResult = Database.update(contactToUpdate, options);
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
        Profile adminProfile = TestDataFactory.selectSystemAdminProfile();
        return TestDataFactory.createUser('Admin', 'Minlopro', adminProfile.Id);
    }
}
