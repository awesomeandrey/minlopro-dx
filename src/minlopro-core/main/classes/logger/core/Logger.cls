public without sharing class Logger {
    private static final Boolean IS_ENABLED = isEnabled();
    private static final String ORG_NAMESPACE = [SELECT NamespacePrefix FROM Organization].NamespacePrefix;
    private static final String CLASSNAME = Logger.class.getName();
    private static final Pattern STACK_LINE = Pattern.compile(
        '^(?:Class\\.)?([^.]+)\\.?([^\\.\\:]+)?[\\.\\:]?([^\\.\\:]*): line (\\d+), column (\\d+)$'
    );
    private static Log__e log = null;

    public static void debug() {
        debug('', new List<Object>());
    }

    public static void debug(String message) {
        debug(message, new List<Object>());
    }

    public static void debug(Integer count) {
        debug(String.valueOf(count), new List<Object>());
    }

    public static void debug(List<SObject> records) {
        debug(JSON.serialize(records), new List<Object>());
    }

    public static void debug(List<Object> values) {
        debug('', values);
    }

    public static void debug(String message, List<Object> values) {
        emit(message, values, LoggingLevel.DEBUG);
    }

    public static void error() {
        error('', new List<Object>());
    }

    public static void error(String message) {
        error(message, new List<Object>());
    }

    public static void error(List<Object> values) {
        error('', values);
    }

    public static void error(Exception ex) {
        Map<String, String> exceptionInfo = Exceptions.getDetails(ex);
        error(JSON.serialize(exceptionInfo));
    }

    public static void error(String message, List<Object> values) {
        emit(message, values, LoggingLevel.ERROR);
    }

    private static void emit(String message, List<Object> values, LoggingLevel level) {
        // Generate complete log message;
        List<String> valuesAsStrings = cast(values);
        for (Integer i = 0; i < valuesAsStrings.size(); i++) {
            message = message.replaceAll('\\{' + String.valueOf(i) + '\\}', valuesAsStrings[i]);
        }
        // Emit platform event with log payload;
        if (IS_ENABLED) {
            LogData logData = new LogData();
            logData.authorId = UserInfo.getUserId();
            logData.authorProfileId = UserInfo.getProfileId();
            logData.transactionId = Request.getCurrent().getRequestId();
            logData.level = level;
            logData.quiddity = Request.getCurrent().getQuiddity();
            logData.stackTrace = captureStackTrace();
            logData.message = message.abbreviate(1000);
            logData
                .addData(
                    'Callouts',
                    String.format('{0} out of {1}', new List<Object>{ Limits.getCallouts(), Limits.getLimitCallouts() })
                )
                .addData(
                    'CpuTime',
                    String.format('{0} out of {1}', new List<Object>{ Limits.getCpuTime(), Limits.getLimitCpuTime() })
                )
                .addData(
                    'HeapSize',
                    String.format('{0} out of {1}', new List<Object>{ Limits.getHeapSize(), Limits.getLimitHeapSize() })
                )
                .addData(
                    'Queries',
                    String.format('{0} out of {1}', new List<Object>{ Limits.getQueries(), Limits.getLimitQueries() })
                )
                .addData(
                    'DMLRows',
                    String.format('{0} out of {1}', new List<Object>{ Limits.getDmlRows(), Limits.getLimitDmlRows() })
                )
                .addData(
                    'FutureCalls',
                    String.format('{0} out of {1}', new List<Object>{ Limits.getFutureCalls(), Limits.getLimitFutureCalls() })
                )
                .addData(
                    'QueryRows',
                    String.format('{0} out of {1}', new List<Object>{ Limits.getQueryRows(), Limits.getLimitQueryRows() })
                )
                .addData(
                    'QueueableJobs',
                    String.format('{0} out of {1}', new List<Object>{ Limits.getQueueableJobs(), Limits.getLimitQueueableJobs() })
                );
            log = logData.castToEvent();
            EventBus.publish(log);
        }
        // Output to system debug anyway (use `JSON.serializePretty()` to log ALL message content in multiline fashion);
        if (level == LoggingLevel.ERROR) {
            System.debug(level, '🔴 LOG  => ' + message + '\n');
        } else {
            System.debug(level, '⚪ LOG  => ' + message + '\n');
        }
    }

    private static List<String> cast(List<Object> values) {
        List<String> result = new List<String>();
        for (Object value : values) {
            result.add('' + value);
        }
        return result;
    }

    private static LogData.StackTrace captureStackTrace() {
        // Note: Idea taken from https://salesforce.stackexchange.com/questions/153835
        List<String> stacktrace = new DmlException().getStackTraceString().split('\n');
        for (String line : stacktrace) {
            Matcher matcher = STACK_LINE.matcher(line);
            if (matcher.find() && !line.startsWith('Class.' + CLASSNAME + '.')) {
                return new LogData.StackTrace(className(matcher), methodName(matcher), Integer.valueOf(matcher.group(4)));
            }
        }
        return new LogData.StackTrace();
    }

    private static String className(Matcher matcher) {
        String result = null;
        if ((hasNamespace(matcher))) {
            result = (matcher.group(1).equals(ORG_NAMESPACE)) ? matcher.group(2) : matcher.group(1) + '.' + matcher.group(2);
        } else {
            result = matcher.group(1);
        }
        return result;
    }

    private static String methodName(Matcher matcher) {
        return (hasNamespace(matcher)) ? prettyMethod(matcher.group(3)) : prettyMethod(matcher.group(2));
    }

    private static Boolean hasNamespace(Matcher matcher) {
        return (String.isNotBlank(matcher.group(3)));
    }

    private static String prettyMethod(String method) {
        String result = (method == null) ? 'anonymous' : method;
        return (result.contains('init')) ? 'ctor' : result;
    }

    private static Boolean isEnabled() {
        fflib_SObjectDescribe objectDescribe = fflib_SObjectDescribe.getDescribe(Log__e.SObjectType);
        if (!objectDescribe.getDescribe().isCreateable()) {
            return false;
        }
        LoggerSettings__c userSettings = LoggerSettings__c.getValues(UserInfo.getUserId());
        LoggerSettings__c profileSettings = LoggerSettings__c.getValues(UserInfo.getProfileId());
        return isEnabled(userSettings) || isEnabled(profileSettings);
    }

    private static Boolean isEnabled(LoggerSettings__c settings) {
        return (settings == null) ? false : (settings.LogsEmissionDate__c >= System.today());
    }

    @TestVisible
    private static Log__e currentEvent() {
        return log;
    }
}
