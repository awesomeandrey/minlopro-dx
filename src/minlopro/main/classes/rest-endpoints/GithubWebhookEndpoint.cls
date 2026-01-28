@RestResource(UrlMapping='/github')
global with sharing class GithubWebhookEndpoint {
    @TestVisible
    private static String GITHUB_WEBHOOK_SECRET = '${SF_GITHUB_WEBHOOK_SECRET}';
    @TestVisible
    private static final String GITHUB_SIGNATURE_HEADER = 'X-Hub-Signature-256';
    @TestVisible
    private static final String GITHUB_SIGNATURE_PREFIX = 'sha256';

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            // Validate the request;
            if (!isValidRequest(req)) {
                Logger.error('GitHub signature DID NOT match!');
                res.statusCode = 403;
                res.responseBody = Blob.valueOf('Invalid signature.');
                return;
            }
            // Process the GitHub event;
            String requestBody = req.requestBody.toString();
            GithubWebhookEndpoint.Event event = (GithubWebhookEndpoint.Event) JSON.deserialize(
                requestBody,
                GithubWebhookEndpoint.Event.class
            );
            if (!isSubscribedEvent(event)) {
                String infoMessage = String.format('Unsubscribed event: {0}.', Lists.of(requestBody));
                res.statusCode = 202;
                res.responseBody = Blob.valueOf(infoMessage);
                return;
            }
            // Act upon subscribed event;
            sendNotificationToAdmin(event);
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('Request processed successfully.');
            // Logger.debug('Successfully processed GitHub webhook!');
        } catch (Exception ex) {
            String errorMessage = String.format('Unhandled REST exception: {0}.', Lists.of(Exceptions.getDetails(ex).toString()));
            Logger.error(errorMessage);
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(errorMessage);
        }
    }

    private static Boolean isValidRequest(RestRequest req) {
        // Logger.debug('{0}: {1}', Lists.of(GITHUB_SIGNATURE_HEADER, req.headers.get(GITHUB_SIGNATURE_HEADER)));
        if (!req.headers.containsKey(GITHUB_SIGNATURE_HEADER)) {
            return false;
        }
        String requestBodyString = req.requestBody.toString();
        String expectedSignature = String.format(
            '{0}={1}',
            Lists.of(GITHUB_SIGNATURE_PREFIX, generateHmacSHA256(requestBodyString, GITHUB_WEBHOOK_SECRET))
        );
        String actualSignature = req.headers.get(GITHUB_SIGNATURE_HEADER);
        return expectedSignature.equals(actualSignature);
    }

    private static Boolean isSubscribedEvent(GithubWebhookEndpoint.Event event) {
        if (event.workflow_run == null) {
            return false;
        }
        // Case 1 event.action='completed' and wf.status='completed' and wf.conclusion='success'
        // Case 2 event.action='completed' and wf.status='completed' and wf.conclusion='failure'
        // Case 3 event.action='requested' and wf.status='queued' and wf.conclusion='null'

        // Filter by event action;
        final Set<String> subscribedActions = Sets.of('completed', 'requested');
        if (!subscribedActions.contains(event.action)) {
            return false;
        }
        // Filter by workflow status;
        final Set<String> workflowStatuses = Sets.of('queued', 'completed');
        if (!workflowStatuses.contains(event.workflow_run.status)) {
            return false;
        }
        // Filter by workflow conclusions;
        final Set<String> subscribedConclusions = new Set<String>{ null, 'success', 'failure', 'cancelled' };
        if (!subscribedConclusions.contains(event.workflow_run.conclusion)) {
            return false;
        }
        // Filter by workflow name;
        final Set<String> subscribedWorkflowNames = Sets.of('Deploy Source', 'Validate Pull Request');
        Iterator<String> it = subscribedWorkflowNames.iterator();
        while (it.hasNext()) {
            if (event.workflow_run.name.startsWithIgnoreCase(it.next())) {
                return true;
            }
        }
        return false;
    }

    private static void sendNotificationToAdmin(GithubWebhookEndpoint.Event event) {
        // Logger.debug('Notification for [{0}] github event.', Lists.of(event.workflow_run?.name));
        // Logger.debug('Event Action: {0}', Lists.of(event.action));
        // Logger.debug('WF Status: {0}', Lists.of(event.workflow_run.status));
        // Logger.debug('WF Conclusion: {0}', Lists.of(event.workflow_run.conclusion));
        // Prepare the Flow input variables;
        Group adminsGroup = [
            SELECT Id, Name, DeveloperName
            FROM Group
            WHERE DeveloperName = 'OrgAdmins' AND Type = 'Regular'
            LIMIT 1
        ];
        List<String> recipientIds = Lists.of(adminsGroup.Id);
        String message = event.workflow_run.composeMessage();
        String targetPageRef = JSON.serialize(
            new Map<String, Object>{
                'type' => 'standard__webPage',
                'attributes' => new Map<String, String>{ 'url' => event.workflow_run.html_url }
            }
        );
        // Invoke Flow;
        final String flowApiName = 'Minlopro_SendGitHubWebhookNotification';
        Map<String, Object> inputParametersMap = new Map<String, Object>();
        inputParametersMap.put('recipientIds', recipientIds);
        inputParametersMap.put('message', message);
        inputParametersMap.put('targetPageRef', targetPageRef);
        // Invoke Flow;
        if (!Test.isRunningTest()) {
            Flow.Interview.createInterview(flowApiName, inputParametersMap).start();
        }
    }

    @TestVisible
    private static String generateHmacSHA256(String data, String key) {
        Blob mac = Crypto.generateMac('hmacSHA256', Blob.valueOf(data), Blob.valueOf(key));
        return EncodingUtil.convertToHex(mac);
    }

    public class Event {
        public String action; // 'completed', 'requested'
        public WorkflowRun workflow_run;
    }

    public class WorkflowRun {
        public String id;
        public String name;
        public String html_url;
        public String status; // 'queued', 'completed';
        public String conclusion; // null, 'failure', 'success', 'cancelled';

        private final String conclusionIcon {
            get {
                switch on this.conclusion {
                    when null {
                        return '⚠️';
                    }
                    when 'failure' {
                        return '❌';
                    }
                    when 'success' {
                        return '✅';
                    }
                    when else {
                        return '⚠️';
                    }
                }
            }
        }

        public String composeMessage() {
            if (this.status.equalsIgnoreCase('queued')) {
                return String.format('Workflow "{0}" has been {1}.', Lists.of(this.name, this.status));
            } else {
                return String.format(
                    'Workflow "{0}" has {1} with conclusion "{2} {3}".',
                    new List<String>{ this.name, this.status, this.conclusion, this.conclusionIcon }
                );
            }
        }
    }
}
