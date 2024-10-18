## Messaging for In-App and Web for Digital Experience Sites

Originally inspired by the following articles:

-   https://medium.com/@rjallu01/salesforce-how-to-setup-messaging-for-in-app-and-web-user-verification-for-communities-eb77ebd96b85
-   https://medium.com/@rjallu01/salesforce-messaging-miaw-how-to-setup-pre-chat-form-for-communities-6886ec58d7c9

### Post-Deployment Manual Steps

1. Activate `Minlopro - DigEx Messaging Channel` messaging channel (see `Setup > Messaging Settings`)
2. Publish `Minlopro - DigEx Messaging` ESD (see `Setup > Embedded Service Deployments`)
3. Assign _Service Presence Statuses_ to `Minlopro - DigEx In-App & Web Messaging` permission set

### CI/CD Considerations

The following files leverage SFDX Replacements in scope of deployments:

-   [ESW_Minlopro_DigExMessaging Site](src/minlopro-digex-messaging/main/sites/ESW_Minlopro_DigExMessaging.site-meta.xml)
-   [DogEx Home Page](src/minlopro-digex/main/experiences/DigEx1/views/home.json)

### Questions to resolve

1. Replace org url in "src/minlopro-digex/main/experiences/DigEx1/views/home.json" (see messaging component) 2. See https://lwc-lake-6472-dev-ed.scratch.my.salesforce-scrt.com
2. Identify root cause of Flow Error coming to inbox when new work item is created
3. Incorporate EDS into CI/CD workflow completely (looks like another custom post script would be needed)
