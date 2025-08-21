@SuppressWarnings('PMD')
public inherited sharing class Constants {
    public static Constants.Org Org {
        get {
            return Org == null ? (Org = new Constants.Org()) : Org;
        }
        private set;
    }

    public static Constants.NamedCredential NamedCredential {
        get {
            return NamedCredential == null ? (NamedCredential = new Constants.NamedCredential()) : NamedCredential;
        }
        private set;
    }

    public static Constants.Files Files {
        get {
            return Files == null ? (Files = new Constants.Files()) : Files;
        }
        private set;
    }

    // Class definitions;

    public class Org {
        public final String ApiVersion = '63.0';
    }

    public class NamedCredential {
        public final String Loopback = 'SalesforceRestApi';
    }

    public class Files {
        public final String StandardAssetsLibraryApiName = 'sfdc_asset_company_assets';
    }
}
