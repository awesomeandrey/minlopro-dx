import { api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import LightningModal from 'lightning/modal';
import { isEmpty } from 'c/utilities';

export default class ModalFieldPathSelection extends LightningModal {
    @api objectType = 'Account';

    @track selectedFieldPath = null;

    get headerLabel() {
        return `Select ${this.wiredObjectInfo?.data?.label} Field`;
    }

    get doDisableConfirmBtn() {
        return isEmpty(this.selectedFieldPath);
    }

    @wire(getObjectInfo, { objectApiName: '$objectType' })
    wiredObjectInfo = {};

    handleSelectFieldPath(event) {
        this.selectedFieldPath = event.detail['value'];
    }

    handleConfirmAndCloseModal(event) {
        this.close({ selectedFieldPath: this.selectedFieldPath });
    }

    handleCloseModal(event) {
        this.close({ selectedFieldPath: null });
    }
}
