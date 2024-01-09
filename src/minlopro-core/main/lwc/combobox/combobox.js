import { api, LightningElement, track } from 'lwc';
import { formatLabel, isEmptyArray, isNotEmpty, uniqueId, wait, cloneObject } from 'c/utilities';
import {
    FocusedStateManager,
    FixedDropdownMonitor,
    isElementCloseToViewportBottom,
    MULTI_PICKLIST_SEPARATOR
} from 'c/comboboxUtils';

// Custom Labels;
import selectOptionLbl from '@salesforce/label/c.Commons_Lbl_SelectOption';
import selectMultipleOptionsLbl from '@salesforce/label/c.Commons_Lbl_SelectMultipleOptions';
import nItemsLbl from '@salesforce/label/c.Commons_Lbl_NItems';
import completeThisFieldLbl from '@salesforce/label/c.Commons_Lbl_CompleteThisField';

// Templates;
import disabledOrReadOnlyTemplate from './comboboxDisabledOrReadOnly.html';
import inputTemplate from './combobox.html';

// Constants;
const SLDS_HAS_ERROR_CLASS_NAME = 'slds-has-error';
const SLDS_IS_OPEN_CLASS_NAME = 'slds-is-open';

/**
 * A reusable combobox component implemented using the Lightning Web Component framework.
 * This component supports single and multi-select options with custom labels and styling.
 * It also includes accessibility and UI state management features.
 *
 * Note: the order of properties in consuming LWC matters:
 * make sure to define 'value' property after 'options' & 'multiSelect'!
 */
export default class Combobox extends LightningElement {
    /**
     * Unique identifier for the combobox.
     * @type {string}
     */
    @api name = uniqueId();

    /**
     * Label for the combobox.
     * @type {string|null}
     */
    @api label = null;

    /**
     * Placeholder text displayed when no option is selected.
     * @type {string|null}
     */
    @api placeholder = null;

    /**
     * Array of options for the combobox.
     * Each option is an object with `label`,`value` and `iconName` properties.
     * @type {Array}
     */
    @api options = [];

    /**
     * Determines if multiple options can be selected.
     * @type {boolean}
     */
    @api multiSelect = false;

    /**
     * Indicates if the combobox is required in a form.
     * @type {boolean}
     */
    @api required = false;

    /**
     * Indicates if the combobox is disabled.
     * @type {boolean}
     */
    @api disabled = false;

    /**
     * Indicates if the combobox is read-only.
     * @type {boolean}
     */
    @api readOnly = false;

    /**
     * Indicates dropdown panel rendering mode.
     * Allowed values are "absolute" (default) and "fixed".
     * @type {string}
     */
    @api mode = 'absolute';

    /**
     * Gets the selected value(s) as a string joined by a separator.
     * For multi-select, values are joined by `MULTI_PICKLIST_SEPARATOR`.
     * For single-select, it returns the selected value.
     * @return {string}
     */
    @api
    get value() {
        return this.selectedValues.filter(Boolean).join(MULTI_PICKLIST_SEPARATOR);
    }

    /**
     * Sets the selected value(s) of the combobox.
     * For multi-select, splits the string by `MULTI_PICKLIST_SEPARATOR` and selects corresponding options.
     * For single-select, selects the first option from the split values.
     * @param {string} value - The value(s) to select.
     */
    set value(value) {
        this.selectedValues = (value || '').split(MULTI_PICKLIST_SEPARATOR);
    }

    @api
    get validity() {
        return {
            valid: !this.hasError,
            valueMissing: !this.hasValueDefined
        };
    }

    @api setCustomValidity(errorMessage) {
        this.errorMessage = errorMessage;
    }

    @api reportValidity() {
        if (this.hasError) {
            this.$container.classList.add(SLDS_HAS_ERROR_CLASS_NAME);
            return false;
        } else {
            this.$container.classList.remove(SLDS_HAS_ERROR_CLASS_NAME);
            return true;
        }
    }

    @api showHelpMessageIfInvalid() {
        console.log(`Combobox.js | ${this.name}`, 'showHelpMessageIfInvalid()');
    }

    @api open() {
        if (!this.isDisabledOrReadOnly) {
            this.isOpen = true;
        }
    }

    @track debugModeEnabled = false; // Turn on/off to identify bottlenecks;
    @track selectedValues = [];
    @track errorMessage = '';
    @track isOpen = false;
    @track hideDropdownBound = this.hideDropdown.bind(this);
    @track comboboxId = FocusedStateManager.generateId();
    @track alignment = 'top'; // 'top' | 'bottom';
    @track fixedDropdownMonitor = new FixedDropdownMonitor({
        selectInputElement: () => this.$input,
        selectDropdownElement: () => this.$dropdown,
        hideDropdown: this.hideDropdownBound,
        debugModeEnabled: this.debugModeEnabled
    });

    get normalizedOptions() {
        // Convert array-like object to array;
        let clonedOptions = cloneObject(this.options);
        if (!Array.isArray(clonedOptions)) {
            // Force array-like object;
            clonedOptions.length = Object.getOwnPropertyNames(clonedOptions).length;
        }
        clonedOptions = Array.from(clonedOptions);
        // Normalize options;
        const result = clonedOptions.map((option) => ({
            ...option,
            selected: this.selectedValues.includes(option.value)
        }));
        if (this.multiSelect) {
            // Selected options are shifted to the top;
            result.sort(({ selected: a }, { selected: b }) => {
                if (a === true && b === false) return -1;
                if (a === false && b === true) return 1;
                return 0;
            });
        }
        return result;
    }

