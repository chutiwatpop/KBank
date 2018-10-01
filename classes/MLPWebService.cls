global class MLPWebService {
	private static MLPWebService instance;
	//private Map<String, String> requestMap;
	public static MLPWebService getInstance() {
        if(instance == null) instance = new MLPWebService();
        return instance;
	}

	public CIBaseResponseModel calloutWebservice() {
    	Map<String, String> requestMap = getCalloutModel();
    	CIBaseResponseModel responseModel = new CIBaseResponseModel();
    	try {
    	    if(!requestMap.isEmpty()) {
    	    	responseModel = getResponse(requestMap);
    	    } else {
    	    	responseModel.error = new CIBaseResponseModel.ErrorResponse();
    	    	responseModel.error.message = 'Invalid request parameter';	
    	    }
    	} catch (Exception e) {
    		responseModel.error = new CIBaseResponseModel.ErrorResponse();
    	    responseModel.error.message = e.getMessage();	
    	}

    	return responseModel;
    }

    private CIBaseResponseModel getResponse(Map<String, String> reqModel){
    	String jsonResponse = '';
      	jsonResponse = SME_CIRestWebservice.updateStatusLeadMLPToDIH(JSON.serialize(reqModel));
        CIBaseResponseModel responseModel = (CIBaseResponseModel) System.JSON.deserialize(jsonResponse, CIBaseResponseModel.class);
        return responseModel;
    }

    private Map<String, String> getCalloutModel(){
    	Map<String,String> requestMap = new Map<String,String>();
    	requestMap.put('date', SME_JSONGenerator.toValue(System.today()));
    	return requestMap;
    }
}