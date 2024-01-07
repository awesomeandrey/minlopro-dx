import { LightningElement, track } from 'lwc';
import { cloneObject, uniqueId, parseError } from 'c/utilities';
import { MULTI_PICKLIST_SEPARATOR } from 'c/comboboxUtils';

// Running User ID;
import USER_ID from '@salesforce/user/Id';

// Custom combobox options;
const GENDER_OPTIONS = [
    { label: 'Male', value: 'male', iconName: 'utility:activity' },
    { label: 'Female', value: 'female', iconName: 'utility:data_cloud' },
    { label: 'Bisexual', value: 'bisexual', iconName: 'utility:add_source' }
];
const SKILL_OPTIONS = [
    { label: 'Active Listening', value: 'active_listening' },
    { label: 'Relationship Building', value: 'relationship_building' },
    { label: 'Adaptability', value: 'adaptability' },
    { label: 'Time Management', value: 'time_management' },
    { label: 'Product Knowledge', value: 'product_knowledge' },
    { label: 'Extra Skill #1', value: 'extra_skill_1' },
    { label: 'Extra Skill #2', value: 'extra_skill_2' },
    { label: 'Extra Skill #3', value: 'extra_skill_3' },
    { label: 'Extra Skill #4', value: 'extra_skill_4' },
    { label: 'Extra Skill #5', value: 'extra_skill_5' }
];

export default class DatatablePlayground extends LightningElement {
    @track records = [];
    @track draftValues = [];
    @track errors = { rows: {}, table: {} };
    @track KEY_FIELD = 'id';

    get columns() {
        return [
            {
                label: 'Agent Name',
                fieldName: 'name',
                type: 'text',
                editable: true
            },
            {
                label: 'User',
                fieldName: 'userId',
                type: 'customLookup',
                editable: true,
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: 'userId',
                    objectApiName: 'User',
                    value: { fieldName: 'userId' },
                    required: true,
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
                label: 'Account',
                fieldName: 'accountId',
                type: 'customLookup',
                editable: true,
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: 'accountId',
                    objectApiName: 'Account',
                    value: { fieldName: 'accountId' },
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
                label: 'Gender (Single)',
                fieldName: 'gender',
                type: 'customCombobox',
                editable: true,
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: 'gender',
                    value: { fieldName: 'gender' },
                    required: false,
                    options: GENDER_OPTIONS,
                    multi: false
                }
            },
            {
                label: 'Skills (Multi)',
                fieldName: 'skills',
                type: 'customCombobox',
                editable: true,
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: 'skills',
                    value: { fieldName: 'skills' },
                    required: true,
                    options: SKILL_OPTIONS,
                    multi: true
                }
            }
        ];
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

    errorCallback(error, stack) {
        console.log('DatatablePlayground.js', error, stack);
    }

    connectedCallback() {
        this.reset();
    }

    handleResetDemo() {
        this.reset();
    }

    handleCellChange(event) {
        console.group('cellchange');
        event.stopPropagation();
        // Assumption - 'draftValues' event payload would always have single entry;
        let [changedEntry = {}] = event.detail.draftValues;
        console.log(JSON.stringify(changedEntry));
        // Normalize entry ID;
        changedEntry[this.KEY_FIELD] = changedEntry[this.KEY_FIELD] || changedEntry['context'];
        // Update draft values;
        if (this.checkEntryPresenceByKeyField(changedEntry)) {
            console.log('existing draft entry');
            // Update existing draft entry;
            this.draftValues = this.draftValues.map((entry) => {
                if (entry[this.KEY_FIELD] === changedEntry[this.KEY_FIELD]) {
                    for (let field of Object.getOwnPropertyNames(changedEntry)) {
                        entry[field] = changedEntry[field];
                    }
                }
                return entry;
            });
        } else {
            console.log('new draft entry');
            // Add new one;
            this.draftValues = [...this.draftValues, changedEntry];
        }
        console.groupEnd();
    }

    handleCellError(event) {
        console.log('cellerror', event.detail);
        const { context, fieldName, error } = event.detail;
        const currentErrors = this.errors;
        currentErrors.rows[context] = {
            title: 'Cell Error Occurred',
            messages: [parseError(error).message],
            fieldNames: [fieldName]
        };
        this.errors = cloneObject(currentErrors);
    }

    handleSave(event) {
        console.group('save');
        event.detail.draftValues.forEach((draftRecord) => {
            console.log(JSON.stringify(draftRecord));
        });
        console.groupEnd();
        // Validate drafts;
        const rowKeyByError = this.validateDrafts();
        if (rowKeyByError.size === 0) {
            let savedRecords = cloneObject(this.normalizedRecords);
            this.reset();
            this.records = savedRecords;
        } else {
            // Init 'error' prop;
            this.errors = Array.from(rowKeyByError).reduce(
                (obj, [key, value]) => {
                    obj.rows[key] = value;
                    return obj;
                },
                {
                    rows: {},
                    table: {
                        title: 'Failed to save changes',
                        messages: ['Fix the errors and try again']
                    }
                }
            );
        }
    }

    handleCancel(event) {
        this.errors = { rows: {}, table: {} };
        this.draftValues = [];
    }

    handleSet2Entries(event) {
        this.reset();
        this.records = this.generateData().slice(0, 2);
    }

    // Service Methods;

    reset() {
        this.errors = { rows: {}, table: {} };
        this.draftValues = [];
        this.records = this.generateData();
    }

    validateDrafts() {
        const rowKeyByError = new Map();
        this.draftValues.forEach((draftRecord) => {
            let errors = this.validateDraft(draftRecord);
            if (errors.messages.length !== 0) {
                rowKeyByError.set(draftRecord[this.KEY_FIELD], {
                    title: 'Record Level Error',
                    ...errors
                });
            }
        });
        return rowKeyByError;
    }

    validateDraft({ accountId, skills }) {
        let messages = [],
            fieldNames = [];
        if (accountId !== undefined && !Boolean(accountId)) {
            messages.push('"Account" is mandatory!');
            fieldNames.push('accountId');
        }
        if (skills !== undefined && (!Boolean(skills) || skills.split(MULTI_PICKLIST_SEPARATOR).length < 2)) {
            messages.push('There should be at least 2 skills selected');
            fieldNames.push('skills');
        }
        return { messages, fieldNames };
    }

    generateData() {
        const data = [];
        data.push({
            id: uniqueId(),
            userId: USER_ID,
            accountId: 'unknownId',
            name: 'John',
            gender: 'male',
            skills: 'time_management;product_knowledge'
        });
        data.push({
            id: uniqueId(),
            userId: null,
            accountId: null,
            name: 'Michelle',
            gender: 'female',
            skills: 'relationship_building;product_knowledge;time_management'
        });
        // Dummy data;
        data.push(
            ...new Array(5).fill(null).map((_) => {
                return {
                    id: uniqueId(),
                    name: 'Nicolas',
                    gender: 'bisexual',
                    skills: null
                };
            })
        );
        return data;
    }

    checkEntryPresenceByKeyField(entry = {}) {
        return this.draftValues.some((_) => _[this.KEY_FIELD] === entry[this.KEY_FIELD]);
    }
}
