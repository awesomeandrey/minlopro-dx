import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import $Toastify from 'c/toastify';

// Mock hardcoded Custom Labels with prefix;
const CL_PREFIX = 'MOCKED';
jest.mock(
    '@salesforce/label/c.Commons_Msg_Success',
    () => {
        return { default: `${CL_PREFIX}-Success` };
    },
    { virtual: true }
);
jest.mock(
    '@salesforce/label/c.Commons_Msg_Error',
    () => {
        return { default: `${CL_PREFIX}-Error` };
    },
    { virtual: true }
);
jest.mock(
    '@salesforce/label/c.Commons_Msg_Warning',
    () => {
        return { default: `${CL_PREFIX}-Warning` };
    },
    { virtual: true }
);
jest.mock(
    '@salesforce/label/c.Commons_Msg_Info',
    () => {
        return { default: `${CL_PREFIX}-Info` };
    },
    { virtual: true }
);

describe('Throw toast messages via "toastify.js"', () => {
    beforeEach(() => {
        // Create BUTTON element;
        const $buttonElement = document.createElement('button');
        $buttonElement.innerHTML = 'Show Toast Message';
        document.body.appendChild($buttonElement);
    });

    afterEach(() => {
        // Reset Jest Mocks;
        jest.clearAllMocks();
        // Cleanup DOM;
        const $buttonElement = document.querySelector('button');
        $buttonElement.remove();
    });

    it('Throw toast messages by variants', () => {
        // Query BUTTON element and add event listener;
        const $buttonElement = document.querySelector('button');
        const toastMessage = `Clicked on [${$buttonElement.innerHTML}] button!`;
        $buttonElement.addEventListener('click', (event) => {
            // Throw toast upon button click;
            $Toastify.success({ message: toastMessage });
            $Toastify.error({ message: toastMessage });
            $Toastify.warning({ message: toastMessage });
            $Toastify.info({ message: toastMessage });
        });
        // Mock handler;
        const toastHandler = jest.fn();
        window.addEventListener(ShowToastEventName, toastHandler);
        // Trigger BUTTON 'click' event;
        $buttonElement.click();
        // Verify;
        return Promise.resolve().then(() => {
            expect(toastHandler).toHaveBeenCalled();
            expect(toastHandler).toHaveBeenCalledTimes(4);
            // Verify each event payload;
            toastHandler.mock.calls.forEach((_) => {
                expect(_[0].detail.message).toEqual(toastMessage);
                expect(_[0].detail.title).toMatch(new RegExp(`^${CL_PREFIX}`));
            });
            // Preserve the same order!
            const [successCalls, errorCalls, warningCalls, infoCalls] = toastHandler.mock.calls;
            expect(successCalls[0].detail.variant).toEqual($Toastify.Variant.SUCCESS);
            expect(errorCalls[0].detail.variant).toEqual($Toastify.Variant.ERROR);
            expect(warningCalls[0].detail.variant).toEqual($Toastify.Variant.WARNING);
            expect(infoCalls[0].detail.variant).toEqual($Toastify.Variant.INFO);
        });
    });
});
