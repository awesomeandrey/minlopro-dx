import { createElement } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import AuraPubsub from 'c/auraPubsub';
import flushPromises from 'flush-promises';

// Mocked Page Reference;
import MOCKED_APP_PAGE_REF from '../../../../test/jest-mocks/pageReferences/appPageRef.json';

// Custom Event Name(s);
const EVENT_NAME1 = 'customEvt_1';
const EVENT_NAME2 = 'customEvt_2';

describe('Subscribe to Event and Invoke Handler via "auraPubsub.js"', () => {
    afterEach(() => {
        // Reset Jest Mocks;
        jest.clearAllMocks();
        // Cleanup DOM;
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Subscribe to "ready" event', () => {
        const onReadyHandler = jest.fn();
        const $auraPubsubElement = createElement('c-aura-pubsub', { is: AuraPubsub });
        $auraPubsubElement.addEventListener('ready', onReadyHandler);
        document.body.appendChild($auraPubsubElement);
        return Promise.resolve().then(() => {
            expect(onReadyHandler).toHaveBeenCalled();
            expect(onReadyHandler).toHaveBeenCalledTimes(1);
        });
    });

    it('Subscribe to CUSTOM events', async () => {
        const $auraPubsubElement = createElement('c-aura-pubsub', { is: AuraPubsub });
        document.body.appendChild($auraPubsubElement);
        // Mock Page Reference;
        CurrentPageReference.emit(MOCKED_APP_PAGE_REF);
        await flushPromises();
        // Register/fire 'EVENT_NAME1';
        const onCustomEvt1Handler = jest.fn();
        $auraPubsubElement.registerListener(EVENT_NAME1, onCustomEvt1Handler);
        const message1 = 'Jest Tests are cool!';
        $auraPubsubElement.fireEvent(EVENT_NAME1, { message: message1 });
        const message2 = 'Salesforce is awesome!';
        $auraPubsubElement.fireEvent(EVENT_NAME1, { message: message2 });
        // Fire 'EVENT_NAME2' without registering it;
        const onCustomEvt2Handler = jest.fn();
        const message3 = '<This handler should not be called>';
        $auraPubsubElement.fireEvent(EVENT_NAME2, { message: message3 });
        // Verify handler for the 'EVENT_NAME1';
        await flushPromises();
        expect(onCustomEvt1Handler).toHaveBeenCalled();
        expect(onCustomEvt1Handler).toHaveBeenCalledTimes(2);
        const [calls1, calls2] = onCustomEvt1Handler.mock.calls;
        expect(calls1[0].message).toEqual(message1);
        expect(calls2[0].message).toEqual(message2);
        // Verify handler for the 'EVENT_NAME2';
        expect(onCustomEvt2Handler).toHaveBeenCalledTimes(0);
    });

    it('Unregister from CUSTOM events', async () => {
        const $auraPubsubElement = createElement('c-aura-pubsub', { is: AuraPubsub });
        document.body.appendChild($auraPubsubElement);
        // Mock Page Reference;
        CurrentPageReference.emit(MOCKED_APP_PAGE_REF);
        await flushPromises();
        // Subscribe to events and invoke them;
        const onCustomEvt1Handler = jest.fn();
        $auraPubsubElement.registerListener(EVENT_NAME1, onCustomEvt1Handler);
        $auraPubsubElement.fireEvent(EVENT_NAME1, {});
        const onCustomEvt2Handler = jest.fn();
        $auraPubsubElement.registerListener(EVENT_NAME2, onCustomEvt2Handler);
        $auraPubsubElement.fireEvent(EVENT_NAME2, {});
        await flushPromises();
        // Verify handler invocation;
        expect(onCustomEvt1Handler).toHaveBeenCalledTimes(1);
        expect(onCustomEvt2Handler).toHaveBeenCalledTimes(1);
        // Unregister from 'EVENT_NAME1' and fire both events;
        $auraPubsubElement.unregisterListener(EVENT_NAME1, onCustomEvt1Handler);
        $auraPubsubElement.fireEvent(EVENT_NAME1, {});
        $auraPubsubElement.fireEvent(EVENT_NAME2, {});
        await flushPromises();
        // Verify handler invocation;
        expect(onCustomEvt1Handler).toHaveBeenCalledTimes(1);
        expect(onCustomEvt2Handler).toHaveBeenCalledTimes(2);
        // Unregister from all events and fire both events;
        $auraPubsubElement.unregisterAllListeners();
        $auraPubsubElement.fireEvent(EVENT_NAME1, {});
        $auraPubsubElement.fireEvent(EVENT_NAME2, {});
        await flushPromises();
        // Verify handler invocation;
        expect(onCustomEvt1Handler).toHaveBeenCalledTimes(1);
        expect(onCustomEvt2Handler).toHaveBeenCalledTimes(2);
    });
});
