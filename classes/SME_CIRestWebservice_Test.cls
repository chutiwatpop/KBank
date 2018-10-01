/*------------------------------------------------------------
Author: Sasitorn Saisuttichai
Company : Beryl8
Description:   A test class for CIRestWebservice

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015	Sasitorn.S 			First Create
14/03/2016  Charnun.T           Refactor test for callout
------------------------------------------------------------*/
@isTest
private class SME_CIRestWebservice_Test {
	public static final String PROSPECT = 'Prospect';
    public static final String NAME_TH = 'Name_TH__c';
    public static final String NAME_EN = 'Name_EN__c';
    public static final String SURNAME_TH = 'Surname_TH__c';
    public static final String SURNAME_EN = 'Surname_EN__c';
    public static final String IDENT_NO = 'Identification_No__c';
    public static final String CIS_ID = 'CIS__c';
    public static final String CIS_LIST = 'cis_ids';
    public static final String SORT_DIRECTION = 'sort_dir';

    public static final String SEARCH_POSITIVE = 'SEARCH_POSITIVE';
    public static final String SEARCH_ERROR_ONLY = 'SEARCH_ERROR_ONLY';
    public static final String SEARCH_PARTIAL_ERROR = 'SEARCH_PARTIAL_ERROR';
    public static final String SEARCH_STATUS_500 = 'SEARCH_STATUS_500';
    public static final String SORT_POSITIVE = 'SORT_POSITIVE';
    public static final String EMPTY_RESPONSE = 'EMPTY_RESPONSE';
    public static final String EMPTY_JSON = 'EMPTY_JSON';
    public static final String SORT_PARTIAL_ERROR = 'SORT_PARTIAL_ERROR';
    public static final String SORT_INVALID_RESPONSE = 'SORT_INVALID_RESPONSE';
    public static final String SEARCH_INVALID_RESPONSE = 'SEARCH_INVALID_RESPONSE';

    private static void verifyCISList(List<String> expectedCISList,List<String> actualCISList){
		for(Integer i=0; i<expectedCISList.size(); i++) {
   			String expectedValue = expectedCISList.get(i);
			String actualValue = actualCISList.get(i);
			System.assertEquals(expectedValue,actualValue);
		}
	}

	@isTest static void test_sort_deserializeJSON_Positive() {
      String jsonStr = '{\"sortResponse\":{'+
        '\"cis_id\": [\"5137447\", \"5137448\", \"2309876\"]'+
        '}}';
		CustomerResponseModel respModel = SME_CIRestWebservice.getResponseModelFromSortResultStr(jsonStr);
		List<String> expectedCISList = new List<String>();
		expectedCISList.add('5137447');
		expectedCISList.add('5137448');
		expectedCISList.add('2309876');
		expectedCISList.size();
		respModel.cisList.size();
		System.assertEquals(expectedCISList.size(),respModel.cisList.size());
		verifyCISList(expectedCISList,respModel.cisList);
	}

	@isTest static void test_serializeJSON_Positive() {
		CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';

        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
		String requestStr = SME_CIRestWebservice.getRequestStringFromMap(actualModel.requestMap);
		//String expectedRequestStr = 'IP_ID=testCis&&IDENT_NO=testId&&EN_FRST_NM=SURNAME_EN=testFirst&&testLastName&&';
		String expectedRequestStr = 'EN_FRST_NM=testFirst&&EN_SURNM=testLastName';
		System.assertEquals(expectedRequestStr,requestStr);
	}

	@isTest static void test_search_deserializeJSON_Positive() {
		String jsonStr = '{\"searchResponse\":{'+
        '\"cis_id\": [\"5137447\", \"5137448\", \"2309876\"]'+
        '}}';
		CustomerResponseModel respModel = SME_CIRestWebservice.getResponseModelFromSearchResultStr(jsonStr);
		List<String> expectedCISList = new List<String>();
		expectedCISList.add('5137447');
		expectedCISList.add('5137448');
		expectedCISList.add('2309876');
		respModel.cisList.size();
		System.debug('respModel'+respModel);
		System.assertEquals(expectedCISList.size(),respModel.cisList.size());
		verifyCISList(expectedCISList,respModel.cisList);
	}


