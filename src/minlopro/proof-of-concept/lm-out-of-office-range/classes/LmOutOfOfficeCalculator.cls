/**
 * Determines whether a given moment falls within a recurring weekly Out-Of-Office (OOO) window.
 *
 * Configuration:
 *   In production these values would come from a custom metadata type record.
 *   For this POC they are stored as overridable statics so tests can inject any scenario.
 *
 * Algorithm overview:
 *   A full week has 7 × 24 = 168 hour-slots, numbered 0 (Mon 00:00) … 167 (Sun 23:00).
 *   We convert the current time and both OOO boundaries to that scale, then do a plain
 *   integer range-check — with a wrap-around variant for windows that cross the week boundary
 *   (e.g. Friday 17:00 → Monday 09:00).
 */
public without sharing class LmOutOfOfficeCalculator {
    // ─── Configuration (simulates custom metadata record) ────────────────────────────

    @TestVisible
    private static String OOO_START_DAY = 'Friday';
    @TestVisible
    private static Integer OOO_START_HOUR = 17; // 0-23, military time
    @TestVisible
    private static String OOO_END_DAY = 'Monday';
    @TestVisible
    private static Integer OOO_END_HOUR = 9; // 0-23, military time
    @TestVisible
    private static String TZ_SID_KEY = 'America/New_York';

    // ─── Day name → ISO week number (Monday = 1 … Sunday = 7) ───────────────────────

    private static final Map<String, Integer> DAY_NUMBER = new Map<String, Integer>{
        'Monday' => 1,
        'Tuesday' => 2,
        'Wednesday' => 3,
        'Thursday' => 4,
        'Friday' => 5,
        'Saturday' => 6,
        'Sunday' => 7
    };

    // ─── Public API ──────────────────────────────────────────────────────────────────

    /**
     * Returns true if `dt` falls within the configured weekly OOO window.
     * In production always pass System.now() as `dt`.
     */
    public static Boolean isOutOfOffice(Datetime dt) {
        // Step 1 – render dt in the configured timezone to get local day name and hour
        String localDayName = dt.format('EEEE', TZ_SID_KEY); // e.g. "Friday"
        Integer localHour = Integer.valueOf(dt.format('H', TZ_SID_KEY)); // e.g. 17

        // Step 2 – convert current time and OOO boundaries to week positions (0-167)
        Integer currentPos = toWeekPosition(DAY_NUMBER.get(localDayName), localHour);
        Integer startPos = toWeekPosition(DAY_NUMBER.get(OOO_START_DAY), OOO_START_HOUR);
        Integer endPos = toWeekPosition(DAY_NUMBER.get(OOO_END_DAY), OOO_END_HOUR);

        // Step 3 – range check
        if (startPos == endPos) {
            // Zero-length window → treat as "never OOO"
            return false;
        } else if (startPos < endPos) {
            // Normal window: does not cross the week boundary (e.g. Sat 09:00 → Sun 20:00)
            //   Timeline:  ──────[start══════end]──────
            return currentPos >= startPos && currentPos < endPos;
        } else {
            // Wrap-around window: crosses the week boundary (e.g. Fri 17:00 → Mon 09:00)
            //   Timeline:  ══end]────────────[start══
            return currentPos >= startPos || currentPos < endPos;
        }
    }

    // ─── Private helpers ─────────────────────────────────────────────────────────────

    /**
     * Maps an ISO day number (1=Mon … 7=Sun) and an hour (0-23) to a single
     * integer position on a 0-167 weekly timeline.
     *
     *   Monday    00:00 →   0
     *   Monday    23:00 →  23
     *   Friday    17:00 → 113   ( (5-1)*24 + 17 )
     *   Sunday    23:00 → 167
     */
    private static Integer toWeekPosition(Integer isoDayNumber, Integer hour) {
        return (isoDayNumber - 1) * 24 + hour;
    }
}
