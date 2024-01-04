import LightningDatatable from 'lightning/datatable';
import { loadStyle } from 'lightning/platformResourceLoader';

// Global styles
import GLOBAL_STYLES from '@salesforce/resourceUrl/GlobalStyles';

// Templates

// Base LWC combobox;
import baseComboboxReadonlyTemplate from './templates/baseCombobox/readonly.html';
import baseComboboxEditableTemplate from './templates/baseCombobox/editable.html';

// Custom LWC combobox;
import customComboboxReadonlyTemplate from './templates/customCombobox/readonly.html';
import customComboboxEditableTemplate from './templates/customCombobox/editable.html';

// Custom Lookup;
import customLookupReadonlyTemplate from './templates/customLookup/readonly.html';
import customLookupEditableTemplate from './templates/customLookup/editable.html';

/**
 * Inspired by https://techdicer.com/picklist-in-lwc-datatable-inline-edit/
 * + https://techdicer.com/lookup-field-in-lwc-datatable-inline-edit/
 */
export default class Datatable extends LightningDatatable {
    static COMMON_TYPE_ATTRIBUTES = ['value', 'fieldName', 'context', 'editable'];
    static customTypes = {
        baseCombobox: {
            template: baseComboboxReadonlyTemplate,
            editTemplate: baseComboboxEditableTemplate,
            standardCellLayout: true,
            typeAttributes: [...this.COMMON_TYPE_ATTRIBUTES, 'options']
        },
        customCombobox: {
            template: customComboboxReadonlyTemplate,
            editTemplate: customComboboxEditableTemplate,
            standardCellLayout: true,
            typeAttributes: [...this.COMMON_TYPE_ATTRIBUTES, 'options', 'multi']
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
