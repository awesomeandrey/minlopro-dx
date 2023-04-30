public with sharing class NavigationMenuItemsController {
    /**
     * Perform two SOQL queries to determine all the children NavigationMenuItems
     * belonging to the provided menuName and publishedState. This example uses the
     * NavigationLinkSet.MasterLabel for the menuName. One could also use the
     * NavigationLinkSet.Id to ensure referential integrity if the MasterLabel changes.
     *
     * NavigationLinkSet contains both Draft and Live versions of the NavigationMenuItems.
     * Use the publishedState enumeration to filter between them.
     *
     * Cacheable = true allows this function to be wired.
     */
    @AuraEnabled(Cacheable=true)
    public static List<NavigationMenuItem> getNavigationMenuItems(String menuApiName, String siteState) {
        if (String.isEmpty(menuApiName)) {
            return new List<NavigationMenuItem>();
        }
        String networkId = Network.getNetworkId();
        // find the link set belonging to the navigation menuName and active networkId
        List<NavigationLinkSet> linkSets = [
            SELECT Id
            FROM NavigationLinkSet
            WHERE DeveloperName = :menuApiName AND NetworkId = :networkId
        ];
        Id linkSetId = linkSets.get(0).Id;
        // collect all the menu items belonging to the link set
        // published state is either Draft or Live
        return [
            SELECT Label, Target, Type, DefaultListViewId, AccessRestriction, ParentId, Position, Status, TargetPrefs
            FROM NavigationMenuItem
            WHERE NavigationLinkSetId = :linkSetId AND Status = :siteState
            ORDER BY Position
        ];
    }
}
