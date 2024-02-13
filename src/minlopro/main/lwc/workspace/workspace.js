import { LightningElement, track } from 'lwc';

// Tab Names;
const $Playground = 'playground';
const $CurrencyRollup = 'currencyRollup';
const $DuplicatesManager = 'duplicatesManager';
const $DatatableContacts = 'datatableContacts';
const $CustomCombobox = 'customCombobox';
const $ModalDemo = 'lwcModalDemo';

export default class Workspace extends LightningElement {
    @track selectedTabName = $Playground;
    @track doCollapseTabs = window.localStorage.getItem('doCollapseTabs') === 'true';

    get tabs() {
        return [
            { label: 'Playground', name: $Playground, iconName: 'utility:activity' },
            { label: 'Currency Rollup', name: $CurrencyRollup, iconName: 'utility:money' },
            { label: 'Duplicates Manager', name: $DuplicatesManager, iconName: 'utility:groups' },
            { label: 'Datatable Contacts', name: $DatatableContacts, iconName: 'utility:table' },
            { label: 'Custom Combobox', name: $CustomCombobox, iconName: 'utility:bundle_policy' },
            { label: 'LWC Modal Demo', name: $ModalDemo, iconName: 'utility:preview' }
        ].map((tabInfo) => {
            tabInfo.label = this.doCollapseTabs ? '' : tabInfo.label;
            return tabInfo;
        });
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

    handleSelectTab(event) {
        const { name } = event.detail;
        this.selectedTabName = name;
    }

    handleToggleTabs(event) {
        this.doCollapseTabs = !this.doCollapseTabs;
        window.localStorage.setItem('doCollapseTabs', this.doCollapseTabs);
    }
}
