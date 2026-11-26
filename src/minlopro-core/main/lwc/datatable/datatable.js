import LightningDatatable from 'lightning/datatable';
import { loadStyle } from 'lightning/platformResourceLoader';
import { customTypes } from 'c/customDataTypes';

// Global styles
import GLOBAL_STYLES from '@salesforce/resourceUrl/GlobalStyles';

/**
 * Custom data types are defined in `c/customDataTypes` (shared with `c-tree-grid`).
 *
 * Inspired by https://techdicer.com/picklist-in-lwc-datatable-inline-edit/
 * + https://techdicer.com/lookup-field-in-lwc-datatable-inline-edit/
 *
 * LWC docs - https://developer.salesforce.com/docs/platform/lwc/guide/data-table-custom-types-editable.html
 */
export default class Datatable extends LightningDatatable {
    static customTypes = customTypes;

    constructor() {
        super();
        Promise.all([loadStyle(this, GLOBAL_STYLES + '/globalStyles.css')]).catch((error) => {
            console.error('Datatable.js', error);
        });
    }
}
