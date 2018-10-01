@isTest
private class Cmas_Service_Test {
	private static final String accountNameRM = 'accountNameRM';
	//private static final String cwuRefNo = '001';
	private static final String cmasRefNo = 'CB/0103/12822/2560/0005';
	private static final String cmasAppID = '1010101010';
	private static final String oppName = 'Test Opp 1';
	private static final String appTypeCode = '01';
	private static final String cwuStatus ='01';
	private static final String businessCode ='002020201';
	private static final String creditType='01';
	private static final String facCode1 ='105023001';
	private static final String facCode2 ='105023002';
	@testSetup static void setupAccount(){
		Test.startTest();
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCodeOnlySme();
		User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			 insert new Account(
			            Name = accountNameRM,
			            Port_Pool__c = GlobalConstants.PORT,
			            RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
			            Primary_Segment_Code__c = 'SM',
			            Temporary_Customer__c = true,
			            Is_createby_Integration__c = true,
			            Customer_Type_Code__c = 'O',
			            Customer_Status__c = 'P',
			            CIS__c = '723'
			        );

		//mt.newAccount(accountNameRM,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
		}
		User updateUserJobcode = new User(Id=UserInfo.getUserId(),Job_Code__c='ME4A',RC_Code__c='54321',Employee_Id__c = '4000000001');
		TriggerHandler.bypass('UserTriggerHandler');
		update updateUserJobcode;
		TriggerHandler.clearbypass('UserTriggerHandler');
		Test.stopTest();

