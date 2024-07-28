import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { isNotEmpty, parseError } from 'c/utilities';

// Static Resources;
import PDF_JS_ZIP from '@salesforce/resourceUrl/pdfJs';

export default class PdfToPngConverter extends LightningElement {
    @track isPdfJsInitialized = false;

    get pdfJsLib() {
        return window['pdfjsLib'];
    }

    @api
    async convert({ file, scale = 2 }) {
        if (!this.isPdfJsInitialized) {
            throw new Error('pdfJs was not initialized!');
        }
        const fileName = file.name;
        return new Promise((resolve, reject) => {
            const fileReader = new FileReader();
            fileReader.onload = async () => {
                const typedArray = new Uint8Array(fileReader.result);
                const pdf = await this.pdfJsLib.getDocument({ data: typedArray }).promise;
                const pngFiles = [];
                for (let i = 1; i <= pdf.numPages; i++) {
                    // Render each PDF page in canvas element;
                    const page = await pdf.getPage(i);
                    const viewport = page.getViewport({ scale });
                    const canvas = document.createElement('canvas');
                    const context = canvas.getContext('2d');
                    canvas.width = viewport.width;
                    canvas.height = viewport.height;
                    const renderContext = {
                        canvasContext: context,
                        viewport: viewport
                    };
                    await page.render(renderContext).promise;
                    // Generate File instance;
                    const pdfPageAsFile = await this.canvasToPngFile({ canvas, fileName: `${fileName} - Page ${i}` });
                    if (isNotEmpty(pdfPageAsFile)) {
                        pngFiles.push(pdfPageAsFile);
                    }
                }
                resolve(pngFiles);
            };
            fileReader.onerror = reject;
            fileReader.readAsArrayBuffer(file);
        });
    }

    renderedCallback() {
        if (this.isPdfJsInitialized) {
            return;
        }
        Promise.all([loadScript(this, PDF_JS_ZIP + '/pdf.min.js'), loadScript(this, PDF_JS_ZIP + '/pdf.worker.min.js')])
            .then(() => {
                this.isPdfJsInitialized = isNotEmpty(window['pdfjsLib']);
            })
            .catch((error) => {
                this.isPdfJsInitialized = false;
                console.error('Error loading "pdf.js":', parseError(error));
            });
    }

    async canvasToPngFile({ canvas, mimeType = 'image/png', fileName }) {
        return new Promise((resolve) => {
            canvas.toBlob((blob) => {
                if (blob) {
                    resolve(new File([blob], fileName, { type: mimeType }));
                } else {
                    console.warn('Canvas is empty! Could not convert PDF page to PNG.');
                    resolve(null);
                }
            }, mimeType);
        });
    }
}
