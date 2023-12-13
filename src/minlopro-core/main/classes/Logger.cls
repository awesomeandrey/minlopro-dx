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

    public static void debug(List<Object> values) {
        debug('', values);
    }

    public static void debug(String message, List<Object> values) {
        emit(message, values, LoggingLevel.DEBUG);
    }

    public static void error() {
        error('', new List<Object>());
    }

    public static void error(List<Object> values) {
        error('', values);
    }

    public static void error(String message) {
        error(message, new List<Object>());
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
        // Emit platform event with payload;
        if (IS_ENABLED) {
            System.debug('\n\n isEnabled() => ' + isEnabled() + '\n');
            Map<String, Object> data = new Map<String, Object>{
                'Message' => message,
                'Quiddity' => Request.getCurrent().getQuiddity(),
                /* Limits */
                'Callouts' => String.format(
                    '{0} out of {1}',
                    new List<Object>{ Limits.getCallouts(), Limits.getLimitCallouts() }
                ),
                'CpuTime' => String.format('{0} out of {1}', new List<Object>{ Limits.getCpuTime(), Limits.getLimitCpuTime() }),
                'HeapSize' => String.format(
                    '{0} out of {1}',
                    new List<Object>{ Limits.getHeapSize(), Limits.getLimitHeapSize() }
                ),
                'Queries' => String.format('{0} out of {1}', new List<Object>{ Limits.getQueries(), Limits.getLimitQueries() }),
                'DMLRows' => String.format('{0} out of {1}', new List<Object>{ Limits.getDmlRows(), Limits.getLimitDmlRows() }),
                'FutureCalls' => String.format(
                    '{0} out of {1}',
                    new List<Object>{ Limits.getFutureCalls(), Limits.getLimitFutureCalls() }
                ),
                'QueryRows' => String.format(
                    '{0} out of {1}',
                    new List<Object>{ Limits.getQueryRows(), Limits.getLimitQueryRows() }
                ),
                'QueueableJobs' => String.format(
                    '{0} out of {1}',
                    new List<Object>{ Limits.getQueueableJobs(), Limits.getLimitQueueableJobs() }
                )
            };
            storeLocation(data);
            log = new Log__e(
                AuthorId__c = UserInfo.getUserId(),
                AuthorProfileId__c = UserInfo.getProfileId(),
                Context__c = Request.getCurrent().getRequestId(),
                Level__c = level.name(),
                Data__c = JSON.serializePretty(data, true)
            );
            EventBus.publish(log);
        }
        // Output to debug anyway;
        System.debug(level, 'LOG  => ' + message + '\n');
    }

    private static List<String> cast(List<Object> values) {
        List<String> result = new List<String>();
        for (Object value : values) {
            result.add('' + value);
        }
        return result;
    }

    private static void storeLocation(Map<String, Object> data) {
        // Note: Idea taken from https://salesforce.stackexchange.com/questions/153835
        List<String> stacktrace = new DmlException().getStackTraceString().split('\n');
        for (String line : stacktrace) {
            Matcher matcher = STACK_LINE.matcher(line);
            if (matcher.find() && !line.startsWith('Class.' + CLASSNAME + '.')) {
                data.put('Class', className(matcher));
                data.put('Method', methodName(matcher));
                data.put('Line', Integer.valueOf(matcher.group(4)));
                return;
            }
        }
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
        // User-level;
        LoggerSettings__c settings = LoggerSettings__c.getValues(UserInfo.getUserId());
        if (settings == null) {
            // Profile-level;
            settings = LoggerSettings__c.getValues(UserInfo.getProfileId());
        }
        if (settings == null) {
            // Org-default level;
            settings = LoggerSettings__c.getOrgDefaults();
        }
        return (settings == null) ? false : (settings.LogsEmissionDate__c >= System.today());
    }

    @TestVisible
    private static Log__e currentEvent() {
        return log;
    }
}
