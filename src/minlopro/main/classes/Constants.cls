public inherited sharing class Constants {
    public static final Org Org {
        get {
            return new Org();
        }
    }

    public static final Constants.NamedCredential NamedCredential {
        get {
            return new Constants.NamedCredential();
        }
    }

    public class Org {
        public final String ApiVersion = '63.0';
    }

    public class NamedCredential {
        public final String Loopback = 'SalesforceRestApi';
    }
}
