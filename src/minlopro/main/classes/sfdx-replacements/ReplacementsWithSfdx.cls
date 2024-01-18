public without sharing class ReplacementsWithSfdx {
    private static final String secretValue = '@SF_USERNAME';

    public static void showSecretToConsole() {
        Map<String, String> dataItem = new Map<String, String>{ 'sfUsername' => secretValue };
        List<String> fieldNames = Lists.of(dataItem.keySet());
        DebugTableFormatter formatter = new DebugTableFormatter(fieldNames, new List<Map<String, String>>{ dataItem });
        formatter.log('⚪ Printing secret value');
    }
}
