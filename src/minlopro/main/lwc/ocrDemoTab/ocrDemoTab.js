import { LightningElement, track } from 'lwc';
import { readFileAsBlob, uniqueId, parseError, cloneObject, isNotEmpty, isEmpty, pipe } from 'c/utilities';

// Originally inspired by https://github.com/mirkomutic/SalesforceOcr
export default class OcrDemoTab extends LightningElement {
    @track filesMap = new Map();
    @track processQueue = new Set();
    @track messageListenerFunc = this.handleVFResponse.bind(this);
    @track loading = false;
    @track error = null;

    get files() {
        return Array.from(this.filesMap.values());
    }

    get acceptedFormats() {
        return ['image/png', 'image/jpg', 'application/pdf'].join(',');
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

    get $iframe() {
        return this.refs.ocrIframe;
    }

    get $pdfConverter() {
        return this.refs.pdfConverter;
    }

    connectedCallback() {
        window.addEventListener('message', this.messageListenerFunc);
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.messageListenerFunc);
    }

    // Event Handlers;

    async handleFilesUpload(event) {
        this.loading = true;
        const files = [];
        for await (let uploadedFile of Array.from(event.target.files)) {
            if (uploadedFile.type === 'application/pdf') {
                // Convert PDF to PNG image(s);
                let pdfAsPngFiles = await this.$pdfConverter.convert({ file: uploadedFile });
                pdfAsPngFiles.forEach(pipe(this.captureFileInfo.bind(this), files.push.bind(files)));
            } else {
                files.push(this.captureFileInfo(uploadedFile));
            }
        }
        this.filesMap = new Map(files.map((_) => [_.id, _]));
        this.loading = false;
    }

    async handleRecognizeText(event) {
        this.loading = true;
        this.processQueue = new Set();
        try {
            for await (let { file, id } of this.filesMap.values()) {
                // Convert file to Blob representation;
                const fileAsBlob = await readFileAsBlob(file);
                // Notify Visualforce Page;
                this.$iframe.contentWindow.postMessage({ id, blob: fileAsBlob }, '*');
                // Append to process queue;
                this.processQueue.add(id);
            }
        } catch (error) {
            this.loading = false;
            this.error = parseError(error);
        }
    }

    // Service Methods;

    handleReset(event) {
        this.filesMap = new Map();
        this.processQueue = new Set();
        this.loading = false;
        this.error = null;
    }

    handleVFResponse(event) {
        if (event.source !== this.$iframe.contentWindow) {
            return;
        }
        // Extract event payload;
        const { status, text, id, errorMessage } = event.data;
        // Capture recognized text & additional attributes;
        this.filesMap.get(id)['result'] = { status, text, errorMessage };
        // Remove file from processing queue;
        this.processQueue.delete(id);
        this.processQueue = cloneObject(this.processQueue);
        // Turn off spinner;
        if (!this.isProcessing) {
            this.loading = false;
        }
    }

    captureFileInfo(file) {
        let id = uniqueId();
        return {
            id,
            name: file.name,
            size: file.size,
            type: file.type,
            file
        };
    }
}
