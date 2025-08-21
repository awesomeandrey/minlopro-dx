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

    public static Constants.Users Users {
        get {
            return Users == null ? (Users = new Constants.Users()) : Users;
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

    public class Users {
        public final User AutomatedProcessUser {
            get {
                return this.usersByAlias.get(this.autoProcAlias);
            }
        }

        private final String autoProcAlias = 'autoproc';
        private final Map<String, User> usersByAlias = new Map<String, User>();

        private Users() {
            for (User userItem : [
                SELECT Id, Name, Profile.Name, IsActive
                FROM User
                WHERE Alias IN :Lists.of(this.autoProcAlias)
                LIMIT 10
            ]) {
                this.usersByAlias.put(userItem.Alias, userItem);
            }
        }
    }
}
