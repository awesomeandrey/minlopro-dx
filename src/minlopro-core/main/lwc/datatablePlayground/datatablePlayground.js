import { LightningElement, track } from 'lwc';
import { uniqueId } from 'c/utilities';

// Custom combobox options;
const GENDER_OPTIONS = [
    { label: 'Male', value: 'male', iconName: 'utility:activity' },
    { label: 'Female', value: 'female', iconName: 'utility:data_cloud' }
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

    get columns() {
        return [
            {
                label: 'Agent Name',
                fieldName: 'name',
                type: 'text'
            },
            {
                label: 'Gender',
                fieldName: 'gender',
                type: 'combobox',
                cellAttributes: {
                    class: 'my-cell-class'
                },
                typeAttributes: {
                    value: { fieldName: 'gender' },
                    options: GENDER_OPTIONS,
                    multi: false
                }
            },
            {
                label: 'Skills',
                fieldName: 'skills',
                type: 'combobox',
                cellAttributes: {
                    class: 'my-custom-class'
                },
                typeAttributes: {
                    value: { fieldName: 'skills' },
                    options: SKILL_OPTIONS,
                    multi: true
                }
            }
        ];
    }

    connectedCallback() {
        // Generate sample data;
        this.records.push({
            id: uniqueId(),
            name: 'John',
            gender: 'male',
            skills: 'active_listening;time_management'
        });
        this.records.push({
            id: uniqueId(),
            name: 'Michelle',
            gender: 'female',
            skills: 'relationship_building;product_knowledge;time_management'
        });
        // Dummy data;
        this.records = [
            ...this.records,
            ...new Array(5).fill(null).map((_) => {
                return {
                    id: uniqueId(),
                    name: 'John Doe',
                    gender: 'male',
                    skills: 'relationship_building'
                };
            })
        ];
    }
}
