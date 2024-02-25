import { api, track, wire } from 'lwc';
import DatatableEditableCdt from 'c/datatableEditableCdt';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { wait } from 'c/utilities';

export default class CdtLookup extends NavigationMixin(DatatableEditableCdt) {
    @api context;
    @api fieldName;
    @api value;
    @api wrapText = false;
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

    get $focusedInput() {
        return this.refs.recordPicker;
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

    connectedCallback() {
        super.log(this.connectedCallback);
    }

    renderedCallback() {
        super.log(this.renderedCallback);
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
                    super.log('focus record picker');
                    this.refs.recordPicker?.focus();
                }, 500);
            }
        }
    }

    disconnectedCallback() {
        super.log(this.disconnectedCallback);
        window.removeEventListener('click', this.boundEscapeFromWindowClick);
    }

    handleLookupChange(event) {
        super.log(this.handleLookupChange, event.detail);
        // Extract lookup record ID;
        const { recordId } = event.detail;
        if (recordId !== null) {
            this.value = recordId;
        }
    }

    handleLookupBlur(event) {
        super.log(this.handleLookupBlur, this.context);
    }

    handleClickContainer(event) {
        super.log(this.handleClickContainer, this.context);
        event.stopPropagation();
    }

    handleClearAndEscape(event) {
        super.log(this.handleClearAndEscape);
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
        super.log(this.handleLookupError, event.detail);
        const { error } = event.detail;
        this.notifyError(error);
    }

    handleNavigate(event) {
        super.log(this.handleNavigate);
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
        super.log(this.escapeFromWindowClick, event.detail);
        this.escape();
    }
}
