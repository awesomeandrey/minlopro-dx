import LightningDatatable from 'lightning/datatable';
import { loadStyle } from 'lightning/platformResourceLoader';

// Global styles
import GLOBAL_STYLES from '@salesforce/resourceUrl/GlobalStyles';

// Templates

// Custom Combobox;
import customComboboxReadonlyTemplate from './templates/customCombobox/readonly.html';
import customComboboxEditableTemplate from './templates/customCombobox/editable.html';

// Custom Lookup;
import customLookupReadonlyTemplate from './templates/customLookup/readonly.html';
import customLookupEditableTemplate from './templates/customLookup/editable.html';

// Custom Picklist;
import customPicklistReadonlyTemplate from './templates/customPicklist/readonly.html';
import customPicklistEditableTemplate from './templates/customPicklist/editable.html';

// Custom Input;
import customInputReadonlyTemplate from './templates/customInput/readonly.html';
import customInputEditableTemplate from './templates/customInput/editable.html';

// Custom Badge;
import customBadgeReadonlyTemplate from './templates/customBadge/readonly.html';

// Custom Code Snippet;
import customCodeSnippetReadonlyTemplate from './templates/customCodeSnippet/readonly.html';

/**
 * Inspired by https://techdicer.com/picklist-in-lwc-datatable-inline-edit/
 * + https://techdicer.com/lookup-field-in-lwc-datatable-inline-edit/
 *
 * LWC docs - https://developer.salesforce.com/docs/platform/lwc/guide/data-table-custom-types-editable.html
 */
export default class Datatable extends LightningDatatable {
    // Grace period. Previous state >>> static COMMON_TYPE_ATTRIBUTES = ['value', 'fieldName', 'context', 'required'];
    static COMMON_TYPE_ATTRIBUTES = ['fieldName', 'context', 'required'];
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
            typeAttributes: [...this.COMMON_TYPE_ATTRIBUTES, 'objectApiName', 'recordTypeId', 'recordInfo']
        },
        customLookup: {
            template: customLookupReadonlyTemplate,
            editTemplate: customLookupEditableTemplate,
            standardCellLayout: true,
            typeAttributes: [...this.COMMON_TYPE_ATTRIBUTES, 'objectApiName', 'displayInfo', 'matchingInfo', 'nameFieldPath']
        },
        customInput: {
            template: customInputReadonlyTemplate,
            editTemplate: customInputEditableTemplate,
            standardCellLayout: true,
            typeAttributes: [...this.COMMON_TYPE_ATTRIBUTES]
        },
        customBadge: {
            template: customBadgeReadonlyTemplate,
            editTemplate: null,
            standardCellLayout: true
        },
        customCodeSnippet: {
            template: customCodeSnippetReadonlyTemplate,
            editTemplate: null,
            standardCellLayout: true
        }
    };

    constructor() {
        super();
        Promise.all([loadStyle(this, GLOBAL_STYLES + '/globalStyles.css')]).catch((error) => {
            console.error('Datatable.js', error);
        });
    }
}
