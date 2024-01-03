import LightningDatatable from 'lightning/datatable';
import { loadStyle } from 'lightning/platformResourceLoader';

// Global styles
import GLOBAL_STYLES from '@salesforce/resourceUrl/GlobalStyles';

// Templates

// Combobox based on custom LWC;
import baseComboboxReadonlyTemplate from './templates/baseCombobox/readonly.html';
import baseComboboxEditableTemplate from './templates/baseCombobox/editable.html';

// Combobox based on base LWC;
import customComboboxTemplate from './templates/customCombobox/combobox.html';

/**
 * Inspired by https://techdicer.com/picklist-in-lwc-datatable-inline-edit/
 * + https://techdicer.com/lookup-field-in-lwc-datatable-inline-edit/
 */
export default class Datatable extends LightningDatatable {
    static customTypes = {
        baseCombobox: {
            template: baseComboboxReadonlyTemplate,
            editTemplate: baseComboboxEditableTemplate,
            standardCellLayout: true,
            typeAttributes: ['value', 'options', 'context']
        },
        customCombobox: {
            template: customComboboxTemplate,
            editTemplate: undefined,
            standardCellLayout: false,
            typeAttributes: ['value', 'options', 'multi', 'fieldName', 'editable', 'context']
        }
    };

    /**
     * Note: 'constructor()' / 'connectedCallback()' overrides affect Lightning Datatable component
     * capabilities (such as columns resizing)!
     */

    // constructor() {
    //     super();
    //     Promise.all([loadStyle(this, GLOBAL_STYLES + '/globalStyles.css')]).catch((error) => {
    //         console.error('Datatable.js', error);
    //     });
    // }
    //
    // connectedCallback() {}
}
