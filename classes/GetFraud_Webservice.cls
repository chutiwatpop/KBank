global class GetFraud_Webservice {
	private static GetFraud_Webservice instance;
    public static final String CIS_ID = 'CIS_ID';
    webservice String cisId {get;set;}

    public static GetFraud_Webservice getInstance() {
        if(instance == null) instance = new GetFraud_Webservice();
        return instance;
    }

	public GetFraud_Webservice() {
		this.cisId = '';
	}

	global class RequestModel {
		global RequestModel() {}
		public Map<String,String> requestMap {get;set;}
	}

	global class ResponseModel extends CIBaseResponseModel {
		global ResponseModel() {}
		public List<CustomerFraud> customerModel{get;set;}
	}

	global class CustomerFraud {
		public String IP_ID;
		public String IP_TP_CD;
		public String BLIST_TP_CD; //Negative Status
		public String POS_DT;
		public String PPN_TMS;
		public String SRC_STM_ID;
	}

	public GetFraud_Webservice.ResponseModel calloutWebservice() {
    	GetFraud_Webservice.RequestModel requestModel = getRequestModel();
    	GetFraud_Webservice.ResponseModel responseModel = new GetFraud_Webservice.ResponseModel();
	    if(!requestModel.requestMap.isEmpty()) {
	    	responseModel = getResponseFromWebservice(requestModel);
	    } else {
	    	throw new CIWebserviceException('Invalid request parameter');
	    }
    	return responseModel;
    }

    private GetFraud_Webservice.RequestModel getRequestModel(){       
        GetFraud_Webservice.RequestModel reqModel = new GetFraud_Webservice.RequestModel();
        reqModel.requestMap = new Map<String, String>();

        if(this.cisId != null && this.cisId.trim() != ''){
            this.cisId = this.cisId.trim();
            if(GlobalUtility.isNumberAlphabet(this.cisId)){
                reqModel.requestMap.put(CIS_ID, this.cisId);
            }
        }
        return reqModel;
    }

    private GetFraud_Webservice.ResponseModel getResponseFromWebservice(GetFraud_Webservice.RequestModel requestModel){
      	String jsonResponse = '';
      	
      	if(Test.isRunningTest() || (Label.isMockFraud != null && Label.isMockFraud != '' && Label.isMockFraud != 'disable')){
			jsonResponse = mockWebserviceResponse(requestModel); // For Test Class
      	} else {
      		jsonResponse = SME_CIRestWebservice.getFraudStatus(requestModel);
      	}

        GetFraud_Webservice.ResponseModel responseModel;
        responseModel = (GetFraud_Webservice.ResponseModel) System.JSON.deserialize(jsonResponse, GetFraud_Webservice.ResponseModel.class);

        if(responseModel.error != null && responseModel.error.message != null) {
            throw new CIWebserviceException(responseModel.error.message);
        }
        return responseModel;
    }

    private String mockWebserviceResponse(GetFraud_Webservice.RequestModel requestModel) {
        String mockBLIST_TP_CD = Label.isMockFraud;
        if(mockBLIST_TP_CD == 'blank') {
            mockBLIST_TP_CD = '';
        }
        if(requestModel.requestMap.get(CIS_ID) == '1991')
            return '{\"success\":true,\"jobinfo\":{\"jobid\":\"8B305E055080A9A1BF3FEAB21D5D4A69\",\"jobstarttime\":\"2017-06-09T14:35:16.130+07:00\",\"orchestration\":\"Orchestrations/CI088_Online_Fraud\"},\"customerModel\":[{\"IP_ID\":\"'+ requestModel.requestMap.get(CIS_ID) + '\",\"IP_TP_CD\":\"\",\"BLIST_TP_CD\":\"D\"}]}';
        if(requestModel.requestMap.get(CIS_ID) == '1992')
            return '{\"success\":true,\"jobinfo\":{\"jobid\":\"8B305E055080A9A1BF3FEAB21D5D4A69\",\"jobstarttime\":\"2017-06-09T14:35:16.130+07:00\",\"orchestration\":\"Orchestrations/CI088_Online_Fraud\"},\"customerModel\":[{\"IP_ID\":\"'+ requestModel.requestMap.get(CIS_ID) + '\",\"IP_TP_CD\":\"\",\"BLIST_TP_CD\":\"G\"}]}';
        if(requestModel.requestMap.get(CIS_ID) == '1993')
            return '{\"success\":true,\"jobinfo\":{\"jobid\":\"8B305E055080A9A1BF3FEAB21D5D4A69\",\"jobstarttime\":\"2017-06-09T14:35:16.130+07:00\",\"orchestration\":\"Orchestrations/CI088_Online_Fraud\"},\"customerModel\":[{\"IP_ID\":\"'+ requestModel.requestMap.get(CIS_ID) + '\",\"IP_TP_CD\":\"\",\"BLIST_TP_CD\":\"N\"}]}';
        if(requestModel.requestMap.get(CIS_ID) == '1995')
            return '{\"success\":true,\"jobinfo\":{\"jobid\":\"8B305E055080A9A1BF3FEAB21D5D4A69\",\"jobstarttime\":\"2017-06-09T14:35:16.130+07:00\",\"orchestration\":\"Orchestrations/CI088_Online_Fraud\"},\"customerModel\":[{\"IP_ID\":\"195\",\"IP_TP_CD\":\"\",\"BLIST_TP_CD\":\"N\"}]}';
        else
            return '{\"success\":true,\"jobinfo\":{\"jobid\":\"8B305E055080A9A1BF3FEAB21D5D4A69\",\"jobstarttime\":\"2017-06-09T14:35:16.130+07:00\",\"orchestration\":\"Orchestrations/CI088_Online_Fraud\"},\"customerModel\":[{\"IP_ID\":\"'+ requestModel.requestMap.get(CIS_ID) + '\",\"IP_TP_CD\":\"\",\"BLIST_TP_CD\":\"'+mockBLIST_TP_CD+'\"}]}';
    }

}