# Core / Base Modules

## Re-usable Lightning Web Components

- `bridge.js` - used for communication between components (based off of LMS)
- `c-combobox` - custom LWC that extends base `lightning-combobox` LWC
- `c-datatable` - extension of base `lightning-datatable` LWC that supports editable lookups & picklists
- `customDataTypes.js` - shared custom data type definitions (combobox, lookup, picklist, input, badge, code snippet), consumed by `c-datatable` via its `customTypes` static property
- `c-custom-data-types-provider` - slots the same `customDataTypes.js` definitions into any **unextended** base `lightning-datatable`/`lightning-tree-grid` via its `customdatatypes` slot (no subclassing required); see `c-log-monitor`'s "Level" column for a working example. Note: extending `lightning-tree-grid` directly (the `lightning-datatable` pattern) does not work as of this writing — `lightning/treeGrid` does not expose a subclassable class in this org, so the slot-provider approach is the only working route for tree-grid custom types
- `c-stencil-skeleton` - UI LWC that improves UX while component is loading
- `toastify.js` - utility module that facades API around toast notifications
- `utilities.js` - boilerplate JS functions

[Check out `c-datatable` with Custom Data Types](https://youtu.be/DvqtHMrvp8k)

Features:

- CDT for _Lookup_
- CDT for _Picklist (Single/Multi)_
- CDT for _Dependent Picklist (Single/Multi)_
- CDT for _Custom Combobox (with icons & 'fixed' mode)_

| Datatable                                                                                                                        | Lookup CDT                                                               | Picklist CDT                                                               |
| -------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | -------------------------------------------------------------------------- |
| [![Datatable Extension Demo](../../assets/demo/lwc/datatableContacts/datatable_contacts_demo.png)](https://youtu.be/DvqtHMrvp8k) | ![Alt](../../assets/demo/lwc/datatableContacts/datatable_CDT_lookup.png) | ![Alt](../../assets/demo/lwc/datatableContacts/datatable_CDT_picklist.png) |

## FFLib

Open-source framework for Salesforce development.

Sources:

- https://github.com/apex-enterprise-patterns/fflib-apex-common
- https://github.com/apex-enterprise-patterns/fflib-apex-mocks

## Logger

Exposes custom means for Apex logs tracking/monitoring.
Originally inspired by https://github.com/rsoesemann/apex-unified-logging.

![Log Monitor](../../assets/demo/lwc/logMonitor/logMonitor_demo.png)

**How To Use**

1. Assign `Minlopro_Logger.permissionset` to the running user.
2. Configure `LogsMonitor.tab` visibility for the running user and navigate to it.
3. Create `LoggerSettings__c` custom setting record in the org with `LogsEmissionDate__c` field equal to `TODAY`.
4. Invoke `new LoggerDemo().run();` in ANONYMOUS Apex and observe the results!
