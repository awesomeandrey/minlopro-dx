@RestResource(UrlMapping='/playground/*')
global without sharing class PublicRestEndpoint {
    @HttpGet
    global static String echo() {
        return 'This is echo - hello!';
    }
}
