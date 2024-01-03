import { LightningElement, api, track } from 'lwc';
import { wait } from 'c/utilities';

/**
 * TODO
 * - handle CSS styles upon changes CDT (upon hover should still have yellow background color);
 * - pencil icon should be visible upon hover only;
 * - when edited, the content should be bold;
 */
export default class CdtCombobox extends LightningElement {
    // Properties below address record context;
    @api context = null;
    @api fieldName = null;
    // Properties below address 'c-combobox' LWC props;
    @api value = null;
    @api options = [];
    @api multi = false;
    // Asserts that cell can be edited;
    @api editable = false;

    @track mode = 'read'; // 'read' or 'edit';
    @track hasChanged = false;

    get isEditMode() {
        return this.mode === 'edit';
    }

    handleClickOnPencilIcon(event) {
        if (this.editable) {
            this.mode = 'edit';
            wait(() => {
                this.refs.combobox?.open();
            }, 300);
        }
    }

    handleChange(event) {
        event.stopPropagation();
        const { value } = event.detail;
        this.value = value;
        this.hasChanged = true;
    }

    handleClose(event) {
        // Revert back to 'read' display mode;
        this.mode = 'read';
        // Notify parent datatable LWC;
        if (this.hasChanged) {
            this.dispatchEvent(
                new CustomEvent('cellchange', {
                    composed: true,
                    bubbles: true,
                    cancelable: true,
                    detail: {
                        draftValues: [
                            {
                                context: this.context,
                                [this.fieldName]: this.value
                            }
                        ]
                    }
                })
            );
            this.hasChanged = false;
        }
    }
}
