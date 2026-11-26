import { LightningElement, api } from 'lwc';
import { customTypes } from 'c/customDataTypes';

/**
 * Dynamic custom-type provider for base `lightning-datatable` / `lightning-tree-grid`.
 * Slot this into either base component (slot="customdatatypes") to reuse the same
 * type definitions as `c-datatable`, without needing to extend the base component's class.
 *
 * LWC docs - https://developer.salesforce.com/docs/platform/lwc/guide/tree-grid-custom-types.html
 */
export default class CustomDataTypesProvider extends LightningElement {
    @api
    getDataTypes() {
        return customTypes;
    }
}
