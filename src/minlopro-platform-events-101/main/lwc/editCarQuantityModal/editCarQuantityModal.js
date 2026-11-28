import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import { updateRecord } from 'lightning/uiRecordApi';
import { parseError } from 'c/utilities';
import $Toastify from 'c/toastify';

// Schema;
import CAR_QUANTITY_AVAILABLE_FIELD from '@salesforce/schema/Car__c.QuantityAvailable__c';

const QUANTITY_FIELD_API_NAME = CAR_QUANTITY_AVAILABLE_FIELD.fieldApiName;

export default class EditCarQuantityModal extends LightningModal {
    @api recordId;
    @api model;
    @api currentQuantity;

    @track quantity;
    @track loading = false;
    @track error = null;

    connectedCallback() {
        this.quantity = this.currentQuantity;
    }

    get modalLabel() {
        return `Edit Quantity — ${this.model}`;
    }

    handleChange(event) {
        this.quantity = event.detail.value;
    }

    async handleSave() {
        if (!this.refs.quantityInput.reportValidity()) {
            return;
        }
        this.loading = true;
        this.error = null;
        try {
            await updateRecord({
                fields: { Id: this.recordId, [QUANTITY_FIELD_API_NAME]: Number(this.quantity) }
            });
            $Toastify.success({ message: 'Quantity Available updated.' });
            this.close();
        } catch (error) {
            this.error = parseError(error);
            $Toastify.error({ message: 'Failed to update Quantity Available.' });
        } finally {
            this.loading = false;
        }
    }

    handleCancel() {
        this.close();
    }
}
