import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { cloneObject, isEmpty, parseError, uniqueId } from 'c/utilities';
import $Toastify from 'c/toastify';

import getCarsApex from '@salesforce/apex/CarSalePlaygroundController.getCars';
import publishCarSaleEventsApex from '@salesforce/apex/CarSalePlaygroundController.publishCarSaleEvents';

import EditCarQuantityModal from 'c/editCarQuantityModal';

// Schema;
import CAR_MODEL_FIELD from '@salesforce/schema/Car__c.Model__c';
import CAR_SALE_EVENT_MODEL_FIELD from '@salesforce/schema/CarSaleEvent__e.Model__c';
import CAR_SALE_EVENT_QUANTITY_SOLD_FIELD from '@salesforce/schema/CarSaleEvent__e.QuantitySold__c';
import CAR_SALE_EVENT_SET_CHECKPOINT_FIELD from '@salesforce/schema/CarSaleEvent__e.SetCheckpoint__c';
import CAR_SALE_EVENT_THROW_EXCEPTION_FIELD from '@salesforce/schema/CarSaleEvent__e.ThrowException__c';

const KEY_FIELD = 'key';
const MAX_DRAFT_EVENTS = 15;
const DEFAULT_DRAFT_EVENTS_COUNT = 3;

const CAR_MODEL_FIELD_API_NAME = CAR_MODEL_FIELD.fieldApiName;
const MODEL_FIELD_API_NAME = CAR_SALE_EVENT_MODEL_FIELD.fieldApiName;
const QUANTITY_SOLD_FIELD_API_NAME = CAR_SALE_EVENT_QUANTITY_SOLD_FIELD.fieldApiName;
const SET_CHECKPOINT_FIELD_API_NAME = CAR_SALE_EVENT_SET_CHECKPOINT_FIELD.fieldApiName;
const THROW_EXCEPTION_FIELD_API_NAME = CAR_SALE_EVENT_THROW_EXCEPTION_FIELD.fieldApiName;

const QUANTITY_OPTIONS = Array.from({ length: 10 }, (_, index) => {
    const quantity = String(index + 1);
    return { label: quantity, value: quantity };
});

export default class PlatformEvents101Tab extends LightningElement {
    @track loading = false;
    @track error = null;
    @track draftEvents = [];
    @track draftValues = [];
    @track errors = { rows: {}, table: {} };

    @wire(getCarsApex)
    wiredCars = {};

    connectedCallback() {
        // Seed the table with a handful of draft rows so 'Add Row' isn't the only way to get started;
        this.draftEvents = Array.from({ length: DEFAULT_DRAFT_EVENTS_COUNT }, () => this.createDraftEvent());
    }

    get cars() {
        return isEmpty(this.wiredCars.data) ? [] : cloneObject(this.wiredCars.data);
    }

    get modelOptions() {
        return this.cars.map((car) => {
            const model = car[CAR_MODEL_FIELD_API_NAME];
            return { label: model, value: model };
        });
    }

    get columns() {
        return [
            {
                label: 'Model',
                fieldName: MODEL_FIELD_API_NAME,
                type: 'customCombobox',
                editable: true,
                typeAttributes: {
                    context: { fieldName: KEY_FIELD },
                    fieldName: MODEL_FIELD_API_NAME,
                    value: { fieldName: MODEL_FIELD_API_NAME },
                    options: this.modelOptions
                }
            },
            {
                label: 'Quantity Sold',
                fieldName: QUANTITY_SOLD_FIELD_API_NAME,
                type: 'customCombobox',
                editable: true,
                typeAttributes: {
                    context: { fieldName: KEY_FIELD },
                    fieldName: QUANTITY_SOLD_FIELD_API_NAME,
                    value: { fieldName: QUANTITY_SOLD_FIELD_API_NAME },
                    options: QUANTITY_OPTIONS
                }
            },
            {
                label: 'Set Checkpoint',
                fieldName: SET_CHECKPOINT_FIELD_API_NAME,
                type: 'boolean',
                editable: true
            },
            {
                label: 'Throw Exception',
                fieldName: THROW_EXCEPTION_FIELD_API_NAME,
                type: 'boolean',
                editable: true
            },
            {
                type: 'action',
                typeAttributes: {
                    rowActions: [
                        { label: 'Remove', name: 'remove' },
                        { label: 'Move Up', name: 'moveUp' },
                        { label: 'Move Down', name: 'moveDown' }
                    ]
                }
            }
        ];
    }

    get doDisablePublish() {
        return this.loading || isEmpty(this.draftEvents);
    }

    createDraftEvent() {
        return {
            key: uniqueId(),
            [MODEL_FIELD_API_NAME]: '',
            [QUANTITY_SOLD_FIELD_API_NAME]: '1',
            [SET_CHECKPOINT_FIELD_API_NAME]: false,
            [THROW_EXCEPTION_FIELD_API_NAME]: false
        };
    }

    handleAddRow() {
        if (this.draftEvents.length >= MAX_DRAFT_EVENTS) {
            $Toastify.warning({ message: `You cannot add more than ${MAX_DRAFT_EVENTS} entries to this table.` });
            return;
        }
        this.draftEvents = [...this.draftEvents, this.createDraftEvent()];
    }

