public without sharing class BusinessHoursController {
    @AuraEnabled(Cacheable=true)
    public static Schema.BusinessHours getDefaultBusinessHours() {
        return Constants.BusinessHours.Predefined;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Schema.BusinessHours> getBusinessHours() {
        return [
            SELECT Id, Name, TimeZoneSidKey, IsDefault, IsActive
            FROM BusinessHours
            WHERE IsActive = TRUE
            ORDER BY IsDefault DESC
            LIMIT 10
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static BusinessHoursStats calculateMetricsByBusinessHours(Id businessHoursId, Datetime datetimeStamp) {
        try {
            Schema.BusinessHours bh = [SELECT Id, Name, TimeZoneSidKey FROM BusinessHours WHERE Id = :businessHoursId LIMIT 1];
            BusinessHoursStats stats = new BusinessHoursStats(bh, datetimeStamp);
            Logger.debug(stats);
            return stats;
        } catch (Exception rootException) {
            Logger.error(rootException);
            AuraHandledException ex = new AuraHandledException(rootException.getMessage());
            ex.initCause(rootException);
            throw ex;
        }
    }

    // Useful article: https://medium.com/salesforce-zolo/what-every-salesforce-developer-should-know-about-dates-and-times-in-apex-d49bc0a116d4
    public class BusinessHoursStats {
        private final String FORMAT = 'EEE, yyyy-MM-dd HH:mm:ss z';

        @AuraEnabled
        public Schema.BusinessHours businessHours { get; set; }
        @AuraEnabled
        public Datetime datetimeStamp { get; set; }
        @AuraEnabled
        public String formattedDatetimeUtc {
            get {
                return this.datetimeStamp.formatGmt(this.FORMAT);
            }
        }
        @AuraEnabled
        public String formattedDatetimeBh {
            get {
                return this.datetimeStamp.format(this.FORMAT, this.businessHours.TimeZoneSidKey);
            }
        }
        @AuraEnabled
        public Boolean isWorkingHours {
            get {
                return System.BusinessHours.isWithin(this.businessHours.Id, this.datetimeStamp);
            }
        }
        @AuraEnabled
        public Datetime nextStartDate {
            get {
                return System.BusinessHours.nextStartDate(this.businessHours.Id, this.datetimeStamp);
            }
        }
        @AuraEnabled
        public String formattedNextStartDatetimeBh {
            get {
                return this.nextStartDate.format(this.FORMAT, this.businessHours.TimeZoneSidKey);
            }
        }

        public BusinessHoursStats(Schema.BusinessHours businessHours, Datetime datetimeStamp) {
            this.businessHours = businessHours;
            this.datetimeStamp = datetimeStamp;
        }

        public override String toString() {
            return JSON.serializePretty(this);
        }
    }
}
