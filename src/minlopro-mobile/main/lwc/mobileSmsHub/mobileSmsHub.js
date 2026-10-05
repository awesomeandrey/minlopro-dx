import { LightningElement, track } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

const CONVERSATIONS = [
    {
        id: '1',
        customerName: 'Olivia Carter',
        customerInitials: 'OC',
        lastMessageDateTime: '2026-10-06T14:32:00Z',
        messages: [
            { id: '1-1', direction: 'inbound', body: 'Hi, is my order ready for pickup?', timestamp: '2026-10-06T14:20:00Z' },
            {
                id: '1-2',
                direction: 'outbound',
                body: "Yes! It's ready whenever you'd like to stop by.",
                timestamp: '2026-10-06T14:25:00Z'
            },
            { id: '1-3', direction: 'inbound', body: 'Great, see you in 20 minutes.', timestamp: '2026-10-06T14:32:00Z' }
        ]
    },
    {
        id: '2',
        customerName: 'Marcus Lee',
        customerInitials: 'ML',
        lastMessageDateTime: '2026-10-06T11:05:00Z',
        messages: [
            {
                id: '2-1',
                direction: 'outbound',
                body: 'Your appointment is confirmed for Thursday at 10am.',
                timestamp: '2026-10-06T10:58:00Z'
            },
            { id: '2-2', direction: 'inbound', body: 'Thank you, see you then!', timestamp: '2026-10-06T11:05:00Z' }
        ]
    },
    {
        id: '3',
        customerName: 'Priya Natarajan',
        customerInitials: 'PN',
        lastMessageDateTime: '2026-10-05T18:47:00Z',
        messages: [
            { id: '3-1', direction: 'inbound', body: 'Do you have this in a size medium?', timestamp: '2026-10-05T18:40:00Z' },
            {
                id: '3-2',
                direction: 'outbound',
                body: 'Let me check stock and get back to you.',
                timestamp: '2026-10-05T18:47:00Z'
            }
        ]
    },
    {
        id: '4',
        customerName: 'Daniel Osei',
        customerInitials: 'DO',
        lastMessageDateTime: '2026-10-04T09:12:00Z',
        messages: [
            {
                id: '4-1',
                direction: 'outbound',
                body: 'Reminder: your invoice is due Friday.',
                timestamp: '2026-10-04T09:10:00Z'
            },
            { id: '4-2', direction: 'inbound', body: 'Got it, thanks for the heads up.', timestamp: '2026-10-04T09:12:00Z' }
        ]
    }
];

export default class MobileSmsHub extends LightningElement {
    @track currentView = 'list';
    @track selectedConversationId = null;

    get isPhone() {
        return FORM_FACTOR === 'Small';
    }

    get unsupportedFormFactorTitle() {
        return '📵 Mobile SMS Hub';
    }

    get unsupportedFormFactorMsg() {
        return 'Unsupported form factor detected.';
    }

    get isListView() {
        return this.currentView === 'list';
    }

    get conversations() {
        return CONVERSATIONS;
    }

    get selectedConversation() {
        return CONVERSATIONS.find(({ id }) => id === this.selectedConversationId);
    }

    get selectedConversationName() {
        return this.selectedConversation?.customerName;
    }

    get messageEntries() {
        return (this.selectedConversation?.messages || []).map((message) => ({
            ...message,
            listItemCssClass:
                message.direction === 'outbound'
                    ? 'slds-chat-listitem slds-chat-listitem_outbound'
                    : 'slds-chat-listitem slds-chat-listitem_inbound',
            textCssClass:
                message.direction === 'outbound'
                    ? 'slds-chat-message__text slds-chat-message__text_outbound'
                    : 'slds-chat-message__text slds-chat-message__text_inbound'
        }));
    }

    handleSelectConversation(event) {
        const { id } = event.currentTarget.dataset;
        this.selectedConversationId = id;
        this.currentView = 'thread';
    }

    handleBack() {
        this.selectedConversationId = null;
        this.currentView = 'list';
    }
}
