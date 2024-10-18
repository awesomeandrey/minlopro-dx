## Messaging for In-App and Web for Digital Experience Sites

Originally inspired by the following articles:

-   https://medium.com/@rjallu01/salesforce-how-to-setup-messaging-for-in-app-and-web-user-verification-for-communities-eb77ebd96b85
-   https://medium.com/@rjallu01/salesforce-messaging-miaw-how-to-setup-pre-chat-form-for-communities-6886ec58d7c9

Manual step is required:

1. Setup > Messaging Settings > New Channel + activate
2. Make sure presence statuses are granted to the user via permset (note they can be missed)

### CI/CD Considerations

TODO -- replace scratch url nosoftware-connect-8298-dev-ed.scratch.my.site.com

### Questions to resolve

1. Replace org url in "src/minlopro-digex/main/experiences/DigEx1/views/home.json" (see messaging component)
2. Identify root cause of Flow Error coming to inbox when new work item is created
3. Incorporate EDS into CI/CD workflow completely (looks like another custom post script would be needed)
4. CORS?
