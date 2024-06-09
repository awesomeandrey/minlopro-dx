import { LightningElement, track, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { isNotEmpty, isEmpty, cloneObject } from 'c/utilities';

// Static Resource
import $PdfLibResource from '@salesforce/resourceUrl/pdfLib';

// Apex Controller Methods;
import getPdfFilesApex from '@salesforce/apex/PdfLibDemoController.getPdfFiles';
import saveFileApex from '@salesforce/apex/PdfLibDemoController.saveFile';

export default class PdfLibDemo extends NavigationMixin(LightningElement) {
    @track pdfLibInstance = null;
    @track selectedDocuments = [];
    @track filePreviewUrl = null;
    @track fileDocumentId = null;
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
        return this.selectedDocuments.length < 2 || !this.pdfLibInstance;
    }

    get doDisableDownloadBtn() {
        return isEmpty(this.filePreviewUrl) || !this.pdfLibInstance;
    }

    get hasErrors() {
        return isNotEmpty(this.errorObj);
    }

    get stats() {
        return {
            'PDF-Lib Loaded': !!this.pdfLibInstance,
            'Files Amount': this.documentsData.length,
            'Selected Files Amount': this.selectedDocuments.length,
            'File Preview URL': this.filePreviewUrl,
            'Has Errors': this.hasErrors
        };
    }

    get $datatable() {
        return this.refs.datatable;
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
        const selectedRows = event.detail.selectedRows;
        this.selectedDocuments = selectedRows.map(({ id, name, base64Encoded }) => ({ id, name, base64Encoded }));
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

            // Save newly generated Blob as a file;
            const mergedPdfAsBase64 = await ((byteArray) => {
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
            const { Id: fileId, ContentDocumentId: fileDocumentId } = await saveFileApex({ base64Encoded: mergedPdfAsBase64 });
            this.fileDocumentId = fileDocumentId;
            console.log(`Id = ${fileId} and ContentDocumentId = ${fileDocumentId}`);

            // Generate preview URL pointing to the file;
            this.filePreviewUrl = await this[NavigationMixin.GenerateUrl]({
                type: 'standard__namedPage',
                attributes: { pageName: 'filePreview' },
                state: { recordIds: fileDocumentId }
            });
            console.log('Preview Url', this.filePreviewUrl);
        } catch (error) {
            this.errorObj = error;
            this.filePreviewUrl = null;
        } finally {
            this.loading = false;
        }
    }

    async handleReset(event) {
        this.selectedDocuments = [];
        this.filePreviewUrl = null;
        this.errorObj = null;
        this.$datatable.selectedRows = [];
        this.loading = true;
        if (isNotEmpty(this.fileDocumentId)) {
            await deleteRecord(this.fileDocumentId);
            this.fileDocumentId = null;
        }
        await refreshApex(this.wiredPdfFiles);
        this.loading = false;
    }
}
