trigger UserTrigger on User(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    // Leverage FFLIB Object Domain approach;
    fflib_SObjectDomain.triggerHandler(Users.class);
}
