import { api, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import DatatableEditableCdt from 'c/datatableEditableCdt';
import { isNotEmpty, isEmpty, cloneObject, isEmptyArray } from 'c/utilities';

export default class CdtPicklist extends DatatableEditableCdt {
    @api context = null;
    @api fieldName = null;
    @api value = null;
    @api objectApiName = null;
    @api recordTypeId = null;
    @api readOnly = false;
    @api recordInfo = null; // Function with bound context to parent datatable instance;

    @api get validity() {
        return this.refs.cdtCombobox?.validity;
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
        return !!this.controllerFieldName && !!Object.keys(this.controllerValuesMapping).length;
    }

    get controllerFieldValue() {
        if (this.isDependent && typeof this.recordInfo === 'function') {
            return this.recordInfo(this.context)[this.controllerFieldName];
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

    constructor() {
        super();
        this.cdtClassName = 'CdtPicklist';
        this.debugModeEnabled = false;
    }

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
        } else if (error) {
            console.error('CdtPicklist.js', 'wireObjectInfo', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$targetRecordTypeId', fieldApiName: '$fieldPath' })
    wiredPicklistValues({ data, error }) {
        if (data) {
            const { controllerValues, values = [] } = data;
            this.controllerValuesMapping = cloneObject(controllerValues);
            this.options = values.map(({ label, value, validFor }) => ({ label, value, validFor }));
            this.debugModeEnabled && this.logState();
        } else if (error) {
            console.error('CdtPicklist.js', 'wirePicklistValues', error);
        }
    }

    logState() {
        console.group(`Picklist [${this.fieldName}]`);
        console.log('this.required', this.required);
        console.log('this.multi', this.multi);
        console.log('this.options', JSON.stringify(this.options));
        console.log('this.normalizedOptions', JSON.stringify(this.normalizedOptions));
        console.log('isDependent', this.isDependent);
        console.log('this.controllerFieldName', this.controllerFieldName);
        console.log('this.controllerFieldValue', this.controllerFieldValue);
        console.log('this.controllerValuesMapping', JSON.stringify(this.controllerValuesMapping));
        console.groupEnd();
    }
}
