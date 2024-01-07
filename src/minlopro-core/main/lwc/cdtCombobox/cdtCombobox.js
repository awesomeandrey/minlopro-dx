import { api, track } from 'lwc';
import DatatableEditableCdt from 'c/datatableEditableCdt';
import { wait } from 'c/utilities';

export default class CdtCombobox extends DatatableEditableCdt {
    @api context = null;
    @api fieldName = null;
    @api value = null;
    @api required = false;
    @api options = [];
    @api multi = false;

    @api get validity() {
        return this.refs.combobox.validity;
    }

    @api
    showHelpMessageIfInvalid() {
        this.refs.combobox.showHelpMessageIfInvalid();
    }

    @track hasRendered = false;
    @track hasChanged = false;

    constructor() {
        super();
        this.cdtClassName = 'CdtCombobox';
        this.debugModeEnabled = false;
    }

    renderedCallback() {
        this.debugModeEnabled && console.log('CdtCombobox.js | renderedCallback()');
        if (!this.hasRendered) {
            this.hasRendered = true;
            wait(() => {
                this.debugModeEnabled && console.log('CdtCombobox.js | open combobox');
                this.refs.combobox?.open();
            }, 500);
        }
    }

    handleChange(event) {
        this.debugModeEnabled && console.log('CdtCombobox.js | handleChange()');
        event.stopPropagation();
        const { value } = event.detail;
        this.value = value;
        this.hasChanged = true;
    }

    handleClose(event) {
        this.debugModeEnabled && console.log('CdtCombobox.js | handleClose()');
        if (!this.hasChanged) {
            this.escape();
        } else {
            const isValid = this.refs.combobox.reportValidity();
            if (isValid) {
                this.notify();
                this.escape();
            }
        }
    }
}