	@isTest static void test_search_deserializeJSON_InvalidFormat() {
        String jsonStr = '{\"sortResponse\":{'+
		'\"cis_id_invalidKey\": [\"001O000000kfDTl\",\"001O000000kfDTm\",\"001\",\"5137447\", \"5137448\", \"2309876\"],'+
		'\"errorMessage\":\"Incomplete Response\"'+
		'}}';
		String errMsg  = ExceptionMessage.PARSE_FAILED;
		Boolean checkResult = False;
		CIWebserviceException actualEx;
		Test.startTest();
		CustomerResponseModel respModel;
		try{
			respModel = SME_CIRestWebservice.getResponseModelFromSearchResultStr(jsonStr);
		}catch(CIWebserviceException ex){
			actualEx = ex;
		}
		Test.stopTest();
		System.assertEquals(null, respModel.cisList);
		System.assertEquals(null, respModel.errorMsg);
	}

	@isTest static void test_search_deserializeJSON_Error() {
        String jsonStr = '{\"sortResponse\":{'+
		'\"cis_id\": [\"001O000000kfDTl\",\"001O000000kfDTm\",\"001\",\"5137447\", \"5137448\", \"2309876\"],'+
		'\"errorMessage\":\"Incomplete Response\"'+
		'}}';

		String errMsg  = ExceptionMessage.CI_RESPONSE_ERROR;
		CIWebserviceException actualEx;

		Test.startTest();
		try{
			CustomerResponseModel respModel = SME_CIRestWebservice.getResponseModelFromSortResultStr(jsonStr);
		}catch(CIWebserviceException ex){
			actualEx = ex;
		}
		Test.stopTest();

		System.assertNotEquals(null, actualEx, 'An error should be thrown.');
		System.debug(actualEx.getMessage());
		System.assertEquals(True,actualEx.getMessage().containsIgnoreCase(errMsg));

	}
	@isTest static void test_sort_deserializeJSON_Error() {
        String jsonStr = '{\"sortResponse\":{'+
		'\"cis_id\": [\"001O000000kfDTl\",\"001O000000kfDTm\",\"001\",\"5137447\", \"5137448\", \"2309876\"],'+
		'\"errorMessage\":\"Incomplete Response\"'+
		'}}';
		String errMsg  = ExceptionMessage.CI_RESPONSE_ERROR;
		CIWebserviceException actualEx;

		Test.startTest();
		try{
			CustomerResponseModel respModel = SME_CIRestWebservice.getResponseModelFromSortResultStr(jsonStr);
		}catch(CIWebserviceException ex){
			actualEx = ex;
		}
		Test.stopTest();

		System.assertNotEquals(null, actualEx, 'An error should be thrown.');
		System.debug(actualEx.getMessage());
		System.assertEquals(True,actualEx.getMessage().containsIgnoreCase(errMsg));
	}


	@isTest static void test_sendHTTPResponse_Error500() {
		// Set mock callout class

		CIWebserviceException actualEx;
		// Call method to test.
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock.
		String expectedErrorMsg = 'Code:500';
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		// input
		CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = SEARCH_STATUS_500;
        tController.lastname = 'testLastName';

        // execute httpcallout
        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        CustomerResponseModel responseModel = new CustomerResponseModel();
        Test.startTest();
        try{
        	responseModel = SME_CIRestWebservice.searchCISListByCustomerSearchRequest(actualModel);
        } catch(CIWebserviceException ex){
        	actualEx = ex;
        }
		Test.stopTest();
		System.debug('error :'+actualEx.getMessage());
		System.assertNotEquals(null, actualEx, 'An error should be thrown.');
		System.assertEquals(true,actualEx.getMessage().containsIgnoreCase(expectedErrorMsg));
	}

