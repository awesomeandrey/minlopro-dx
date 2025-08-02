import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import { waitAsync } from 'c/utilities';

export default class ModalGenderSelectionDemo extends LightningModal {
    // Pre-built properties;
    @api label;
    @api size; // Supported values are small, medium, large, and full;
    @api disableClose = false;

    // Custom API properties;
    @api gender = null;
    @api genderOptions = [];

    @track loading = false;

    get modalState() {
        return {
            label: this.label,
            size: this.size,
            disableClose: this.disableClose,
            gender: this.gender,
            genderOptions: JSON.stringify(this.genderOptions)
        };
    }

    handleChangeGender(event) {
        const { value } = event.detail;
        this.gender = value;
        // Fire custom event from modal;
        this.dispatchEvent(
            new CustomEvent('genderchange', {
                detail: { selectedGender: this.gender }
            })
        );
    }

    async handleConfirmBtn() {
        if (!this.refs.genderInput.reportValidity()) {
            return;
        }
        this.disableClose = true;
        this.loading = true;
        // Imitate async process;
        await waitAsync(3000);
        this.disableClose = false;
        this.close({
            gender: this.gender
        });
    }

    handleCancelBtn() {
        this.close();
    }
}
