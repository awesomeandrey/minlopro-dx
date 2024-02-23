import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { getFieldValue, getRecord, updateRecord } from 'lightning/uiRecordApi';
import { cloneObject, isNotEmpty } from 'c/utilities';
import $Toastify from 'c/toastify';

// Apex;
import convertLeadApex from '@salesforce/apex/LeadsManagementController.convertLead';

// Schema;
import LEAD_CHECK_IF_DUPLICATE_FIELD from '@salesforce/schema/Lead.CheckIfDuplicate__c';

export default class ConvertLeadModal extends LightningModal {
    @api recordId; // Lead Record ID;
    // Conversion settings;
    @track dryRun = true;
    @track selectedAccountId = null;
    @track selectedContactId = null;
    @track doNotCreateOpportunity = true;
    @track sendNotificationEmail = false;
    @track overwriteLeadSource = false;
    @track allowSaveOnDuplicateRules = false;
    // Utility props;
    @track loading = false;
    @track errorObj = null;

    get stats() {
        return {
            'Lead ID': this.recordId,
            'Parent Account ID': this.selectedAccountId,
            'Parent Contact ID': this.selectedContactId,
            'Has Error': this.hasError
        };
    }

    get hasError() {
        return isNotEmpty(this.errorObj);
    }

    get conversionSettings() {
        // 'name' prop MUST correspond to valid property;
        return [
            { label: 'Dry Run?', name: 'dryRun', value: this.dryRun },
            { label: 'Do Not Create Opportunity?', name: 'doNotCreateOpportunity', value: this.doNotCreateOpportunity },
            { label: 'Send Notification Email?', name: 'sendNotificationEmail', value: this.sendNotificationEmail },
            { label: 'Overwrite Lead Source?', name: 'overwriteLeadSource', value: this.overwriteLeadSource },
            { label: 'Allow Save On Duplicates?', name: 'allowSaveOnDuplicateRules', value: this.allowSaveOnDuplicateRules }
        ];
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [LEAD_CHECK_IF_DUPLICATE_FIELD]
    })
    wiredLead = {};

    handleAccountChange(event) {
        const { recordId } = event.detail;
        this.selectedAccountId = recordId || null;
    }

    handleContactChange(event) {
        const { recordId } = event.detail;
        this.selectedContactId = recordId || null;
    }

    handleConversionSettingChange(event) {
        const { name } = event.target.dataset;
        const { checked } = event.detail;
        this[name] = checked;
    }

    async handleToggleLeadCheckbox() {
        const recordInput = {
            fields: {
                Id: this.recordId,
                CheckIfDuplicate__c: !getFieldValue(this.wiredLead.data, LEAD_CHECK_IF_DUPLICATE_FIELD)
            }
        };
        try {
            this.loading = true;
            this.errorObj = null;
            await updateRecord(recordInput);
        } catch (error) {
            this.errorObject = cloneObject(error);
        } finally {
            this.loading = false;
        }
    }

    async handleConvertBtn() {
        let config = {
            leadId: this.recordId,
            accountId: this.selectedAccountId,
            contactId: this.selectedContactId,
            doNotCreateOpportunity: this.doNotCreateOpportunity,
            sendNotificationEmail: this.sendNotificationEmail,
            overwriteLeadSource: this.overwriteLeadSource,
            allowSaveOnDuplicateRules: this.allowSaveOnDuplicateRules
        };
        try {
            console.group(`Converting Lead [${this.recordId}]`);
            this.errorObj = null;
            this.loading = true;
            let conversionResult = JSON.parse(
                await convertLeadApex({
                    config: JSON.stringify(config),
                    dryRun: this.dryRun
                })
            );
            console.table(cloneObject(conversionResult));
            console.log('RAW OUTPUT', cloneObject(conversionResult));
            if (!this.dryRun) {
                // Celebrate & close modal;
                await this.refs.confetti.celebrate();
                $Toastify.success({ message: 'Lead was successfully converted!' });
                this.handleCancelBtn();
            } else {
                $Toastify.info({ message: 'Dry-run lead conversion results are displayed in browser console.' });
            }
        } catch (error) {
            this.errorObj = cloneObject(error);
            $Toastify.error({ message: 'Failed to convert the lead.' });
        } finally {
            this.loading = false;
            console.groupEnd();
        }
    }

    handleCancelBtn() {
        this.disableClose = false;
        this.close();
    }
}
