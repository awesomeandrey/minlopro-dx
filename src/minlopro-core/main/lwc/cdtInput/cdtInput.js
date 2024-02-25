import { api } from 'lwc';
import DatatableEditableCdt from 'c/datatableEditableCdt';
import { wait } from 'c/utilities';

export default class CdtInput extends DatatableEditableCdt {
    @api context = null;
    @api fieldName = null;
    @api value = null;
    @api readOnly = false;

    @api get validity() {
        return super.validity;
    }

    get $focusedInput() {
        /**
         * Intentionally set to 'null' in order to demonstrate internal 'ieditfinished' event usage.
         */
        return null;
    }

    connectedCallback() {
        wait(() => {
            this.refs.input.focus();
        }, 100);
    }

    handleChange(event) {
        super.log(this.handleChange);
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
        const { value } = event.detail;
        this.value = value;
        this.notify();
    }

    handleEscape() {
        super.log(this.handleEscape);
        this.escape();
    }
}
