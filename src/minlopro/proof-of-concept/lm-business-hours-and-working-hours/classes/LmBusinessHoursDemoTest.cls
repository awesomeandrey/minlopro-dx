@IsTest
private class LmBusinessHoursDemoTest {
    @IsTest
    static void calculateFutureBusinessDatetime_atEarlyMorningAndLateEvening_shouldReturnValidFutureDatetime() {
        // Arrange
        Date testDate = Date.today().addDays(1);
        Datetime earlyMorningStart = Datetime.newInstance(testDate, Time.newInstance(6, 0, 0, 0));
        Datetime lateEveningStart = Datetime.newInstance(testDate, Time.newInstance(21, 0, 0, 0));

        // Act
        Test.startTest();
        Datetime earlyMorningResult = LmBusinessHoursDemo.calculateFutureBusinessDatetime(earlyMorningStart);
        Datetime lateEveningResult = LmBusinessHoursDemo.calculateFutureBusinessDatetime(lateEveningStart);
        Test.stopTest();

        // Assert - Results should be after original datetimes
        Assert.isTrue(earlyMorningResult > earlyMorningStart, 'Early morning result should be after start time');
        Assert.isTrue(lateEveningResult > lateEveningStart, 'Late evening result should be after start time');
        Assert.areNotEqual(earlyMorningStart, earlyMorningResult, 'Early morning result should not equal start time');
        Assert.areNotEqual(lateEveningStart, lateEveningResult, 'Late evening result should not equal start time');

        // Assert - Results should be within business hours
        Id bhId = LmBusinessHoursDemo.companyBusinessHours.Id;
        Assert.isTrue(BusinessHours.isWithin(bhId, earlyMorningResult), 'Early morning result should be within business hours');
        Assert.isTrue(BusinessHours.isWithin(bhId, lateEveningResult), 'Late evening result should be within business hours');

        // Assert - Results should be within working hours window
        String tzSidKey = LmBusinessHoursDemo.companyBusinessHours.TimeZoneSidKey;
        Integer earlyMorningHour = Integer.valueOf(earlyMorningResult.format('HH', tzSidKey));
        Integer lateEveningHour = Integer.valueOf(lateEveningResult.format('HH', tzSidKey));
        Assert.isTrue(
            earlyMorningHour >= LmBusinessHoursDemo.WORKING_HOURS_START &&
                earlyMorningHour < LmBusinessHoursDemo.WORKING_HOURS_END,
            'Early morning result hour (' + earlyMorningHour + ') should be within working hours'
        );
        Assert.isTrue(
            lateEveningHour >= LmBusinessHoursDemo.WORKING_HOURS_START && lateEveningHour < LmBusinessHoursDemo.WORKING_HOURS_END,
            'Late evening result hour (' + lateEveningHour + ') should be within working hours'
        );
    }

    @IsTest
    static void calculateFutureBusinessDatetime_startingOnWeekend_shouldReturnValidBusinessDay() {
        // Arrange
        Date saturdayDate = findNextSaturday(Date.today());
        Datetime weekendStart = Datetime.newInstance(saturdayDate, Time.newInstance(12, 0, 0, 0));

        // Act
        Test.startTest();
        Datetime result = LmBusinessHoursDemo.calculateFutureBusinessDatetime(weekendStart);
        Test.stopTest();

        // Assert - Result should be after weekend start
        Assert.isTrue(result > weekendStart, 'Result should be after weekend start time');
        Assert.areNotEqual(weekendStart, result, 'Result should not equal weekend start time');

        // Assert - Result should be within business hours (not on weekend)
        Id bhId = LmBusinessHoursDemo.companyBusinessHours.Id;
        Assert.isTrue(BusinessHours.isWithin(bhId, result), 'Result should be within business hours');

        // Assert - Result should be within working hours window
        String tzSidKey = LmBusinessHoursDemo.companyBusinessHours.TimeZoneSidKey;
        Integer resultHour = Integer.valueOf(result.format('HH', tzSidKey));
        Assert.isTrue(
            resultHour >= LmBusinessHoursDemo.WORKING_HOURS_START && resultHour < LmBusinessHoursDemo.WORKING_HOURS_END,
            'Result hour (' + resultHour + ') should be within working hours'
        );

        // Assert - Result should not be on Saturday or Sunday
        String dayOfWeek = result.format('EEEE');
        Assert.areNotEqual('Saturday', dayOfWeek, 'Result should not be on Saturday');
        Assert.areNotEqual('Sunday', dayOfWeek, 'Result should not be on Sunday');
    }

    private static Date findNextSaturday(Date startDate) {
        Integer dayOfWeek = Math.mod(Date.newInstance(1900, 1, 7).daysBetween(startDate), 7);
        Integer daysUntilSaturday = Math.mod(6 - dayOfWeek, 7);
        return startDate.addDays(daysUntilSaturday == 0 ? 7 : daysUntilSaturday);
    }
}
