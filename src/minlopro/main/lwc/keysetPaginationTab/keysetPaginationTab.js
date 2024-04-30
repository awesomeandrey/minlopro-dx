import { LightningElement, track } from 'lwc';
import { cloneObject, isNotEmpty, parseError } from 'c/utilities';

// Apex Controllers;
import getTotalContactsCountApex from '@salesforce/apex/KeysetPaginationController.getTotalContactsCount';
import getContactRecordsApex from '@salesforce/apex/KeysetPaginationController.getContactRecords';

// Constants;
const DEFAULT_SORTED_BY = 'Title';
const DEFAULT_SORTED_DIRECTION = 'ASC';
const DEFAULT_PAGE_SIZE = 8;

export default class KeysetPaginationTab extends LightningElement {
    @track totalContactsCount = 0;
    @track contactsData = [];
    @track sortedBy = DEFAULT_SORTED_BY;
    @track sortedDirection = DEFAULT_SORTED_DIRECTION;
    @track pageNumber = 1;
    @track pageSize = DEFAULT_PAGE_SIZE;

    @track loading = false;
    @track error = null;

    get stats() {
        return {
            'Total Contacts Count': this.totalContactsCount,
            'Sort Order': this.sortedDirection.toUpperCase(),
            'Current Page Number': this.pageNumber,
            'Total Pages #': this.totalPagesAmount,
            'Page Size': this.pageSize
        };
    }

    get normalizedColumns() {
        return [
            // {
            //     label: 'Id',
            //     fieldName: 'Id',
            //     type: 'text'
            // },
            {
                label: 'Name',
                fieldName: 'Name',
                type: 'customLookup',
                sortable: true,
                typeAttributes: {
                    context: { fieldName: 'Id' },
                    fieldName: 'Id',
                    objectApiName: 'Contact',
                    value: { fieldName: 'Id' }
                }
            },
            {
                label: 'Title',
                fieldName: 'Title',
                type: 'text',
                sortable: true
            },
            {
                label: 'Mobile Phone',
                fieldName: 'MobilePhone',
                type: 'phone',
                sortable: true
            }
        ];
    }

    get normalizedRecords() {
        return cloneObject(this.contactsData);
    }

    get rowNumberOffset() {
        return (this.pageNumber - 1) * this.pageSize;
    }

    get totalPagesAmount() {
        return Math.ceil(this.totalContactsCount / this.pageSize);
    }

    get disablePrev() {
        return !this.hasData || this.isFirstPage;
    }

    get disableNext() {
        return !this.hasData || this.isLastPage;
    }

    get hasData() {
        return isNotEmpty(this.contactsData);
    }

    // SOQL query getters;

    get isFirstPage() {
        return this.pageNumber === 1;
    }

    get isLastPage() {
        return this.pageNumber === this.totalPagesAmount;
    }

    get pageFirstRecord() {
        return this.contactsData[0] || {};
    }

    get pageLastRecord() {
        return this.contactsData[this.contactsData.length - 1] || {};
    }

    get previousRecordId() {
        return this.pageFirstRecord?.Id || null;
    }

    get nextRecordId() {
        return this.pageLastRecord?.Id || null;
    }

    get previousSortValue() {
        return this.pageFirstRecord[this.sortedBy] || null;
    }

    get nextSortValue() {
        return this.pageLastRecord[this.sortedBy] || null;
    }

    async connectedCallback() {
        await this.pullTotalContactCount();
        await this.pullContacts();
    }

    // Event Handlers;

    async handleReset(event) {
        this.loading = false;
        this.sortedBy = DEFAULT_SORTED_BY;
        this.sortedDirection = DEFAULT_SORTED_DIRECTION;
        this.pageNumber = 1;
        this.pageSize = DEFAULT_PAGE_SIZE;
        this.contactsData = [];
        await this.pullTotalContactCount();
        await this.pullContacts();
    }

    async handleSort(event) {
        const { fieldName: sortBy, sortDirection = 'asc' } = event.detail;
        await this.handleReset();
        this.sortedBy = sortBy;
        this.sortedDirection = sortDirection;
        await this.pullContacts();
    }

    async handleFirstPage() {
        let pageInfo = {
            currentPageNumber: this.pageNumber,
            requestedPageNumber: 1
        };
        this.pageNumber = 1;
        await this.pullContacts(pageInfo);
    }

    async handleNext() {
        let pageInfo = {
            currentPageNumber: this.pageNumber,
            requestedPageNumber: this.pageNumber + 1
        };
        this.pageNumber++;
        await this.pullContacts(pageInfo);
    }

    async handlePrev() {
        let pageInfo = {
            currentPageNumber: this.pageNumber,
            requestedPageNumber: this.pageNumber - 1
        };
        this.pageNumber--;
        await this.pullContacts(pageInfo);
    }

    async handleLastPage() {
        let pageInfo = {
            currentPageNumber: this.pageNumber,
            requestedPageNumber: this.totalPagesAmount
        };
        this.pageNumber = this.totalPagesAmount;
        await this.pullContacts(pageInfo);
    }

    // Service Methods;

    async pullTotalContactCount() {
        this.loading = true;
        try {
            this.error = null;
            this.totalContactsCount = await getTotalContactsCountApex();
        } catch (error) {
            this.error = parseError(error);
        } finally {
            this.loading = false;
        }
    }

    async pullContacts(pageInfo = { currentPageNumber: 1, requestedPageNumber: 1 }) {
        this.loading = true;
        try {
            this.error = null;
            const queryRequest = cloneObject({
                ...pageInfo,
                totalRecordsCount: this.totalContactsCount,
                pageSize: this.pageSize,
                sortBy: this.sortedBy,
                sortDirection: this.sortedDirection,
                previousRecordId: this.previousRecordId,
                nextRecordId: this.nextRecordId,
                previousSortValue: this.previousSortValue,
                nextSortValue: this.nextSortValue
            });
            console.table(queryRequest);
            this.contactsData = await getContactRecordsApex({ queryRequest });
        } catch (error) {
            this.error = parseError(error);
        } finally {
            this.loading = false;
        }
    }
}
