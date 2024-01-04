import { LightningElement, api, track } from 'lwc';
import { wait } from 'c/utilities';

export default class CdtCombobox extends LightningElement {
    @api context = null;
    @api fieldName = null;
    @api value = null;
    @api options = [];
    @api multi = false;

    @api get validity() {
        /**
         * LWC datatable component requires this property since its referenced
         * in underlying processing (see 'processInlineEditFinish()' method in base LWC 'datatable.js').
         */
        return { valid: true };
    }

    @track debugModeEnabled = false; // Turn on/off to identify bottlenecks;
    @track hasRendered = false;
    @track hasChanged = false;

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
        // Notify parent datatable LWC;
        if (this.hasChanged) {
            this.notify();
        }
        // Close cell edit panel;
        this.escape();
    }

    // Service Methods;

    escape() {
        this.debugModeEnabled && console.log('CdtCombobox.js | escape()');
        this.dispatchEvent(
            new CustomEvent('ieditfinished', {
                composed: true,
                bubbles: true,
                cancelable: false,
                detail: {
                    reason: 'lost-focus',
                    rowKeyValue: this.context,
                    colKeyValue: 'unknown'
                }
            })
        );
    }

    notify() {
        this.debugModeEnabled && console.log('CdtCombobox.js | notify()');
        // Force changes updated;
        this.dispatchEvent(
            new CustomEvent('cellchange', {
                composed: true,
                bubbles: true,
                cancelable: true,
                detail: {
                    draftValues: [
                        {
                            ['context']: this.context,
                            [this.fieldName]: this.value
                        }
                    ]
                }
            })
        );
    }
}
