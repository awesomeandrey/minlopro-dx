@IsTest
private class PdfLibDemoControllerTest {
    @IsTest
    static void testGetPdfFiles() {
        User adminUser = TestDataFactory.createAdmin();
        System.runAs(adminUser) {
            ContentVersion cv = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'test.pdf',
                VersionData = Blob.valueOf('Minlopro')
            );
            insert cv;
            List<PdfLibDemoController.Document> fetchedDocuments = PdfLibDemoController.getPdfFiles();
            Assert.isFalse(fetchedDocuments.isEmpty());
            Assert.areEqual(1, fetchedDocuments.size());
            Assert.areEqual(cv.Id, fetchedDocuments[0].id);
        }
    }
}
