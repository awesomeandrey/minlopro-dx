# Common / Reusable Modules

## FFLib

Open-source framework for Salesforce development.

Sources:

-   https://github.com/apex-enterprise-patterns/fflib-apex-common
-   https://github.com/apex-enterprise-patterns/fflib-apex-mocks

## Commons

Contains low-level methods / functions used during product development.

## Logger

Exposes custom means for Apex logs tracking/monitoring.
Originally inspired by https://github.com/rsoesemann/apex-unified-logging.

**How To Use**

0. Assign `LoggerUser.permissionset` to the running user.

1. Create the Apex class in the target org with the content below:

```
public with sharing class LoggerDemo implements Database.Batchable<Integer> {
    public void run() {
        Logger.debug('before');
        futureMethod();
        Logger.error('after 1={0} 2={1}', Lists.of('str1', 'str2'));
    }

    @Future
    public static void futureMethod() {
        Logger.debug('before');
        System.enqueueJob(new AQueueable());
        Logger.debug('after');
    }

    public List<Integer> start(Database.BatchableContext ctx) {
        Logger.debug();
        return new List<Integer>{ 1, 2, 3, 4 };
    }

    public void execute(Database.BatchableContext ctx, List<Integer> scope) {
        Logger.debug('first');
        Logger.error('second');
    }

    public void finish(Database.BatchableContext ctx) {
        Logger.debug('first');
        Logger.error('second');
    }

    public with sharing class AQueueable implements Queueable {
        public void execute(QueueableContext ctx) {
            Logger.debug('before');
            Database.executeBatch(new LoggerDemo(), 1);
            Logger.debug('after');
        }
    }
}
```

2. Configure `LogsMonitor.tab` visibility for the running user and navigate to it.

3. Create `LoggerSettings__c` custom setting record in the org with `LogsEmissionDate__c` field equal to `TODAY`.

4. Invoke `new LoggerDemo().run();` in ANONYMOUS Apex and observe the results!
