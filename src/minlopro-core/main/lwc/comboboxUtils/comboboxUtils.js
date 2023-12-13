import { uniqueId } from 'c/utilities';

// Combobox Focused State Manager;
export default (function () {
    const uniqueComboboxIds = new Set();
    let focusedComboboxId = null;
    return {
        generateId: function () {
            const comboboxId = uniqueId();
            if (uniqueComboboxIds.has(comboboxId)) {
                throw new Error(`This COMBOBOX_ID has already been assigned: ${comboboxId}`);
            }
            uniqueComboboxIds.add(comboboxId);
            return comboboxId;
        },
        isFocused: function (comboboxId) {
            return focusedComboboxId === comboboxId;
        },
        focus: function (comboboxId) {
            focusedComboboxId = comboboxId;
        }
    };
})();
