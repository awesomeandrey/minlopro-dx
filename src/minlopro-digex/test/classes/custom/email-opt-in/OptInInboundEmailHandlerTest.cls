@IsTest
private class OptInInboundEmailHandlerTest {
    @IsTest
    static void testHandleInboundEmail() {
        System.runAs(TestDataFactory.createAdmin()) {
            Account customer = TestDataFactory.createPersonAccounts(1)[0];
            Assert.isFalse(customer.PersonHasOptedOutOfEmail);
            insert customer;
            customer = selectCustomerById(customer.Id);
            Messaging.InboundEnvelope envelope = createEnvelope(customer.PersonEmail);
            Messaging.InboundEmail email = createEmailFromCustomerWithKeyword(customer, 'stop');
            Test.startTest();
            Messaging.InboundEmailResult result = new OptInInboundEmailHandler().handleInboundEmail(email, envelope);
            Test.stopTest();
            Assert.isTrue(result.success);
            customer = selectCustomerById(customer.Id);
            Assert.isTrue(customer.PersonHasOptedOutOfEmail);
            Assert.isFalse(
                [SELECT Id FROM EmailMessage WHERE RelatedToId = :customer.Id AND Subject = :email.subject LIMIT 1].isEmpty(),
                'EmailMessage activity record should have been created for PersonAccount'
            );
        }
    }

    private static Messaging.InboundEmail createEmailFromCustomerWithKeyword(Account customer, String keyword) {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'SUBJECT-' + TestDataFactory.generateRandomString(10);
        email.fromName = customer.Name;
        email.fromAddress = customer.PersonEmail;
        email.toAddresses = new List<String>{ 'invalid@invalid.com.invalid' };
        email.subject = 'Minlopro - Inbound Email';
        email.plainTextBody = String.format('{0}, this is the remaining email body.', Lists.of(keyword));
        return email;
    }

    private static Messaging.InboundEnvelope createEnvelope(String fromAddress) {
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = fromAddress;
        return envelope;
    }

    private static Account selectCustomerById(Id recordId) {
        return [SELECT Id, Name, PersonEmail, PersonHasOptedOutOfEmail, PersonTitle FROM Account WHERE Id = :recordId LIMIT 1];
    }
}
