/**
 * Tests for LmOutOfOfficeCalculator.
 *
 * Strategy:
 *   - Override the @TestVisible config statics to set up each scenario.
 *   - Use TZ_SID_KEY = 'UTC' so that the UTC datetime we construct IS the local time —
 *     no timezone offset arithmetic needed in the test setup.
 *   - Use a fixed reference week (Mon 2026-03-09 … Sun 2026-03-15) so day-of-week
 *     assertions are deterministic and easy to read.
 *
 * Coverage matrix:
 *   1. Wrap-around window (Fri 17:00 → Mon 09:00) — core happy-path + boundary cases
 *   2. Normal window      (Sat 09:00 → Sun 20:00) — no week-boundary crossing
 *   3. Same-day window    (Sun 08:00 → Sun 20:00)
 *   4. Zero-length window (start == end)           — edge case, should always be false
 */
@IsTest
private class LmOutOfOfficeCalculatorTest {
    // ─── Reference week: Mon 2026-03-09 … Sun 2026-03-15 ───────────────────────────
    // Day-of-month lookup so tests read as plain English
    private static final Integer MON = 9;
    private static final Integer TUE = 10;
    private static final Integer WED = 11;
    private static final Integer THU = 12;
    private static final Integer FRI = 13;
    private static final Integer SAT = 14;
    private static final Integer SUN = 15;

    /** Builds a UTC Datetime for a day in the reference week at the given hour. */
    private static Datetime utcAt(Integer dayOfMonth, Integer hour) {
        return Datetime.newInstanceGmt(2026, 3, dayOfMonth, hour, 0, 0);
    }

    // ─── Config helpers ──────────────────────────────────────────────────────────────

    /** Fri 17:00 → Mon 09:00  — wraps the week boundary */
    private static void useWrapAroundWindow() {
        LmOutOfOfficeCalculator.OOO_START_DAY = 'Friday';
        LmOutOfOfficeCalculator.OOO_START_HOUR = 17;
        LmOutOfOfficeCalculator.OOO_END_DAY = 'Monday';
        LmOutOfOfficeCalculator.OOO_END_HOUR = 9;
        LmOutOfOfficeCalculator.TZ_SID_KEY = 'UTC';
    }

    /** Sat 09:00 → Sun 20:00  — normal window, no wrap */
    private static void useNormalWindow() {
        LmOutOfOfficeCalculator.OOO_START_DAY = 'Saturday';
        LmOutOfOfficeCalculator.OOO_START_HOUR = 9;
        LmOutOfOfficeCalculator.OOO_END_DAY = 'Sunday';
        LmOutOfOfficeCalculator.OOO_END_HOUR = 20;
        LmOutOfOfficeCalculator.TZ_SID_KEY = 'UTC';
    }

    /** Sun 08:00 → Sun 20:00  — single-day window */
    private static void useSameDayWindow() {
        LmOutOfOfficeCalculator.OOO_START_DAY = 'Sunday';
        LmOutOfOfficeCalculator.OOO_START_HOUR = 8;
        LmOutOfOfficeCalculator.OOO_END_DAY = 'Sunday';
        LmOutOfOfficeCalculator.OOO_END_HOUR = 20;
        LmOutOfOfficeCalculator.TZ_SID_KEY = 'UTC';
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // 1. Wrap-around window: Fri 17:00 → Mon 09:00
    // ═══════════════════════════════════════════════════════════════════════════════

    @IsTest
    static void isOutOfOffice_wrapAround_saturdayMidday_isOOO() {
        useWrapAroundWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(SAT, 12));
        Test.stopTest();

        Assert.isTrue(result, 'Saturday midday should fall inside the Fri 17:00 → Mon 09:00 window');
    }

    @IsTest
    static void isOutOfOffice_wrapAround_sundayMidday_isOOO() {
        useWrapAroundWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(SUN, 12));
        Test.stopTest();

