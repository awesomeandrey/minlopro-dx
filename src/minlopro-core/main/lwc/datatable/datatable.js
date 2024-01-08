import LightningDatatable from 'lightning/datatable';
import { loadStyle } from 'lightning/platformResourceLoader';

// Global styles
import GLOBAL_STYLES from '@salesforce/resourceUrl/GlobalStyles';

// Templates

// Custom LWC combobox;
import customComboboxReadonlyTemplate from './templates/customCombobox/readonly.html';
import customComboboxEditableTemplate from './templates/customCombobox/editable.html';

// Custom Lookup;
import customLookupReadonlyTemplate from './templates/customLookup/readonly.html';
import customLookupEditableTemplate from './templates/customLookup/editable.html';

// Custom Picklist;
import customPicklistReadonlyTemplate from './templates/customPicklist/readonly.html';
import customPicklistEditableTemplate from './templates/customPicklist/editable.html';

/**
 * Inspired by https://techdicer.com/picklist-in-lwc-datatable-inline-edit/
 * + https://techdicer.com/lookup-field-in-lwc-datatable-inline-edit/
 *
 * LWC docs - https://developer.salesforce.com/docs/platform/lwc/guide/data-table-custom-types-editable.html
 */
export default class Datatable extends LightningDatatable {
    static COMMON_TYPE_ATTRIBUTES = ['value', 'fieldName', 'context', 'required'];
    static customTypes = {
        customCombobox: {
            template: customComboboxReadonlyTemplate,
            editTemplate: customComboboxEditableTemplate,
            standardCellLayout: true,
            typeAttributes: [...this.COMMON_TYPE_ATTRIBUTES, 'options', 'multi']
        },
        customPicklist: {
            template: customPicklistReadonlyTemplate,
            editTemplate: customPicklistEditableTemplate,
            standardCellLayout: true,
            typeAttributes: [...this.COMMON_TYPE_ATTRIBUTES, 'objectApiName', 'recordTypeId']
        },
        customLookup: {
            template: customLookupReadonlyTemplate,
            editTemplate: customLookupEditableTemplate,
            standardCellLayout: true,
            typeAttributes: [...this.COMMON_TYPE_ATTRIBUTES, 'objectApiName', 'displayInfo', 'matchingInfo']
        }
    };

    constructor() {
        super();
        Promise.all([loadStyle(this, GLOBAL_STYLES + '/globalStyles.css')]).catch((error) => {
            console.error('Datatable.js', error);
        });
    }
}
