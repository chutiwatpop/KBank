global class GoogleGeocoding_Webservice {

    public static final String API_KEY_PARAM = 'key';
    public static final String ADDRESS_PARAM = 'address';
    webservice String searchString {get;set;}
    webservice String apiKey {get;set;}
    webservice String requestURL {get;set;}
    @TestVisible
    public static String testMode;

    public GoogleGeocoding_Webservice(Address__c searchAddress, String apiKey, String requestURL) {
        this.apiKey = apiKey;
        this.requestURL = requestURL;
        this.searchString = '';
        this.searchString = concatAddress(this.searchString,searchAddress.House_Number_Encrypt__c);
        this.searchString = concatAddress(this.searchString,searchAddress.Alley__c);
        this.searchString = concatAddress(this.searchString,searchAddress.Village__c);
        this.searchString = concatAddress(this.searchString,searchAddress.Village_Number__c);
        this.searchString = concatAddress(this.searchString,searchAddress.Street__c);
        this.searchString = concatAddress(this.searchString,searchAddress.Sub_District__c);
        this.searchString = concatAddress(this.searchString,searchAddress.District__c);
        this.searchString = concatAddress(this.searchString,searchAddress.Province__c);
        this.searchString = concatAddress(this.searchString,searchAddress.Postcode__c);
    }

    global class RequestModel {
        global RequestModel() {}
        public Map<String,String> requestMap {get;set;}
    }

    global class GoogleLocation {
        public Decimal lat;
        public Decimal lng;
        public String statusMsg;
    }

    public GoogleGeocoding_Webservice.GoogleLocation calloutWebservice() {
        GoogleGeocoding_Webservice.RequestModel requestModel = getRequestModel();
        GoogleGeocoding_Webservice.GoogleLocation responseModel = new GoogleGeocoding_Webservice.GoogleLocation();
        if(requestModel.requestMap.containsKey(API_KEY_PARAM) && requestModel.requestMap.containsKey(ADDRESS_PARAM)) {
            responseModel = getResponseFromWebservice(requestModel, this.requestURL);
        } else {
            //throw new CIWebserviceException('Invalid request parameter');
        }
        return responseModel;
    }

    private GoogleGeocoding_Webservice.RequestModel getRequestModel(){       
        GoogleGeocoding_Webservice.RequestModel reqModel = new GoogleGeocoding_Webservice.RequestModel();
        reqModel.requestMap = new Map<String, String>();
        if(this.searchString != null && this.searchString.trim() != ''){
            reqModel.requestMap.put(ADDRESS_PARAM, this.searchString);
            reqModel.requestMap.put(API_KEY_PARAM, this.apiKey);
        }
        return reqModel;
    }

    private GoogleGeocoding_Webservice.GoogleLocation getResponseFromWebservice(GoogleGeocoding_Webservice.RequestModel requestModel, String requestURL){
        String jsonResponse = '';
        
        if(Test.isRunningTest()){
            jsonResponse = mockWebserviceResponse(); // For Test Class
        } else {
            jsonResponse = GoogleGeocoding_Webservice.getGeocodingCoordWebservice(requestModel, requestURL);
        }
        return GoogleGeocoding_Webservice.getLocationFromJSONResp(jsonResponse);
    }

    webservice static String getGeocodingCoordWebservice(GoogleGeocoding_Webservice.RequestModel requestModel, String requestURL){
        String requestStr = ADDRESS_PARAM + '=' + EncodingUtil.urlEncode(requestModel.requestMap.get(ADDRESS_PARAM), 'UTF-8') + '&' +
        API_KEY_PARAM + '=' + requestModel.requestMap.get(API_KEY_PARAM);

        try {
            HTTPResponse resp = SME_HTTPCallUtil.sendHttpGetRequest(requestURL,requestStr);
            if(resp.getStatusCode() != 200) {
                throw new CIWebserviceException('HTTPResponse:' + resp.getStatusCode() + ' Status:' + resp.getStatus());
            }
            String jsonResponseStr = resp.getBody();
            return jsonResponseStr;
        } catch(CalloutException e){
            String errorMessage = ExceptionMessage.HTTP_CONNECTION_FAILED+' Endpoint:'+requestURL+' Message:'+e.getMessage()+' Trace:'+e.getStackTraceString();
            throw new CIWebserviceException(errorMessage);
        } catch(Exception e){
            String errorMessage = ExceptionMessage.HTTP_CONNECTION_FAILED+' Endpoint:'+requestURL+' Message:'+e.getMessage()+' Trace:'+e.getStackTraceString();
            throw new CIWebserviceException(errorMessage);
        }
    }

    private static GoogleGeocoding_Webservice.GoogleLocation getLocationFromJSONResp(String jsonStr) {
        GoogleGeocoding_Webservice.GoogleLocation locationModel = new GoogleGeocoding_Webservice.GoogleLocation();
        JSONParser parser = JSON.createParser(jsonStr);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'location')) {
                parser.nextToken();
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    locationModel = (GoogleGeocoding_Webservice.GoogleLocation) parser.readValueAs(GoogleGeocoding_Webservice.GoogleLocation.class);
                    break;// focus on first
                }
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'status')) {
                parser.nextToken();
                if(parser.getText() == 'ZERO_RESULTS') locationModel.statusMsg = 'Coord cannot be found from search address.';
                if(parser.getText() == 'OVER_QUERY_LIMIT') locationModel.statusMsg = 'Daily limit has been reached.';
                if(parser.getText() == 'REQUEST_DENIED') locationModel.statusMsg = 'Please ensure this API is activated.';
            }
        }
        return locationModel;
    }

    private static String mockWebserviceResponse() {
        String resultsResp = '';
        if(testMode == 'ZERO_RESULTS') {
            resultsResp = '{"results": [],"status": "ZERO_RESULTS"}';
        } else if(testMode == 'OVER_QUERY_LIMIT') {
            resultsResp = '{"error_message" : "You have exceeded your daily request quota for this API.","results" : [],"status" : "OVER_QUERY_LIMIT"}';
        } else {
            resultsResp = '{"results": [{"address_components": [{"long_name": "10150","short_name": "10150","types": ["postal_code"]}],"formatted_address": "Chom Thong, Bangkok 10150, Thailand","geometry": {"location": {"lat": 13,"lng": 100},"location_type": "APPROXIMATE"}}],"status": "OK"}';
        }
        return resultsResp;
    }

    public String concatAddress(String searchString, String fieldString) {
        if(String.isNotBlank(fieldString)) {
            if(searchString != '') {
                return searchString + ' ' + String.valueOf(fieldString);
            } else {
                return String.valueOf(fieldString);
            }
        }
        return searchString;
    }
}