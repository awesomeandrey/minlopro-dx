import { LightningElement, track, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { isNotEmpty, isEmpty, cloneObject } from 'c/utilities';

// Static Resource
import $PdfLibResource from '@salesforce/resourceUrl/pdfLib';

// Apex Controller Methods;
import getPdfFilesApex from '@salesforce/apex/PdfLibDemoController.getPdfFiles';

export default class PdfLibDemo extends NavigationMixin(LightningElement) {
    @track pdfLibInstance = null;
    @track selectedDocuments = [];
    @track mergedPdfAsBase64 = null;
    @track loading = false;
    @track errorObj = null;

    get documentsData() {
        if (isEmpty(this.wiredPdfFiles.data)) {
            return [];
        }
        return cloneObject(this.wiredPdfFiles.data);
    }

    get documentsColumns() {
        return [
            {
                label: 'File Name',
                fieldName: 'id',
                type: 'customLookup',
                typeAttributes: {
                    context: { fieldName: 'id' },
                    fieldName: 'id',
                    objectApiName: 'ContentVersion',
                    value: { fieldName: 'id' },
                    nameFieldPath: 'Title'
                }
            },
            {
                label: 'File Type',
                fieldName: 'type',
                type: 'text'
            }
        ];
    }

    get doDisableMergeBtn() {
        return this.selectedDocuments.length < 1 || !this.pdfLibInstance;
    }

    get hasErrors() {
        return isNotEmpty(this.errorObj);
    }

    get stats() {
        return {
            'PDF-Lib Loaded': !!this.pdfLibInstance,
            'Files Amount': this.documentsData.length,
            'Selected Files Amount': this.selectedDocuments.length,
            'Has Errors': this.hasErrors
        };
    }

    get $datatable() {
        return this.refs.datatable;
    }

    get $iframe() {
        return this.refs.iframe;
    }

    @wire(getPdfFilesApex)
    wiredPdfFiles = {};

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

    handleSelectDocument(event) {
        const { selectedRows = [] } = event.detail;
        this.selectedDocuments = selectedRows.map((_) => ({ ..._ }));
    }

    async handleMergeDocuments(event) {
        try {
            this.loading = true;

            // Merge PDF files using 3rd party library;
            const { PDFDocument } = this.pdfLibInstance;
            const mergedPdf = await PDFDocument.create();
            for (let pdfFile of this.selectedDocuments) {
                const pdfBytes = Uint8Array.from(atob(pdfFile['base64Encoded']), (c) => c.charCodeAt(0));
                const pdfDoc = await PDFDocument.load(pdfBytes);
                const copiedPages = await mergedPdf.copyPages(pdfDoc, pdfDoc.getPageIndices());
                copiedPages.forEach((page) => mergedPdf.addPage(page));
            }
            const mergedPdfBytes = await mergedPdf.save();

            // Cast to Base64 encoded string;
            this.mergedPdfAsBase64 = await ((byteArray) => {
                return new Promise((resolve, reject) => {
                    const blob = new Blob([byteArray], { type: 'application/pdf' });
                    const reader = new FileReader();
                    reader.onload = function () {
                        const dataUrl = reader.result;
                        const base64 = dataUrl.split(',')[1];
                        resolve(base64);
                    };
                    reader.onerror = reject;
                    reader.readAsDataURL(blob);
                });
            })(mergedPdfBytes);
            // Pass Base64 encoded PDF file to custom Visualforce page;
            this.postMessageToIframe(this.mergedPdfAsBase64);
        } catch (error) {
            this.errorObj = error;
        } finally {
            this.loading = false;
        }
    }

    async handleReset(event) {
        this.postMessageToIframe(null);
        this.$datatable.selectedRows = [];
        this.selectedDocuments = [];
        this.errorObj = null;
        this.mergedPdfAsBase64 = null;
        this.loading = true;
        await refreshApex(this.wiredPdfFiles);
        this.loading = false;
    }

    // Service methods;

    postMessageToIframe(message) {
        // The origin validity is verified at Visualforce page level;
        const targetOrigin = '*';
        this.$iframe.contentWindow.postMessage(message, targetOrigin);
    }
}
