import { LightningElement, track } from 'lwc';
import { isEmpty } from 'c/utilities';

export default class UserMonitorObjectAccess extends LightningElement {
    @track selectedObjectName = 'Account';

    get doDisableOlsViewerSection() {
        return isEmpty(this.selectedObjectName);
    }

    get doDisableFlsViewerSection() {
        return isEmpty(this.selectedObjectName);
    }

    get $progressSlider() {
        return this.refs.progressSlider;
    }

    handlePrevious(event) {
        event.preventDefault();
        this.$progressSlider.previous();
    }

    handleNext(event) {
        event.preventDefault();
        this.$progressSlider.next();
    }
}
