/**
 * Documentation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_dml_examples_merge.htm
 */
@IsTest
private class MergeDuplicatePersonAccountsTest {
    static final String RULE_NAME = 'DeduplicatePersonAccounts';

    @TestSetup
    static void setup() {
        // Verify that custom duplicate rule is active;
        List<DuplicateRule> rules = [
            SELECT Id
            FROM DuplicateRule
            WHERE DeveloperName = :RULE_NAME AND IsActive = TRUE AND SobjectType = 'Account'
            LIMIT 1
        ];
        Assert.isFalse(rules.isEmpty(), String.format('{0} rule must be active!', Lists.of(RULE_NAME)));
    }

    @IsTest
    static void testFindDuplicatesAndMergePersonAccounts() {
        List<Account> sampleDuplicatePersonAccounts = generateSampleDuplicatePersonAccounts();
        Assert.areEqual(3, sampleDuplicatePersonAccounts.size(), 'There should be 3 duplicate PersonAccounts pre-generated');

        // User #1 creates 2 duplicate PersonAccounts;
        User regularUser1 = TestDataFactory.createRegularUser();
        System.runAs(regularUser1) {
            Account pa1 = sampleDuplicatePersonAccounts[0];
            Account pa2 = sampleDuplicatePersonAccounts[1];
            insert new List<Account>{ pa1, pa2 };
            pa1 = selectAccountById(pa1.Id);
            Assert.areEqual(regularUser1.Id, pa1.OwnerId);
            pa2 = selectAccountById(pa2.Id);
            Assert.areEqual(regularUser1.Id, pa2.OwnerId);
        }

        // User #2 creates 1 duplicate PersonAccount with Opportunities;
        User regularUser2 = TestDataFactory.createRegularUser();
        System.runAs(regularUser2) {
            Account pa3 = sampleDuplicatePersonAccounts[2];
            insert pa3;
            pa3 = selectAccountById(pa3.Id);
            Assert.areEqual(regularUser2.Id, pa3.OwnerId);

            List<Opportunity> testOpportunities = TestDataFactory.createOpportunities(5, pa3.Id);
            insert testOpportunities;
            Assert.areEqual(
                5,
                selectOpportunitiesByOwnerId(regularUser2.Id).size(),
                'There should be Opportunities owned by User #2'
            );
            Assert.areEqual(
                5,
                selectOpportunitiesByAccountId(pa3.Id).size(),
                'Opportunities should be linked to Account owned by User #2'
            );
        }

        // Admin user finds duplicates and merges them;
        User adminUser = TestDataFactory.createAdmin();
        System.runAs(adminUser) {
            Assert.areEqual(3, countPersonAccounts(), 'PersonAccount records count should be equal to 3');
            Assert.areEqual(3, countPersonAccountContacts(), 'PersonAccount Contact records count should be equal to 3 too');

            // Query PersonAccounts;
            List<Account> personAccountsOfUser1 = selectPersonAccountsByOwnerId(regularUser1.Id);
            Assert.areEqual(2, personAccountsOfUser1.size());
            List<Account> personAccountsOfUser2 = selectPersonAccountsByOwnerId(regularUser2.Id);
            Assert.areEqual(1, personAccountsOfUser2.size());

            // Invoke Duplicate API;
            List<Account> personAccountsToDeDuplicate = new List<Account>();
            personAccountsToDeDuplicate.addAll(personAccountsOfUser1);
            personAccountsToDeDuplicate.addAll(personAccountsOfUser2);
            List<Datacloud.FindDuplicatesResult> foundDupResults = Datacloud.FindDuplicates.findDuplicates(
                personAccountsToDeDuplicate
            );
            Assert.areEqual(3, foundDupResults.size(), '3 Duplicate Results should be found');
            for (Datacloud.FindDuplicatesResult foundResult : foundDupResults) {
                Assert.isTrue(foundResult.isSuccess());
                Assert.areEqual(1, foundResult.getDuplicateResults().size());
                Datacloud.DuplicateResult dupResult = foundResult.getDuplicateResults().get(0);
                Assert.isFalse(dupResult.getMatchResults().isEmpty(), 'At least 1 matched result should have been found');
            }

            Account masterRecord = personAccountsOfUser1[0];
            Account dupe1 = personAccountsOfUser1[1];
            Account dupe2 = personAccountsOfUser2[0];

            /**
             * From Docs:
             *  Using the Apex merge operation, field values on the master record always supersede the corresponding field values
             *  on the records to be merged. To preserve a merged record field value, simply set this field value on the master sObject
             *  before performing the merge.
             */
            masterRecord = resolveMergeFields(masterRecord, dupe1);
            masterRecord = resolveMergeFields(masterRecord, dupe2);

            // Before assertions;
            Assert.areEqual(0, selectOpportunitiesByAccountId(masterRecord.Id).size());
            Assert.areEqual(5, selectOpportunitiesByAccountId(dupe2.Id).size()); // User #2 Accounts with Opportunities;

            // Merge PersonAccounts;
            List<Database.MergeResult> mergeResults = Database.merge(masterRecord, new List<Account>{ dupe1, dupe2 });
            Assert.areEqual(1, mergeResults.size(), '1 merge result is expected!');

            // After assertions;
            masterRecord = selectAccountById(masterRecord.Id);
            Assert.areEqual(regularUser1.Id, masterRecord.OwnerId);
            Assert.areEqual(1, countPersonAccounts(), 'PersonAccount records count should be equal to 1 after merge');
            Assert.areEqual(
                1,
                countPersonAccountContacts(),
                'PersonAccount Contact records count should be equal to 1 after merge too'
            );

            // Check whether Opportunities were re-parented;
            Assert.areEqual(
                5,
                selectOpportunitiesByOwnerId(regularUser2.Id).size(),
                'User #2 should still remain opportunities owner'
            );
            Assert.areEqual(
                0,
                selectOpportunitiesByOwnerId(regularUser1.Id).size(),
                'User #1 should have no ownership of opportunities after merge'
            );
            Assert.areEqual(
                5,
                selectOpportunitiesByAccountId(masterRecord.Id).size(),
                'Master PersonAccount should have opportunities linked after merge'
            );

            DebugTableFormatter logFormatter = new DebugTableFormatter(
                new List<String>{ 'Salutation', 'FirstName', 'LastName', 'PersonEmail', 'Phone', 'Type' },
                Lists.of(masterRecord, dupe1, dupe2)
            );
            logFormatter.log('=== Duplicate PersonAccounts ===');
            Assert.isNotNull(masterRecord.Salutation);
            Assert.isNotNull(masterRecord.FirstName);
            Assert.isNotNull(masterRecord.LastName);
            Assert.isNotNull(masterRecord.PersonEmail);
            Assert.isNotNull(masterRecord.Phone);
            Assert.isNotNull(masterRecord.Type);
        }
    }

