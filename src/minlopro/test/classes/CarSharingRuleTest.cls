@SuppressWarnings('PMD')
@IsTest
private class CarSharingRuleTest {
    /**
     * Note that criteria-based sharing rules CANNOT be verified in Apex Tests (https://help.salesforce.com/s/articleView?id=sf.security_sharing_rule_types.htm&type=5).
     * On the contrary, owner-based sharing rules are subject for reflection in Apex Tests.
     *
     * In the context of this Apex Test, familiarise yourself with `GrantReadOnlyShares` sharing rule on `Car__c` object.
     */

    @IsTest
    static void testGrantAndRevokeRecordAccessViaSharingRule() {
        User adminUser = TestDataFactory.createAdmin();
        User regularUser = TestDataFactory.createRegularUser();
        Id testCarId = null;
        // Create 'Car__c' record on behalf of Regular User (sharing rule should not be triggered yet);
        System.runAs(regularUser) {
            Car__c testCar = new Car__c(Brand__c = 'AUDI');
            insert testCar;
            testCarId = testCar.Id;
        }
        Assert.isNotNull(testCarId, 'Test Car record ID should have been captured!');

        // Verify there is 1 share record for the Owner only;
        CarSharesInfo sharesInfo = getCarSharesInfo(testCarId);
        sharesInfo.log('>>> Regular User created "Car__c" record.');
        Assert.isTrue(sharesInfo.hasOwnerShares);
        Assert.areEqual(1, sharesInfo.ownerShares.size());
        Assert.isFalse(sharesInfo.hasRuleShares, 'There should not be any share records with "Rule" row cause yet.');
        Assert.isFalse(sharesInfo.hasManualShares, 'There should not be any share records with "Manual" row cause.');

        // Change the record owner in order to trigger sharing rule re-calculation;
        System.runAs(regularUser) {
            Car__c testCar = new Car__c(Id = testCarId, OwnerId = adminUser.Id);
            update testCar;
        }
        // Verify that now there should be additional share record with 'Rule' row cause;
        sharesInfo = getCarSharesInfo(testCarId);
        sharesInfo.log(
            '>>> Regular User has changed "Car__c" record owner and it should have triggered sharing rules recalculation.'
        );
        Assert.isTrue(sharesInfo.shareRecords.size() > 1, 'Total share records count should have been increased.');
        Assert.isTrue(sharesInfo.hasRuleShares, 'Share record with "Rule" row cause should have been created via sharing rule.');
        Assert.isFalse(sharesInfo.hasManualShares, 'There should not be any share records with "Manual" row cause.');

        // Restore original record owner in order to trigger sharing rule re-calculation AGAIN (this time 'Rule' shares should be revoked);
        System.runAs(adminUser) {
            Car__c testCar = new Car__c(Id = testCarId, OwnerId = regularUser.Id);
            update testCar;
        }
        // Verify share records were revoked;
        sharesInfo = getCarSharesInfo(testCarId);
        sharesInfo.log(
            '>>> Admin User has restored "Car__c" record owner and it should have triggered sharing rules recalculation AGAIN.'
        );
        Assert.areEqual(1, sharesInfo.shareRecords.size(), 'Total share records count should have been decreased to 1.');
        Assert.isFalse(sharesInfo.hasRuleShares, '"Rule" share records should have been gone due to sharing rule recalculation.');
        Assert.isFalse(sharesInfo.hasManualShares, 'There should not be any share records with "Manual" row cause.');
    }

    private static CarSharesInfo getCarSharesInfo(Id parentRecordId) {
        Assert.isNotNull(parentRecordId, 'Invalid Car record ID provided.');
        List<Car__Share> shareRecords = [
            SELECT Id, ParentId, RowCause, UserOrGroupId, AccessLevel
            FROM Car__Share
            WHERE ParentId = :parentRecordId
        ];
        Assert.isFalse(shareRecords.isEmpty(), 'There should be at least 1 share record per Car record.');
        return new CarSharesInfo(shareRecords);
    }

    private class CarSharesInfo {
        private List<Car__Share> shareRecords = new List<Car__Share>();
        private final List<Car__Share> ruleShares {
            get {
                return this.collectSharesByRowCause('Rule');
            }
        }
        private final List<Car__Share> manualShares {
            get {
                return this.collectSharesByRowCause('Manual');
            }
        }
        private final List<Car__Share> ownerShares {
            get {
                return this.collectSharesByRowCause('Owner');
            }
        }
        private final Boolean hasRuleShares {
            get {
                return !this.ruleShares.isEmpty();
            }
        }
        private final Boolean hasManualShares {
            get {
                return !this.manualShares.isEmpty();
            }
        }
        private final Boolean hasOwnerShares {
            get {
                return !this.ownerShares.isEmpty();
            }
        }

        private CarSharesInfo(List<Car__Share> shareRecords) {
            this.shareRecords = shareRecords;
        }

        private List<Car__Share> collectSharesByRowCause(String rowCause) {
            List<Car__Share> result = new List<Car__Share>();
            for (Car__Share shareRecord : this.shareRecords) {
                if (shareRecord.RowCause.equalsIgnoreCase(rowCause)) {
                    result.add(shareRecord);
                }
            }
            return result;
        }

        private void log(String title) {
            DebugTableFormatter formatter = new DebugTableFormatter(
                new List<String>{
                    Car__Share.ParentId.getDescribe().getName(),
                    Car__Share.RowCause.getDescribe().getName(),
                    Car__Share.UserOrGroupId.getDescribe().getName(),
                    Car__Share.AccessLevel.getDescribe().getName()
                },
                this.shareRecords
            );
            formatter.log(title);
        }
    }
}
