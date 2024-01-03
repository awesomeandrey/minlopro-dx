import { LightningElement, track } from 'lwc';
import { cloneObject, uniqueId } from 'c/utilities';

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
    { label: 'Product Knowledge', value: 'product_knowledge' }
];

export default class DatatablePlayground extends LightningElement {
    @track records = [];
    @track draftValues = [];
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
                label: 'Gender (Base CBX)',
                fieldName: 'gender',
                type: 'baseCombobox',
                editable: true,
                typeAttributes: {
                    context: { fieldName: 'id' },
                    value: { fieldName: 'gender' },
                    options: { fieldName: 'genderOptions' }
                }
            },
            {
                label: 'Skills (Custom CBX)',
                fieldName: 'skills',
                type: 'customCombobox',
                editable: false,
                typeAttributes: {
                    context: { fieldName: 'id' },
                    fieldName: 'skills',
                    value: { fieldName: 'skills' },
                    options: { fieldName: 'skillOptions' },
                    // options: SKILL_OPTIONS,
                    multi: true,
                    editable: true
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

    connectedCallback() {
        this.draftValues = [];
        this.records = [];
        // Generate sample data;
        this.records.push({
            id: uniqueId(),
            name: 'John',
            gender: 'male',
            genderOptions: GENDER_OPTIONS,
            skills: 'time_management;product_knowledge',
            skillOptions: SKILL_OPTIONS
        });
        this.records.push({
            id: uniqueId(),
            name: 'Michelle',
            gender: 'female',
            genderOptions: GENDER_OPTIONS,
            skills: 'relationship_building;product_knowledge;time_management',
            skillOptions: SKILL_OPTIONS
        });
        // Dummy data;
        this.records = [
            ...this.records,
            ...new Array(18).fill(null).map((_) => {
                return {
                    id: uniqueId(),
                    name: 'John Doe',
                    gender: 'bisexual',
                    genderOptions: GENDER_OPTIONS,
                    skills: null,
                    skillOptions: SKILL_OPTIONS
                };
            })
        ];
    }

    errorCallback(error, stack) {
        console.log('DatatablePlayground.js', error, stack);
    }

    handleResetDemo() {
        this.connectedCallback();
    }

    handleCellChange(event) {
        // Assumption - 'draftValues' event payload would always have single entry;
        let [changedEntry = {}] = event.detail.draftValues;
        // Normalize entry ID;
        changedEntry[this.KEY_FIELD] = changedEntry[this.KEY_FIELD] || changedEntry['context'];
        // Update draft values;
        if (this.checkEntryPresenceByKeyField(changedEntry)) {
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
            // Add new one;
            this.draftValues = [...this.draftValues, changedEntry];
        }
    }

    handleSave(event) {
        console.group('onsave');
        event.detail.draftValues.forEach((draftRecord) => {
            console.log(JSON.stringify(draftRecord));
        });
        console.groupEnd();
        this.records = cloneObject(this.normalizedRecords);
        this.draftValues = [];
    }

    handleCancel(event) {
        console.log('oncancel');
    }

    checkEntryPresenceByKeyField(entry = {}) {
        return this.draftValues.some((_) => _[this.KEY_FIELD] === entry[this.KEY_FIELD]);
    }
}
