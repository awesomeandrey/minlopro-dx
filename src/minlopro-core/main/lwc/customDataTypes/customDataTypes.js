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
 * Shared custom data type definitions for lightning/datatable & lightning/treeGrid extensions (c-datatable, c-tree-grid).
 *
 * Inspired by https://techdicer.com/picklist-in-lwc-datatable-inline-edit/
 * + https://techdicer.com/lookup-field-in-lwc-datatable-inline-edit/
 *
 * LWC docs - https://developer.salesforce.com/docs/platform/lwc/guide/data-table-custom-types-editable.html
 * Tree grid docs - https://developer.salesforce.com/docs/platform/lwc/guide/tree-grid-custom-types.html
 */
export const COMMON_TYPE_ATTRIBUTES = ['fieldName', 'context', 'required'];

export const customTypes = {
    customCombobox: {
        template: customComboboxReadonlyTemplate,
        editTemplate: customComboboxEditableTemplate,
        standardCellLayout: true,
        typeAttributes: [...COMMON_TYPE_ATTRIBUTES, 'options', 'multi']
    },
    customPicklist: {
        template: customPicklistReadonlyTemplate,
        editTemplate: customPicklistEditableTemplate,
        standardCellLayout: true,
        typeAttributes: [...COMMON_TYPE_ATTRIBUTES, 'objectApiName', 'recordTypeId', 'recordInfo']
    },
    customLookup: {
        template: customLookupReadonlyTemplate,
        editTemplate: customLookupEditableTemplate,
        standardCellLayout: true,
        typeAttributes: [...COMMON_TYPE_ATTRIBUTES, 'objectApiName', 'displayInfo', 'matchingInfo', 'nameFieldPath']
    },
    customInput: {
        template: customInputReadonlyTemplate,
        editTemplate: customInputEditableTemplate,
        standardCellLayout: true,
        typeAttributes: [...COMMON_TYPE_ATTRIBUTES]
    },
    customBadge: {
        template: customBadgeReadonlyTemplate,
        editTemplate: null,
        standardCellLayout: true,
        typeAttributes: [...COMMON_TYPE_ATTRIBUTES, 'variant']
    },
    customCodeSnippet: {
        template: customCodeSnippetReadonlyTemplate,
        editTemplate: null,
        standardCellLayout: true
    }
};
