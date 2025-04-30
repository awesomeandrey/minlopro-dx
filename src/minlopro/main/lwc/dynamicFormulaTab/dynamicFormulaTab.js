import { LightningElement, track } from 'lwc';
import { cloneObject, isNotEmpty, parseError, resolveRecordId } from 'c/utilities';

// Modal;
import ModalFieldPathSelection from 'c/modalFieldPathSelection';

// Apex Controller Methods;
import evaluateApex from '@salesforce/apex/DynamicFormulaController.evaluate';

export default class DynamicFormulaTab extends LightningElement {
    @track selectedObjectType = null;
    @track selectedRecordId = null;
    @track formulaExpression = null;
    @track formulaReturnType = null;
    @track formulaResult = null;
    @track loading = false;
    @track errorObj = null;

    get objectTypeOptions() {
        return [
            { label: 'Account', value: 'Account' },
            { label: 'Lead', value: 'Lead' },
            { label: 'User', value: 'User' }
        ];
    }

    get selectedObjectTypeLookupSettings() {
        switch (this.selectedObjectType) {
            case 'Account':
                return {
                    label: 'Account',
                    placeholder: 'Select Account Record',
                    displayInfo: {
                        additionalFields: ['Phone']
                    },
                    matchingInfo: {
                        primaryField: { fieldPath: 'Name' },
                        additionalFields: [{ fieldPath: 'Phone' }]
                    }
                };
            case 'Lead':
                return {
                    label: 'Lead',
                    placeholder: 'Select Lead Record',
                    displayInfo: {
                        additionalFields: ['Email']
                    },
                    matchingInfo: {
                        primaryField: { fieldPath: 'Name' },
                        additionalFields: [{ fieldPath: 'Email' }]
                    }
                };
            case 'User':
                return {
                    label: 'User',
                    placeholder: 'Select User Record',
                    displayInfo: {
                        additionalFields: ['Username']
                    },
                    matchingInfo: {
                        primaryField: { fieldPath: 'Name' },
                        additionalFields: [{ fieldPath: 'Username' }]
                    }
                };
            default:
                throw new Error(`Unsupported object type ${this.selectedObjectType}`);
        }
    }

    get hasSelectedRecord() {
        return isNotEmpty(this.selectedRecordId);
    }

    get formulaExpressionInputLabel() {
        return `[${this.selectedObjectType}] Formula Expression`.toUpperCase();
    }

    get formulaReturnTypeInputLabel() {
        return `[${this.selectedObjectType}] Formula Return Type`.toUpperCase();
    }

    get formulaResultOutputLabel() {
        return `[${this.selectedObjectType}] Formula Result`.toUpperCase();
    }

    get formulaReturnTypeOptions() {
        return ['STRING', 'BOOLEAN', 'DATE', 'DATETIME', 'DECIMAL', 'DOUBLE', 'ID', 'INTEGER', 'LONG', 'TIME'].map((t) => ({
            label: t,
            value: t
        }));
    }

    get doDisableFormulaInputs() {
        return this.loading || !this.hasSelectedRecord;
    }

    get hasFormulaResult() {
        return isNotEmpty(this.formulaResult);
    }

    get hasError() {
        return isNotEmpty(this.errorObj);
    }

    constructor() {
        super();
        this.reset();
        this.selectedRecordId = resolveRecordId('${SF_SAMPLE_ACCOUNT_ID}');
    }

    errorCallback(error, stack) {
        console.error('DynamicFormulaTab.js', error, stack);
        this.errorObj = parseError(error);
    }

    // Event Handlers;

    handleSelectObjectType(event) {
        this.reset();
        this.selectedObjectType = event.detail['value'];
    }

    handleSelectRecord(event) {
        this.selectedRecordId = event.detail['recordId'];
    }

    handleReset() {
        this.reset();
    }

    handleChangeFormula(event) {
        this.formulaExpression = event.detail['value'];
        this.refs.formulaInput.setCustomValidity('');
    }

    handleSelectFormulaReturnType(event) {
        this.formulaReturnType = event.detail['value'];
    }

    async handleEvaluateFormula(event) {
        this.refs.formulaInput.reportValidity();
        if (!this.refs.formulaInput.checkValidity()) {
            return;
        }
        this.loading = true;
        this.errorObj = null;
        this.formulaResult = null;
        try {
            const formulaInputs = {
                record: { sobjectType: this.selectedObjectType, Id: this.selectedRecordId },
                formulaReturnTypeName: this.formulaReturnType,
                formulaExpression: this.formulaExpression
            };
            console.table(cloneObject(formulaInputs));
            this.formulaResult = cloneObject(await evaluateApex({ formulaInputs })) + ''; // Cast to string type;
        } catch (error) {
            this.errorObj = parseError(error);
        } finally {
            this.loading = false;
        }
    }

    async handleSelectFieldPath(event) {
        const { selectedFieldPath } =
            (await ModalFieldPathSelection.open({
                size: 'medium',
                disableClose: false,
                objectType: this.selectedObjectType
            })) || {};
        if (isNotEmpty(selectedFieldPath)) {
            this.refs.formulaInput.setRangeText(selectedFieldPath);
        }
    }

    reset() {
        this.selectedObjectType = 'Account';
        this.selectedRecordId = null;
        this?.refs?.recordPicker.clearSelection();
        this.formulaExpression = null;
        this.formulaReturnType = 'STRING';
        this.formulaResult = null;
        this.errorObj = null;
        this.loading = false;
    }
}
