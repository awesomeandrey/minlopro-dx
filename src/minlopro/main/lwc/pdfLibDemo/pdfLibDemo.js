import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { isNotEmpty } from 'c/utilities';

// Static Resource
import $PdfLibResource from '@salesforce/resourceUrl/pdfLib';

export default class PdfLibDemo extends LightningElement {
    @track pdfLibInstance = null;
    @track loading = false;
    @track errorObj = null;

    get hasErrors() {
        return isNotEmpty(this.errorObj);
    }

    get stats() {
        return {
            'PDF-Lib Loaded': !!this.pdfLibInstance,
            'Has Errors': this.hasErrors
        };
    }

    connectedCallback() {}

    renderedCallback() {
        if (!!this.pdfLibInstance) {
            return;
        }
        loadScript(this, $PdfLibResource + '/pdf-lib.min.js')
            .then(() => {
                if (window['pdfLib'] || window['PDFLib']) {
                    this.pdfLibInstance = window['pdfLib'] || window['PDFLib'];
                } else {
                    this.errorObj = { message: 'PDF-LIB not loaded correctly.' };
                }
            })
            .catch((error) => {
                this.pdfLibInstance = null;
                this.errorObj = error;
            });
    }

    handleReset(event) {}
}
