// Fetch target PSG;
final String digExPsgName = 'Minlopro_PSG_DigExUser';
PermissionSetGroup digExPsg = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName = :digExPsgName LIMIT 1][0];
Assert.areEqual(digExPsgName, digExPsg.DeveloperName, 'DigEx Permission Set Group is not found!');

// Fetch network definition;
final String digExNetworkName = 'DigEx';
List<Network> networks = (List<Network>) [SELECT Id, Name FROM Network WHERE Name = :digExNetworkName LIMIT 1];
Assert.isFalse(networks.isEmpty(), 'There are no networks/sites defined!');
Network digExNetwork = networks[0];
Assert.areEqual(digExNetworkName, digExNetwork.Name, 'DigEx network is not found!');

// Fetch all network members and create PSG-assignments accordingly;
List<PermissionSetAssignment> permissionSetAssignmentsToInsert = new List<PermissionSetAssignment>();
for (NetworkMember nMember : [SELECT NetworkId, Member.Name FROM NetworkMember WHERE NetworkId = :digExNetwork.Id]) {
    permissionSetAssignmentsToInsert.add(new PermissionSetAssignment(PermissionSetGroupId = digExPsg.Id, AssigneeId = nMember.MemberId));
}

// Fetch DigEx Guest user;
User guestUser = [SELECT Id, Name FROM User WHERE Profile.Name = 'DigEx Profile' AND UserType = 'Guest' LIMIT 1][0];
Assert.isFalse(guestUser == null, 'DigEx Guest user is not found!');
permissionSetAssignmentsToInsert.add(new PermissionSetAssignment(PermissionSetGroupId = digExPsg.Id, AssigneeId = guestUser.Id));

// Insert PSG assignment;
Assert.isFalse(permissionSetAssignmentsToInsert.isEmpty(), 'There are no DigEx members to update!');
System.debug(
        String.format('\n\n DigEx members amount to update = {0} \n', Lists.of(String.valueOf(permissionSetAssignmentsToInsert.size())))
);
for (Database.SaveResult saveResultItem : Database.insert(permissionSetAssignmentsToInsert, false)) {
    if (!saveResultItem.isSuccess()) {
        Database.Error errorItem = saveResultItem.getErrors().get(0);
        if (errorItem.getStatusCode() != StatusCode.DUPLICATE_VALUE) {
            System.debug('\n\n Unknown Error Occurred => ' + errorItem + '\n');
        }
    }
}