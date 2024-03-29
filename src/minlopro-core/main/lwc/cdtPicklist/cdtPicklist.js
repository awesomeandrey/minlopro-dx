import { api, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import DatatableEditableCdt from 'c/datatableEditableCdt';
import { isNotEmpty, isEmpty, cloneObject, isEmptyArray, wait } from 'c/utilities';

export default class CdtPicklist extends DatatableEditableCdt {
    @api context = null;
    @api fieldName = null;
    @api value = null;
    @api wrapText = false;
    @api objectApiName = null;
    @api recordTypeId = null;
    @api readOnly = false;
    /**
     * Function with bound context to parent datatable instance.
     * Make sure this property is included for dependent picklists!
     * @type {function}
     */
    @api recordInfo;

    @api get validity() {
        return this.refs.cdtCombobox?.validity;
    }

    get $focusedInput() {
        return this.refs.cdtCombobox;
    }

    get targetRecordTypeId() {
        if (isNotEmpty(this.recordTypeId) && this.recordTypeInfos?.hasOwnProperty(this.recordTypeId)) {
            // `recordTypeId` value corresponds to record type for context object;
            return this.recordTypeId;
        } else if (isEmpty(this.recordTypeId) && isNotEmpty(this.defaultRecordTypeId)) {
            // `recordTypeId` is empty but there is default record type available;
            return this.defaultRecordTypeId;
        } else {
            // Return MASTER record type ID;
            const recordTypes = Object.values(this.recordTypeInfos);
            return recordTypes.find(({ master = false }) => master === true)?.recordTypeId;
        }
    }

    get fieldPath() {
        return [this.objectApiName, this.fieldName].join('.');
    }

    get doShowSpinner() {
        return isEmptyArray(this.options);
    }

    get isEditMode() {
        return this.readOnly === false;
    }

    get isDependent() {
        return isNotEmpty(this.controllerFieldName) && !isEmptyArray(Object.keys(this.controllerValuesMapping));
    }

    get controllerFieldValue() {
        if (this.isDependent && typeof this.recordInfo === 'function') {
            return (this.recordInfo(this.context) || {})[this.controllerFieldName];
        }
        return null;
    }

    get normalizedOptions() {
        if (this.isEditMode && this.isDependent) {
            return this.options.filter(({ validFor = [] }) =>
                validFor.includes(this.controllerValuesMapping[this.controllerFieldValue])
            );
        } else {
            return this.options;
        }
    }

    @track recordTypeInfos = {};
    @track defaultRecordTypeId = null;
    @track options = [];
    @track multi = false;
    @track required = false;

    // Properties for handling dependent picklists;
    @track controllerFieldName; // Captured from 'getObjectInfo' wire adapter;
    @track controllerValuesMapping = {}; // // Captured from 'getPicklistValues' wire adapter;

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    wiredObjectInfo({ data, error }) {
        if (data) {
            const { fields, recordTypeInfos, defaultRecordTypeId } = data;
            // Persist info about record types (used for correct picklist options retrieval);
            this.recordTypeInfos = cloneObject(recordTypeInfos);
            this.defaultRecordTypeId = defaultRecordTypeId;
            // Extract picklist field meta info;
            const { dataType, required = false, controllerName } = fields[this.fieldName];
            this.multi = dataType === 'MultiPicklist';
            this.required = required;
            this.controllerFieldName = controllerName;
            // Set focus in underlying input element;
            this.focusCombobox();
        } else if (error) {
            this.notifyError(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$targetRecordTypeId', fieldApiName: '$fieldPath' })
    wiredPicklistValues({ data, error }) {
        if (data) {
            const { controllerValues, values = [] } = data;
            this.controllerValuesMapping = cloneObject(controllerValues);
            this.options = cloneObject(values).map(({ label, value, validFor }) => ({ label, value, validFor }));
            // Log state;
            this.logState();
            // Set focus in underlying input element;
            this.focusCombobox();
        } else if (error) {
            this.notifyError(error);
        }
    }

    logState() {
        if (this.debugModeEnabled) {
            console.group(`Picklist [${this.fieldName}]`);
            super.log('this.required', this.required);
            super.log('this.multi', this.multi);
            super.log('this.options', this.options);
            super.log('this.normalizedOptions', this.normalizedOptions);
            super.log('isDependent', this.isDependent);
            super.log('this.controllerFieldName', this.controllerFieldName);
            super.log('this.controllerFieldValue', this.controllerFieldValue);
            super.log('this.controllerValuesMapping', this.controllerValuesMapping);
            console.groupEnd();
        }
    }

    focusCombobox() {
        if (this.isEditMode) {
            wait(() => {
                this.refs.cdtCombobox.focus();
            });
        }
    }
}