	@isTest static void test_getResponseModelFromSearchResultStr_Positive() {
		// Call method to test.
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock.
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		// input
		CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = SEARCH_POSITIVE;
        tController.lastname = 'testLastName';
		List<String> expectedCISList = new List<String>();
		expectedCISList.add('001O000000kfDTl1');
		expectedCISList.add('001O000000kfDTm1');
        // execute httpcallout
        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        CustomerResponseModel responseModel;
        Test.startTest();
        responseModel = SME_CIRestWebservice.searchCISListByCustomerSearchRequest(actualModel);
		Test.stopTest();
		System.assertEquals(null,responseModel.errorMsg);
		System.assertEquals(expectedCISList.size(),responseModel.cisList.size());
		verifyCISList(expectedCISList,responseModel.cisList);
	}

	@isTest static void test_sortCISListByCustomerSearchRequest_Positive() {
		// Call method to test.
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock.
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		// input
		CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'SORTTYPE';
        tController.lastname = 'SORTTYPE';
        tController.sortDirection = 'ASC';
        List<String> cisList = new List<String>();
        cisList.add('5137447');
        cisList.add('5137448');
        tController.displayedCisList = cisList;

		List<String> expectedCISList = new List<String>();
		expectedCISList.add('5137448');
		expectedCISList.add('5137447');
        // execute httpcallout
        Test.startTest();
        CustomerSearchRequestModel actualModel = tController.getCustomerRequestForSorting(); 
        CustomerResponseModel responseModel;
 
        responseModel = SME_CIRestWebservice.sortCISListByCustomerSearchRequest(actualModel);
		System.debug(responseModel);
		Test.stopTest();
		System.assertEquals(null,responseModel.errorMsg);
		System.assertEquals(expectedCISList.size(),responseModel.cisList.size());
		verifyCISList(expectedCISList,responseModel.cisList);
	}
	@isTest static void test_getResponseModelFromSearchResultStr_ErrorOnly() {
		// Set mock callout class
		CIWebserviceException actualEx;
		// Call method to test.
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock.
		String expectedErrorMsg = ExceptionMessage.CI_RESPONSE_ERROR;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		// input
		CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = SEARCH_ERROR_ONLY;
        tController.lastname = 'testLastName';

        // execute httpcallout
        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        CustomerResponseModel responseModel = new CustomerResponseModel();
        Test.startTest();
        try{
        	responseModel = SME_CIRestWebservice.searchCISListByCustomerSearchRequest(actualModel);
        } catch(CIWebserviceException ex){
        	actualEx = ex;
        }
		Test.stopTest();
		System.assertNotEquals(null, actualEx, 'An error should be thrown.');
		System.assertEquals(True,actualEx.getMessage().containsIgnoreCase(expectedErrorMsg));
	}

	@isTest static void test_getResponseModelFromSearchResultStr_ErrorAndData() {
	// Set mock callout class
		CIWebserviceException actualEx;
		// Call method to test.
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock.
		String expectedErrorMsg = ExceptionMessage.CI_RESPONSE_ERROR;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		// input
		CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = SEARCH_PARTIAL_ERROR;
        tController.lastname = 'testLastName';
        List<String> cisList = new List<String>();
        cisList.add('5137447');
        cisList.add('5137448');
        tController.displayedCisList = cisList;
        // execute httpcallout
        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        CustomerResponseModel responseModel = new CustomerResponseModel();
        Test.startTest();
        try{
        	responseModel = SME_CIRestWebservice.searchCISListByCustomerSearchRequest(actualModel);
        } catch(CIWebserviceException ex){
        	actualEx = ex;
        }
		Test.stopTest();
		System.assertNotEquals(null, actualEx, 'An error should be thrown.');
		System.assertEquals(True,actualEx.getMessage().containsIgnoreCase(expectedErrorMsg));
	
	}


