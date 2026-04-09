try {
    SystemAlert.setupContentWorkspace();
} catch (Exception ex) {
    Logger.error(ex);
}
try {
    FilesManagementController.setupContentWorkspace();
} catch (Exception ex) {
    Logger.error(ex);
}
