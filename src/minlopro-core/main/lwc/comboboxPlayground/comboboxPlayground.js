import { LightningElement, track } from 'lwc';
import { cloneObject } from 'c/utilities';

export default class ComboboxPlayground extends LightningElement {
    @track multiSelectModeEnabled = false;
    @track nullifiedOptionsModeEnabled = false;
    @track readOnly = false;
    @track required = true;
    @track selectedValueAsStr = null;

    get dynamicOptions() {
        if (this.nullifiedOptionsModeEnabled) {
            return [];
        }
        const shortOptions = new Array(5).fill(null).map((_, index) => {
            return {
                label: `Default Lbl ${index}`,
                value: `short_opt_${index}`,
                iconName: 'utility:connected_apps'
            };
        });
        const longOptions = new Array(2).fill(null).map((_, index) => {
            const loremText = "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s";
            const label = `Long option label for #${index} > ${loremText}`;
            return {
                label,
                value: `long_opt_${index}`,
                iconName: 'utility:left_align_text'
            };
        });
        return [...shortOptions, ...longOptions];
    }

    get containers() {
        return [
            { label: 'Single Select #1', columnsSize: 3, componentName: 'single_1' },
            { label: 'Single Select #2', columnsSize: 4, componentName: 'single_2' },
            { label: 'Single Select #3', columnsSize: 5, componentName: 'single_3' },
            { label: 'Multi Select #1', columnsSize: 3, componentName: 'multi_1', multi: true },
            { label: 'Multi Select #2', columnsSize: 4, componentName: 'multi_2', multi: true },
            { label: 'Multi Select #3', columnsSize: 5, componentName: 'multi_3', multi: true }
        ];
    }

    get $comboboxComponents() {
        return this.template.querySelectorAll('c-combobox');
    }

    handleChange(event) {
        const { name, value, multiSelect = false, selectedOptions = [] } = event.detail;
        this.selectedValueAsStr = value;
        console.group('Combobox Input Change');
        console.log('CHANGE event');
        console.log('name:', name);
        console.log('value:', value);
        console.log('multiSelect:', multiSelect);
        console.log('selectedOptions:', cloneObject(selectedOptions));
        console.groupEnd();
    }

    // State Handlers;

    handleReset(event) {
        this.multiSelectModeEnabled = false;
        this.nullifiedOptionsModeEnabled = false;
        this.readOnly = false;
        this.required = true;
        this.selectedValueAsStr = null;
        this.$comboboxComponents.forEach((component) => {
            component.setCustomValidity(null);
            component.reportValidity();
        });
    }

    handleToggleRequired(event) {
        this.required = !this.required;
    }

    handleToggleNullifyOptions(event) {
        this.nullifiedOptionsModeEnabled = !this.nullifiedOptionsModeEnabled;
    }

    handleToggleReadOnly() {
        this.readOnly = !this.readOnly;
    }

    handleSetCustomValidity(event) {
        this.$comboboxComponents.forEach((component) => {
            component.setCustomValidity('Custom Error Message');
        });
    }

    handleReportValidity(event) {
        this.$comboboxComponents.forEach((component) => {
            const validity = component.reportValidity();
            console.log(`[${component.name}] validity`, validity);
        });
    }
}
