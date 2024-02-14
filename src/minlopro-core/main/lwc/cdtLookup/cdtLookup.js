import { api, track, wire } from 'lwc';
import DatatableEditableCdt from 'c/datatableEditableCdt';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { wait } from 'c/utilities';

export default class CdtLookup extends NavigationMixin(DatatableEditableCdt) {
    @api context;
    @api fieldName;
    @api value;
    @api objectApiName;
    @api required = false;
    @api displayInfo = null;
    @api matchingInfo = null;
    @api readOnly = false;
    @api nameFieldPath = null;

    @api get validity() {
        if (this.isInputMode) {
            let recordPicker = this.refs.recordPicker;
            return { valid: recordPicker?.validity?.valid || recordPicker.reportValidity() };
        }
        return { valid: true };
    }

    get wiredFields() {
        return [`${this.objectApiName}.${this.nameFieldPath || 'Name'}`];
    }

    get recordName() {
        if (!!this.value) {
            return getFieldValue(this.wiredRecord?.data, this.wiredFields[0]) || Symbol.for(undefined);
        } else {
            return null;
        }
    }

    get recordLink() {
        return !!this.value ? `/${this.value}` : null;
    }

    get isInputMode() {
        return this.readOnly === false;
    }

    get normalizedDisplayInfo() {
        try {
            return JSON.parse(this.displayInfo);
        } catch (error) {
            return null;
        }
    }

    get normalizedMatchingInfo() {
        try {
            return JSON.parse(this.matchingInfo);
        } catch (error) {
            return null;
        }
    }

    get doShowSpinner() {
        return !!this.value && this.recordName === Symbol.for(undefined);
    }

    @wire(getRecord, { recordId: '$value', fields: '$wiredFields' })
    wiredRecord = {};

    @track hasRendered = false;
    @track boundEscapeFromWindowClick = this.escapeFromWindowClick.bind(this);

    constructor() {
        super();
        this.cdtClassName = 'CdtLookup';
        this.debugModeEnabled = false;
    }

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
        const isValid = this.refs.recordPicker.reportValidity();
        if (isValid) {
            this.notify();
            this.escape();
        }
    }

    handleLookupError(event) {
        console.error('CdtLookup.js', `handleLookupError() | ${JSON.stringify(event.detail)}`);
        const { error } = event.detail;
        this.notifyError(error);
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
                this.notifyError(error);
            });
    }

    // Service Methods;

    escapeFromWindowClick(event) {
        this.debugModeEnabled && console.log('CdtLookup.js | escapeFromWindowClick()', JSON.stringify(event.detail));
        this.escape();
    }
}
