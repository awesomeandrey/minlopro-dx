import { isEmptyArray, isNotEmpty } from 'c/utilities';

const availableLettersStack = Array.from('ABCDEFGHIJKLMNOPQRSTUVWXYZ');

const hasNext = () => !isEmptyArray(availableLettersStack);

const gain = () => {
    if (!hasNext()) {
        throw new Error('Lack of letters for markers!');
    }
    return availableLettersStack.shift();
};

const revoke = (letter) => {
    if (isNotEmpty(letter) && typeof letter === 'string') {
        availableLettersStack.unshift(letter);
    }
};

export { gain, revoke, hasNext };
