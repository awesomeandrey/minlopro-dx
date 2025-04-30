import { LightningElement, track } from 'lwc';
import ModalGenderSelectionDemo from 'c/modalGenderSelectionDemo';

// Custom combobox options;
const GENDER_OPTIONS = [
    { label: 'Male', value: 'male', iconName: 'utility:activity' },
    { label: 'Female', value: 'female', iconName: 'utility:data_cloud' },
    { label: 'Bisexual', value: 'bisexual', iconName: 'utility:apex_plugin' }
];

export default class ModalDemoTab extends LightningElement {
    @track modalSize = 'small';
    @track selectedGender = null;

    get modalSizeOptions() {
        return [
            { label: 'Small', value: 'small' },
            { label: 'Medium', value: 'medium' },
            { label: 'Large', value: 'large' },
            { label: 'Full', value: 'full' }
        ];
    }

    get genderOptions() {
        return GENDER_OPTIONS;
    }

    handleChangeModalSize(event) {
        const { value } = event.detail;
        this.modalSize = value;
    }

    async handleOpenModal() {
        // The result data can’t be modified after the close operation begins;
        const result = await ModalGenderSelectionDemo.open({
            label: 'Demo Modal Header',
            size: this.modalSize,
            disableClose: false,
            gender: this.selectedGender,
            genderOptions: this.genderOptions,
            /**
             * A modal can only fire events captured by the component that opened it, not the modal itself.
             * Normal techniques can't catch events that fire from the modal, because the events bubble up
             * to a top root element outside of the component that opened the modal.
             *
             * To capture modal events, attach them in the .open() method invoked by the component that opens the modal.
             *
             * Capturing modal events requires Lightning Web Security (LWS) to be enabled in the Salesforce org.
             *
             * If your modal component runs in an org that can’t enable LWS yet,
             * the workaround is to wrap the code that calls dispatchEvent in a child component that extends LightningElement.
             * Use the wrapper component as a child of one of the modal components in the modal template.
             */
            ongenderchange: (event) => {
                event.stopPropagation();
                console.log('> Modal Custom Event', JSON.stringify(event.detail));
            }
        });
        console.log('> Modal Close Promise', JSON.stringify(result));
        if (result !== undefined) {
            const { gender: newGender } = result;
            console.log(`> Changed gender to [${newGender}]`);
            this.selectedGender = newGender;
        } else {
            console.log('> Closed Modal without changing gender');
        }
    }
}
