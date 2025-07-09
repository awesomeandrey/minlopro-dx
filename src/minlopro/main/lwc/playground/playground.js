import { LightningElement, track } from 'lwc';
import { cloneObject, resolveRecordId, uniqueId, waitAsync } from 'c/utilities';

import USER_ID from '@salesforce/user/Id';
import USER_TIME_ZONE from '@salesforce/i18n/timeZone';
import USER_LOCALE from '@salesforce/i18n/locale';

// Constants;
const SAMPLE_ACCOUNT_ID = resolveRecordId('${SF_SAMPLE_ACCOUNT_ID}');
const SAMPLE_CONTACT_ID = resolveRecordId('${SF_SAMPLE_CONTACT_ID}');

export default class Playground extends LightningElement {
    @track loading = false;

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

    async handleCelebrateWithConfetti(event) {
        await this.refs.confetti.celebrate();
    }
}
