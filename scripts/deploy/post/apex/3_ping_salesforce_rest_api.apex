try {
    new CCFPlayground().run();
} catch (Exception ex) {
    String errors = JSON.serialize(Exceptions.getDetails(ex));
    System.debug(String.format('\n\n Ping failed: [{0}] \n', Lists.of(errors)));
}
