import { LightningElement, track, wire } from 'lwc';
import { isEmpty, isNotEmpty, parseError, resolveRecordId } from 'c/utilities';
import { getFieldValue, getRecord, updateRecord } from 'lightning/uiRecordApi';

// Modal;
import ModalFieldPathSelection from 'c/modalFieldPathSelection';

// Schema;
import WYSIWYG_NOTES_FIELD from '@salesforce/schema/Account.WysiwygNotes__c';

export default class WysiwygTab extends LightningElement {
    @track richTextValue = null;
    @track selectedAccountId = resolveRecordId('${SF_SAMPLE_ACCOUNT_ID}');
    @track loading = false;
    @track errorObj = null;

    get allowedFormats() {
        return [
            'font',
            'size',
            'bold',
            'italic',
            'underline',
            'strike',
            'list',
            'indent',
            'align',
            'link',
            'image',
            'clean',
            'table',
            'header',
            'color',
            'background',
            'code',
            'code-block',
            'script',
            'blockquote',
            'direction'
        ];
    }

    get customFormatOptions() {
        return [
            { iconName: 'utility:apex', name: 'code' },
            { iconName: 'utility:insert_tag_field', name: 'code-block' },
            { iconName: 'utility:text_template', name: 'script' },
            { iconName: 'utility:quotation_marks', name: 'blockquote' }
        ].map((_) => ({ ..._, label: `Format as <${_.name}>` }));
    }

    get accountLookupSettings() {
        return {
            displayInfo: {
                additionalFields: ['Phone']
            },
            matchingInfo: {
                primaryField: { fieldPath: 'Name' },
                additionalFields: [{ fieldPath: 'Phone' }]
            }
        };
    }

    get doDisableControls() {
        return this.loading || isEmpty(this.selectedAccountId);
    }

    get hasError() {
        return isNotEmpty(this.errorObj);
    }

    @wire(getRecord, { recordId: '$selectedAccountId', fields: [WYSIWYG_NOTES_FIELD] })
    wireAccountRecord({ error, data }) {
        if (error) {
            this.errorObj = parseError(error);
            throw new Error(this.errorObj.message);
        } else if (data && isEmpty(this.richTextValue)) {
            debugger;
            this.richTextValue = getFieldValue(data, WYSIWYG_NOTES_FIELD);
            if (isEmpty(this.richTextValue)) {
                // Set default value to play with;
                this.richTextValue =
                    "<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry.</p><p>Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.</p><p>Contrary to popular belief, Lorem Ipsum is not simply random text.</p>";
            }
        }
    }

    handleSelectAccount(event) {
        this.selectedAccountId = event.detail['recordId'];
        this.richTextValue = '';
    }

    async handleSaveAccount(event) {
        this.loading = true;
        try {
            await updateRecord({
                fields: { ['Id']: this.selectedAccountId, [WYSIWYG_NOTES_FIELD.fieldApiName]: this.richTextValue }
            });
        } catch (error) {
            this.errorObj = parseError(error);
        } finally {
            this.loading = false;
        }
    }

    handleChangeRichText(event) {
        this.richTextValue = event.detail.value;
    }

    handleApplyCustomFormat(event) {
        const selectedFormat = event.target.dataset.name;
        const inputRichText = this.refs.input;
        const currentFormat = inputRichText.getFormat();
        inputRichText.setFormat({ [selectedFormat]: !currentFormat[selectedFormat] }); // Toggle selected format state;
    }

    async handleInsertUserField(event) {
        const { selectedFieldPath } =
            (await ModalFieldPathSelection.open({
                size: 'medium',
                disableClose: false,
                objectType: 'User'
            })) || {};
        if (isNotEmpty(selectedFieldPath)) {
            const mergeExpression = ['{!$User.', selectedFieldPath, '}'].join('');
            this.refs.input.setRangeText(mergeExpression);
            this.refs.input.setFormat({ code: true });
        }
    }

    handleReset(event) {
        this.richTextValue = '';
        this.selectedAccountId = null;
        this?.refs?.recordPicker.clearSelection();
        this.loading = false;
        this.errorObj = null;
    }
}
