public without sharing class LmBusinessHoursDemo {
    @TestVisible
    private static final Integer WORKING_HOURS_START = 9;
    @TestVisible
    private static final Integer WORKING_HOURS_END = 18;
    @TestVisible
    private static final Long DEFAULT_DELAY_HOURS = 48;
    @TestVisible
    private static Map<Datetime, Datetime> memoCache = new Map<Datetime, Datetime>();

    public static Schema.BusinessHours companyBusinessHours {
        get {
            if (companyBusinessHours == null) {
                companyBusinessHours = [
                    SELECT Id, Name, TimeZoneSidKey
                    FROM BusinessHours
                    WHERE IsActive = TRUE AND Name LIKE 'Ukraine | SMS % 24/7 Weekdays'
                    LIMIT 1
                ];
            }
            return companyBusinessHours;
        }
        set;
    }

    public static Datetime calculateFutureBusinessDatetime(Datetime startTime) {
        Datetime cacheKey = truncateToMinute(startTime);
        if (memoCache.containsKey(cacheKey)) {
            return memoCache.get(cacheKey);
        }
        /*
        Note: 'BusinessHours.add()' method adds an interval of time from a start Datetime traversing business hours only
        Long delayMs = DEFAULT_DELAY_HOURS * 60 * 60 * 1000;
        Datetime nextBusinessDatetime = BusinessHours.add(companyBusinessHours.Id, startTime, delayMs);
        */
        Datetime nextBusinessDatetime = startTime.addHours(48); // Add strict 48 hours
        while (!isValid(nextBusinessDatetime)) {
            // Move clock 1 hour ahead
            nextBusinessDatetime = nextBusinessDatetime.addHours(1);
        }
        memoCache.put(cacheKey, nextBusinessDatetime);
        return nextBusinessDatetime;
    }

    // Floors dt to the nearest minute using integer division on epoch ms — sub-minute remainder is discarded.
    // e.g. 10:15:37.842 → getTime()=X → (X/60000)*60000 → 10:15:00.000
    public static Datetime truncateToMinute(Datetime dt) {
        Long truncatedMs = (dt.getTime() / 60000) * 60000;
        return Datetime.newInstance(truncatedMs);
    }

    public static Boolean isValid(Datetime datetimeStamp) {
        // Double-check for holidays
        Boolean isWithinBusinessHours = System.BusinessHours.isWithin(companyBusinessHours.Id, datetimeStamp);
        // Working hours check
        Integer hourInBhTimezone = Integer.valueOf(datetimeStamp.format('HH', companyBusinessHours.TimeZoneSidKey));
        Boolean isWithinWorkingHours = hourInBhTimezone >= WORKING_HOURS_START && hourInBhTimezone < WORKING_HOURS_END;
        // Working day check
        String dayInBhTimezone = datetimeStamp.format('EEEE', companyBusinessHours.TimeZoneSidKey);
        Boolean isWorkingDay = !(dayInBhTimezone == 'Saturday' || dayInBhTimezone == 'Sunday');
        return isWithinBusinessHours && isWithinWorkingHours && isWorkingDay;
    }
}
