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

    @api showHelpMessageIfInvalid() {
        this.refs.combobox.showHelpMessageIfInvalid();
    }

    @api focus() {
        this.refs.combobox.focus();
    }

    get $focusedInput() {
        return this.refs.combobox;
    }

    @track hasRendered = false;
    @track hasChanged = false;

    renderedCallback() {
        super.log(this.renderedCallback);
        if (!this.hasRendered) {
            this.hasRendered = true;
            wait(() => {
                super.log('open combobox');
                this.refs.combobox?.focus();
                this.refs.combobox?.open();
            }, 500);
        }
    }

    handleChange(event) {
        super.log(this.handleChange);
        event.stopPropagation();
        const { value } = event.detail;
        this.value = value;
        this.hasChanged = true;
        this.notify();
    }

    handleClose() {
        super.log(this.handleClose);
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
