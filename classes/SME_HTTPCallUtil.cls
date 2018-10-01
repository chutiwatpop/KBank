/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/27/2015  Charnun.T       First Create
------------------------------------------------------------*/
public with sharing class SME_HTTPCallUtil {

    // Unique label corresponding to the continuation
    public static String requestLabel;

    public static HttpRequest createHttpRequest(String endpoint, String body, Integer timeout) {
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', SME_HTTPCallUtil.getAuthorizationHeader());
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setbody(body);
        //req.setTimeout(CustomSettingUtil.getTimeout());
        req.setTimeout(timeout);
        return req;
    }

    public static HTTPResponse sendHttpCallout(String endpoint, String body) {
        HTTPResponse response;
        HttpRequest req = new HttpRequest();
        System.debug('endpoint : '+ endpoint + ', Body : ' + body);
        req.setHeader('Authorization',getAuthorizationHeader());
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setbody(body);
        req.setTimeout(CustomSettingUtil.getTimeout());
        
        Http http = new Http();
        response = http.send(req);

        System.debug('[Response Body]:'+response.getBody());
        return response;
    }

    public static HTTPResponse sendHttpGetRequest(String endpoint, String body) {
        HTTPResponse response;
        HttpRequest req = new HttpRequest();

        req.setEndpoint(endpoint + '?' + body);
        req.setMethod('GET');
        //req.setTimeout(CustomSettingUtil.getTimeout());
        
        Http http = new Http();
        response = http.send(req);

        return response;
    }

    public static Object sendContinuationHttpCallout(String endpoint, String body) {
        // Create continuation with a timeout
        Continuation con = new Continuation(60);
        String requestNumber;

        // Set callback method
        con.continuationMethod='processResponse';

        // Create callout request
        HttpRequest req = new HttpRequest();

        req.setHeader('Authorization', getAuthorizationHeader());
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setbody(body);

        System.debug('[Continuation Callout][endpoint]'+endpoint);
        // Add callout request to continuation
        SME_HTTPCallUtil.requestLabel = con.addHttpRequest(req);
        System.debug('[Continuation Callout][Continuation]'+con);
        System.debug('[Continuation Callout][requestLabel1]'+SME_HTTPCallUtil.requestLabel);
        // Return the continuation
        return con;
    }

    public static Object sendContinuationHttpCallout2() {
        // Create continuation with a timeout
        Continuation con = new Continuation(60);
        String requestNumber;

        // Set callback method
        con.continuationMethod='processResponse';

        // Create callout request
        HttpRequest req = new HttpRequest();

        req.setHeader('Authorization', SME_HTTPCallUtil.getAuthorizationHeader());
        req.setEndpoint('http://58.137.161.149/SMECustomSearch');
        req.setMethod('POST');
        //req.setbody(body);
        req.setbody('IP_ID=1234');

        System.debug('[Continuation Callout][endpoint]');
        // Add callout request to continuation
        SME_HTTPCallUtil.requestLabel = con.addHttpRequest(req);
        System.debug('[Continuation Callout][Continuation]'+con);
        System.debug('[Continuation Callout][requestLabel1]'+SME_HTTPCallUtil.requestLabel);
        // Return the continuation
        return con;
    }
    
    public static Object processResponse() {
        // Get the response by using the unique label
        System.debug('[Continuation Callout][requestLabel2]'+SME_HTTPCallUtil.requestLabel);
        HttpResponse response = Continuation.getResponse(SME_HTTPCallUtil.requestLabel);
        System.debug('[Continuation Callout][response]'+response);
        SME_CIRestWebservice.continuationResponse = response;
        return null;
    }

    public static String getAuthorizationHeader() {
        String authorizationHeader = '';
        try{
            String username = CustomSettingUtil.getHttpUsername();
            String password = CustomSettingUtil.getHttpPassword();

            Blob headerValue = Blob.valueOf(username +':' +password);
            authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        }catch(Exception ex){
            GlobalUtility.logMessage('ERROR','SME_HTTPCallUtil','getAuthorizationHeader',null,null,'Error when propare authorizationHeader',null,ex,null);
        }
        return authorizationHeader;
    }
}