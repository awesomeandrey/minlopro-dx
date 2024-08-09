public inherited sharing class EmailTemplateSelector extends fflib_SObjectSelector {
    private final Repository repository = (Repository) Application.Service.newInstance(Repository.class);

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
