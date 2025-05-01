public inherited sharing class TriggerDispatcher {
    // Static properties;
    private static final Map<SObjectType, Set<TriggerHandler>> activeHandlersByObjectTypeMap {
        get {
            if (activeHandlersByObjectTypeMap == null) {
                activeHandlersByObjectTypeMap = new Map<SObjectType, Set<TriggerHandler>>();
                for (TriggerHandler__mdt handlerCmt : [
                    SELECT Id, TargetObject__c, ApexClassName__c, Order__c, Active__c
                    FROM TriggerHandler__mdt
                    WHERE Active__c = TRUE
                    ORDER BY Order__c ASC
                ]) {
                    TriggerHandler handlerItem = new TriggerHandler(handlerCmt);
                    if (!activeHandlersByObjectTypeMap.containsKey(handlerItem.objectType)) {
                        activeHandlersByObjectTypeMap.put(handlerItem.objectType, new Set<TriggerHandler>());
                    }
                    activeHandlersByObjectTypeMap.get(handlerItem.objectType).add(handlerItem);
                }
            }
            return activeHandlersByObjectTypeMap;
        }
        set;
    }
    private static final Map<SObjectType, Set<TriggerHandler>> selectedHandlersByObjectTypeMap = new Map<SObjectType, Set<TriggerHandler>>();
    private static final Map<TriggerHandler, LoopCount> loopCountMap = new Map<TriggerHandler, LoopCount>();
    private static final Set<TriggerHandler> bypassedHandlers = new Set<TriggerHandler>();
    // Turn off for production;
    public static Boolean debugModeEnabled = false;

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
            this.debug('Trigger context was not matched!');
            return;
        }
        List<TriggerHandler> objectHandlers = new List<TriggerHandler>(this.getObjectHandlers());
        objectHandlers.sort();
        this.debug('Loaded {0} trigger handlers.', Lists.of(String.valueOf(objectHandlers.size())));
        Iterator<TriggerHandler> handlersIterator = objectHandlers.iterator();
        while (handlersIterator.hasNext()) {
            TriggerHandler handlerToExecute = handlersIterator.next();
            if (!handlerToExecute.isValid()) {
                // Verify that the Apex implementation is valid;
                throw new TriggerDispatcherException(
                    String.format('Invalid handler implementation detected: {0}', Lists.of(handlerToExecute.getName()))
                );
            } else if (bypassedHandlers.contains(handlerToExecute)) {
                this.debug('Bypassing trigger handler: {0}.', Lists.of(handlerToExecute.getName()));
                // Bypass particular handler;
                continue;
            } else {
                this.debug('Running "{0}" trigger handler.', Lists.of(handlerToExecute.getName()));
                // Validate max loop count;
                this.setAndValidateMaxLoopCount(handlerToExecute);
                // Execute trigger handler logic according to trigger phase;
                BasicTriggerHandler handlerImpl = handlerToExecute.getInstance();
                handlerImpl.setObjectType(this.currentObjectType);
                switch on Trigger.operationType {
                    when BEFORE_DELETE {
                        handlerImpl.beforeDelete(Trigger.old);
                    }
                    when BEFORE_INSERT {
                        handlerImpl.beforeInsert(Trigger.new);
                    }
                    when BEFORE_UPDATE {
                        handlerImpl.beforeUpdate(Trigger.oldMap, Trigger.newMap);
                    }
                    when AFTER_DELETE {
                        handlerImpl.afterDelete(Trigger.old);
                    }
                    when AFTER_INSERT {
                        handlerImpl.afterInsert(Trigger.new);
                    }
                    when AFTER_UNDELETE {
                        handlerImpl.afterUndelete(Trigger.new);
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
        } else if (activeHandlersByObjectTypeMap.containsKey(this.currentObjectType)) {
            return activeHandlersByObjectTypeMap.get(this.currentObjectType);
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
            Integer loopCounterValue = loopCountMap.get(handler).count;
            throw new TriggerDispatcherException(
                String.format(
                    'Max loop count reached: {0} ({1} iterations)',
                    Lists.of(handler.getName(), loopCounterValue.toString())
                )
            );
        }
    }

    private void debug(String message) {
        this.debug(message, new List<String>());
    }

    private void debug(String template, List<String> params) {
        if (debugModeEnabled) {
            String logTemplate = String.format(
                '⚪ Trigger on [{0} > {1}] | ',
                Lists.of(this.currentObjectType.toString(), Trigger.operationType.name().toUpperCase())
            );
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
            Type dynamicType = Type.forName(this.apexClassName);
            return dynamicType == null ? false : BasicTriggerHandler.class.isAssignableFrom(dynamicType);
        }

        private String getName() {
            return String.format('{0}.cls', Lists.of(this.apexClassName));
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
