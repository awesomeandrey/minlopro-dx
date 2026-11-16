import { LightningElement, track } from 'lwc';
import { cloneObject, isEmpty, parseError } from 'c/utilities';

import detectSentiment from '@salesforce/apex/AwsSentimentAnalysisController.detectSentiment';

// Keyed by the exact 'Sentiment' label Comprehend returns.
const SENTIMENT_META = {
    POSITIVE: { label: 'Positive', badgeClass: 'slds-theme_success', iconName: 'utility:like', iconVariant: 'success' },
    NEGATIVE: { label: 'Negative', badgeClass: 'slds-theme_error', iconName: 'utility:dislike', iconVariant: 'error' },
    NEUTRAL: { label: 'Neutral', badgeClass: 'slds-theme_shade', iconName: 'utility:dash', iconVariant: 'neutral' },
    MIXED: { label: 'Mixed', badgeClass: 'slds-theme_warning', iconName: 'utility:merge', iconVariant: 'warning' }
};

export default class AwsSentimentAnalysisTab extends LightningElement {
    @track text = null;
    @track result = null;
    @track loading = false;
    @track error = null;

    get templates() {
        // Stable ids (not uniqueId()) - this getter re-evaluates on every re-render, and
        // handleSelectTemplate looks an id back up in a fresh call to this same getter.
        return [
            {
                id: 'positive-example',
                buttonLabel: 'Positive example',
                variant: 'success',
                iconName: 'utility:like',
                text: 'The support team resolved my issue within an hour, and I am absolutely thrilled with the fantastic service!'
            },
            {
                id: 'negative-example',
                buttonLabel: 'Negative example',
                variant: 'destructive',
                iconName: 'utility:dislike',
                text: 'My order arrived two weeks late, the box was damaged, and nobody responded to my complaints.'
            },
            {
                id: 'neutral-example',
                buttonLabel: 'Neutral example',
                variant: 'neutral',
                iconName: 'utility:dash',
                text: 'The quarterly report will be published on the company website next Monday at 9 AM.'
            }
        ];
    }

    get disableDetectBtn() {
        return isEmpty(this.text);
    }

    // The Lambda returns Comprehend's SentimentScore dict verbatim, keyed
    // 'Positive'/'Negative'/'Neutral'/'Mixed' - reused as-is for display labels.
    get sentimentResult() {
        if (!this.result) return null;
        const meta = SENTIMENT_META[this.result.sentiment] || SENTIMENT_META.NEUTRAL;
        const scores = Object.entries(this.result.scores || {}).map(([key, value]) => ({
            key,
            label: key,
            percent: Math.round(value * 100)
        }));
        return { ...meta, scores };
    }

    async handleDetect(event) {
        event.preventDefault();
        if (!this.refs.text.reportValidity()) return;
        this.loading = true;
        this.error = null;
        this.result = null;
        try {
            const response = await detectSentiment({ text: this.text });
            // HTTP API's Lambda integration honors the Lambda's own statusCode as the real
            // transport status, so response.success now reflects validation/Comprehend
            // failures (400/502) too, not just transport-level errors.
            const body = response.body ? JSON.parse(response.body) : {};
            if (!response.success) {
                throw new Error(body.instructions || `Callout failed with status ${response.statusCode}`);
            }
            this.result = body;
        } catch (error) {
            this.error = cloneObject(parseError(error));
        } finally {
            this.loading = false;
        }
    }

    handleReset(event) {
        event.preventDefault();
        this.text = this.result = this.error = null;
        this.loading = false;
    }

    handleTextChange(event) {
        event.preventDefault();
        this.text = event.detail.value;
    }

    handleSelectTemplate(event) {
        event.preventDefault();
        const template = this.templates.find((t) => t.id === event.currentTarget.dataset.id);
        if (template) {
            this.text = template.text;
            this.result = null;
            this.error = null;
        }
    }
}
