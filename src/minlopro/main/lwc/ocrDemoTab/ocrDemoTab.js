import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { readFileAsBlob, uniqueId, parseError, cloneObject, isNotEmpty, isEmpty, readBase64AsFile, wait } from 'c/utilities';

import getFileVersionsByTypesApex from '@salesforce/apex/FilesManagementController.getFileVersionsByTypes';

// Originally inspired by https://github.com/mirkomutic/SalesforceOcr
export default class OcrDemoTab extends LightningElement {
    @track filesMap = new Map();
    @track processQueue = new Set();
    @track messageListenerFunc = this.handleTesseractPageResponse.bind(this);
    @track loading = false;
    @track error = null;

    get files() {
        return Array.from(this.filesMap.values());
    }

    get doShowSpinner() {
        return isEmpty(this.error) && (this.loading || this.processQueue.size > 0);
    }

    get doDisableBtn() {
        return this.filesMap.size === 0 || isNotEmpty(this.error);
    }

    get isProcessing() {
        return this.processQueue.size > 0;
    }

    get documentsData() {
        if (isEmpty(this.wiredFileVersions.data)) {
            return [];
        }
        return cloneObject(this.wiredFileVersions.data);
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
                type: 'customCodeSnippet'
            }
        ];
    }

    get stats() {
        return {
            'Images to process': this.filesMap.size
        };
    }

    get $ocrIframe() {
        return this.refs.ocrIframe;
    }

    get $pdfConverter() {
        return this.refs.pdfConverter;
    }

    @wire(getFileVersionsByTypesApex, { fileTypes: ['PDF', 'PNG'] })
    wiredFileVersions = {};

    connectedCallback() {
        window.addEventListener('message', this.messageListenerFunc);
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.messageListenerFunc);
    }

    // Event Handlers;

    async handleRecognizeText() {
        this.loading = true;
        this.processQueue = new Set();
        try {
            for await (const { file, id } of this.filesMap.values()) {
                // Convert file to Blob representation;
                const fileAsBlob = await readFileAsBlob(file);
                // Notify Visualforce Page;
                this.$ocrIframe.contentWindow.postMessage({ id, blob: fileAsBlob }, '*');
                // Append to process queue;
                this.processQueue.add(id);
            }
            wait(() => {
                if (this.isProcessing) {
                    // The OCR process took too long to complete, and an error likely occurred
                    this.loading = false;
                }
            }, 7000);
        } catch (error) {
            this.loading = false;
            this.error = parseError(error);
        }
    }

    async handleRowSelection(event) {
        this.loading = true;
        try {
            const { selectedRows } = event.detail;
            // Cast to `File` instances;
            const files = selectedRows.map(({ base64EncodedContent, type, name }) => {
                return readBase64AsFile(base64EncodedContent, type, name);
            });
            const capture = (file) => {
                return {
                    id: uniqueId(),
                    name: file.name,
                    size: file.size,
                    type: file.type,
                    file
                };
            };
            // Cast to manageable entries to post to iframe;
            const imageEntries = [];
            for (const fileItem of files) {
                if (fileItem.type === 'application/pdf') {
                    // Convert PDF to PNG image(s);
                    const pdfAsPngFiles = await this.$pdfConverter.convert({ file: fileItem });
                    pdfAsPngFiles.forEach((pngFile) => imageEntries.push(capture(pngFile)));
                } else {
                    imageEntries.push(capture(fileItem));
                }
            }
            console.table(imageEntries);
            this.filesMap = new Map(imageEntries.map((_) => [_.id, _]));
        } catch (error) {
            this.error = parseError(error);
        } finally {
            this.loading = false;
        }
    }

    // Service Methods;

    async handleReset() {
        this.filesMap = new Map();
        this.processQueue = new Set();
        this.loading = false;
        this.error = null;
        this.refs.datatable.selectedRows = [];
        await refreshApex(this.wiredFileVersions);
    }

    handleTesseractPageResponse(event) {
        if (event.source !== this.$ocrIframe.contentWindow) {
            return;
        }
        // Extract event payload;
        const { status, text, id, errorMessage } = event.data;
        // Capture recognized text & additional attributes;
        this.filesMap.get(id)['result'] = { status, text, errorMessage };
        // Remove file from processing queue;
        this.processQueue.delete(id);
        // Turn off spinner;
        if (!this.isProcessing) {
            this.loading = false;
        }
    }
}
