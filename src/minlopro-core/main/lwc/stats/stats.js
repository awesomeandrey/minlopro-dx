import { LightningElement, api } from 'lwc';
import { cloneObject, copyToClipboard, isNotEmpty, parseError, uniqueId, isUrl } from 'c/utilities';
import $Toastify from 'c/toastify';

export default class Stats extends LightningElement {
    @api label = 'Stats';
    @api value = {};
    @api iconName = 'standard:setup_modal';

    get statsAsUniqueEntries() {
        return Object.entries(cloneObject(this.value || {}))
            .map(([key, value]) => {
                const endsWithPunctuationCharacters = /.*\W+$/.test(key);
                const isBoolean = typeof value === 'boolean';
                const canCopy = isNotEmpty(value) && !isBoolean;
                return [
                    { isKey: true, id: uniqueId(), content: endsWithPunctuationCharacters ? key : `${key}:` },
                    {
                        isValue: true,
                        id: uniqueId(),
                        content: value,
                        canCopy,
                        isBoolean,
                        isUrl: isUrl(value)
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
}
