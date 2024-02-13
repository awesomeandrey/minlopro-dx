public with sharing class TriggerDispatcher {
    // Static properties;
    private static final Map<SObjectType, Set<TriggerHandler>> activateHandlersByObjectTypeMap {
        get {
            if (activateHandlersByObjectTypeMap == null) {
                activateHandlersByObjectTypeMap = new Map<SObjectType, Set<TriggerHandler>>();
                for (TriggerHandler__mdt handlerCmt : [
                    SELECT Id, TargetObject__c, ApexClassName__c, Order__c, Active__c
                    FROM TriggerHandler__mdt
                    WHERE Active__c = TRUE
                    ORDER BY Order__c ASC
                ]) {
                    TriggerHandler handlerItem = new TriggerHandler(handlerCmt);
                    if (!activateHandlersByObjectTypeMap.containsKey(handlerItem.objectType)) {
                        activateHandlersByObjectTypeMap.put(handlerItem.objectType, new Set<TriggerHandler>());
                    }
                    activateHandlersByObjectTypeMap.get(handlerItem.objectType).add(handlerItem);
                }
                debug('🔵 Loaded handlers info from CMTs.');
            }
            return activateHandlersByObjectTypeMap;
        }
        set;
    }
    private static final Map<SObjectType, Set<TriggerHandler>> selectedHandlersByObjectTypeMap = new Map<SObjectType, Set<TriggerHandler>>();
    private static final Map<TriggerHandler, LoopCount> loopCountMap = new Map<TriggerHandler, LoopCount>();
    private static final Set<TriggerHandler> bypassedHandlers = new Set<TriggerHandler>();
    // Turn off for production;
    public static Boolean debugModeEnabled = true;

    // Instance properties;
    private final SObjectType currentObjectType;

    public static TriggerDispatcher setContext(SObjectType objectType) {
        // The new class instance is created upon each trigger phase (including recursive executions too).
        return new TriggerDispatcher(objectType);
    }

    public static void bypass(SObjectType objectType, String apexClassName) {
        bypassedHandlers.add(new TriggerHandler(objectType, apexClassName));
    }

    public static void clearBypass(SObjectType objectType, String apexClassName) {
        bypassedHandlers.remove(new TriggerHandler(objectType, apexClassName));
    }

    public static void clearAllBypass() {
        bypassedHandlers.clear();
    }

    private TriggerDispatcher(SObjectType objectType) {
        this.currentObjectType = objectType;
    }

    public void run() {
        if (!this.isTriggerContext()) {
            debug('Trigger context was not matched!');
            return;
        }
        List<TriggerHandler> objectHandlers = new List<TriggerHandler>(this.getObjectHandlers());
        objectHandlers.sort();
        debug(
            'Loaded {0} trigger handlers for [{1}] object.',
            Lists.of(String.valueOf(objectHandlers.size()), this.currentObjectType.toString())
        );
        Iterator<TriggerHandler> handlersIterator = objectHandlers.iterator();
        while (handlersIterator.hasNext()) {
            TriggerHandler handlerToExecute = handlersIterator.next();
            if (!handlerToExecute.isValid()) {
                // Verify that the Apex implementation is valid;
                throw new TriggerDispatcherException(
                    String.format('Invalid handler implementation detected: {0}', Lists.of(handlerToExecute.getName()))
                );
            } else if (bypassedHandlers.contains(handlerToExecute)) {
                debug('Bypassing trigger handler: {0}.', Lists.of(handlerToExecute.getName()));
                // Bypass particular handler;
                continue;
            } else {
                debug('Running {0} trigger handler...', Lists.of(handlerToExecute.getName()));
                // Validate max loop count;
                this.setAndValidateMaxLoopCount(handlerToExecute);
                // Execute trigger handler logic according to trigger phase;
                BasicTriggerHandler handlerImpl = handlerToExecute.getInstance();
                switch on Trigger.operationType {
                    when BEFORE_INSERT {
                        handlerImpl.beforeInsert(Trigger.new);
                    }
                    when BEFORE_UPDATE {
                        handlerImpl.beforeUpdate(Trigger.oldMap, Trigger.newMap);
                    }
                    when AFTER_INSERT {
                        handlerImpl.afterInsert(Trigger.new);
                    }
                    when AFTER_UPDATE {
                        handlerImpl.afterUpdate(Trigger.oldMap, Trigger.newMap);
                    }
                }
            }
        }
    }

    private Boolean isTriggerContext() {
        /**
         * In Apex, the System.Trigger.isExecuting context variable is a boolean flag
         * that indicates whether the current code is being executed in the context of a trigger,
         * as opposed to being executed from a Visualforce page, an Apex class directly, or another context.
         * This flag is useful in multiple scenarios to ensure that
         * certain code blocks only run when initiated by a trigger,
         * helping to manage execution flow and prevent unintended operations.
         */
        return Trigger.isExecuting;
    }

    private Set<TriggerHandler> getObjectHandlers() {
        if (isSelectiveMode()) {
            if (selectedHandlersByObjectTypeMap.containsKey(this.currentObjectType)) {
                return selectedHandlersByObjectTypeMap.get(this.currentObjectType);
            } else {
                return new Set<TriggerHandler>();
            }
        } else if (activateHandlersByObjectTypeMap.containsKey(this.currentObjectType)) {
            return activateHandlersByObjectTypeMap.get(this.currentObjectType);
        } else {
            return new Set<TriggerHandler>();
        }
    }

    @TestVisible
    private static Boolean isSelectiveMode() {
        return Test.isRunningTest() && !selectedHandlersByObjectTypeMap.isEmpty();
    }

    @TestVisible
    private static void enableObjectHandler(SObjectType objectType, String apexClassName) {
        if (Test.isRunningTest()) {
            TriggerHandler handler = new TriggerHandler(objectType, apexClassName);
            if (!selectedHandlersByObjectTypeMap.containsKey(handler.objectType)) {
                selectedHandlersByObjectTypeMap.put(handler.objectType, new Set<TriggerHandler>());
            }
            Set<TriggerHandler> objectHandlers = selectedHandlersByObjectTypeMap.get(handler.objectType);
            // Augment handler order incrementally;
            handler.order = objectHandlers.size() + 1;
            objectHandlers.add(handler);
        }
    }

    private void setAndValidateMaxLoopCount(TriggerHandler handler) {
        BasicTriggerHandler handlerImpl = handler.getInstance();
        if (!loopCountMap.containsKey(handler)) {
            loopCountMap.put(handler, new LoopCount(handlerImpl.getMaxLoopCount()));
        }
        loopCountMap.get(handler).increment();
        if (loopCountMap.get(handler).hasExceeded()) {
            throw new TriggerDispatcherException(String.format('Max loop count reached: {0}', Lists.of(handler.getName())));
        }
    }

    private static void debug(String message) {
        debug(message, new List<String>());
    }

    private static void debug(String template, List<String> params) {
        if (debugModeEnabled) {
            String logTemplate = String.format('\n\n ⚪ Trigger > [{0}]:', Lists.of(Trigger.operationType.name().toUpperCase()));
            Logger.debug(logTemplate + ' ' + String.format(template, params));
        }
    }

    private class TriggerHandler implements Comparable {
        private final SObjectType objectType;
        private final String apexClassName;
        private Integer order;
        private BasicTriggerHandler instance;

        private TriggerHandler(SObjectType objectType, String apexClassName) {
            this.objectType = objectType;
            this.apexClassName = apexClassName;
            this.order = 1;
        }

        private TriggerHandler(SObjectType objectType, String apexClassName, Integer order) {
            this(objectType, apexClassName);
            this.order = order;
        }

        private TriggerHandler(TriggerHandler__mdt handlerCmt) {
            this.objectType = ((SObject) Type.forName(handlerCmt.TargetObject__c).newInstance()).getSObjectType();
            this.apexClassName = handlerCmt.ApexClassName__c;
            this.order = (Integer) handlerCmt.Order__c;
        }

        private BasicTriggerHandler getInstance() {
            if (this.instance == null) {
                Type typeInfo = Type.forName(this.apexClassName);
                this.instance = (BasicTriggerHandler) typeInfo.newInstance();
            }
            return this.instance;
        }

        private Boolean isValid() {
            try {
                Type typeInfo = Type.forName(this.apexClassName);
                return BasicTriggerHandler.class.isAssignableFrom(typeInfo);
            } catch (Exception ex) {
                debug(ex.getMessage());
                debug(ex.getTypeName());
                debug(ex.getStackTraceString());
                return false;
            }
        }

        private String getName() {
            return String.format('{0}:{1}.cls', Lists.of(this.objectType.toString(), this.apexClassName));
        }

        public Boolean equals(Object obj) {
            TriggerHandler thatHandler = (TriggerHandler) obj;
            return this.objectType.equals(thatHandler.objectType) &&
                this.apexClassName.equalsIgnoreCase(thatHandler.apexClassName);
        }

        public override Integer hashCode() {
            return 31 * System.hashCode(this.objectType) + System.hashCode(this.apexClassName);
        }

        public Integer compareTo(Object obj) {
            TriggerHandler thatHandler = (TriggerHandler) obj;
            if (this.order < thatHandler.order) {
                return -1;
            } else if (this.order > thatHandler.order) {
                return 1;
            } else {
                return 0;
            }
        }
    }

    private class LoopCount {
        private final Integer max;
        private Integer count;

        private LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        private void increment() {
            this.count++;
        }

        private Boolean hasExceeded() {
            return this.max >= 0 && this.count > this.max;
        }
    }

    public class TriggerDispatcherException extends Exception {
    }
}