        Assert.isTrue(result, 'Sunday midday should fall inside the Fri 17:00 → Mon 09:00 window');
    }

    @IsTest
    static void isOutOfOffice_wrapAround_mondayEarlyMorning_isOOO() {
        // Mon 08:00 is still before the 09:00 end
        useWrapAroundWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(MON, 8));
        Test.stopTest();

        Assert.isTrue(result, 'Monday 08:00 should still be inside the OOO window (end is 09:00)');
    }

    @IsTest
    static void isOutOfOffice_wrapAround_wednesdayMidday_isNotOOO() {
        useWrapAroundWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(WED, 12));
        Test.stopTest();

        Assert.isFalse(result, 'Wednesday midday should be outside the Fri 17:00 → Mon 09:00 window');
    }

    @IsTest
    static void isOutOfOffice_wrapAround_mondayAfternoon_isNotOOO() {
        useWrapAroundWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(MON, 14));
        Test.stopTest();

        Assert.isFalse(result, 'Monday afternoon should be outside the OOO window');
    }

    // ─── Boundary cases ──────────────────────────────────────────────────────────────

    @IsTest
    static void isOutOfOffice_wrapAround_exactlyAtStart_isOOO() {
        // Start hour is inclusive
        useWrapAroundWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(FRI, 17));
        Test.stopTest();

        Assert.isTrue(result, 'Exactly at OOO start hour should be considered OOO (inclusive)');
    }

    @IsTest
    static void isOutOfOffice_wrapAround_exactlyAtEnd_isNotOOO() {
        // End hour is exclusive
        useWrapAroundWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(MON, 9));
        Test.stopTest();

        Assert.isFalse(result, 'Exactly at OOO end hour should NOT be considered OOO (exclusive)');
    }

    @IsTest
    static void isOutOfOffice_wrapAround_oneHourBeforeStart_isNotOOO() {
        useWrapAroundWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(FRI, 16));
        Test.stopTest();

        Assert.isFalse(result, 'One hour before OOO start should not be OOO');
    }

    @IsTest
    static void isOutOfOffice_wrapAround_oneHourAfterEnd_isNotOOO() {
        useWrapAroundWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(MON, 10));
        Test.stopTest();

        Assert.isFalse(result, 'One hour after OOO end should not be OOO');
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // 2. Normal window: Sat 09:00 → Sun 20:00  (no week-boundary crossing)
    // ═══════════════════════════════════════════════════════════════════════════════

    @IsTest
    static void isOutOfOffice_normalWindow_saturdayMidday_isOOO() {
        useNormalWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(SAT, 12));
        Test.stopTest();

        Assert.isTrue(result, 'Saturday midday should be inside the Sat 09:00 → Sun 20:00 window');
    }

    @IsTest
    static void isOutOfOffice_normalWindow_sundayBeforeEnd_isOOO() {
        useNormalWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(SUN, 19));
        Test.stopTest();

        Assert.isTrue(result, 'Sunday 19:00 should be inside the window (end is 20:00)');
    }

    @IsTest
    static void isOutOfOffice_normalWindow_sundayAfterEnd_isNotOOO() {
        useNormalWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(SUN, 21));
        Test.stopTest();

        Assert.isFalse(result, 'Sunday 21:00 should be outside the Sat 09:00 → Sun 20:00 window');
    }

    @IsTest
    static void isOutOfOffice_normalWindow_fridayAfternoon_isNotOOO() {
        useNormalWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(FRI, 15));
        Test.stopTest();

        Assert.isFalse(result, 'Friday afternoon should be outside the Sat→Sun window');
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // 3. Same-day window: Sun 08:00 → Sun 20:00
    // ═══════════════════════════════════════════════════════════════════════════════

    @IsTest
    static void isOutOfOffice_sameDayWindow_sundayMidday_isOOO() {
        useSameDayWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(SUN, 12));
        Test.stopTest();

        Assert.isTrue(result, 'Sunday midday should be inside the Sunday-only window');
    }

    @IsTest
    static void isOutOfOffice_sameDayWindow_sundayAfterEnd_isNotOOO() {
        useSameDayWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(SUN, 21));
        Test.stopTest();

        Assert.isFalse(result, 'Sunday 21:00 should be outside the Sun 08:00 → Sun 20:00 window');
    }

    @IsTest
    static void isOutOfOffice_sameDayWindow_mondayMidday_isNotOOO() {
        useSameDayWindow();

        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(MON, 12));
        Test.stopTest();

        Assert.isFalse(result, 'Monday midday should be outside the Sunday-only window');
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // 4. Zero-length window (start == end) — should never be OOO
    // ═══════════════════════════════════════════════════════════════════════════════

    @IsTest
    static void isOutOfOffice_zeroLengthWindow_neverOOO() {
        LmOutOfOfficeCalculator.OOO_START_DAY = 'Monday';
        LmOutOfOfficeCalculator.OOO_START_HOUR = 9;
        LmOutOfOfficeCalculator.OOO_END_DAY = 'Monday';
        LmOutOfOfficeCalculator.OOO_END_HOUR = 9;
        LmOutOfOfficeCalculator.TZ_SID_KEY = 'UTC';

        // Exactly at the configured moment — still should return false
        Test.startTest();
        Boolean result = LmOutOfOfficeCalculator.isOutOfOffice(utcAt(MON, 9));
        Test.stopTest();

        Assert.isFalse(result, 'A zero-length OOO window (start == end) should never return true');
    }
}
