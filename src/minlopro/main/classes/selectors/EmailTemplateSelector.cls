public inherited sharing class EmailTemplateSelector extends fflib_SObjectSelector {
    public SObjectType getSObjectType() {
        return EmailTemplate.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<SObjectField>{
            EmailTemplate.Id,
            EmailTemplate.Name,
            EmailTemplate.DeveloperName,
            EmailTemplate.Body,
            EmailTemplate.HtmlValue,
            EmailTemplate.IsActive
        };
    }
}
