public with sharing class LogsMonitorPanelController {
    private final static String PARTITION_NS = 'local.LogsMonitor';
    private final static String RATIO_KEY = 'leftDivRatio';
    private final static Integer DEFAULT_RATIO = 75;

    @AuraEnabled(Cacheable=true)
    public static Boolean hasPartitionDefined() {
        try {
            return Cache.Session.getPartition(PARTITION_NS) <> null;
        } catch (Cache.Session.SessionCacheException ex) {
            Logger.error('No SessionPartition allocated: {0}', Lists.of(PARTITION_NS));
            return false;
        } catch (Exception ex) {
            String exceptionDetails = Exceptions.getDetails(ex).toString();
            Logger.error(exceptionDetails);
            throw new AuraHandledException(exceptionDetails);
        }
    }

    @AuraEnabled
    public static Integer getRatio() {
        try {
            Cache.SessionPartition logsPartition = Cache.Session.getPartition(PARTITION_NS);
            if (!logsPartition.contains(RATIO_KEY)) {
                return DEFAULT_RATIO;
            }
            return (Integer) logsPartition.get(RATIO_KEY);
        } catch (Exception ex) {
            String exceptionDetails = Exceptions.getDetails(ex).toString();
            Logger.error(exceptionDetails);
            throw new AuraHandledException(exceptionDetails);
        }
    }

    @AuraEnabled
    public static void setRatio(Integer ratio) {
        try {
            Cache.SessionPartition logsPartition = Cache.Session.getPartition(PARTITION_NS);
            logsPartition.put(RATIO_KEY, ratio);
        } catch (Exception ex) {
            String exceptionDetails = Exceptions.getDetails(ex).toString();
            Logger.error(exceptionDetails);
            throw new AuraHandledException(exceptionDetails);
        }
    }
}
