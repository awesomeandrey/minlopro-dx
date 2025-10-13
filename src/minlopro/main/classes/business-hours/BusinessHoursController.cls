public without sharing class BusinessHoursController {
    @AuraEnabled(Cacheable=true)
    public static Schema.BusinessHours getDefaultBusinessHours() {
        return Constants.BusinessHours.Predefined;
    }

    @AuraEnabled(Cacheable=true)
    public static Metrics calculateMetrics(Datetime datetime1, Datetime datetime2) {
        try {
            Schema.BusinessHours defBusinessHours = getDefaultBusinessHours();
            Metrics metricsDto = new Metrics();
            metricsDto.isBusinessDay = BusinessHours.isWithin(defBusinessHours.Id, datetime1);
            metricsDto.nextBusinessDay = BusinessHours.nextStartDate(defBusinessHours.Id, datetime1);
            metricsDto.diff = BusinessHours.diff(defBusinessHours.Id, datetime1, datetime2);
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
