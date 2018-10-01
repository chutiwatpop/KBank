global with sharing class CreateProspect_Webservice {
	private static CreateProspect_Webservice instance;

	// Request Parameter
    public static final String CIS_ID 				= 'CIS_ID';
    public static final String IDENTIFICATION_NO 	= 'IDENT_NO';
    public static final String BIRTH_DATE 			= 'BRTH_ESTB_DT';

    webservice String cisId {get;set;}
	webservice String birthDate {get;set;}
	webservice String identNo {get;set;}

	@TestVisible
    public static String mockJSONResponse;
	
	public CreateProspect_Webservice() {
		this.cisId = '';
		this.identNo = '';
		this.birthDate = '';
	}

	// Webservice Request/Response
	global class ResponseModel extends CIBaseResponseModel {
		global ResponseModel() {}
		public CustomerInfo customerModel{get;set;}
		public List<CustomerAddress> customerAddresses{get;set;}
	}

	global class CustomerInfo {
		//INTEGER(11) - Id of involved party / เลขที่ลูกค้า
		public String IP_ID;
		//CHAR(1) - Flag that use to identify type of involved party (prospect or customer) / Prospect  หรือ Customer 
		public String PRVN_F;
		//CHAR(1) - Code of involved party type / รหัสประเภทลูกค้า
		public String IP_TP_CD;
		//DATE - Birth Date or Registration Date
		public String BRTH_ESTB_DT;
		//CHAR(2) - Code to identify type of document  ประเภทเอกสารสำคัญ 11=บัตรประชาชน 12=หนังสือเดินทาง 13=ใบต่างด้าว 21=เลขที่จดทะเบียนบริษัท  99=เอกสารอื่นๆT 
		public String DOC_ITM_CD;
		//CHAR(1) - Code of involved party performance status that identify customer is good customer or bad customer เป็นลูกค้าไม่ดีหรือไม่
		public String IP_PERF_ST_CD;
		//CHAR(2) - Code of segment which is a group of customer / รหัสกลุ่มลูกค้า 
		public String PRIM_SEG_CD;
		//CHAR(2) - Code of segment which is a group of customer / รหัสกลุ่มลูกค้า
		public String PRIM_SUB_SEG_CD;
		//CHAR(2) - Code of segment which is a group of customer / รหัสกลุ่มลูกค้า
		public String DUAL_SEG_CD;
		//CHAR(2) - Code of segment which is a group of customer / รหัสกลุ่มลูกค้า
		public String DUAL_SUB_SEG_CD;
		//CHAR(9) - Industry classification code / รหัสประเภทธุรกิจ
		public String KBNK_IDY_CL_CD;
		//CHAR(9) - Industry classification code / รหัสประเภทธุรกิจ 
		public String CO_IDY_CL_CD;
		public String EN_TTL;
		public String TH_TTL;
		public String EN_FRST_NM;
		public String TH_FRST_NM;
		public String EN_MDL_NM;
		public String TH_MDL_NM;
		public String EN_SURNM;
		public String TH_SURNM;
		public String IDENT_NO;
	}

	global class CustomerAddress {
		//	DECIMAL(15,0)	A number uniquely identifying an address. / เลขที่ของที่อยู่
		public String ADR_ID; 
		//	CHAR(2)	Code of address use type code to identify use type (which use to classify) / รหัสประเภทของที่อยู่
		public String ADR_USE_TP_CD; 
		//	VARCHAR(100)	Place Name / ชื่อสถานที่
		public String WRKPLC_NM; 
		//	VARCHAR(20)	Box Number / ตู้ ปณ.
		public String BOX_NO; 
		//	CHAR(15)	House number / บ้านเลขที่
		public String HS_NO; 
		//	CHAR(10)	Village number / หมู่ที่
		public String VILL_NO; 
		//	VARCHAR(40)	Village / หมู่บ้าน
		public String VILL; 
		//	VARCHAR(40)	Building Name / อาคาร
		public String BLD_NM; 
		//	CHAR(10)	Room number / ห้อง
		public String ROOM_NO; 
		//	CHAR(8)	Floor number / ชั้น
		public String FLR_NO; 
		//	VARCHAR(40)	Alley / ซอย
		public String ALY; 
		//	VARCHAR(40)	Street name / ถนน
		public String STR_NM; 
		//	VARCHAR(30)	Sub-district / แขวง/ตำบล
		public String SUBDSTC; 
		//	VARCHAR(30)	District / เขต/อำเภอ
		public String DSTC; 
		//	VARCHAR(40)	Province / จังหวัด
		public String PROV; 
		//	CHAR(10)	Original code from CIS / รหัสที่อยู่จากระบบเดิม
		public String CIS_SRC_STM_CD; 
		//	CHAR(5)	Postcode area code / รหัสไปรษณีย์
		public String PSTCD_AREA_CD; 
		//	CHAR(3)	Country code / รหัสประเทศ
		public String CTY_CD; 
	}

	public class CustomerResultModel {
		Account accountObj;
		Boolean isProspect;
		Boolean isError;
	}

	global class RequestModel {
		global RequestModel() {}
		public Map<String,String> requestMap {get;set;}
	}

	public static CreateProspect_Webservice getInstance() {
        if(instance == null) instance = new CreateProspect_Webservice();
        return instance;
    }

    public void setRequestParamFromAccount(Account requestAccount) {
    	if(GlobalUtility.isNumberAlphabet(requestAccount.CIS__c)) {
            this.cisId = requestAccount.CIS__c;
        }
        if(requestAccount.Birthdate_Registration_Date__c != null){
            this.birthDate = SME_JSONGenerator.toValue(requestAccount.Birthdate_Registration_Date__c);
        }
        if(requestAccount.Encrypt_Identification_No__c != null){
            this.identNo = requestAccount.Encrypt_Identification_No__c;
        }
    }

    public CreateProspect_Webservice.ResponseModel calloutWebservice() {
    	String functionName = 'calloutWebservice';
    	CreateProspect_Webservice.RequestModel requestModel = getRequestModel();
    	System.debug('requestModel:' + requestModel);
    	CreateProspect_Webservice.ResponseModel responseModel = new CreateProspect_Webservice.ResponseModel();
    	try {
    	    if(!requestModel.requestMap.isEmpty()) {
    	    	responseModel = getResponseFromWebservice(requestModel);
    	    } else {
    	    	responseModel.error = new CIBaseResponseModel.ErrorResponse();
    	    	responseModel.error.message = 'Invalid request parameter';
    	    }
    	}
    	catch (Exception e) {
    	    responseModel.error = new CIBaseResponseModel.ErrorResponse();
    	    responseModel.error.message = e.getMessage();
    	}

    	return responseModel;
    }

    private CreateProspect_Webservice.RequestModel getRequestModel(){       
        CreateProspect_Webservice.RequestModel reqModel = new CreateProspect_Webservice.RequestModel();
        reqModel.requestMap = new Map<String, String>();

        if(this.cisId != null && this.cisId.trim() != ''){
            this.cisId = this.cisId.trim();
            if(GlobalUtility.isNumberAlphabet(this.cisId)){
                reqModel.requestMap.put(CIS_ID, this.cisId);
            }
        }

        if(this.identNo != null && this.identNo.trim() != ''){
            this.identNo = this.identNo.trim();
            reqModel.requestMap.put(IDENTIFICATION_NO, this.identNo);
        }

        if(this.birthDate != null && this.birthDate.trim() != ''){
            this.birthDate = this.birthDate.trim();
            reqModel.requestMap.put(BIRTH_DATE, this.birthDate);
        }

        return reqModel;
    }

	private CreateProspect_Webservice.ResponseModel getResponseFromWebservice(CreateProspect_Webservice.RequestModel requestModel){
      	String jsonResponse = '';
      	
      	if(Test.isRunningTest()) {
      		jsonResponse = mockJSONResponse;
      	} else {
      		jsonResponse = SME_CIRestWebservice.createProspectRequest(requestModel);	
      	}

        CreateProspect_Webservice.ResponseModel responseModel;
        responseModel = parseJSONString(jsonResponse);

        return responseModel;
    }

    public static ResponseModel parseJSONString(String jsonString) {
		return (ResponseModel) System.JSON.deserialize(jsonString, ResponseModel.class);
	}
}