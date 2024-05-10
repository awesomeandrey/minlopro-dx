import { LightningElement, track, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { updateRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { cloneObject, parseError, resolveRecordId } from 'c/utilities';
import $Toastify from 'c/toastify';

// Apex Controller Methods;
import rollupOpportunitiesByAccountIdApex from '@salesforce/apex/CurrencyRollupController.rollupOpportunitiesByAccountId';
import getOrgCurrencyTypesApex from '@salesforce/apex/CurrencyRollupController.getOrgCurrencyTypes';
import fetchOpportunitiesByAccountIdApex from '@salesforce/apex/CurrencyRollupController.fetchOpportunitiesByAccountId';

// Schema;
import USER_CURRENCY_ISO_CODE_FIELD from '@salesforce/schema/User.CurrencyIsoCode';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import CURRENCY_ISO_CODE_FIELD from '@salesforce/schema/Opportunity.CurrencyIsoCode';
import AMOUNT_FIELD from '@salesforce/schema/Opportunity.Amount';
import STAGE_NAME_FIELD from '@salesforce/schema/Opportunity.StageName';

// Running user props;
import $UserId from '@salesforce/user/Id';
import $IsGuest from '@salesforce/user/isGuest';

export default class CurrencyRollupTab extends LightningElement {
    @track selectedAccountId = resolveRecordId('@SF_SAMPLE_ACCOUNT_ID');
    @track draftValues = [];
    @track apexRollupToOrgCurrency = 0;

    @track KEY_FIELD = 'Id';
    @track loading = false;
    @track error = null;
    @track tableErrors = { rows: {}, table: {} };

    get runningUserId() {
        return $UserId;
    }

    get runningUserCurrencyIsoCode() {
        if ($IsGuest) {
            return this.corporateCurrencyIsoCode;
        } else if (this.wiredUserInfo.data) {
            return getFieldValue(this.wiredUserInfo.data, USER_CURRENCY_ISO_CODE_FIELD);
        }
        return null;
    }

    get corporateCurrencyIsoCode() {
        return this.currencyTypeData.find(({ IsCorporate = false }) => IsCorporate)?.IsoCode;
    }

    get accountDisplayInfo() {
        return {
            additionalFields: ['Phone']
        };
    }

    get accountMatchingInfo() {
        return {
            primaryField: { fieldPath: 'Name' },
            additionalFields: [{ fieldPath: 'Phone' }]
        };
    }

    get hasAccountSelected() {
        return Boolean(this.selectedAccountId);
    }

    get hasErrors() {
        return Boolean(this.normalizedErrorObject);
    }

    get normalizedErrorObject() {
        if (Boolean(this.wiredRelatedOpps?.error)) {
            return this.wiredRelatedOpps.error;
        } else if (Boolean(this.wiredCurrencyTypes?.error)) {
            return this.wiredCurrencyTypes.error;
        } else if (Boolean(this.wiredRelatedOppsApex?.error)) {
            return this.wiredRelatedOppsApex.error;
        } else if (Boolean(this.error)) {
            return this.error;
        }
        return null;
    }

    get opportunityFields() {
        return [NAME_FIELD, CURRENCY_ISO_CODE_FIELD, AMOUNT_FIELD, STAGE_NAME_FIELD];
    }

    get opportunityFieldNames() {
        return this.opportunityFields.map(({ fieldApiName }) => `Opportunity.${fieldApiName}`);
    }

    get opportunityColumns() {
        return [
            {
                label: 'Name',
                fieldName: this.KEY_FIELD,
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: this.KEY_FIELD,
                    objectApiName: 'Opportunity',
                    value: { fieldName: this.KEY_FIELD }
                }
            },
            {
                label: 'Currency ISO Code',
                fieldName: 'CurrencyIsoCode',
                type: 'customPicklist',
                editable: true,
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: 'CurrencyIsoCode',
                    value: { fieldName: 'CurrencyIsoCode' },
                    objectApiName: 'Opportunity'
                }
            },
            {
                label: 'Amount',
                fieldName: 'Amount',
                type: 'currency',
                editable: true,
                typeAttributes: {
                    currencyCode: { fieldName: 'CurrencyIsoCode' },
                    currencyDisplayAs: 'symbol'
                }
            },
            {
                label: 'Stage',
                fieldName: 'StageName',
                type: 'customPicklist',
                typeAttributes: {
                    context: { fieldName: this.KEY_FIELD },
                    fieldName: 'StageName',
                    value: { fieldName: 'StageName' },
                    objectApiName: 'Opportunity'
                }
            }
        ];
    }

    get opportunityData() {
        const draftValuesAsMap = this.draftValues.reduce((map, draftRecord) => {
            map.set(draftRecord[this.KEY_FIELD], draftRecord);
            return map;
        }, new Map());
        const { data } = this.wiredRelatedOpps;
        if (data) {
            const relatedRecords = cloneObject(data.records).map(({ id, fields = {} }) => {
                return {
                    Id: id,
                    [CURRENCY_ISO_CODE_FIELD.fieldApiName]: fields[CURRENCY_ISO_CODE_FIELD.fieldApiName].value,
                    [AMOUNT_FIELD.fieldApiName]: fields[AMOUNT_FIELD.fieldApiName].value,
                    [STAGE_NAME_FIELD.fieldApiName]: fields[STAGE_NAME_FIELD.fieldApiName].value
                };
            });
            return relatedRecords.map((record) => {
                if (draftValuesAsMap.has(record[this.KEY_FIELD])) {
                    return { ...record, ...draftValuesAsMap.get(record[this.KEY_FIELD]) };
                } else {
                    return record;
                }
            });
        } else if (this.wiredRelatedOppsApex.data) {
            return cloneObject(this.wiredRelatedOppsApex.data).map((record) => {
                if (draftValuesAsMap.has(record[this.KEY_FIELD])) {
                    return { ...record, ...draftValuesAsMap.get(record[this.KEY_FIELD]) };
                } else {
                    return record;
                }
            });
        }
        return [];
    }

    get opportunitiesCount() {
        return this.opportunityData.length;
    }

    get stats() {
        return {
            'User Currency ISO Code': `${this.runningUserCurrencyIsoCode} ${$IsGuest ? '(defaulted to corporate)' : ''}`,
            'Corporate ISO Code': this.corporateCurrencyIsoCode,
            'Selected Account Record ID': this.selectedAccountId,
            'Is Guest User?': $IsGuest,
            'Has Errors?': this.hasErrors
        };
    }

    get rollupStats() {
        return {
            'Apex Rollup to Org Currency': `${this.apexRollupToOrgCurrency} ${this.corporateCurrencyIsoCode}`,
            'Manual Rollup to Org Currency': `${this.manualRollupToOrgCurrency} ${this.corporateCurrencyIsoCode}`
        };
    }

    get manualRollupToOrgCurrency() {
        /**
         * Works fine when running user is:
         * - Guest User
         * - Portal Enabled User
         * - Logged In Internal User
         */
        const currencyRateByCodeMap = this.currencyTypeData.reduce((map, { IsoCode, ConversionRate }) => {
            map.set(IsoCode, ConversionRate);
            return map;
        }, new Map());
        if (!currencyRateByCodeMap.has(this.runningUserCurrencyIsoCode)) {
            return 0;
        }
        return this.opportunityData
            .reduce((rollup, { Amount: oppAmount, CurrencyIsoCode: oppIsoCode }) => {
                let rate = currencyRateByCodeMap.get(oppIsoCode);
                return rollup + oppAmount / rate;
            }, 0)
            .toFixed(2);
    }

    get currencyTypeColumns() {
        return [
            {
                label: 'ISO Code',
                fieldName: 'IsoCode',
                type: 'text'
            },
            {
                label: 'Conversion Rate',
                fieldName: 'ConversionRate',
                type: 'text'
            },
            {
                label: 'Is Corporate?',
                fieldName: 'IsCorporate',
                type: 'boolean'
            }
        ];
    }

    get currencyTypeData() {
        const { data = [] } = this.wiredCurrencyTypes;
        if (data) {
            return cloneObject(data).map(({ IsoCode, ConversionRate, IsCorporate }) => {
                return { IsoCode, ConversionRate, IsCorporate };
            });
        }
        return [];
    }

    @wire(getRecord, {
        recordId: '$runningUserId',
        fields: [USER_CURRENCY_ISO_CODE_FIELD]
    })
    wiredUserInfo = {};

    @wire(getOrgCurrencyTypesApex)
    wiredCurrencyTypes = {};

    @wire(fetchOpportunitiesByAccountIdApex, { accountId: '$selectedAccountId' })
    wiredRelatedOppsApex = {};

    @wire(getRelatedListRecords, {
        parentRecordId: '$selectedAccountId',
        relatedListId: 'Opportunities',
        fields: '$opportunityFieldNames',
        sortBy: ['Opportunity.Name']
    })
    wiredRelatedOpps = {};

    // Event Handlers;

    handleReset(event) {
        this.selectedAccountId = null;
        this.refs.accountPicker.clearSelection();
        this.error = null;
        this.tableErrors = { rows: {}, table: {} };
        this.apexRollupToOrgCurrency = 0;
        this.loading = false;
    }

    handleRefreshWireAdapters(event) {
        refreshApex(this.wiredUserInfo);
        refreshApex(this.wiredRelatedOpps);
        refreshApex(this.wiredCurrencyTypes);
        refreshApex(this.wiredRelatedOppsApex);
    }

    handleAccountLookupChange(event) {
        console.log('CurrencyRollupTab.js', `handleAccountLookupChange() | ${JSON.stringify(event.detail)}`);
        const { recordId } = event.detail;
        this.handleReset();
        this.selectedAccountId = recordId || null;
    }

    handleCellChange(event) {
        event.stopPropagation();
        let [changedEntry = {}] = cloneObject(event.detail.draftValues);
        changedEntry[this.KEY_FIELD] = changedEntry[this.KEY_FIELD] || changedEntry['context'];
        delete changedEntry['context'];
        if (this.checkEntryPresenceByKeyField(changedEntry)) {
            this.draftValues = this.draftValues.map((entry) => {
                if (entry[this.KEY_FIELD] === changedEntry[this.KEY_FIELD]) {
                    for (let field of Object.getOwnPropertyNames(changedEntry)) {
                        entry[field] = changedEntry[field];
                    }
                }
                return entry;
            });
        } else {
            this.draftValues = [...this.draftValues, changedEntry];
        }
    }

    handleCellError(event) {
        const { context, fieldName, error } = event.detail;
        const currentErrors = this.tableErrors;
        currentErrors.rows[context] = {
            title: 'Cell Error Occurred',
            messages: [parseError(error).message],
            fieldNames: [fieldName]
        };
        this.tableErrors = cloneObject(currentErrors);
    }

    async handleSave(event) {
        console.group('onsave');
        // Turn on spinner;
        this.loading = true;
        // Capture current records state and update with values accordingly;
        let clonedDrafts = cloneObject(this.draftValues) || [];
        let clonedErrors = cloneObject(this.tableErrors) || {};
        // Save record updates via LDS;
        const updatePromises = clonedDrafts.map((record) => {
            const recordInput = { fields: cloneObject(record) };
            return updateRecord(recordInput);
        });
        const settledPromises = await Promise.allSettled(updatePromises);
        settledPromises.forEach((result, index) => {
            let { status, reason, value: data } = result;
            if (status === 'fulfilled') {
                console.log(`Record #${index} updated successfully`);
                // Copy modified fields only;
                let targetDraftRecord = clonedDrafts.find((_) => _[this.KEY_FIELD] === data.id);
                console.log('targetDraftRecord', JSON.stringify(targetDraftRecord));
                // Remove updated record from drafts;
                clonedDrafts = clonedDrafts.filter((_) => _[this.KEY_FIELD] !== targetDraftRecord[this.KEY_FIELD]);
                // Nullify any errors related this this draft;
                delete clonedErrors.rows[data.id];
            } else if (status === 'rejected') {
                console.error(`Record #${index} failed with reason: ${JSON.stringify(reason)}`);
                const recordId = this.draftValues[index][this.KEY_FIELD];
                const { message = '', output = {} } = reason.body;
                const fieldErrors = output['fieldErrors'] || {};
                console.error(`Failures | ${JSON.stringify(fieldErrors)}`);
                clonedErrors.rows[recordId] = {
                    title: message,
                    messages: Object.values(fieldErrors)
                        .flat()
                        .map((_) => _['message']),
                    fieldNames: Object.keys(fieldErrors)
                };
            } else {
                throw new Error(`Unknown error occurred: ${result}.`);
            }
        });
        // Re-set state;
        this.draftValues = clonedDrafts;
        this.tableErrors = clonedErrors;
        // Turn off spinner;
        this.loading = false;
        // Refresh wired Opportunities;
        await refreshApex(this.wiredRelatedOpps);
        console.groupEnd();
    }

    handleCancel(event) {
        this.draftValues = [];
    }

    async handleRollupOpps(event) {
        this.loading = true;
        try {
            this.apexRollupToOrgCurrency = await rollupOpportunitiesByAccountIdApex({ accountId: this.selectedAccountId });
        } catch (error) {
            // Capture error details;
            this.error = cloneObject(error);
            const { message } = parseError(error);
            // Show notification;
            $Toastify.error({ title: 'Failed to rollup Opps amount via Apex!', message });
        } finally {
            this.loading = false;
        }
    }

    // Service Methods;

    checkEntryPresenceByKeyField(entry = {}) {
        return this.draftValues.some((_) => _[this.KEY_FIELD] === entry[this.KEY_FIELD]);
    }
}
