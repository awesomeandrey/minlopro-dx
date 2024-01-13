// Find Digex Guest User;
final String SITE_NAME = 'DigEx';
List<Site> sitesList = [
    SELECT Id, Name, GuestUserId, GuestUser.Name, GuestUser.UserType
    FROM Site
    WHERE Name = :SITE_NAME
    LIMIT 1
];
if (sitesList.isEmpty()) {
    System.debug(String.format('\n\n ❌ Site was not found: [{0}] \n', Lists.of(SITE_NAME)));
    return;
}
final User guestUser = sitesList[0].GuestUser;

// Assign 'Minlopro_PSG_DigExUser' PSG to site guest user;
PermissionSetService service = PermissionSetService.getInstance();
service.assign(guestUser.Id, Sets.of('Minlopro_PSG_DigExUser'));
