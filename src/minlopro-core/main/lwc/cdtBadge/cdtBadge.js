import { LightningElement, api } from 'lwc';

const VARIANT_CLASS_BY_NAME = {
    success: 'slds-theme_success',
    error: 'slds-theme_error',
    warning: 'slds-theme_warning',
    info: 'slds-theme_info',
    inverse: 'slds-badge_inverse',
    lightest: 'slds-badge_lightest'
};

export default class CdtBadge extends LightningElement {
    @api value = null;
    @api variant = null;

    get computedClass() {
        return VARIANT_CLASS_BY_NAME[this.variant] ?? 'slds-badge_lightest';
    }
}
