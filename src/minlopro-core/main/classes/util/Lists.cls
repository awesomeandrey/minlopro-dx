public inherited sharing class Lists {
    private Lists() {
    }

    // Verify LIST emptiness;

    public static Boolean isEmpty(List<Object> values) {
        if (values == null) {
            return true;
        }
        return values.isEmpty();
    }

    public static Boolean isNotEmpty(List<Object> values) {
        return !isEmpty(values);
    }

    // Randomizer;

    public static Object getRandomItem(List<Object> values) {
        if (isEmpty(values)) {
            return null;
        }
        // Generate a random index between 0 and items.size() - 1
        Integer randomIndex = Math.floor(Math.random() * values.size()).intValue();
        return values[randomIndex];
    }

    // Working with 'String's;

    public static List<String> of(String value) {
        return new List<String>{ value };
    }

    public static List<String> of(String str1, String str2) {
        return new List<String>{ str1, str2 };
    }

    public static List<String> of(String str1, String str2, String str3) {
        return new List<String>{ str1, str2, str3 };
    }

    public static List<String> of(Set<String> values) {
        return new List<String>(values);
    }

    // Working with 'Id's;

    public static List<Id> of(Id value) {
        return new List<Id>{ value };
    }

    public static List<Id> of(Set<Id> ids) {
        return new List<Id>(ids);
    }

    // Working with 'SObject's;

    public static List<SObject> of(SObject record) {
        return new List<SObject>{ record };
    }

    public static List<SObject> of(SObject record1, SObject record2) {
        return new List<SObject>{ record1, record2 };
    }

    public static List<SObject> of(SObject record1, SObject record2, SObject record3) {
        return new List<SObject>{ record1, record2, record3 };
    }

    public static List<SObject> of(Set<SObject> records) {
        return new List<SObject>(records);
    }
}
