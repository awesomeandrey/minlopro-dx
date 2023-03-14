public inherited sharing class Sets {
    private Sets() {
    }

    // Verify SET emptiness;

    public static Boolean isEmpty(Set<Id> recordIds) {
        return recordIds == null || recordIds.isEmpty();
    }

    public static Boolean isNotEmpty(Set<Id> recordIds) {
        return !isEmpty(recordIds);
    }

    public static Boolean isEmpty(Set<String> values) {
        return values == null || values.isEmpty();
    }

    public static Boolean isNotEmpty(Set<String> values) {
        return !isEmpty(values);
    }

    // Working with 'Id's;

    public static Set<Id> of(Id recordId) {
        return new Set<Id>{ recordId };
    }

    public static Set<Id> of(Id recordId1, Id recordId2) {
        return new Set<Id>{ recordId1, recordId2 };
    }

    public static Set<Id> of(List<Id> recordId) {
        return new Set<Id>(recordId);
    }

    // Working with 'String's;

    public static Set<String> of(String value) {
        return new Set<String>{ value };
    }

    public static Set<String> of(String value1, String value2) {
        return new Set<String>{ value1, value2 };
    }

    public static Set<String> of(String value1, String value2, String value3) {
        return new Set<String>{ value1, value2, value3 };
    }

    public static Set<String> of(List<String> values) {
        return new Set<String>(values);
    }

    public static Set<SObject> of(SObject record) {
        return new Set<SObject>{ record };
    }
}
