public inherited sharing class FlowLogger {
    @InvocableMethod(Label='Log')
    public static void log(List<LogEntry> logEntries) {
        try {
            for (LogEntry entry : logEntries) {
                if (entry.isError()) {
                    Logger.error(entry.message);
                } else {
                    Logger.debug(entry.message);
                }
            }
        } catch (Exception ex) {
            Logger.error(ex);
        }
    }

    public class LogEntry {
        @InvocableVariable(Label='Logging Level' DefaultValue='DEBUG')
        public String level = LoggingLevel.DEBUG.name();
        @InvocableVariable(Label='Message' Description='Message to log')
        public String message = '';

        public Boolean isError() {
            return this.level?.equalsIgnoreCase(LoggingLevel.ERROR.name());
        }
    }
}
