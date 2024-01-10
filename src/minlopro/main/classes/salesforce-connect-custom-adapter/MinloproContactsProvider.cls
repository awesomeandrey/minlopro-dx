/**
 * @description
 * DataSource.Provider class informs Salesforce of the functional and
 * authentication capabilities that are supported by or required to connect to the external system
 * */
global with sharing class MinloproContactsProvider extends DataSource.Provider {
    global override List<DataSource.AuthenticationCapability> getAuthenticationCapabilities() {
        List<DataSource.AuthenticationCapability> capabilities = new List<DataSource.AuthenticationCapability>();
        // Using Named Credential for authentication. Can be BASIC or OAUTH or CERTIFICATE
        capabilities.add(DataSource.AuthenticationCapability.ANONYMOUS);
        return capabilities;
    }

    global override List<DataSource.Capability> getCapabilities() {
        List<DataSource.Capability> capabilities = new List<DataSource.Capability>();
        capabilities.add(DataSource.Capability.ROW_QUERY);
        //        capabilities.add(DataSource.Capability.SEARCH);
        //        capabilities.add(DataSource.Capability.ROW_CREATE);
        //        capabilities.add(DataSource.Capability.ROW_UPDATE);
        return capabilities;
    }

    global override DataSource.Connection getConnection(DataSource.ConnectionParams connectionParams) {
        return new MinloproContactsConnection(connectionParams);
    }
}
