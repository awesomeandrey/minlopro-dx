/**
 * @description Service class for fuzzy string matching operations
 * @author Claude
 * @date 2026-01-29
 *
 * GOVERNOR LIMIT CONSIDERATIONS:
 * - CPU Time: Levenshtein is O(m×n). Use async processing for >100 comparisons
 * - Heap Size: Dynamic programming matrix uses ~(m×n) memory
 *
 * RECOMMENDED USAGE:
 * - Synchronous: <50 string pairs per transaction
 * - Asynchronous: Batch/Queueable for bulk deduplication
 */
public with sharing class StringMatchingService {
    // Constants for tuning
    private static final Integer MAX_STRING_LENGTH = 1000; // Prevent runaway CPU

    /**
     * @description Calculate Levenshtein distance between two strings
     * @param source First string to compare
     * @param target Second string to compare
     * @return Integer representing the edit distance (0 = identical)
     *
     * @example
     * Integer distance = StringMatchingService.getLevenshteinDistance('Salesforce', 'Salesforse');
     * System.debug(distance); // Returns 1 (one substitution: c->s)
     */
    public static Integer getLevenshteinDistance(String source, String target) {
        // Input validation
        if (String.isBlank(source) && String.isBlank(target)) {
            return 0;
        }
        if (String.isBlank(source)) {
            return target.length();
        }
        if (String.isBlank(target)) {
            return source.length();
        }

        // Normalize inputs (trim and lowercase for consistency)
        source = source.trim().toLowerCase();
        target = target.trim().toLowerCase();

        // Safety check for governor limits
        if (source.length() > MAX_STRING_LENGTH || target.length() > MAX_STRING_LENGTH) {
            throw new StringMatchingException(
                'String length exceeds maximum allowed (' +
                    MAX_STRING_LENGTH +
                    '). ' +
                    'Consider using substring or external service for very long strings.'
            );
        }

        Integer sourceLen = source.length();
        Integer targetLen = target.length();

        // Create dynamic programming matrix
        List<List<Integer>> matrix = new List<List<Integer>>();

        // Initialize matrix
        for (Integer i = 0; i <= sourceLen; i++) {
            List<Integer> row = new List<Integer>();
            for (Integer j = 0; j <= targetLen; j++) {
                row.add(0);
            }
            matrix.add(row);
        }

        // Populate first row and column
        for (Integer i = 0; i <= sourceLen; i++) {
            matrix[i][0] = i;
        }
        for (Integer j = 0; j <= targetLen; j++) {
            matrix[0][j] = j;
        }

        // Calculate distances
        for (Integer i = 1; i <= sourceLen; i++) {
            for (Integer j = 1; j <= targetLen; j++) {
                Integer cost = (source.substring(i - 1, i) == target.substring(j - 1, j)) ? 0 : 1;

                matrix[i][j] = Math.min(
                    Math.min(
                        matrix[i - 1][j] +
                        1, // Deletion
                        matrix[i][j - 1] +
                        1 // Insertion
                    ),
                    matrix[i - 1][j - 1] +
                    cost // Substitution
                );
            }
        }

        return matrix[sourceLen][targetLen];
    }

    /**
     * @description Calculate similarity percentage between two strings
     * @param source First string to compare
     * @param target Second string to compare
     * @return Decimal percentage (0.0 to 100.0)
     *
     * @example
     * Decimal similarity = StringMatchingService.getSimilarityPercentage('Apple Inc.', 'Apple Inc');
     * System.debug(similarity); // Returns ~90.9 (very similar)
     */
    public static Decimal getSimilarityPercentage(String source, String target) {
        if (String.isBlank(source) && String.isBlank(target)) {
            return 100.0;
        }
        if (String.isBlank(source) || String.isBlank(target)) {
            return 0.0;
        }

        Integer distance = getLevenshteinDistance(source, target);
        Integer maxLength = Math.max(source.trim().length(), target.trim().length());

        Decimal similarity = (1 - (Decimal.valueOf(distance) / maxLength)) * 100;
        return similarity.setScale(2); // Round to 2 decimal places
    }

    /**
     * @description Primary fuzzy matching method with configurable threshold
     * @param source First string to compare
     * @param target Second string to compare
     * @param threshold Minimum similarity percentage to return true (default 80%)
     * @return Boolean true if strings are fuzzy-matched above threshold
     *
     * @example
     * Boolean isMatch = StringMatchingService.isFuzzyMatch('Acme Corporation', 'ACME Corp', 75);
     * System.debug(isMatch); // Returns true if similarity >= 75%
     */
    public static Boolean isFuzzyMatch(String source, String target, Decimal threshold) {
        if (threshold == null || threshold < 0 || threshold > 100) {
            threshold = 80.0; // Default threshold
        }

        Decimal similarity = getSimilarityPercentage(source, target);
        return similarity >= threshold;
    }

    /**
     * @description Overloaded method with default 80% threshold
     */
    public static Boolean isFuzzyMatch(String source, String target) {
        return isFuzzyMatch(source, target, 80.0);
    }

    /**
     * @description Exact match comparison (case-insensitive)
     * @param source First string to compare
     * @param target Second string to compare
     * @return Boolean true if strings are exactly equal (ignoring case/whitespace)
     */
    public static Boolean isExactMatch(String source, String target) {
        if (String.isBlank(source) && String.isBlank(target)) {
            return true;
        }
        if (String.isBlank(source) || String.isBlank(target)) {
            return false;
        }

        return source.trim().equalsIgnoreCase(target.trim());
    }

    /**
     * @description Custom exception for string matching errors
     */
    public class StringMatchingException extends Exception {
    }
}
