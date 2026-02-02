@IsTest
private class StringMatchingServiceTest {
    @IsTest
    static void testLevenshteinDistance_IdenticalStrings() {
        Integer distance = StringMatchingService.getLevenshteinDistance('Salesforce', 'Salesforce');
        Assert.areEqual(0, distance, 'Identical strings should have distance 0');
    }

    @IsTest
    static void testLevenshteinDistance_OneCharDifference() {
        Integer distance = StringMatchingService.getLevenshteinDistance('Salesforce', 'Salesforse');
        Assert.areEqual(1, distance, 'One substitution should result in distance 1');
    }

    @IsTest
    static void testLevenshteinDistance_CompletelyDifferent() {
        Integer distance = StringMatchingService.getLevenshteinDistance('ABC', 'XYZ');
        Assert.areEqual(3, distance, 'Completely different strings of same length should have distance equal to length');
    }

    @IsTest
    static void testLevenshteinDistance_NullAndEmpty() {
        Assert.areEqual(0, StringMatchingService.getLevenshteinDistance(null, null), 'Two nulls should have distance 0');
        Assert.areEqual(0, StringMatchingService.getLevenshteinDistance('', ''), 'Two empty strings should have distance 0');
        Assert.areEqual(
            5,
            StringMatchingService.getLevenshteinDistance('Hello', ''),
            'Non-empty vs empty should return source length'
        );
        Assert.areEqual(
            5,
            StringMatchingService.getLevenshteinDistance('', 'World'),
            'Empty vs non-empty should return target length'
        );
        Assert.areEqual(
            5,
            StringMatchingService.getLevenshteinDistance(null, 'World'),
            'Null vs non-empty should return target length'
        );
        Assert.areEqual(
            5,
            StringMatchingService.getLevenshteinDistance('Hello', null),
            'Non-empty vs null should return source length'
        );
    }

    @IsTest
    static void testLevenshteinDistance_CaseInsensitive() {
        Integer distance = StringMatchingService.getLevenshteinDistance('Hello', 'HELLO');
        Assert.areEqual(0, distance, 'Case differences should be ignored');
    }

    @IsTest
    static void testLevenshteinDistance_Whitespace() {
        Integer distance = StringMatchingService.getLevenshteinDistance('  Hello  ', 'Hello');
        Assert.areEqual(0, distance, 'Leading/trailing whitespace should be trimmed');
    }

    @IsTest
    static void testSimilarityPercentage_IdenticalStrings() {
        Decimal similarity = StringMatchingService.getSimilarityPercentage('Salesforce', 'Salesforce');
        Assert.areEqual(100.00, similarity, 'Identical strings should have 100% similarity');
    }

    @IsTest
    static void testSimilarityPercentage_HighSimilarity() {
        Decimal similarity = StringMatchingService.getSimilarityPercentage('Apple Inc.', 'Apple Inc');
        Assert.isTrue(similarity >= 90, 'Very similar strings should score >=90%, got: ' + similarity);
    }

    @IsTest
    static void testSimilarityPercentage_LowSimilarity() {
        Decimal similarity = StringMatchingService.getSimilarityPercentage('Salesforce', 'Microsoft');
        Assert.isTrue(similarity < 50, 'Dissimilar strings should score <50%, got: ' + similarity);
    }

    @IsTest
    static void testSimilarityPercentage_BothBlank() {
        Assert.areEqual(100.0, StringMatchingService.getSimilarityPercentage(null, null), 'Both null should return 100%');
        Assert.areEqual(100.0, StringMatchingService.getSimilarityPercentage('', ''), 'Both empty should return 100%');
    }

    @IsTest
    static void testSimilarityPercentage_OneBlank() {
        Assert.areEqual(0.0, StringMatchingService.getSimilarityPercentage('Hello', null), 'Non-empty vs null should return 0%');
        Assert.areEqual(0.0, StringMatchingService.getSimilarityPercentage(null, 'Hello'), 'Null vs non-empty should return 0%');
    }

    @IsTest
    static void testIsFuzzyMatch_WithDefaultThreshold() {
        // "Salesforce Inc." vs "Salesforce Inc" — very similar, should match at 80%
        Assert.isTrue(
            StringMatchingService.isFuzzyMatch('Salesforce Inc.', 'Salesforce Inc'),
            'Nearly identical company names should fuzzy match at default 80% threshold'
        );

        // Completely different strings should NOT match
        Assert.isFalse(
            StringMatchingService.isFuzzyMatch('Apple', 'Microsoft'),
            'Different company names should not fuzzy match'
        );
    }

