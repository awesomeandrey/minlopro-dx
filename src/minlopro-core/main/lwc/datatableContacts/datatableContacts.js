import { LightningElement, track, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { cloneObject, parseError, to, isEmptyArray } from 'c/utilities';
import $Toastify from 'c/toastify';

// Apex Controller Methods;
import getContactsCountApex from '@salesforce/apex/DatatableController.getContactsCount';
import getContactsApex from '@salesforce/apex/DatatableController.getContacts';

// Custom combobox options;
const GENDER_OPTIONS = [
    { label: 'Male', value: 'Male', iconName: 'utility:activity' },
    { label: 'Female', value: 'Female', iconName: 'utility:data_cloud' }
];

export default class DatatableContacts extends LightningElement {
    @track records = [];
    @track draftValues = [];
    @track errors = { rows: {}, table: {} };
    @track KEY_FIELD = 'Id';

    @track loading = false;
    @track showCdtColumnsOnly = false;
    @track objectApiName = 'Contact';
    @track recordInfo = (recordId) => this.normalizedRecords.find((record) => record[this.KEY_FIELD] === recordId);

    get columns() {
        /**
         * Contact.Id - 'customLookup', readonly
         * Contact.Title - 'text', editable
         * Contact.AccountId - 'customLookup', editable
         * Contact.GenderIdentity - 'customCombobox', editable
         * Contact.Industry__c - 'customPicklist', editable
         * Contact.JobFunction__c - 'customPicklist', editable
         * Contact.Email - 'email', readonly
         * Contact.MobilePhone - 'phone', editable
         * Contact.Birthdate - 'date-local', editable (used for 'Date' data type)
         * Contact.HasOptedOutOfEmail - 'boolean', editable
         * Contact.LastCURequestDate - 'date', editable (used for 'DateTime' data type)
         */
        return [
            {
                label: 'Name',
                fieldName: 'Id', // aka 'this.KEY_FIELD';
                type: 'customLookup',
                editable: false,
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: this.KEY_FIELD,
                    objectApiName: this.objectApiName,
                    value: { fieldName: this.KEY_FIELD }
                }
            },
            {
                label: 'Title',
                fieldName: 'Title',
                type: 'customInput',
                editable: true,
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: 'Title',
                    value: { fieldName: 'Title' }
                }
            },
            {
                label: 'Account',
                fieldName: 'AccountId',
                type: 'customLookup',
                editable: true,
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: 'AccountId',
                    objectApiName: 'Account',
                    value: { fieldName: 'AccountId' },
                    required: false,
                    displayInfo: JSON.stringify({
                        additionalFields: ['Phone']
                    }),
                    matchingInfo: JSON.stringify({
                        primaryField: { fieldPath: 'Name' },
                        additionalFields: [{ fieldPath: 'Phone' }]
                    })
                }
            },
            {
                label: 'Gender',
                fieldName: 'GenderIdentity',
                type: 'customCombobox',
                editable: true,
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: 'GenderIdentity',
                    value: { fieldName: 'GenderIdentity' },
                    options: GENDER_OPTIONS
                }
            },
            {
                label: 'Industry',
                fieldName: 'Industry__c',
                type: 'customPicklist',
                editable: true,
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: 'Industry__c',
                    value: { fieldName: 'Industry__c' },
                    objectApiName: 'Contact'
                }
            },
            {
                label: 'Job Function',
                fieldName: 'JobFunction__c',
                type: 'customPicklist',
                editable: true,
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: 'JobFunction__c',
                    value: { fieldName: 'JobFunction__c' },
                    objectApiName: 'Contact',
                    recordInfo: this.recordInfo
                }
            },
            {
                label: 'Email',
                fieldName: 'Email',
                type: 'email',
                editable: false
            },
            {
                label: 'Mobile Phone',
                fieldName: 'MobilePhone',
                type: 'phone',
                editable: true
            },
            {
                label: 'Birthdate',
                fieldName: 'Birthdate',
                type: 'date-local',
                editable: true,
                typeAttributes: {
                    month: '2-digit',
                    day: '2-digit'
                }
            },
            {
                label: 'Email Opt Out',
                fieldName: 'HasOptedOutOfEmail',
                type: 'boolean',
                editable: true
            },
            {
                label: 'Last Modified Date',
                fieldName: 'LastModifiedDate',
                type: 'date',
                editable: true,
                typeAttributes: {
                    year: 'numeric',
                    month: 'short',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit'
                }
            }
        ].filter(({ type }) => {
            if (this.showCdtColumnsOnly && Boolean(type)) {
                return type.startsWith('custom');
            } else {
                return true;
            }
        });
    }

    get normalizedRecords() {
        const draftValuesAsMap = this.draftValues.reduce((map, draftRecord) => {
            map.set(draftRecord[this.KEY_FIELD], draftRecord);
            return map;
        }, new Map());
        return cloneObject(this.records).map((record) => {
            if (draftValuesAsMap.has(record[this.KEY_FIELD])) {
                return { ...record, ...draftValuesAsMap.get(record[this.KEY_FIELD]) };
            } else {
                return record;
            }
        });
    }

    get totalRecordsCount() {
        return parseInt(this.wiredContactsCount?.data) || 0;
    }

    get hasDuplicates() {
        const deduplicatedRecordIds = this.records.reduce((map, _) => {
            map.add(_[this.KEY_FIELD]);
            return map;
        }, new Set());
        return !isEmptyArray(this.records) && deduplicatedRecordIds.size !== this.records.length;
    }

    get enableInfiniteLoading() {
        return this.totalRecordsCount > 0 && this.totalRecordsCount > this.records.length;
    }

    get stats() {
        return {
            'Total Records Count': this.totalRecordsCount,
            'Current Records Count': this.records.length,
            'Draft Records Count': this.draftValues.length,
            'Current Offset': this.records.length,
            'Has Duplicates': this.hasDuplicates,
            'Enable Infinite Loading': this.enableInfiniteLoading
        };
    }

    get cdtOnlyBtnLabel() {
        return this.showCdtColumnsOnly ? 'Show All Columns' : 'Show CDT Column Only';
    }

    @wire(getContactsCountApex)
    wiredContactsCount = {};

    connectedCallback() {
        // Load records;
        this.fetchAndAppendContacts();
    }

    errorCallback(error, stack) {
        console.error(error, stack);
    }

    // Event Handlers;

    handleToggleCdtsOnly() {
        this.showCdtColumnsOnly = !this.showCdtColumnsOnly;
    }

    handleReset(event) {
        this.reset();
        this.fetchAndAppendContacts();
    }

    handleCellChange(event) {
        event.stopPropagation();
        let [changedEntry = {}] = cloneObject(event.detail.draftValues);
        changedEntry[this.KEY_FIELD] = changedEntry[this.KEY_FIELD] || changedEntry['context'];
        delete changedEntry['context'];
        if (this.checkEntryPresenceByKeyField(changedEntry)) {
            this.draftValues = this.draftValues.map((entry) => {
                if (entry[this.KEY_FIELD] === changedEntry[this.KEY_FIELD]) {
                    for (let field of Object.getOwnPropertyNames(changedEntry)) {
                        entry[field] = changedEntry[field];
                    }
                }
                return entry;
            });
        } else {
            this.draftValues = [...this.draftValues, changedEntry];
        }
    }

    handleCellError(event) {
        const { context, fieldName, error } = event.detail;
        const currentErrors = this.errors;
        currentErrors.rows[context] = {
            title: 'Cell Error Occurred',
            messages: [parseError(error).message],
            fieldNames: [fieldName]
        };
        this.errors = cloneObject(currentErrors);
    }

    async handleSave(event) {
        console.group('onsave');
        // Turn on spinner;
        this.loading = true;
        // Capture current records state and update with values accordingly;
        let clonedRecords = cloneObject(this.records) || [];
        let clonedDrafts = cloneObject(this.draftValues) || [];
        let clonedErrors = cloneObject(this.errors) || {};
        // Save record updates via LDS;
        const updatePromises = clonedDrafts.map((record) => {
            const recordInput = { fields: cloneObject(record) };
            return updateRecord(recordInput);
        });
        const settledPromises = await Promise.allSettled(updatePromises);
        settledPromises.forEach((result, index) => {
            let { status, reason, value: data } = result;
            if (status === 'fulfilled') {
                console.log(`Record #${index} updated successfully`);
                // Copy modified fields only;
                let targetRecord = clonedRecords.find((_) => _[this.KEY_FIELD] === data.id);
                console.log('targetRecord', JSON.stringify(targetRecord));
                let targetDraftRecord = clonedDrafts.find((_) => _[this.KEY_FIELD] === data.id);
                console.log('targetDraftRecord', JSON.stringify(targetDraftRecord));
                for (let fieldName of Object.getOwnPropertyNames(targetDraftRecord)) {
                    let fieldValue = targetDraftRecord[fieldName];
                    console.log(`Copying "${fieldName}" field value (${fieldValue}) into [targetRecord]`);
                    targetRecord[fieldName] = fieldValue;
                }
                // Remove updated record from drafts;
                clonedDrafts = clonedDrafts.filter((_) => _[this.KEY_FIELD] !== targetDraftRecord[this.KEY_FIELD]);
                // Nullify any errors related this this draft;
                delete clonedErrors.rows[data.id];
            } else if (status === 'rejected') {
                console.error(`Record #${index + 1} failed with reason: ${JSON.stringify(reason)}`);
                const recordId = clonedDrafts[index][this.KEY_FIELD];
                const { message = '', output = {} } = reason.body;
                const fieldErrors = output['fieldErrors'] || {};
                console.error(`Failures | ${JSON.stringify(fieldErrors)}`);
                clonedErrors.rows[recordId] = {
                    title: message,
                    messages: Object.values(fieldErrors)
                        .flat()
                        .map((_) => _['message']),
                    fieldNames: Object.keys(fieldErrors)
                };
            } else {
                throw new Error(`Unknown error occurred: ${result}.`);
            }
        });
        // Collect DML stats;
        const totalRecordsAmount = this.draftValues.length; // Original draft records amount;
        const failedRecordsAmount = clonedDrafts.length; // All records still left in drafts;
        const succeededRecordsAmount = totalRecordsAmount - failedRecordsAmount;
        // Re-set state;
        this.records = clonedRecords;
        this.draftValues = clonedDrafts;
        this.errors = clonedErrors;
        // Turn off spinner;
        this.loading = false;
        console.groupEnd();
        // Show custom toast messages;
        if (totalRecordsAmount === succeededRecordsAmount) {
            $Toastify.success({ message: 'All records were updated!' });
        } else if (totalRecordsAmount === failedRecordsAmount) {
            $Toastify.error({ message: 'All records failed to save!' });
        } else {
            $Toastify.warning({
                title: 'Partial Success',
                message: `${failedRecordsAmount} record failed to save, but the rest of ${succeededRecordsAmount} succeeded.`
            });
        }
    }

    handleCancel(event) {
        this.errors = { rows: {}, table: {} };
        this.draftValues = [];
    }

    handleLoadMore(event) {
        if (!this.loading && this.enableInfiniteLoading) {
            // Load more data;
            this.fetchAndAppendContacts();
        }
    }

    // Service Methods;

    checkEntryPresenceByKeyField(entry = {}) {
        return this.draftValues.some((_) => _[this.KEY_FIELD] === entry[this.KEY_FIELD]);
    }

    async fetchAndAppendContacts() {
        // Turn on spinner;
        this.loading = true;
        // Handle offset state and step;
        const offset = this.records.length,
            step = 15;
        // Pull data from server;
        const [error, records] = await to(
            getContactsApex({
                query: {
                    fieldApiNames: this.columns.map(({ fieldName }) => fieldName),
                    offsetValue: offset,
                    limitValue: step
                }
            })
        );
        if (error) {
            console.error('DatatableContacts.js', error);
            this.reset();
        } else {
            this.records = [...this.records, ...cloneObject(records)];
        }
        // Turn off spinner;
        this.loading = false;
    }

    reset() {
        this.errors = { rows: {}, table: {} };
        this.draftValues = [];
        this.records = [];
    }
}
