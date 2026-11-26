import { LightningElement, track } from 'lwc';
import { cloneObject, isNotEmpty, parseError, to, uniqueId } from 'c/utilities';
import toastify from 'c/toastify';

// Apex;
import getAllOrgLimitsApex from '@salesforce/apex/SystemInfoController.getOrgLimits';

export default class OrgLimits extends LightningElement {
    @track rawOrgLimits = [];
    @track showAllLimits = false;
    @track errorObj = {};
    @track sortedBy = 'value';
    @track sortedDirection = 'desc';

    get orgLimitsColumns() {
        return [
            {
                fieldName: 'name',
                label: 'Name',
                sortable: true
            },
            {
                fieldName: 'value',
                label: 'Consumed',
                type: 'number',
                sortable: true
            },
            {
                fieldName: 'limit',
                label: 'Limit',
                type: 'number',
                sortable: true
            }
        ];
    }

    get filteredOrgLimits() {
        return this.rawOrgLimits.filter(({ value: consumed }) => {
            if (this.showAllLimits) {
                return true;
            } else {
                return Number(consumed) > 0;
            }
        });
    }

    get orgLimitsData() {
        const { sortedBy, sortedDirection } = this;
        const multiplier = sortedDirection === 'asc' ? 1 : -1;
        return [...this.filteredOrgLimits].sort((a, b) => {
            const valueA = a[sortedBy];
            const valueB = b[sortedBy];
            return (valueA > valueB ? 1 : valueA < valueB ? -1 : 0) * multiplier;
        });
    }

    get hasOrgLimitsData() {
        return isNotEmpty(this.rawOrgLimits);
    }

    get hasError() {
        return isNotEmpty(this.errorObj);
    }

    get orgLimitsAmountBadge() {
        return `Org Limits Amount: ${this.orgLimitsData.length}`;
    }

    get toggleFilterBtnVariant() {
        return this.showAllLimits ? 'neutral' : 'brand';
    }

    get toggleFilterBtnLabel() {
        return this.showAllLimits ? 'Show Consumed' : 'Show All';
    }

    async connectedCallback() {
        await this.fetchOrgLimits();
    }

    async handleRefresh() {
        this.rawOrgLimits = [];
        this.errorObj = {};
        await this.fetchOrgLimits();
    }

    async handleToggleFilter() {
        this.showAllLimits = !this.showAllLimits;
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection: sortedDirection } = event.detail;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortedDirection;
    }

    async fetchOrgLimits() {
        const [error, result = []] = await to(getAllOrgLimitsApex());
        if (isNotEmpty(error)) {
            this.errorObj = error;
            const { message } = parseError(error);
            toastify.error({ message });
            return;
        }
        // Enrich with `uid`;
        this.rawOrgLimits = cloneObject(result).map((_) => ({
            uid: uniqueId(),
            ..._
        }));
    }
}
