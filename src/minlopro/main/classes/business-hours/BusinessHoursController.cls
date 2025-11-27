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

    @AuraEnabled
    public static BusinessHoursStats calculateMetricsByBusinessHours(
        Id businessHoursId,
        Datetime datetimeStamp,
        Integer nextSmsHoursDelay
    ) {
        try {
            Schema.BusinessHours bh = [SELECT Id, Name, TimeZoneSidKey FROM BusinessHours WHERE Id = :businessHoursId LIMIT 1];
            BusinessHoursStats stats = new BusinessHoursStats(bh, datetimeStamp, nextSmsHoursDelay);
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
        private Integer nextSmsHoursDelay = 3;

        @AuraEnabled
        public Schema.BusinessHours businessHours { get; set; }
        @AuraEnabled
        public Datetime datetimeStamp { get; set; }
        @AuraEnabled
        public String formattedDatetimeStampUtc {
            get {
                return this.datetimeStamp.formatGmt(this.FORMAT);
            }
        }
        @AuraEnabled
        public String formattedDatetimeStampBh {
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

        // Next SMS Date/Time Stamp Calculations

        @AuraEnabled
        public Datetime nextSmsDatetimeStamp {
            get {
                Long millisecondsDelay = this.nextSmsHoursDelay * 60L * 60 * 1000; // N hours in milliseconds
                Datetime nextDatetimeStamp = System.BusinessHours.add(
                    this.businessHours.Id,
                    this.datetimeStamp,
                    millisecondsDelay
                );
                // If calculated time falls outside business hours (e.g., exactly at closing time),
                // move it to the next business hours opening
                /*
                if (!System.BusinessHours.isWithin(this.businessHours.Id, nextDatetimeStamp)) {
                    return System.BusinessHours.nextStartDate(this.businessHours.Id, nextDatetimeStamp);
                }
                */
                return nextDatetimeStamp;
            }
        }
        @AuraEnabled
        public String formattedNextSmsDatetimeStampUtc {
            get {
                return this.nextSmsDatetimeStamp.formatGmt(this.FORMAT);
            }
        }
        @AuraEnabled
        public String formattedNextSmsDatetimeStampBh {
            get {
                return this.nextSmsDatetimeStamp.format(this.FORMAT, this.businessHours.TimeZoneSidKey);
            }
        }
        @AuraEnabled
        public Boolean isNextSmsWorkingHours {
            get {
                return System.BusinessHours.isWithin(this.businessHours.Id, this.nextSmsDatetimeStamp);
            }
        }

        public BusinessHoursStats(Schema.BusinessHours businessHours, Datetime datetimeStamp, Integer nextSmsHoursDelay) {
            this.businessHours = businessHours;
            this.datetimeStamp = datetimeStamp;
            this.nextSmsHoursDelay = nextSmsHoursDelay;
        }

        public override String toString() {
            return JSON.serializePretty(this);
        }
    }
}
