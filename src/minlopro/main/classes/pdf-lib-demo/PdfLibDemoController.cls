public with sharing class PdfLibDemoController {
    private static final ContentVersionSelector cvSelector = (ContentVersionSelector) Application.Selector.newInstance(
        ContentVersion.SObjectType
    );

    @AuraEnabled(Cacheable=true)
    public static List<PdfLibDemoController.Document> getPdfFiles() {
        try {
            List<PdfLibDemoController.Document> documentDtos = new List<PdfLibDemoController.Document>();
            for (ContentVersion cvRecord : cvSelector.selectByTypeWithLimit(Lists.of('PDF'), 5)) {
                PdfLibDemoController.Document documentDto = new PdfLibDemoController.Document();
                documentDto.id = cvRecord.Id;
                documentDto.name = cvRecord.Title;
                documentDto.type = cvRecord.FileType;
                documentDto.base64Encoded = EncodingUtil.base64Encode(cvRecord.VersionData);
                documentDtos.add(documentDto);
            }
            return documentDtos;
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static ContentVersion saveFile(String base64Encoded) {
        try {
            ContentVersion cv = new ContentVersion(
                Title = 'Merged Files Result',
                PathOnClient = 'merged_files_result.pdf',
                VersionData = EncodingUtil.base64Decode(base64Encoded),
                IsMajorVersion = true
            );
            insert cv;
            return (ContentVersion) cvSelector.selectSObjectsById(Sets.of(cv.Id))[0];
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class Document {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public String base64Encoded { get; set; }
    }
}
