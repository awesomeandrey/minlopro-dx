public class NavigationLinkSetPickList extends VisualEditor.DynamicPickList {
    public override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Default Navigation', 'Default Navigation');
        return defaultValue;
    }

    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();
        List<NavigationLinkSet> navigationLinkSetList = [
            SELECT MasterLabel, DeveloperName
            FROM NavigationLinkSet
        ];
        for (NavigationLinkSet navigationLinkSet : navigationLinkSetList) {
            VisualEditor.DataRow value = new VisualEditor.DataRow(navigationLinkSet.MasterLabel, navigationLinkSet.DeveloperName);
            picklistValues.addRow(value);
        }
        return picklistValues;
    }
}
