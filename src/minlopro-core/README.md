# Core / Base Modules

## FFLib

Open-source framework for Salesforce development.

Sources:

-   https://github.com/apex-enterprise-patterns/fflib-apex-common
-   https://github.com/apex-enterprise-patterns/fflib-apex-mocks

## Utilities

Contains low-level methods / functions used during product development.

## Logger

Exposes custom means for Apex logs tracking/monitoring.
Originally inspired by https://github.com/rsoesemann/apex-unified-logging.

**How To Use**

1. Assign `Minlopro_Logger.permissionset` to the running user.
2. Configure `LogsMonitor.tab` visibility for the running user and navigate to it.
3. Create `LoggerSettings__c` custom setting record in the org with `LogsEmissionDate__c` field equal to `TODAY`.
4. Invoke `new LoggerDemo().run();` in ANONYMOUS Apex and observe the results!
