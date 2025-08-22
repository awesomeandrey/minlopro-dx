public without sharing class BusinessHoursController {
    @AuraEnabled(Cacheable=true)
    public static Metrics calculateMetrics(Datetime datetime1, Datetime datetime2) {
        try {
            Metrics metricsDto = new Metrics();
            metricsDto.isBusinessDay = BusinessHours.isWithin(Constants.BusinessHours.Predefined.Id, datetime1);
            metricsDto.nextBusinessDay = BusinessHours.nextStartDate(Constants.BusinessHours.Predefined.Id, datetime1);
            metricsDto.diff = BusinessHours.diff(Constants.BusinessHours.Predefined.Id, datetime1, datetime2);
            Logger.debug(metricsDto);
            return metricsDto;
        } catch (Exception rootException) {
            Logger.error(rootException);
            AuraHandledException ex = new AuraHandledException(rootException.getMessage());
            ex.initCause(rootException);
            throw ex;
        }
    }

    public class Metrics {
        @AuraEnabled
        public Boolean isBusinessDay;
        @AuraEnabled
        public Datetime nextBusinessDay;
        @AuraEnabled
        public Long diff;
    }
}
