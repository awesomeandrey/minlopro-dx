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

    @track recordTypeInfos = {};
    @track defaultRecordTypeId = null;
    @track options = [];
    @track multi = false;
    @track required = false;

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    wiredObjectInfo({ data, error }) {
        if (data) {
            const { fields, recordTypeInfos, defaultRecordTypeId } = data;
            // Persist info about record types (used for correct picklist options retrieval);
            this.recordTypeInfos = cloneObject(recordTypeInfos);
            this.defaultRecordTypeId = defaultRecordTypeId;
            // Check if picklist is mandatory & supports multi-selection;
            const { dataType, required = false } = fields[this.fieldName];
            this.multi = dataType === 'MultiPicklist';
            this.required = required;
        } else if (error) {
            console.error('CdtPicklist.js', 'wireObjectInfo', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$targetRecordTypeId', fieldApiName: '$fieldPath' })
    wiredPicklistValues({ data, error }) {
        if (data) {
            const { values = [] } = data;
            this.options = values.map(({ label, value }) => ({ label, value }));
        } else if (error) {
            console.error('CdtPicklist.js', 'wirePicklistValues', error);
        }
    }
}
