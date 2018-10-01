//@isTest
//global class MockSME_CIRestWebservice implements WebServiceMock {
//   global void doInvoke(
//           Object stub,
//           Object request,
//           Map<String, Object> response,
//           String endpoint,
//           String soapAction,
//           String requestName,
//           String responseNS,
//           String responseName,
//           String responseType) {
//   		//HttpRequest httpRequest = new HttpRequest();
//     //  	HTTPResponse resp = httpRequest;
//       	response.put('response_x', respElement);
//   }
//}
@isTest
global class MockSME_CIRestWebservice implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Authorization', 'application/json');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(200);

        return res;
    }
}