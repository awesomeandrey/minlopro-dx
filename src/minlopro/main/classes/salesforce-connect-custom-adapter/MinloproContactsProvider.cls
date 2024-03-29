/**
 * @description
 * DataSource.Provider class informs Salesforce of the functional and authentication capabilities
 * that are supported by or required to connect to the external system
 *
 * Salesforce Connect or OData Connector can be enabled in Developer edition org.
 * See SF docs - https://help.salesforce.com/s/articleView?id=000387779&type=1.
 * */
global with sharing class MinloproContactsProvider extends DataSource.Provider {
    global override List<DataSource.AuthenticationCapability> getAuthenticationCapabilities() {
        List<DataSource.AuthenticationCapability> capabilities = new List<DataSource.AuthenticationCapability>();
        // Using Named Credential for authentication
        capabilities.add(DataSource.AuthenticationCapability.ANONYMOUS);
        return capabilities;
    }

    global override List<DataSource.Capability> getCapabilities() {
        List<DataSource.Capability> capabilities = new List<DataSource.Capability>();
        capabilities.add(DataSource.Capability.ROW_QUERY);
        capabilities.add(DataSource.Capability.QUERY_PAGINATION_SERVER_DRIVEN);
        // capabilities.add(DataSource.Capability.ROW_CREATE);
        // capabilities.add(DataSource.Capability.ROW_UPDATE);
        return capabilities;
    }

    global override DataSource.Connection getConnection(DataSource.ConnectionParams connectionParams) {
        return new MinloproContactsConnection(connectionParams);
    }
}