	@isTest static void test_getResponseModelFromSearchResultStr_InvalidResponse() {
	// Set mock callout class
		CIWebserviceException actualEx;
		// Call method to test.
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock.
		String expectedErrorMsg = ExceptionMessage.PARSE_FAILED;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		// input
		CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = SEARCH_INVALID_RESPONSE;
        tController.lastname = 'testLastName';
        List<String> cisList = new List<String>();
        cisList.add('5137447');
        cisList.add('5137448');
        tController.displayedCisList = cisList;
        // execute httpcallout
        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        CustomerResponseModel responseModel = new CustomerResponseModel();
        Test.startTest();
        try{
        	responseModel = SME_CIRestWebservice.searchCISListByCustomerSearchRequest(actualModel);
        } catch(CIWebserviceException ex){
        	actualEx = ex;
        }
		Test.stopTest();
		System.assertNotEquals(null, actualEx, 'An error should be thrown.');
		System.assertEquals(True,actualEx.getMessage().containsIgnoreCase(expectedErrorMsg));
	
	}

	@isTest static void test_sortCISListByCustomerSortRequest_ErrorAndData() {
	// Set mock callout class
		CIWebserviceException actualEx;
		List<String> cisList = new List<String>();
		// Call method to test.
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock.
		String expectedErrorMsg = ExceptionMessage.CI_RESPONSE_ERROR;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		// input
		CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'ENFIRSTNAME';
        tController.lastname = 'testLastName';
        tController.sortDirection = 'ASC';


        cisList.add('5137447');
        cisList.add('5137448');
        tController.displayedCisList = cisList;
        // execute httpcallout
        CustomerSearchRequestModel actualModel = tController.getCustomerRequestForSorting(); 
        CustomerResponseModel responseModel = new CustomerResponseModel();
        Test.startTest();
        try{
        	responseModel = SME_CIRestWebservice.sortCISListByCustomerSearchRequest(actualModel);
        } catch(CIWebserviceException ex){
        	actualEx = ex;
        }
		Test.stopTest();
		//System.assertNotEquals(null, actualEx, 'An error should be thrown.');
		//System.assertEquals(True,actualEx.getMessage().containsIgnoreCase(expectedErrorMsg));
	
	}


	@isTest static void test_sortCISListByCustomerSortRequest_InvalidResponse() {
	// Set mock callout class
		CIWebserviceException actualEx;
		List<String> cisList = new List<String>();
		// Call method to test.
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock.
		String expectedErrorMsg = ExceptionMessage.PARSE_FAILED;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		// input
		CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = SORT_INVALID_RESPONSE;
        tController.lastname = 'testLastName';
        tController.sortDirection = 'DESC';
        cisList.add('5137447');
        cisList.add('5137448');
        tController.displayedCisList = cisList;
        // execute httpcallout
        CustomerSearchRequestModel actualModel = tController.getCustomerRequestForSorting(); 
        CustomerResponseModel responseModel = new CustomerResponseModel();
        Test.startTest();
        try{
        	responseModel = SME_CIRestWebservice.sortCISListByCustomerSearchRequest(actualModel);
        } catch(CIWebserviceException ex){
        	actualEx = ex;
        }
		Test.stopTest();
		System.assertNotEquals(null, actualEx, 'An error should be thrown.');
		System.assertEquals(True,actualEx.getMessage().containsIgnoreCase(expectedErrorMsg));
	
	}

	@isTest static void test_getResponseModelFromSearchResultStr_EmptyResponse() {
		// Call method to test.
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock.
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		// input
		CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = EMPTY_RESPONSE;
        tController.lastname = 'testLastName';
        // execute httpcallout
        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        CustomerResponseModel responseModel;
        Test.startTest();
        responseModel = SME_CIRestWebservice.searchCISListByCustomerSearchRequest(actualModel);
		Test.stopTest();
		System.assertEquals(null,responseModel.errorMsg);
		System.assertEquals(null,responseModel.cisList);
	}