    get normalizedPlaceholder() {
        if (isEmptyArray(this.normalizedOptions)) {
            return 'No available options';
        }
        if (typeof this.placeholder === 'string') {
            return this.placeholder;
        }
        return this.multiSelect ? selectMultipleOptionsLbl : selectOptionLbl;
    }

    get isDisabled() {
        return Boolean(this.disabled) || isEmptyArray(this.normalizedOptions);
    }

    get isReadOnly() {
        return Boolean(this.readOnly);
    }

    get isDisabledOrReadOnly() {
        return this.isReadOnly || this.isDisabled;
    }

    get inputValueLabel() {
        if (this.isDisabledOrReadOnly) {
            return this.selectedOptions.map(({ label }) => label).join(`${MULTI_PICKLIST_SEPARATOR} `);
        }
        const { length: selectedOptionsAmount = 0, 0: firstSelectedOption = {} } = this.selectedOptions;
        if (this.multiSelect && selectedOptionsAmount > 1) {
            return formatLabel(nItemsLbl, selectedOptionsAmount);
        }
        return firstSelectedOption.label || '';
    }

    get selectedOptions() {
        return this.normalizedOptions.filter(({ selected = false }) => selected);
    }

    get hasError() {
        if (this.required && !this.hasValueDefined) {
            return true;
        }
        return isNotEmpty(this.errorMessage);
    }

    get normalizedErrorMessage() {
        if (!this.hasError) {
            return null;
        }
        if (this.required && !this.hasValueDefined) {
            return completeThisFieldLbl;
        }
        return this.errorMessage;
    }

    get hasValueDefined() {
        return isNotEmpty(this.value);
    }

    get isFixedMode() {
        return this.mode === 'fixed';
    }

    get comboboxClassName() {
        const classNames = ['slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click'];
        if (this.isOpen) {
            classNames.push(SLDS_IS_OPEN_CLASS_NAME);
        }
        return classNames.join(' ');
    }

    get dropdownClassName() {
        const classNames = ['slds-dropdown slds-dropdown_length-5 slds-dropdown_fluid slds-listbox_vertical'];
        if (this.alignment === 'bottom') {
            classNames.push('slds-dropdown_bottom');
        }
        return classNames.join(' ');
    }

    get $container() {
        return this.refs.container;
    }

    get $input() {
        return this.refs.input;
    }

    get $dropdown() {
        return this.refs.dropdown;
    }

    // Lifecycle Hooks;

    render() {
        return this.isDisabledOrReadOnly ? disabledOrReadOnlyTemplate : inputTemplate;
    }

    /**
     * Lifecycle hook that's invoked when the component is rendered.
     * Manages the focus state and attaches an event listener for closing the dropdown.
     */
    renderedCallback() {
        if (this.isDisabledOrReadOnly) {
            return;
        }
        window.removeEventListener('click', this.hideDropdownBound, { capture: false });
        if (this.isOpen) {
            // Dropdown is open;
            FocusedStateManager.focus(this.comboboxId);
            // Add event listener to close dropdown when clicked outside;
            wait(() => {
                /**
                 * NOTE: adding event listener during event bubbling phase automatically invokes the handler!
                 * Therefore, the event listener gets added in another current execution context.
                 */
                window.addEventListener('click', this.hideDropdownBound, { once: true, capture: false });
            });
            if (this.isFixedMode) {
                // Calculate dropdown position for 'fixed' mode;
                this.fixedDropdownMonitor.applyAndObserve();
            } else {
                // Calculate dropdown vertical alignment for 'absolute' mode;
                this.alignment = isElementCloseToViewportBottom(this.$input, 230) ? 'bottom' : 'top';
            }
        } else {
            // Dropdown is closed;
            this.fixedDropdownMonitor.unobserve();
        }
    }

    disconnectedCallback() {
        this.fixedDropdownMonitor.unobserve();
    }

    // Event Handlers;

    handleDropdownInputClick(event) {
        // 'event.stopPropagation()' should be invoked only when user interacts with this specific combobox instance;
        if (FocusedStateManager.isFocused(this.comboboxId)) {
            event.stopPropagation();
        }
        // Open / close dropdown;
        this.isOpen = !this.isOpen;
    }

    handleDropdownOptionsContainerClick(event) {
        // This handler auto-closes dropdown when the option is selected/clicked on;
        if (this.multiSelect) {
            // For 'multiSelect' mode dropdown panel remains opened (clicking outside of it should hide the panel);
            event.stopPropagation();
        } else {
            this.hideDropdown();
        }
    }

    handleDropdownOptionClick(event) {
        // Capture selected option(s) and dispatch event;
        const value = event.currentTarget.dataset.value;
        if (this.multiSelect) {
            if (this.selectedValues.includes(value)) {
                // De-select option item;
                this.selectedValues = this.selectedValues.filter((_) => _ !== value);
            } else {
                // Select option item;
                this.selectedValues = [...this.selectedValues, value];
            }
        } else {
            this.selectedValues = [value];
        }
        // Dispatch custom event;
        this.notify();
    }

    // Service Methods;

    hideDropdown(event) {
        this.debugModeEnabled && console.log(`Combobox.js | ${this.name}`, 'hideDropdown()');
        if (this.isOpen) {
            this.isOpen = false;
            this.dispatchEvent(
                new CustomEvent('close', {
                    composed: true,
                    bubbles: true,
                    cancelable: true
                })
            );
        }
    }

    notify() {
        this.dispatchEvent(
            new CustomEvent('change', {
                composed: true,
                bubbles: true,
                cancelable: true,
                detail: {
                    name: this.name,
                    value: this.value,
                    multiSelect: this.multiSelect,
                    selectedOptions: this.selectedOptions
                }
            })
        );
    }
}
