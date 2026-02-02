import { LightningElement, track } from 'lwc';
import { uniqueId } from 'c/utilities';

// import USER_ID from '@salesforce/user/Id';
import USER_TIME_ZONE from '@salesforce/i18n/timeZone';
import USER_LOCALE from '@salesforce/i18n/locale';

// Constants;
// const SAMPLE_ACCOUNT_ID = resolveRecordId('${SF_SAMPLE_ACCOUNT_ID}');
// const SAMPLE_CONTACT_ID = resolveRecordId('${SF_SAMPLE_CONTACT_ID}');

export default class Playground extends LightningElement {
    @track loading = false;

    get pastDate() {
        return Date.now() - 2 * 60 * 60 * 1000;
    }

    get futureDate() {
        return Date.now() + 2 * 60 * 60 * 1000;
    }

    get formattedDateTimeStamp() {
        const utcDateStr = '2025-04-25T11:29:28.000Z';
        const formatter = new Intl.DateTimeFormat(USER_LOCALE, {
            USER_TIME_ZONE,
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        });
        const parts = formatter.formatToParts(new Date(utcDateStr));
        const getPart = (type) => parts.find((p) => p.type === type)?.value;

        const day = getPart('day');
        const month = getPart('month');
        const year = getPart('year');
        const hour = getPart('hour');
        const minute = getPart('minute');

        return `${day}-${month}-${year} ${hour}:${minute}`;
    }

    get quickReplies() {
        return [
            "Thank you for contacting us! I'd be happy to help you with your policy. Could you please provide your policy number so I can assist you better?",
            'I understand your concern. Let me look into this right away and get back to you with a solution within the next 24 hours.',
            "Great question! Yes, that's covered under your current policy. Would you like me to send you the detailed coverage information via email?",
            "I apologize for any inconvenience this has caused. I'm escalating this to our claims department and you'll receive an update within 2 business days.",
            'Your policy renewal is coming up on [DATE]. Would you like to review your coverage options or do you have any questions about your current plan?',
            'Thank you for your payment! Your policy is now active and fully covered. You should receive a confirmation email within the next hour.',
            "I see you're interested in adding additional coverage. Let me prepare a customized quote for you. What specific coverage are you looking to add?",
            'Your claim has been approved! The payment will be processed within 3-5 business days. Is there anything else I can help you with today?'
        ].map((message) => ({ key: uniqueId(), message }));
    }

    async handleCelebrateWithConfetti() {
        await this.refs.confetti.celebrate();
    }
}
