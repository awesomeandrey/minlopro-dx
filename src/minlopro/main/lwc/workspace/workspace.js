import { LightningElement, track } from 'lwc';
import { isEmpty } from 'c/utilities';

// Tab Names;
const $Playground = 'playground';
const $CurrencyRollup = 'currencyRollup';
const $DuplicatesManager = 'duplicatesManager';
const $DatatableContacts = 'datatableContacts';
const $CustomCombobox = 'customCombobox';
const $ModalDemo = 'lwcModalDemo';
const $FilesManager = 'filesManager';
const $LeadsManager = 'leadsManager';
const $ApprovalProcess = 'approvalProcessBreakdown';

// Custom Permissions;
import IS_FILES_MANAGER from '@salesforce/customPermission/IsFilesManager';
import IS_LEADS_MANAGER from '@salesforce/customPermission/IsLeadManager';

export default class Workspace extends LightningElement {
    @track selectedTabName = this.isValidTabName(this.lc_selectedTabName) ? this.lc_selectedTabName : $Playground;
    @track doCollapseTabs = this.lc_doCollapseTabs;

    get tabs() {
        return [
            { label: 'Playground', name: $Playground, iconName: 'utility:activity', visible: true },
            { label: 'Currency Rollup', name: $CurrencyRollup, iconName: 'utility:money', visible: true },
            { label: 'Duplicates Manager', name: $DuplicatesManager, iconName: 'utility:groups', visible: true },
            { label: 'Datatable Contacts', name: $DatatableContacts, iconName: 'utility:table', visible: true },
            { label: 'Custom Combobox', name: $CustomCombobox, iconName: 'utility:bundle_policy', visible: true },
            { label: 'LWC Modal Demo', name: $ModalDemo, iconName: 'utility:preview', visible: true },
            { label: 'Files Manager', name: $FilesManager, iconName: 'utility:share_file', visible: IS_FILES_MANAGER },
            { label: 'Leads Conversion', name: $LeadsManager, iconName: 'utility:lead', visible: IS_LEADS_MANAGER },
            { label: 'Approval Process Breakdown', name: $ApprovalProcess, iconName: 'utility:approval', visible: true }
        ]
            .map((tabInfo) => {
                tabInfo.label = this.doCollapseTabs ? '' : tabInfo.label;
                tabInfo.iconName = isEmpty(tabInfo.iconName) ? 'utility:bundle_policy' : tabInfo.iconName;
                return tabInfo;
            })
            .filter(({ visible = false }) => visible);
    }

    get isPlayground() {
        return this.selectedTabName === $Playground;
    }

    get isCurrencyRollup() {
        return this.selectedTabName === $CurrencyRollup;
    }

    get isDuplicatesManager() {
        return this.selectedTabName === $DuplicatesManager;
    }

    get isDatatableContacts() {
        return this.selectedTabName === $DatatableContacts;
    }

    get isCustomCombobox() {
        return this.selectedTabName === $CustomCombobox;
    }

    get isModalDemo() {
        return this.selectedTabName === $ModalDemo;
    }

    get isFilesManager() {
        return this.selectedTabName === $FilesManager;
    }

    get isLeadsManager() {
        return this.selectedTabName === $LeadsManager;
    }

    get isApprovalProcessBreakdown() {
        return this.selectedTabName === $ApprovalProcess;
    }

    get lc_selectedTabName() {
        return window.localStorage.getItem('selectedTabName');
    }

    get lc_doCollapseTabs() {
        return window.localStorage.getItem('doCollapseTabs') === 'true';
    }

    connectedCallback() {}

    handleSelectTab(event) {
        const { name } = event.detail;
        this.selectedTabName = name;
        window.localStorage.setItem('selectedTabName', name);
    }

    handleToggleTabs(event) {
        this.doCollapseTabs = !this.doCollapseTabs;
        window.localStorage.setItem('doCollapseTabs', this.doCollapseTabs);
    }

    isValidTabName(tabNameToCheck) {
        return this.tabs.some(({ name }) => name === tabNameToCheck);
    }
}