		String applicationNo = '';
		Application_History__c newAppHis;
		Opportunity newOpp;
		//Address__c newAddr;
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM LIMIT 1];
		
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Name,CIS__c');
		account.Temporary_Customer__c = false;
		update account;

		System.runAs(rmUser){
			newOpp = Mockup_Test.newOpportunity(account.Id, oppName, GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
			insert newOpp;
			newAppHis = Mockup_Test.newApplicationHistory(newOpp.Id, applicationNo, GlobalConstants.ESTIMATE_CREDIT_MODEL_DLA, 'ส่งครั้งแรก', GlobalConstants.CMAS, System.today(), 100000);
			insert newAppHis;
			Address__c mockAddress = new Address__c(
				CIS_ID__c = account.Id,
				Place__c = 'place',
				Pin_Location__Latitude__s = 13.001,
				Pin_Location__Longitude__s = 100.001
			);
			insert mockAddress;	
		}


		//Mock PIM Code
		PIM__c pimObj1 = new PIM__c();
		PIM__c pimObj2 = new PIM__c();
		pimObj1.Product_Name_English__c = 'K-Cash Connect Plus';
		pimObj1.Product_Group_English__c = 'K-Cash Management Solutions';
		pimObj1.Product_subGroup_English__c = 'K-Business Electronic Service Solutions';
		pimObj2.Product_Name_English__c = 'K-Cash Connect Plus2';
		pimObj2.Product_Group_English__c = 'K-Cash Management Solutions2';
		pimObj2.Product_subGroup_English__c = 'K-Business Electronic Service Solutions2';


		List<PIM__c> pimList = new List<PIM__c>();
		pimList.add(pimObj1);
		pimList.add(pimObj2);

		insert pimList;

		//PL กับ DLA 
		TriggerHandler.bypass('OpportunityTriggerHandler');
		update newOpp;
		TriggerHandler.clearbypass('OpportunityTriggerHandler');
	}
	@isTest static void sendtoCMAS() {
		//136
		List<Opportunity>  oppList = [SELECT ID,CWU_Number__c FROM Opportunity WHERE Name=:oppName];
		List<Application_History__c> appList = [SELECT ID,App_Num_CMAS__c,SP_Approval_Result__c,SP_Approve_Option__c FROM Application_History__c WHERE OppName__r.Name=:oppName];

		Id oppID = oppList.get(0).Id;
		Id appID = appList.get(0).Id;
		String jsonResponse = CMAS_Service.sendToCMAS(appID);
	}

	//@isTest static void sendtoCMASError() {
	//	//136
	//	List<Opportunity>  oppList = [SELECT ID,CWU_Number__c FROM Opportunity WHERE Name=:oppName];
	//	List<Application_History__c> appList = [SELECT ID,App_Num_CMAS__c,Business_Code__r.Sub_Industry_Group__c,Current_Team_Name__r.Hub_Code__c FROM Application_History__c WHERE OppName__r.Name=:oppName];
	//	System.debug(' Business_Code__r.Sub_Industry_Group__c'+appList.get(0).Business_Code__r.Sub_Industry_Group__c);
	//	System.debug(' Current_Team_Name__r.Hub_Code__c'+appList.get(0).Current_Team_Name__r.Hub_Code__c);
	//	Id oppID = oppList.get(0).Id;
	//	Id appID = appList.get(0).Id;
	//	String jsonResponse = CMAS_Service.sendToCMAS(appID);
	//}

	@isTest static void ci131_TFB_SO_CW_STA() {
		// Implement test code
		
		List<Application_History__c> appList = [SELECT ID,CWU_Number__c,App_Num_CMAS__c,SP_Approval_Result__c,SP_Approve_Option__c FROM Application_History__c WHERE OppName__r.Name=:oppName];
		String appID = String.valueOf(appList.get(0).Id);
		String JsonMsg='{"batch_Name":"TFB_SO_CW_STA","cwu_ref_no":"'+appID+'"}';

		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}

	@isTest static void ci131_TFB_SO_CW_STA_NullRef() {
		// Implement test code
		String JsonMsg='{"batch_Name":"TFB_SO_CW_STA","cwu_ref_no":""}';

		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug('RestContext ci131_TFB_SO_CW_STA_Error');
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}
	@isTest static void ci131_TFB_SO_CW_STA_Fault() {
		// Implement test code
		String JsonMsg='{"batch_Name":"TFB_SO_CW_STA","cwu_ref_no":"000000000000000"}';

		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug('RestContext ci131_TFB_SO_CW_STA_Fault');
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}

	//{"batch_Name":"TFB_SO_CW_STA_UPD","cwu_ref_no":"0065D000002En7O","cwu_status":"05","update_datetime":"2017-11-23-19.24.52.880"}
	@isTest static void ci132_TFB_SO_CW_STA_UPD() {

		List<Application_History__c> appList = [SELECT ID,CWU_Number__c,App_Num_CMAS__c,SP_Approval_Result__c,SP_Approve_Option__c FROM Application_History__c WHERE OppName__r.Name=:oppName];
		String appID = String.valueOf(appList.get(0).Id);
		String JsonMsg='{"batch_Name":"TFB_SO_CW_STA_UPD","cwu_ref_no":"'+appID+'"}';
		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}

	@isTest static void ci132_TFB_SO_CW_STA_UPD_NullRef() {
		List<Opportunity>  oppList = [SELECT ID,CWU_Number__c FROM Opportunity WHERE Name=:oppName];
		String oppID = String.valueOf(oppList.get(0).Id);
		String JsonMsg='{"batch_Name":"TFB_SO_CW_STA_UPD","cwu_ref_no":"","cwu_status":"01","update_datetime":"2017-11-23-19.24.52.880"}';

		Test.startTest();
		//As Per Best Practice it is important to instantiate the Rest Context 
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}
	@isTest static void ci132_TFB_SO_CW_STA_UPD_Fault() {
		List<Opportunity>  oppList = [SELECT ID,CWU_Number__c FROM Opportunity WHERE Name=:oppName];
		String oppID = String.valueOf(oppList.get(0).Id);
		String JsonMsg='{"batch_Name":"TFB_SO_CW_STA_UPD","cwu_ref_no":"000000000000000","cwu_status":"01","update_datetime":"2017-11-23-19.24.52.880"}';

		Test.startTest();
		//As Per Best Practice it is important to instantiate the Rest Context 
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}

	//{"batch_Name":"TFB_SO_OPP","cwu_ref_no":"000000000317542"}
	@isTest static void ci133_TFB_SO_OPP() {
		List<Application_History__c> appList = [SELECT ID,CWU_Number__c,App_Num_CMAS__c,SP_Approval_Result__c,SP_Approve_Option__c FROM Application_History__c WHERE OppName__r.Name=:oppName];
		String appID = String.valueOf(appList.get(0).Id);
		String JsonMsg='{"batch_Name":"TFB_SO_OPP","cwu_ref_no":"'+appID+'"}';
		Test.startTest();
		//As Per Best Practice it is important to instantiate the Rest Context 
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}
	
	@isTest static void ci133_TFB_SO_OPP_NullRef() {
		List<Opportunity>  oppList = [SELECT ID,CWU_Number__c FROM Opportunity WHERE Name=:oppName];
		String oppID = String.valueOf(oppList.get(0).Id);
		String JsonMsg='{"batch_Name":"TFB_SO_OPP","cwu_ref_no":""}';

		Test.startTest();
		//As Per Best Practice it is important to instantiate the Rest Context 
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}
	@isTest static void ci133_TFB_SO_OPP_Fault() {
		List<Opportunity>  oppList = [SELECT ID,CWU_Number__c FROM Opportunity WHERE Name=:oppName];
		String oppID = String.valueOf(oppList.get(0).Id);
		String JsonMsg='{"batch_Name":"TFB_SO_OPP","cwu_ref_no":"000000000000000"}';

		Test.startTest();
		//As Per Best Practice it is important to instantiate the Rest Context 
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}


	//{"batch_Name":"TFB_SO_OPP_CR","opportunity_id":"NEXT","facility_status":"0","cwu_ref_no":"0065D000002Emp0","tfb_so_opp_c_vw_facility_cd":"110581001","tfb_so_opp_c_vw_facility_limit":"40000","tfb_so_opp_c_vw_facility_tenure":"","tfb_so_opp_c_vw_facility_tenure_type":""}
	@isTest static void ci134_TFB_SO_CW_STA() {
		List<Application_History__c> appList = [SELECT ID,CWU_Number__c,App_Num_CMAS__c,SP_Approval_Result__c,SP_Approve_Option__c FROM Application_History__c WHERE OppName__r.Name=:oppName];
		String appID = String.valueOf(appList.get(0).Id);
		String JsonMsg='{"batch_Name":"TFB_SO_OPP_CR","opportunity_id":"'+appID+'","facility_status":"0","cwu_ref_no":"'+appID+'","tfb_so_opp_c_vw_facility_cd":"110581001","tfb_so_opp_c_vw_facility_limit":"40000","tfb_so_opp_c_vw_facility_tenure":"","tfb_so_opp_c_vw_facility_tenure_type":""}';

		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}
	@isTest static void ci134_TFB_SO_CW_STA_NullRef() {
		List<Opportunity>  oppList = [SELECT ID,CWU_Number__c FROM Opportunity WHERE Name=:oppName];
		String oppID = String.valueOf(oppList.get(0).Id);
		String JsonMsg='{"batch_Name":"TFB_SO_OPP_CR","opportunity_id":"","facility_status":"0","cwu_ref_no":"","tfb_so_opp_c_vw_facility_cd":"110581001","tfb_so_opp_c_vw_facility_limit":"40000","tfb_so_opp_c_vw_facility_tenure":"","tfb_so_opp_c_vw_facility_tenure_type":""}';

		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}
	@isTest static void ci134_TFB_SO_CW_STA_Fault() {
		List<Opportunity>  oppList = [SELECT ID,CWU_Number__c FROM Opportunity WHERE Name=:oppName];
		String oppID = String.valueOf(oppList.get(0).Id);
		String JsonMsg='{"batch_Name":"TFB_SO_OPP_CR","opportunity_id":"00000000000000","facility_status":"0","cwu_ref_no":"00000000000000","tfb_so_opp_c_vw_facility_cd":"110581001","tfb_so_opp_c_vw_facility_limit":"40000","tfb_so_opp_c_vw_facility_tenure":"","tfb_so_opp_c_vw_facility_tenure_type":""}';

		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}

	//{"batch_Name":"TFB_SO_OPP_UPD","opportunity_id":"","facility_status":"3","tfb_so_opp_c_vw_facility_cd":"","tfb_so_opp_c_vw_facility_limit":"","tfb_so_opp_c_vw_facility_tenure":"","tfb_so_opp_c_vw_facility_tenure_type":""}
	@isTest static void ci135_TFB_SO_OPP_UPD() {
		List<Application_History__c> appList = [SELECT ID,CWU_Number__c,App_Num_CMAS__c,SP_Approval_Result__c,SP_Approve_Option__c FROM Application_History__c WHERE OppName__r.Name=:oppName];
		String appID = String.valueOf(appList.get(0).Id);
		String JsonMsg='{"batch_Name":"TFB_SO_OPP_UPD","opportunity_id":"'+appID+'","facility_status":"3","tfb_so_opp_c_vw_facility_cd":"","tfb_so_opp_c_vw_facility_limit":"","tfb_so_opp_c_vw_facility_tenure":"","tfb_so_opp_c_vw_facility_tenure_type":""}';
		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}
	@isTest static void ci135_TFB_SO_OPP_UPD_NullRef() {
		String JsonMsg='{"batch_Name":"TFB_SO_OPP_UPD","opportunity_id":"","facility_status":"3","tfb_so_opp_c_vw_facility_cd":"","tfb_so_opp_c_vw_facility_limit":"","tfb_so_opp_c_vw_facility_tenure":"","tfb_so_opp_c_vw_facility_tenure_type":""}';

		Test.startTest();
		//As Per Best Practice it is important to instantiate the Rest Context 
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}
	@isTest static void ci135_TFB_SO_OPP_UPD_Fault() {
		String JsonMsg='{"batch_Name":"TFB_SO_OPP_UPD","opportunity_id":"000000000000000","facility_status":"3","tfb_so_opp_c_vw_facility_cd":"","tfb_so_opp_c_vw_facility_limit":"","tfb_so_opp_c_vw_facility_tenure":"","tfb_so_opp_c_vw_facility_tenure_type":""}';

		Test.startTest();
		//As Per Best Practice it is important to instantiate the Rest Context 
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}

	//{"batch_Name":"TFB_SO_TEAM","cust_id":"390263"}
	@isTest static void ci137_TFB_SO_TEAM() {
		String JsonMsg='{"batch_Name":"TFB_SO_TEAM","cust_id":"723"}';

		User nh = [SELECT Id,Name,Manager.Name From User WHERE Firstname =:Mockup_Test.userFirstNameNH limit 1];
		User ah = [SELECT Id,Name,Manager.Name From User WHERE Firstname =:Mockup_Test.userFirstNameAH limit 1];
		User tm = [SELECT Id,Name,Manager.Name From User WHERE Firstname =:Mockup_Test.userFirstNameTM limit 1];
		User rm = [SELECT Id,Name,Manager.Name From User WHERE Firstname =:Mockup_Test.userFirstNameRM limit 1];

		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug('137 RS:'+RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}

	@isTest static void ci137_TFB_SO_TEAM_Fault() {
		String JsonMsg='{"batch_Name":"TFB_SO_TEAM","cust_id":"724"}';
		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug('137 RS:'+RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}

	//{"batch_Name":"TFB_SO_CUST_INFO","cust_id":"390263","cis_id":""}
	@isTest static void ci138_TFB_SO_CUST_INFO() {
		String JsonMsg='{"batch_Name":"TFB_SO_CUST_INFO","cust_id":"723","cis_id":""}';

		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}

	@isTest static void ci138_TFB_SO_CUST_INFO_Fault() {
		String JsonMsg='{"batch_Name":"TFB_SO_CUST_INFO","cust_id":"724","cis_id":""}';

		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}
	@isTest static void ci139_TFB_SO_CUST_ADDR() {
		String JsonMsg='{"batch_Name":"TFB_SO_CUST_ADDR","cust_id":"723","cis_id":""}';

		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}
	@isTest static void ci139_TFB_SO_CUST_ADDR_Fault() {
		String JsonMsg='{"batch_Name":"TFB_SO_CUST_ADDR","cust_id":"724","cis_id":""}';

		Test.startTest();

		//As Per Best Practice it is important to instantiate the Rest Context 

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/CMASservices';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
		RestContext.response= res;

		Cmas_Service.doPost(); //Call the Method of the Class with Proper       Constructor
		System.debug(RestContext.response.responseBody.toString());
		System.assertNotEquals(RestContext.response.responseBody.toString(),NULL);
		Test.stopTest();
	}
	
}