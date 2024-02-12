public class LogData {
    public String authorId { get; set; }
    public String context { get; set; }
    public System.LoggingLevel level { get; set; }
    public System.Quiddity quiddity { get; set; }
    public String message { get; set; }
    public Map<String, Object> data { get; set; }

    // Volatile properties;
    public String authorProfileId { get; set; }
    public StackTrace stackTrace { get; set; }

    // See 'Logger.cls';
    public LogData() {
        this.data = new Map<String, Object>();
    }

    // See 'TH_Log_CaptureAndPersist.cls';
    public LogData(Log__e logEvent) {
        this();
        // Extract field values from platform event;
        this.authorId = logEvent.AuthorId__c;
        this.context = logEvent.Context__c;
        this.level = System.LoggingLevel.valueOf(logEvent.Level__c);
        // Dynamically extract values from JSON;
        this.data = (Map<String, Object>) JSON.deserializeUntyped(logEvent.Data__c);
        this.quiddity = System.Quiddity.valueOf((String) this.data.get('Quiddity'));
        this.message = (String) this.data.get('Message');
        this.stackTrace = new StackTrace().cast(this.data);
    }

    public LogData addData(String key, Object value) {
        this.data.put(key, value);
        return this;
    }

    public Log__e castToEvent() {
        // 'Data__c' field must contain 'Message' and 'Quiddity' properties;
        this.addData('Message', this.message);
        this.addData('Quiddity', this.quiddity.name().toUpperCase());
        // Add stack trace info as well;
        this.data.putAll(this.stackTrace.castToMap());
        return new Log__e(
            AuthorId__c = this.authorId,
            AuthorProfileId__c = authorProfileId,
            Context__c = this.context,
            Level__c = this.level.name().toUpperCase(),
            Data__c = JSON.serializePretty(this.data, true)
        );
    }

    public LogEntry__c castToEntry() {
        LogEntry__c logEntry = new LogEntry__c();
        logEntry.Author__c = Id.valueOf(this.authorId);
        logEntry.TransactionId__c = this.context;
        logEntry.Level__c = this.level.name().toUpperCase();
        logEntry.Message__c = this.message;
        logEntry.Quiddity__c = this.quiddity.name().toUpperCase();
        logEntry.ApexClass__c = this.stackTrace.className;
        logEntry.ApexClassMethod__c = this.stackTrace.methodName;
        logEntry.ApexClassLine__c = String.valueOf(this.stackTrace.lineNumber);
        return logEntry;
    }

    public class StackTrace {
        private String className;
        private String methodName;
        private Integer lineNumber;

        public StackTrace() {
            this.className = 'UnknownClass';
            this.methodName = 'unknownMethod';
            this.lineNumber = 0;
        }

        public StackTrace(String className, String methodName, Integer lineNumber) {
            this();
            this.className = className;
            this.methodName = methodName;
            this.lineNumber = lineNumber;
        }

        public StackTrace cast(Map<String, Object> dataMap) {
            this.className = (String) dataMap.get('Class');
            this.methodName = (String) dataMap.get('Method');
            this.lineNumber = (Integer) dataMap.get('Line');
            return this;
        }

        private Map<String, Object> castToMap() {
            return new Map<String, Object>{ 'Class' => this.className, 'Method' => this.methodName, 'Line' => this.lineNumber };
        }
    }
}
