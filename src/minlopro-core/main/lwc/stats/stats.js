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
                return [
                    { isKey: true, id: uniqueId(), content: endsWithPunctuationCharacters ? key : `${key}:` },
                    { isValue: true, id: uniqueId(), hasContent: isNotEmpty(value), content: value }
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
