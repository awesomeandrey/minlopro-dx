import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import { uniqueId, copyToClipboard, to } from 'c/utilities';
import $Toastify from 'c/toastify';

const PROP_UID_FIELD_NAME = 'uid';
const PROP_KEY_FIELD_NAME = 'propKey';
const PROP_VALUE_FIELD_NAME = 'propValue';
export default class LogModal extends LightningModal {
    @api label;
    @api value = {};

    get keyFieldName() {
        return PROP_UID_FIELD_NAME;
    }

    get columns() {
        return [
            {
                label: 'KEY',
                fieldName: PROP_KEY_FIELD_NAME,
                type: 'text'
            },
            {
                label: 'VALUE',
                fieldName: PROP_VALUE_FIELD_NAME,
                type: 'text',
                wrapText: true
            }
        ];
    }

    get data() {
        return Object.entries(this.value)
            .filter(([key]) => key.startsWith('data.'))
            .sort(([key1], [key2]) => key1.localeCompare(key2))
            .map(([key, value]) => ({
                [PROP_UID_FIELD_NAME]: uniqueId(),
                [PROP_KEY_FIELD_NAME]: key,
                [PROP_VALUE_FIELD_NAME]: value
            }));
    }

    get message() {
        return this.value['data.Message'];
    }

    handleClose() {
        this.close();
    }

    async handleCopyLogMessage() {
        const [error] = await to(copyToClipboard(this.message));
        if (!!error) {
            $Toastify.error({ message: `Could not copy log message due to: ${error}` });
        } else {
            $Toastify.info({ message: 'Copied log message to clipboard.' });
        }
    }
}
