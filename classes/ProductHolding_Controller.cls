global without sharing class ProductHolding_Controller {
	global ProductHolding_Controller() {
		
	}

	@AuraEnabled
	global static ResponseMessage shouldRequest(){
		ResponseMessage message = new ResponseMessage();

		//// if already request today

		/// not yet
		request();
		return message;
	} 

	@RemoteAction
	global static Object  request(){
		System.debug('request');

		Continuation con = new Continuation(120);
        String requestNumber;
        String endpoint = SME_CIRestWebservice.SEARCH_ENDPOINT;

        Map<String,String> requestCISMap = new Map<String,String>{'IP_ID'=>'4321'};
        CustomerSearchRequestModel reqModel = new CustomerSearchRequestModel();
        reqModel.requestMap = requestCISMap;

        String requestStr = SME_CIRestWebservice.getRequestStringFromMap(reqModel.requestMap);

        //// Set callback method
        con.continuationMethod='responseHandler';

        // Create callout request
        HttpRequest req = new HttpRequest();

        req.setHeader('Authorization', SME_HTTPCallUtil.getAuthorizationHeader());
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setbody(requestStr);
        return con;
	}

	global static Object responseHandler(Object requestLabel){
		System.debug('responseHandler');
		HttpResponse continuationResponse = Continuation.getResponse((String)requestLabel);
		String body = continuationResponse.getBody();
		System.debug(body);
		return body;
	}

	global Class ResponseMessage{
		@AuraEnabled
		global String message {public get;private set;}
		@AuraEnabled
		global Boolean doRequest {public get;private set;}
	}

	@RemoteAction
    global static Object getProduct(Integer productId, Integer duration){
    	system.debug('getProduct');
        // Make an HTTPRequest as we normally would
        // Remember to configure a Remote Site Setting for the service!
        String url = 'https://long-running.herokuapp.com/products';
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(url);

        // Create a Continuation for the HTTPRequest        
        Continuation con = new Continuation(60);
        con.state = con.addHttpRequest(req);
        con.continuationMethod = 'callback';        

        // Return it to the system for processing
        return con;
    }

    global static Object callback(Object state) {
    	system.debug('callback');
        HttpResponse response = Continuation.getResponse((String)state);
        Integer statusCode = response.getStatusCode();
        if (statusCode >= 2000) {
            return 'Continuation error: ' + statusCode;
        }
        return response.getBody();
    }

}