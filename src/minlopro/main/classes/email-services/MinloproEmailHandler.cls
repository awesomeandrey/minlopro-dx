public with sharing class MinloproEmailHandler implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Logger.debug('From Address: {0}', Lists.of(email.fromAddress));
        Logger.debug('From Name: {0}', Lists.of(email.fromName));
        Logger.debug('HTML Body: {0}', Lists.of(email.htmlBody));
        Logger.debug('Message ID: {0}', Lists.of(email.messageId));
        Logger.debug('Subject: {0}', Lists.of(email.subject));
        Logger.debug('To Addresses: {0}', Lists.of(email.toAddresses.toString()));
        Logger.debug('Envelope > From Address: {0}', Lists.of(envelope.fromAddress));
        Logger.debug('Envelope > To Address: {0}', Lists.of(envelope.toAddress));
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.success = true;
        result.message = 'This is the message generated within [Messaging.InboundEmailHandler].';
        return result;
    }
}