    static RecordTypeInfo selectPersonAccountRecordType() {
        return Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Customer');
    }

    static List<Account> generateSampleDuplicatePersonAccounts() {
        // Test data should comply with 'DeduplicatePersonAccounts' duplicate/matching rule criteria;

        final RecordTypeInfo personAccountRecordTypeInfo = selectPersonAccountRecordType();
        Assert.isNotNull(personAccountRecordTypeInfo, 'PersonAccount record type undefined.');

        final String COMMON_EMAIL_ADDRESS = 'pa.dupe@minlopro.edu';
        final String COMMON_PHONE = '872-345-6789';

        Account pa1 = new Account(
            RecordTypeId = personAccountRecordTypeInfo.getRecordTypeId(),
            Salutation = null,
            FirstName = 'Katherine',
            LastName = 'MACDONALD',
            PersonEmail = COMMON_EMAIL_ADDRESS,
            Phone = null,
            Type = null
        );
        Account pa2 = new Account(
            RecordTypeId = personAccountRecordTypeInfo.getRecordTypeId(),
            Salutation = 'MRS',
            FirstName = 'Katherine',
            LastName = 'macdonald',
            PersonEmail = COMMON_EMAIL_ADDRESS,
            Phone = COMMON_PHONE,
            Type = 'Customer'
        );
        Account pa3 = new Account(
            RecordTypeId = personAccountRecordTypeInfo.getRecordTypeId(),
            Salutation = 'mrs',
            FirstName = 'Katherine',
            LastName = 'McDonald',
            PersonEmail = null,
            Phone = COMMON_PHONE,
            Type = 'Customer'
        );

        Assert.areEqual(pa1.PersonEmail, pa2.PersonEmail);
        Assert.areEqual(pa2.Phone, pa3.Phone);

        return new List<Account>{ pa1, pa2, pa3 };
    }

    static Account selectAccountById(Id accountId) {
        return [
            SELECT Id, Salutation, FirstName, LastName, RecordTypeId, PersonEmail, Phone, Type, IsPersonAccount, OwnerId
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
    }

    static Integer countPersonAccounts() {
        return [SELECT Id FROM Account WHERE IsPersonAccount = TRUE].size();
    }

    static Integer countPersonAccountContacts() {
        return [SELECT Id FROM Contact WHERE IsPersonAccount = TRUE].size();
    }

    static List<Account> selectPersonAccountsByOwnerId(Id ownerId) {
        // 'Security.stripInaccessible' removes non-writable fields prior to records merging;
        return Security.stripInaccessible(
                AccessType.UPSERTABLE,
                [
                    SELECT Id, Salutation, FirstName, LastName, RecordTypeId, PersonEmail, Phone, Type, IsPersonAccount, OwnerId
                    FROM Account
                    WHERE IsPersonAccount = TRUE AND OwnerId = :ownerId
                ]
            )
            .getRecords();
    }

    static List<Opportunity> selectOpportunitiesByOwnerId(Id ownerId) {
        return [
            SELECT Id, Name, Account.Name
            FROM Opportunity
            WHERE OwnerId = :ownerId
        ];
    }

    static List<Opportunity> selectOpportunitiesByAccountId(Id accountId) {
        return [
            SELECT Id, Name, Account.Name
            FROM Opportunity
            WHERE AccountId = :accountId
        ];
    }

    static Account resolveMergeFields(Account masterRecord, Account mergeRecord) {
        for (
            SObjectField field : new List<SObjectField>{
                Account.Salutation,
                Account.FirstName,
                Account.LastName,
                Account.Phone,
                Account.PersonEmail,
                Account.Type
            }
        ) {
            if (!field.getDescribe().isUpdateable()) {
                continue;
            }
            if (masterRecord.get(field) == null || String.isBlank(masterRecord.get(field).toString())) {
                masterRecord.put(field, mergeRecord.get(field));
            }
        }
        return masterRecord;
    }
}
