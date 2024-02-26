import { uniqueId } from 'c/utilities';

// Picklist values separator character for multi-select combobox;
export const MULTI_PICKLIST_SEPARATOR = ';';

export const isElementCloseToViewportBottom = (element, threshold = 100) => {
    const rect = element.getBoundingClientRect();
    const viewportHeight = window.innerHeight;
    const bottomPosition = rect.bottom;
    // Distance from the bottom of the element to the bottom of the viewport
    const distanceFromBottom = viewportHeight - bottomPosition;
    // Check if the distance is less than the threshold
    return distanceFromBottom <= threshold;
};

// Combobox Focused State Manager;
export const FocusedStateManager = (function () {
    const uniqueComboboxIds = new Set();
    let focusedComboboxId = null;
    return {
        generateId: function () {
            const comboboxId = uniqueId();
            if (uniqueComboboxIds.has(comboboxId)) {
                throw new Error(`This COMBOBOX_ID has already been assigned: ${comboboxId}.`);
            }
            uniqueComboboxIds.add(comboboxId);
            return comboboxId;
        },
        isFocused: function (comboboxId) {
            return focusedComboboxId === comboboxId;
        },
        focus: function (comboboxId) {
            focusedComboboxId = comboboxId;
        },
        unfocus: function (comboboxId) {
            uniqueComboboxIds.delete(comboboxId);
        }
    };
})();

// Combobox Fixed Mode Monitor;
export class FixedDropdownMonitor {
    constructor({
        selectInputElement,
        selectDropdownElement,
        hideDropdown,
        isModalContext = false,
        debugModeEnabled = false,
        log
    }) {
        this.selectInputElement = selectInputElement;
        this.selectDropdownElement = selectDropdownElement;
        this.hideDropdown = hideDropdown;
        this.isModalContext = isModalContext;
        this.debugModeEnabled = debugModeEnabled;
        this.log = log.bind(this);
        // Internal state properties;
        this.originalInputRect = null;
        this.checkIntervalId = null;
    }

    get $input() {
        return this.selectInputElement();
    }

    get $dropdown() {
        return this.selectDropdownElement();
    }

    applyAndObserve() {
        // Already observing;
        if (this.checkIntervalId !== null) return;
        this.log(this.applyAndObserve);

        // Capture original input coordinates;
        this.originalInputRect = this.$input.getBoundingClientRect();

        // In 'fixed' mode the dropdown gets closed upon any actions out of combobox;
        window.addEventListener('resize', this.hideDropdown, { once: true, capture: false });
        window.addEventListener('scroll', this.hideDropdown, { once: true, capture: false });

        // Override dropdown positioning from 'absolute' to 'fixed' coordinates;
        const dropdownElement = this.$dropdown;
        const rect = dropdownElement.getBoundingClientRect();
        dropdownElement.style.position = 'fixed';
        dropdownElement.style.width = `${rect.width}px`;
        dropdownElement.style.zIndex = '999999';
        dropdownElement.style.top = (() => {
            if (isElementCloseToViewportBottom(this.$input, 230)) {
                let { height: inputHeight } = this.originalInputRect;
                return `${rect.top - rect.height - inputHeight * 1.2}px`;
            }
            return `${rect.top}px`;
        })();
        /**
         * Correlate depending on modal context (in modal context
         * there is no need to change 'left' and 'transform' style props);
         */
        if (!this.isModalContext) {
            dropdownElement.style.left = `${rect.left}px`;
            dropdownElement.style.transform = 'none';
        }
        // Launch interval check;
        this.checkIntervalId = setInterval(() => {
            this.log('running interval function...');
            const inputRect = this.$input?.getBoundingClientRect();
            if (inputRect.top !== this.originalInputRect.top || inputRect.left !== this.originalInputRect.left) {
                this.hideDropdown();
            }
        }, 20);
    }

    unobserve() {
        this.log(this.unobserve);
        clearInterval(this.checkIntervalId);
        this.checkIntervalId = null;
        window.removeEventListener('resize', this.hideDropdown, { capture: false });
        window.removeEventListener('scroll', this.hideDropdown, { capture: false });
    }
}
