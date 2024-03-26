import { LightningElement, api } from 'lwc';
import { copyToClipboard, isNotEmpty, parseError, uniqueId } from 'c/utilities';
import $Toastify from 'c/toastify';

export default class Stats extends LightningElement {
    @api label = 'Stats';
    @api value = {};
    @api iconName = 'standard:setup_modal';

    get statsAsUniqueEntries() {
        return Object.entries(this.value)
            .map(([key, value]) => {
                let endsWithPunctuationCharacters = /.*\W+$/.test(key);
                let isBoolean = typeof value === 'boolean';
                let isUrl = this.isUrl(value);
                let canCopy = isNotEmpty(value) && !isBoolean;
                return [
                    { isKey: true, id: uniqueId(), content: endsWithPunctuationCharacters ? key : `${key}:` },
                    {
                        isValue: true,
                        id: uniqueId(),
                        content: value,
                        canCopy,
                        isBoolean,
                        isUrl
                    }
                ];
            })
            .flat(Infinity);
    }

    async handleCopy(event) {
        event.preventDefault();
        let { value } = event.target.dataset;
        try {
            await copyToClipboard(value);
            $Toastify.info({ message: 'Copied to clipboard!' });
        } catch (error) {
            let { message } = parseError(error);
            $Toastify.error({ message });
        }
    }

    isUrl(value) {
        const urlPattern = /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/;
        return urlPattern.test(value);
    }
}
