public with sharing class Playground {
    public void play() {
        // Fetch target PSG;
        final String psgName = 'Minlopro_PSG_InternalUser';
        PermissionSetGroup targetPsg = [
            SELECT Id, DeveloperName
            FROM PermissionSetGroup
            WHERE DeveloperName = :psgName
            LIMIT 1
        ][0];
        Assert.areEqual(psgName, targetPsg.DeveloperName, 'Minlopro Permission Set Group (for internal users) is not found!');

        // Insert PSG assignment;
        Database.SaveResult saveResultItem = Database.insert(
            new PermissionSetAssignment(PermissionSetGroupId = targetPsg.Id, AssigneeId = UserInfo.getUserId()),
            false
        );
        if (!saveResultItem.isSuccess()) {
            Database.Error errorItem = saveResultItem.getErrors().get(0);
            if (errorItem.getStatusCode() != StatusCode.DUPLICATE_VALUE) {
                System.debug('\n\n Unknown Error Occurred => ' + errorItem + '\n');
            }
        }
    }
}
