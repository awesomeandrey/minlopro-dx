import { LightningElement, api } from 'lwc';

export default class LwcToPdfTab extends LightningElement {
    @api mode = 'default'; // options: default, print

    get vfPageUrl() {
        return '/apex/LwcToPdfPoc';
    }

    /**
     * Pros: the easiest option.
     * Cons:
     *  - captures current Application header (but renders as blank space)
     *  - captures current Application footer (utility tab)
     *  - the aforementioned elements can't be excluded
     *  - ignores 'standard:avatar' icon(s)
     */
    handlePrintCurrentPage(event) {
        event.preventDefault();
        window.print();
    }

    // Inspired by https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_media_queries/Printing
    handlePrintViaDynamicIframe() {
        this.refs.iframeContainer.textContent = '';

        function setPrint() {
            /**
             * `SecurityError: Failed to set a named property 'onbeforeunload' on 'Window':
             * Blocked a frame with origin "https://nosoftware-customization-18-dev-ed.scratch.lightning.force.com"
             * from accessing a cross-origin frame.`
             *
             * `SecurityError: Failed to read a named property 'print' from 'Window':
             * Blocked a frame with origin "https://nosoftware-customization-18-dev-ed.scratch.lightning.force.com"
             * from accessing a cross-origin frame.`
             */
            this.contentWindow.print(); // Set 'debugger' here to capture error above;
        }
        const vfFrame = document.createElement('iframe');
        vfFrame.onload = setPrint;
        vfFrame.setAttribute('sandbox', 'allow-scripts allow-same-origin'); // Still can't bypass SOP enforced by browser (Same-Origin-Policy);
        vfFrame.style.display = 'none';
        vfFrame.src = this.vfPageUrl;
        this.refs.iframeContainer.appendChild(vfFrame);
    }

    // The idea is to trigger 'window.print()' by sending 'window.postMessage()' signal to hidden iframe
    handlePrintViaLtngOut(event) {
        event.preventDefault();
        this.refs.ltngOutIframeContainer.contentWindow.postMessage({ type: 'PRINT', delay: 1000 }, '*');
    }
}
