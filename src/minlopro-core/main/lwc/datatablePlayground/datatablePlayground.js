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
                label: 'Account Name',
                fieldName: 'accountId',
                type: 'customLookup',
                editable: true,
                typeAttributes: {
                    context: { fieldName: 'id' },
                    fieldName: 'accountId',
                    objectApiName: 'Account',
                    value: { fieldName: 'accountId' },
                    displayInfo: {
                        additionalFields: ['Phone']
                    },
                    matchingInfo: {
                        primaryField: { fieldPath: 'Name' },
                        additionalFields: [{ fieldPath: 'Phone' }]
                    }
                }
            },
            // {
            //     label: 'Gender (Base CBX)',
            //     fieldName: 'gender',
            //     type: 'baseCombobox',
            //     editable: true,
            //     typeAttributes: {
            //         value: { fieldName: 'gender' },
            //         options: { fieldName: 'genderOptions' }
            //     }
            // },
            {
                label: 'Gender (Custom CBX DIS)',
                fieldName: 'gender',
                type: 'customCombobox',
                editable: true,
                typeAttributes: {
                    context: { fieldName: 'id' },
                    fieldName: 'gender',
                    value: { fieldName: 'gender' },
                    options: GENDER_OPTIONS,
                    multi: false
                }
            },
            {
                label: 'Skills (Custom CBX)',
                fieldName: 'skills',
                type: 'customCombobox',
                editable: true,
                typeAttributes: {
                    context: { fieldName: 'id' },
                    fieldName: 'skills',
                    value: { fieldName: 'skills' },
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
        this.records = this.generateData();
    }

    handleResetDemo() {
        this.draftValues = [];
        this.records = this.generateData();
    }

    /**
     * Observation: LWC datatable automatically handles 'change' events in cells/CDTs.
     * Keep in mind event propagation: bubbling VS capturing!
     * Some base LWCs do not produce bubbling events.
     */
    handleCellChange(event) {
        console.group('cellchange');
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

    handleSet2Entries(event) {
        this.draftValues = [];
        this.records = this.generateData().slice(0, 2);
    }

    // Service Methods;

    generateData() {
        const data = [];
        data.push({
            id: uniqueId(),
            accountId: '0017a00002RFsXzAAL',
            name: 'John',
            gender: 'male',
            genderOptions: GENDER_OPTIONS,
            skills: 'time_management;product_knowledge',
            skillOptions: SKILL_OPTIONS
        });
        data.push({
            id: uniqueId(),
            name: 'Michelle',
            gender: 'female',
            genderOptions: GENDER_OPTIONS,
            skills: 'relationship_building;product_knowledge;time_management',
            skillOptions: SKILL_OPTIONS
        });
        // Dummy data;
        data.push(
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
        );
        return data;
    }

    checkEntryPresenceByKeyField(entry = {}) {
        return this.draftValues.some((_) => _[this.KEY_FIELD] === entry[this.KEY_FIELD]);
    }
}
