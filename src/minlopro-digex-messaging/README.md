## Messaging for In-App and Web for Digital Experience Sites

Originally inspired by the following articles:

-   https://medium.com/@rjallu01/salesforce-how-to-setup-messaging-for-in-app-and-web-user-verification-for-communities-eb77ebd96b85
-   https://medium.com/@rjallu01/salesforce-messaging-miaw-how-to-setup-pre-chat-form-for-communities-6886ec58d7c9

Functionality Preview:

![Service_Chat_Preview.png](../../assets/demo/messaging-for-in-app-and-web/Service_Chat_Preview.png)

### Post-Deployment Manual Steps

1. Activate `Minlopro - DigEx Messaging Channel` messaging channel (see `Setup > Messaging Settings`)
2. Publish `Minlopro - DigEx Messaging` ESD (see `Setup > Embedded Service Deployments`)
3. Assign _Service Presence Statuses_ to `Minlopro - DigEx In-App & Web Messaging` permission set
4. Open `Minlopro - Messages Routed to Agents and Queues` omni-channel flow, update `Route To Queue` element by re-selecting `Service Channel` field, save flow as new version and active the flow

### CI/CD Considerations

The following files leverage SFDX Replacements in scope of deployments:

-   [ESW_Minlopro_DigExMessaging Site](src/minlopro-digex-messaging/main/sites/ESW_Minlopro_DigExMessaging.site-meta.xml)
-   [DigEx Home Page](src/minlopro-digex/main/experiences/DigEx1/views/home.json)

### Troubleshooting

The creation of Experience Site for 'Messaging for In-App and Web' also entails generation of `eswminloprodigexmessaging` Visualforce Page.
Leverage this page to resolve configuration issues or verify messaging functionality. Please note that this VF page is excluded from source intentionally.

Page URL = `https://[org_domain]--c[.scratch].vf.force.com/apex/eswminloprodigexmessaging`.

![Visualforce Page for Messaging Tests.png](../../assets/demo/messaging-for-in-app-and-web/Visualforce_Page_for_Messaging_Tests.png)
