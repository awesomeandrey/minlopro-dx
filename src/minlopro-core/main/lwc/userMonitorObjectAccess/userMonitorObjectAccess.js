import { LightningElement, track } from 'lwc';

// Constants;
const SECTION_SHOW_CLASS_NAME_ = 'expanded';
const SECTION_COLLAPSE_CLASS_NAME_ = 'collapsed';

export default class UserMonitorObjectAccess extends LightningElement {
    get $sections() {
        return [this.refs.objectPicker, this.refs.olsViewer, this.refs.flsViewer];
    }

    connectedCallback() {}

    handleRunDemo(event) {
        setTimeout(() => this.showSection(this.refs.olsViewer), 2000); // simulates user selecting object
        setTimeout(() => this.showSection(this.refs.flsViewer), 5000); // simulates clicking 'view FLS'
    }

    handleOpenObjectPicker(event) {
        this.showSection(this.refs.objectPicker);
    }

    handleOpenFlsViewer(event) {
        this.showSection(this.refs.flsViewer);
    }

    handleOpenOlsViewer(event) {
        this.showSection(this.refs.olsViewer);
    }

    showSection(sectionRef) {
        // Reset all;
        this.$sections.forEach((element) => {
            element.classList.remove(SECTION_SHOW_CLASS_NAME_);
            element.classList.add(SECTION_COLLAPSE_CLASS_NAME_);
        });
        // Expand particular section;
        sectionRef.classList.add(SECTION_SHOW_CLASS_NAME_);
        sectionRef.classList.remove(SECTION_COLLAPSE_CLASS_NAME_);
    }
}