    @IsTest
    static void testIsFuzzyMatch_WithCustomThreshold() {
        // "Acme Corporation" vs "Acme Corp" with a lenient threshold
        Decimal similarity = StringMatchingService.getSimilarityPercentage('Acme Corporation', 'Acme Corp');
        Boolean matchAtLenient = StringMatchingService.isFuzzyMatch('Acme Corporation', 'Acme Corp', 50);
        Assert.isTrue(matchAtLenient, 'Should match at 50% threshold, similarity was: ' + similarity);

        // Same pair should NOT match at a strict threshold
        Boolean matchAtStrict = StringMatchingService.isFuzzyMatch('Acme Corporation', 'Acme Corp', 90);
        Assert.isFalse(matchAtStrict, 'Should not match at 90% threshold, similarity was: ' + similarity);
    }

    @IsTest
    static void testIsFuzzyMatch_InvalidThresholdDefaultsTo80() {
        // Null threshold should default to 80%
        Boolean matchNull = StringMatchingService.isFuzzyMatch('Salesforce', 'Salesforce', null);
        Assert.isTrue(matchNull, 'Null threshold should default to 80% and identical strings should match');

        // Negative threshold should default to 80%
        Boolean matchNeg = StringMatchingService.isFuzzyMatch('Salesforce', 'Salesforce', -10);
        Assert.isTrue(matchNeg, 'Negative threshold should default to 80%');

        // Threshold > 100 should default to 80%
        Boolean matchOver = StringMatchingService.isFuzzyMatch('Salesforce', 'Salesforce', 150);
        Assert.isTrue(matchOver, 'Threshold > 100 should default to 80%');
    }

    @IsTest
    static void testIsExactMatch_CaseInsensitive() {
        Assert.isTrue(
            StringMatchingService.isExactMatch('Salesforce', 'SALESFORCE'),
            'Case-insensitive exact match should return true'
        );
        Assert.isTrue(StringMatchingService.isExactMatch('  Salesforce  ', 'Salesforce'), 'Trimmed strings should match');
        Assert.isFalse(
            StringMatchingService.isExactMatch('Salesforce', 'Salesforse'),
            'Different strings should not exact match'
        );
    }

    @IsTest
    static void testIsExactMatch_NullAndEmpty() {
        Assert.isTrue(StringMatchingService.isExactMatch(null, null), 'Both null should be exact match');
        Assert.isTrue(StringMatchingService.isExactMatch('', ''), 'Both empty should be exact match');
        Assert.isFalse(StringMatchingService.isExactMatch('Hello', null), 'Non-empty vs null should not match');
        Assert.isFalse(StringMatchingService.isExactMatch(null, 'Hello'), 'Null vs non-empty should not match');
    }

    @IsTest
    static void testExceptionHandling_StringTooLong() {
        String veryLongString = 'A'.repeat(1001);

        try {
            StringMatchingService.getLevenshteinDistance(veryLongString, 'Short');
            Assert.fail('Should have thrown StringMatchingException');
        } catch (StringMatchingService.StringMatchingException e) {
            Assert.isTrue(e.getMessage().contains('exceeds maximum'), 'Exception message should mention limit');
        }
    }

    @IsTest
    static void testRealWorldScenario_AccountDeduplication() {
        String officialName = 'Salesforce Inc.';

        // Very close variations should match at 75% threshold
        Assert.isTrue(
            StringMatchingService.isFuzzyMatch(officialName, 'Salesforce Inc', 75),
            'Missing period should still fuzzy match'
        );
        Assert.isTrue(
            StringMatchingService.isFuzzyMatch(officialName, 'salesforce inc.', 75),
            'Lowercase variation should fuzzy match'
        );
        Assert.isTrue(
            StringMatchingService.isFuzzyMatch(officialName, 'Salesforse Inc.', 75),
            'Typo variation should fuzzy match'
        );

        // "SalesForce Incorporated" is more distant — verify actual similarity
        Decimal similarity = StringMatchingService.getSimilarityPercentage(officialName, 'SalesForce Incorporated');
        Assert.isTrue(similarity > 50, 'Expanded variation should have >50% similarity, got: ' + similarity);
    }
}
