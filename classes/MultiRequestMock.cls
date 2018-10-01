@isTest
public class MultiRequestMock implements HttpCalloutMock {
	Map<String, HttpCalloutMock> requests;

	public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
		this.requests = requests;
	} 

	public HTTPResponse respond(HTTPRequest req) {
		HttpCalloutMock mock = requests.get(req.getEndpoint());
		if(mock != null){
			return mock.respond(req);
		}
		else {
            throw new MockException('Error MockHTTPResponse requests cannot does not contains url');
        }
	}

	public void addRequestMock(String url, HttpCalloutMock mock) {
		requests.put(url, mock);
	}

	private class MockException extends Exception{}
}