	@isTest static void test_sortCISListByCustomerSearchRequest_EmptyResponse() {
		// Call method to test.
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock.
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		// input
		CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = EMPTY_RESPONSE;
        tController.lastname = 'testLastName';
        tController.sortDirection = 'ASC';
        // execute httpcallout
        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        CustomerResponseModel responseModel;
        Test.startTest();
        responseModel = SME_CIRestWebservice.sortCISListByCustomerSearchRequest(actualModel);
		Test.stopTest();
		System.assertEquals(null,responseModel.errorMsg);
		System.assertEquals(null,responseModel.cisList);
	}

	@isTest static void test_updateCampaignLeadRequest() {
		RecordType smeLeadCampaignRecType = [SELECT Id FROM RecordType WHERE DeveloperName =: GlobalConstants.SME_LEAD_CAMPAIGN_DEVNAME];
		// Call method to test.
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock.
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        
        Mockup_Test mt = new Mockup_Test().setUpTestWithExtension();
		// input
		Account tempAccount = new Account();
		tempAccount.Name = '457397';
        tempAccount.Temporary_Customer__c  = true;
		insert tempAccount;

		Campaign tempCampaign = new Campaign();
		tempCampaign.Lead_Campaign_Event_Code__c = 'TestCampaign01';
		tempCampaign.Name = 'TestCampaign01';
		tempCampaign.Type__c = GlobalConstants.LEAD_TO_DO;
		tempCampaign.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
		tempCampaign.RecordTypeId = smeLeadCampaignRecType.Id;
		insert tempCampaign;

		Target_List__c tempTargetList  = new Target_List__c();
		tempTargetList.CIS_ID_Prospect_Name__c = tempAccount.Id;
		tempTargetList.Campaign_Lead_Status__c = 'New';
		tempTargetList.Lead_Campaign__c = tempCampaign.Id;
		insert tempTargetList;

		List<Target_List__c> tempListTargetList = new List<Target_List__c>();
		tempListTargetList.add(tempTargetList);

        SME_UpdateCampaignLeadResultResponse responseModel;
        Test.startTest();
        responseModel = SME_CIRestWebservice.updateCampaignLeadRequest(tempListTargetList);
		Test.stopTest();
		System.debug('responseModel: '+responseModel);
		//System.assertEquals(null,responseModel.errorMsg);
		//System.assertEquals(null,responseModel.cisList);
	}

	@isTest static void test_updateContactPrefRequest() {
		// Call method to test.
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock.
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		// input
		Account tempAccount = new Account();
		tempAccount.Name = '457397';
        tempAccount.Temporary_Customer__c  = true;
		insert tempAccount;

		Contact tempContact  = new Contact();
		tempContact.AccountId = tempAccount.Id;
		tempContact.Contact_Firstname__c = 'TempFN';
		tempContact.Phone_Numbers__c = '028463788';
		tempContact.LastName = 'TempLN';
		insert tempContact;

		List<Contact> tempListContact = new List<Contact>();
		tempListContact.add(tempContact);

        SME_UpdateContactPrefResultResponse responseModel;
        Test.startTest();
        responseModel = SME_CIRestWebservice.updateContactPrefRequestList(tempListContact);
		Test.stopTest();
		System.debug('responseModel: '+responseModel);
		//System.assertEquals(null,responseModel.errorMsg);
		//System.assertEquals(null,responseModel.cisList);
	}
	
	@isTest static void test_getResponseModelFromTransactBP() {
		// Call method to test.
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock.
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		// input
		String tempCIS = '1234';
        SME_TransactBPResultResponse responseModel;
        Test.startTest();
        responseModel = SME_CIRestWebservice.getTransactBPRequest(tempCIS);
		Test.stopTest();
		System.debug('responseModel: '+responseModel);
		//System.assertEquals(null,responseModel.errorMsg);
		//System.assertEquals(null,responseModel.cisList);
	}

	@isTest static void test_getResponseFromPurgeLead(){
		
	}
}