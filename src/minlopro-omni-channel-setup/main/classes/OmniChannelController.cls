public with sharing class OmniChannelController {
    @AuraEnabled(Cacheable=true)
    public static List<ServicePresenceStatus> getServicePresenceStatuses() {
        try {
            return [SELECT Id, MasterLabel, DeveloperName FROM ServicePresenceStatus];
        } catch (Exception ex) {
            Logger.error(ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @InvocableMethod(
        Label='Get Online Omni-Agents'
        Description='Captures online agents count based on `UserServicePresence` object'
        Category='Omni-Channel Utilities'
    )
    public static List<OnlineAgents> getOnlineAgents() {
        List<User> onlineAgents = [
            SELECT Id, Name, Profile.Name
            FROM User
            WHERE
                Id IN (
                    SELECT UserId
                    FROM UserServicePresence
                    WHERE IsCurrentState = TRUE AND IsAway = FALSE
                )
        ];
        return new List<OnlineAgents>{ new OnlineAgents(onlineAgents) };
    }

    public class OnlineAgents {
        @InvocableVariable(Label='Online agents count' Required=true)
        public Integer count = 0;
        @InvocableVariable(Label='Online agents status message' Required=true)
        public String statusMessage = '';

        private OnlineAgents() {
        }

        public OnlineAgents(List<User> onlineAgents) {
            this.count = onlineAgents.size();
            this.statusMessage = onlineAgents.isEmpty()
                ? 'There are no online agents to assist you at the moment 😞'
                : String.format('There are {0} agent(s) available, please wait for a second.', Lists.of(this.count.toString()));
        }
    }
}
