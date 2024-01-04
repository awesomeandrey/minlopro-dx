import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldDisplayValue, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { wait } from 'c/utilities';

export default class CdtLookup extends NavigationMixin(LightningElement) {
    @api context;
    @api fieldName;
    @api value;
    @api objectApiName;
    @api displayInfo = {};
    @api matchingInfo = {};
    @api readOnly = false;

    @api get validity() {
        /**
         * LWC datatable component requires this property since its referenced
         * in underlying processing (see 'processInlineEditFinish()' method in base LWC 'datatable.js').
         */
        return { valid: true };
    }

    get wiredFields() {
        return [`${this.objectApiName}.Name`];
    }

    get recordName() {
        if (!!this.value) {
            return (
                getFieldDisplayValue(this.wiredRecord?.data, this.wiredFields[0]) ||
                getFieldValue(this.wiredRecord?.data, this.wiredFields[0])
            );
        } else {
            return '';
        }
    }

    get recordLink() {
        return !!this.value ? `/${this.value}` : null;
    }

    get isInputMode() {
        return this.readOnly === false;
    }

    @wire(getRecord, { recordId: '$value', fields: '$wiredFields' })
    wiredRecord = {};

    @track debugModeEnabled = false; // Turn on/off to identify bottlenecks;
    @track hasRendered = false;
    @track boundEscapeFromWindowClick = this.escapeFromWindowClick.bind(this);

    connectedCallback() {
        this.debugModeEnabled && console.log('CdtLookup.js | connectedCallback()');
    }

    renderedCallback() {
        this.debugModeEnabled && console.log('CdtLookup.js | renderedCallback()');
        window.removeEventListener('click', this.boundEscapeFromWindowClick);
        if (this.isInputMode) {
            wait(() => {
                window.addEventListener('click', this.boundEscapeFromWindowClick, { once: true });
            });
        }
        if (!this.hasRendered) {
            this.hasRendered = true;
            if (this.isInputMode) {
                wait(() => {
                    this.debugModeEnabled && console.log('CdtLookup.js | focus record picker');
                    this.refs.recordPicker?.focus();
                }, 500);
            }
        }
    }

    handleLookupChange(event) {
        this.debugModeEnabled && console.log('CdtLookup.js | handleLookupChange()', JSON.stringify(event.detail));
        // Extract lookup record ID;
        const { recordId } = event.detail;
        if (recordId !== null) {
            this.value = recordId;
        }
    }

    handleLookupBlur(event) {
        this.debugModeEnabled && console.log('CdtLookup.js | handleLookupBlur()', this.context);
    }

    handleClickContainer(event) {
        this.debugModeEnabled && console.log('CdtLookup.js | handleClickContainer()', this.context);
        event.stopPropagation();
    }

    handleClearAndEscape(event) {
        this.debugModeEnabled && console.log('CdtLookup.js | handleClearAndEscape()');
        event.preventDefault();
        this.refs.recordPicker?.clearSelection();
        this.value = null;
        this.notify();
        this.escape();
    }

    handleLookupError(event) {
        // TODO - throw custom error to parent datatable;
        console.error('CdtLookup.js', `handleLookupError() | ${JSON.stringify(event.detail)}`);
    }

    handleNavigate(event) {
        this.debugModeEnabled && console.log('CdtLookup.js | handleNavigate()');
        event.preventDefault();
        if (!this.value) {
            return;
        }
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.value,
                objectApiName: this.objectApiName,
                actionName: 'view'
            }
        })
            .then((url) => {
                window.open(url, '_blank').focus();
            })
            .catch((error) => {
                // TODO - throw custom error to parent datatable;
            });
    }

    // Service Methods;

    escapeFromWindowClick(event) {
        this.debugModeEnabled && console.log('CdtLookup.js | escapeFromWindowClick()', JSON.stringify(event.detail));
        this.escape();
    }

    escape() {
        this.debugModeEnabled && console.log('CdtLookup.js | escape()');
        if (this.isInputMode) {
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
    }

    notify() {
        this.debugModeEnabled && console.log('CdtLookup.js | notify()');
        if (this.isInputMode) {
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
}
