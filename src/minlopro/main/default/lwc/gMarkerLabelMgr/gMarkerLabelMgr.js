import { isEmptyArray, isNotEmpty } from 'c/commons';

const availableLettersStack = Array.from('ABCDEFGHIJKLMNOPQRSTUVWXYZ');

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

const hasNext = () => !isEmptyArray(availableLettersStack);

export { gain, revoke, hasNext };
