@isTest
private class FeatureToggleTest {
    //    @isTest
    //    static void testIsActive_ToggleIsActive() {
    //        // Create a mock FeatureToggle__mdt record
    //        FeatureToggle__mdt toggle = new FeatureToggle__mdt(
    //            DeveloperName = 'TestToggle',
    //            MasterLabel = 'Test Toggle',
    //            Active__c = true,
    //            Description__c = 'Test Description'
    //        );
    //        FeatureToggle.toggles = new List<FeatureToggle__mdt>{ toggle };
    //
    //        Test.startTest();
    //        Boolean isActive = FeatureToggle.isActive('TestToggle');
    //        Test.stopTest();
    //
    //        System.assertEquals(true, isActive, 'The toggle should be active.');
    //    }
    //
    //    @isTest
    //    static void testIsActive_ToggleIsInactive() {
    //        // Create a mock FeatureToggle__mdt record
    //        FeatureToggle__mdt toggle = new FeatureToggle__mdt(
    //            DeveloperName = 'TestToggle',
    //            MasterLabel = 'Test Toggle',
    //            Active__c = false,
    //            Description__c = 'Test Description'
    //        );
    //        FeatureToggle.toggles = new List<FeatureToggle__mdt>{ toggle };
    //
    //        Test.startTest();
    //        Boolean isActive = FeatureToggle.isActive('TestToggle');
    //        Test.stopTest();
    //
    //        System.assertEquals(false, isActive, 'The toggle should be inactive.');
    //    }
    //
    //    @isTest
    //    static void testIsActive_ToggleNotFound() {
    //        FeatureToggle.toggles = new List<FeatureToggle__mdt>();
    //        Test.startTest();
    //        Boolean isActive = FeatureToggle.isActive('NonExistentToggle');
    //        Test.stopTest();
    //
    //        System.assertEquals(false, isActive, 'A non-existent toggle should be considered inactive.');
    //    }
    //
    //    @isTest
    //    static void testIsActive_NullToggleName() {
    //        Test.startTest();
    //        Boolean isActive = FeatureToggle.isActive(null);
    //        Test.stopTest();
    //
    //        System.assertEquals(false, isActive, 'A null toggle name should be considered inactive.');
    //    }
    //
    //    @isTest
    //    static void testIsActive_EmptyToggleName() {
    //        Test.startTest();
    //        Boolean isActive = FeatureToggle.isActive('');
    //        Test.stopTest();
    //
    //        System.assertEquals(false, isActive, 'An empty toggle name should be considered inactive.');
    //    }
}
