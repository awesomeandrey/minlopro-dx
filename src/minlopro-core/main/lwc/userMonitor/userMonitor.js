import { LightningElement, track } from 'lwc';
import { cloneObject, parseError, debounce, isNotEmpty } from 'c/utilities';
import $Toastify from 'c/toastify';

// Static Resources;
import COMMONS_ASSETS from '@salesforce/resourceUrl/CommonsAssets';

// Apex Controller Methods;
import getPermissionsApex from '@salesforce/apex/UserMonitorController.getPermissions';

export default class UserMonitor extends LightningElement {
    @track permissionData = [];
    @track permissionFilters = {
        showEnabled: true,
        showDisabled: false,
        showSystem: false,
        showCustom: false,
        showUser: false,
        searchKeyword: null
    };
    @track permissionSortingState = {
        sortedBy: 'label',
        sortedDirection: 'asc'
    };
    @track loading = false;
    @track debouncedHandleChangeSearchKeyword = debounce(this.handleChangeSearchKeyword.bind(this), 1000);

    get permissionColumns() {
        return [
            {
                label: 'Label',
                fieldName: 'label',
                type: 'text',
                sortable: true
            },
            {
                label: 'API Name',
                fieldName: 'name',
                type: 'customCodeSnippet',
                sortable: true
            },
            {
                label: 'Value',
                fieldName: 'value',
                type: 'boolean',
                sortable: true
            },
            {
                label: 'Type',
                fieldName: 'type',
                type: 'customBadge',
                sortable: true
            }
        ];
    }

    get normalizedPermissionData() {
        return [...this.permissionData]
            .filter((permission) => {
                const doMatchByValueToggle = () => {
                    const { showEnabled, showDisabled } = this.permissionFilters;
                    if (showEnabled === showDisabled) {
                        return true;
                    }
                    return showEnabled ? permission.value === true : permission.value === false;
                };
                const doMatchByTypeToggle = () => {
                    const { showSystem, showCustom, showUser } = this.permissionFilters;
                    if (showSystem === showCustom && showCustom === showUser) {
                        return true;
                    }
                    const allowed = [showSystem && 'system', showCustom && 'custom', showUser && 'user'].filter(Boolean);
                    return allowed.includes(permission.type);
                };

                const doMatchBySearchKeyword = () => {
                    let { searchKeyword } = this.permissionFilters;
                    if (typeof searchKeyword?.trim() !== 'string') {
                        // Disregard search keyword;
                        return true;
                    }
                    searchKeyword = searchKeyword.toLowerCase();
                    return (
                        permission.label.toLowerCase().includes(searchKeyword) ||
                        permission.name.toLowerCase().includes(searchKeyword)
                    );
                };
                return doMatchByValueToggle() && doMatchByTypeToggle() && doMatchBySearchKeyword();
            })
            .sort((a, b) => {
                // Handle sorting;
                const { sortedBy, sortedDirection } = this.permissionSortingState;
                const isAscending = sortedDirection.toLowerCase() === 'asc';
                const valA = a[sortedBy];
                const valB = b[sortedBy];
                if (typeof valA === 'boolean' && typeof valB === 'boolean') {
                    return isAscending ? valA - valB : valB - valA;
                }
                if (typeof valA === 'string' && typeof valB === 'string') {
                    return isAscending ? valA.localeCompare(valB) : valB.localeCompare(valA);
                }
                return 0;
            });
    }

    get normalizedPermissionFilters() {
        return new Proxy(
            { ...this.permissionFilters },
            {
                get(target, propName) {
                    if (typeof propName === 'string' && propName.endsWith('Variant')) {
                        let filterPropName = propName.replace('Variant', '');
                        return target[filterPropName] === true ? 'brand' : 'neutral';
                    }
                    return target[propName];
                }
            }
        );
    }

    get permissionCount() {
        return `# ${this.normalizedPermissionData.length}`;
    }

    get hasPermissions() {
        return isNotEmpty(this.normalizedPermissionData);
    }

    get backgroundImageUrl() {
        return `${COMMONS_ASSETS}/svg/background2.svg`;
    }

    async connectedCallback() {
        await this.handleRefresh();
    }

    handleSort(event) {
        const { fieldName: sortBy, sortDirection = 'asc' } = event.detail;
        this.permissionSortingState = {
            sortedBy: sortBy,
            sortedDirection: sortDirection
        };
    }

    async handleRefresh() {
        try {
            this.loading = true;
            this.permissionData = cloneObject(await getPermissionsApex());
            this.refs?.datatable?.scrollToTop();
        } catch (error) {
            console.table(error);
            $Toastify.error({ message: parseError(error).message });
        } finally {
            this.loading = false;
        }
    }

    handleChangeSearchKeyword(event) {
        const { value } = event.detail;
        this.permissionFilters.searchKeyword = value;
    }

    handleChangeToggleFilter(event) {
        let { filterName } = event.target.dataset;
        this.permissionFilters[filterName] = !this.permissionFilters[filterName];
    }
}
