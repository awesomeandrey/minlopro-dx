public class LogData {
    // Field-driven properties;
    public String authorId { get; set; }
    public String authorProfileId { get; set; }
    public String transactionId { get; set; }
    public System.LoggingLevel level { get; set; }

    // Data-managed properties;
    public System.Quiddity quiddity {
        get {
            if (!this.data.containsKey('Quiddity')) {
                return null;
            }
            return System.Quiddity.valueOf((String) this.data.get('Quiddity'));
        }
        set {
            this.addData('Quiddity', value.name().toUpperCase());
        }
    }
    public String message {
        get {
            if (!this.data.containsKey('Message')) {
                return null;
            }
            return (String) this.data.get('Message');
        }
        set {
            this.addData('Message', value);
        }
    }
    public StackTrace stackTrace {
        get {
            if (!this.data.containsKey('StackTrace')) {
                return null;
            }
            return (StackTrace) JSON.deserialize((String) this.data.get('StackTrace'), StackTrace.class);
        }
        set {
            this.addData('StackTrace', JSON.serialize(value));
        }
    }

    // Primary store for all properties;
    private Map<String, Object> data { get; private set; }

    // See 'Logger.cls';
    public LogData() {
        this.data = new Map<String, Object>();
    }

    // See 'TH_Log_CaptureAndPersist.cls';
    public LogData(Log__e logEvent) {
        this();
        // Extract field values from Platform Event;
        this.authorId = logEvent.AuthorId__c;
        this.authorProfileId = logEvent.AuthorProfileId__c;
        this.transactionId = logEvent.TransactionId__c;
        this.level = System.LoggingLevel.valueOf(logEvent.Level__c);
        this.data = (Map<String, Object>) JSON.deserializeUntyped(logEvent.Data__c);
    }

    public LogData(LogEntry__c logEntry) {
        this();
        // Extract field values from Custom Object record;
        this.authorId = logEntry.Author__c;
        this.authorProfileId = null;
        this.transactionId = logEntry.TransactionId__c;
        this.level = System.LoggingLevel.valueOf(logEntry.Level__c);
        this.quiddity = System.Quiddity.valueOf(logEntry.Quiddity__c);
        this.message = logEntry.Message__c;
        this.stackTrace = new StackTrace(
            logEntry.ApexClass__c,
            logEntry.ApexClassMethod__c,
            Integer.valueOf(logEntry.ApexClassLine__c)
        );
    }

    public LogData addData(String key, Object value) {
        this.data.put(key, value);
        return this;
    }

    public Object getData(String key) {
        return this.data.get(key);
    }

    public Log__e castToEvent() {
        return new Log__e(
            AuthorId__c = this.authorId,
            AuthorProfileId__c = authorProfileId,
            TransactionId__c = this.transactionId,
            Level__c = this.level.name().toUpperCase(),
            Data__c = JSON.serializePretty(this.data, true)
        );
    }

    public LogEntry__c castToEntry() {
        LogEntry__c logEntry = new LogEntry__c();
        logEntry.Author__c = Id.valueOf(this.authorId);
        logEntry.TransactionId__c = this.transactionId;
        logEntry.Level__c = this.level.name().toUpperCase();
        logEntry.Message__c = this.message;
        logEntry.Quiddity__c = this.quiddity.name().toUpperCase();
        logEntry.ApexClass__c = this.stackTrace.className;
        logEntry.ApexClassMethod__c = this.stackTrace.methodName;
        logEntry.ApexClassLine__c = String.valueOf(this.stackTrace.lineNumber);
        return logEntry;
    }

    public class StackTrace {
        public String className;
        public String methodName;
        public Integer lineNumber;
        public String toString {
            get {
                return String.format(
                    '{0}.cls > {1}() > Line #{2}',
                    Lists.of(this.className, this.methodName, String.valueOf(this.lineNumber))
                );
            }
            private set;
        }

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
    }
}
