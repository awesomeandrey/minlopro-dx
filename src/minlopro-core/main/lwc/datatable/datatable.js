import LightningDatatable from 'lightning/datatable';
import { loadStyle } from 'lightning/platformResourceLoader';

// Global styles
import GLOBAL_STYLES from '@salesforce/resourceUrl/GlobalStyles';

// Templates
import comboboxTemplate from './templates/combobox.html';

export default class Datatable extends LightningDatatable {
    static customTypes = {
        combobox: {
            template: comboboxTemplate,
            standardCellLayout: true,
            typeAttributes: ['name', 'label', 'value', 'options', 'multi', 'required']
        }
    };

    constructor() {
        super();
        Promise.all([loadStyle(this, GLOBAL_STYLES + '/globalStyles.css')]).catch((error) => {
            console.error('Datatable.js', error);
        });
    }

    connectedCallback() {}
}