    handleClear() {
        this.draftEvents = [this.createDraftEvent()];
        this.draftValues = [];
        this.errors = { rows: {}, table: {} };
    }

    handleRowAction(event) {
        const { action, row } = event.detail;
        const index = this.draftEvents.findIndex((item) => item.key === row.key);
        if (index === -1) {
            return;
        }
        switch (action.name) {
            case 'remove':
                this.draftEvents = this.draftEvents.filter((item) => item.key !== row.key);
                break;
            case 'moveUp':
                if (index > 0) {
                    this.draftEvents = this.swapRows(index, index - 1);
                }
                break;
            case 'moveDown':
                if (index < this.draftEvents.length - 1) {
                    this.draftEvents = this.swapRows(index, index + 1);
                }
                break;
            default:
                break;
        }
    }

    swapRows(indexA, indexB) {
        const reordered = [...this.draftEvents];
        [reordered[indexA], reordered[indexB]] = [reordered[indexB], reordered[indexA]];
        return reordered;
    }

    handleCellChange(event) {
        event.stopPropagation();
        const [changedEntry = {}] = cloneObject(event.detail.draftValues);
        changedEntry[KEY_FIELD] = changedEntry[KEY_FIELD] || changedEntry.context;
        delete changedEntry.context;
        const hasExistingDraft = this.draftValues.some((item) => item[KEY_FIELD] === changedEntry[KEY_FIELD]);
        if (hasExistingDraft) {
            this.draftValues = this.draftValues.map((item) => {
                return item[KEY_FIELD] === changedEntry[KEY_FIELD] ? { ...item, ...changedEntry } : item;
            });
        } else {
            this.draftValues = [...this.draftValues, changedEntry];
        }
    }

    handleCellError(event) {
        const { context, fieldName, error } = event.detail;
        this.errors = {
            ...this.errors,
            rows: {
                ...this.errors.rows,
                [context]: {
                    title: 'Cell Error Occurred',
                    messages: [parseError(error).message],
                    fieldNames: [fieldName]
                }
            }
        };
    }

    handleSave(event) {
        const draftValuesByKey = new Map(event.detail.draftValues.map((item) => [item[KEY_FIELD], item]));
        this.draftEvents = this.draftEvents.map((item) => {
            return draftValuesByKey.has(item.key) ? { ...item, ...draftValuesByKey.get(item.key) } : item;
        });
        this.draftValues = [];
        this.errors = { rows: {}, table: {} };
    }

    handleCancel() {
        this.draftValues = [];
        this.errors = { rows: {}, table: {} };
    }

    async handlePublishAll() {
        const invalidDraftEvents = this.draftEvents.filter((draftEvent) => {
            return isEmpty(draftEvent[MODEL_FIELD_API_NAME]) || isEmpty(draftEvent[QUANTITY_SOLD_FIELD_API_NAME]);
        });
        if (!isEmpty(invalidDraftEvents)) {
            this.errors = {
                rows: invalidDraftEvents.reduce((rows, draftEvent) => {
                    rows[draftEvent.key] = {
                        title: 'Missing Required Field(s)',
                        messages: ['Model and Quantity Sold are required before publishing.'],
                        fieldNames: []
                    };
                    return rows;
                }, {}),
                table: {}
            };
            $Toastify.error({ message: 'Please populate Model and Quantity Sold for every row before publishing.' });
            return;
        }
        this.loading = true;
        this.error = null;
        try {
            const events = this.draftEvents.map((draftEvent) => {
                return {
                    [MODEL_FIELD_API_NAME]: draftEvent[MODEL_FIELD_API_NAME],
                    [QUANTITY_SOLD_FIELD_API_NAME]: Number(draftEvent[QUANTITY_SOLD_FIELD_API_NAME]),
                    [SET_CHECKPOINT_FIELD_API_NAME]: !!draftEvent[SET_CHECKPOINT_FIELD_API_NAME],
                    [THROW_EXCEPTION_FIELD_API_NAME]: !!draftEvent[THROW_EXCEPTION_FIELD_API_NAME]
                };
            });
            await publishCarSaleEventsApex({ events });
            this.errors = { rows: {}, table: {} };
            $Toastify.success({
                message: `Published ${events.length} Car Sale Event(s)! Watch the Log Monitor for processing results.`
            });
        } catch (error) {
            this.error = parseError(error);
            $Toastify.error({ message: 'Failed to publish Car Sale Events.' });
        } finally {
            this.loading = false;
        }
    }

    async handleRefreshAll() {
        try {
            await refreshApex(this.wiredCars);
            $Toastify.success({ message: 'Refreshed Car inventory.' });
        } catch (error) {
            this.error = parseError(error);
            $Toastify.error({ message: 'Failed to refresh Car inventory.' });
        }
    }

    async handleEditQuantity(event) {
        const { id, model, quantity } = event.target.dataset;
        await EditCarQuantityModal.open({
            size: 'small',
            label: `Edit Quantity — ${model}`,
            recordId: id,
            model,
            currentQuantity: quantity
        });
        await refreshApex(this.wiredCars);
    }
}
