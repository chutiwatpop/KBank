@isTest
private class ManualConvertCustomer_Test {
	
	@testSetup static void setupTest(){
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
        Test.startTest();
	        Mockup_Test mt;
	        System.runAs(new User(Id=UserInfo.getUserId())){
	            mt = new Mockup_Test().setUpTestWithRCCode();
	        }
	        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
	            Account accountRecord = Mockup_Test.newAccountObj('AccountName',GlobalConstants.POOL,
				Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
	            accountRecord.CIS__c = '2141515';
	            insert accountRecord;

	            Account accountRecord2 = Mockup_Test.newAccountObj('AccountName',GlobalConstants.POOL,
	            	recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME));
	            accountRecord2.CIS__c = '12131244';
	            insert accountRecord2;

	        }
        Test.stopTest();
    }

	@isTest static void searchCustomerByCISNumberIndividual(){
		ManualConvertCustomerApexController.ResultResponse expectedResponse = new ManualConvertCustomerApexController.ResultResponse();
		Account expectedAccount = new Account(CIS__c='12131244',LastName='AccountName');
		mockWebservice(expectedAccount, 'WITHCIS','I');

		Test.startTest();
		String resp = ManualConvertCustomerApexController.searchCustomerByCriteria('12131244',null,null);
		Test.stopTest();
		
		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(resp);
		System.assertNotEquals(null,m.get('convertedCustomer'));
	}

	@isTest static void searchCustomerByCISNumberOrganization(){
		ManualConvertCustomerApexController.ResultResponse expectedResponse = new ManualConvertCustomerApexController.ResultResponse();
		Account expectedAccount = new Account(CIS__c='2141515',LastName='AccountName');
		mockWebservice(expectedAccount, 'WITHCIS','O');

		Test.startTest();
		String resp = ManualConvertCustomerApexController.searchCustomerByCriteria('2141515',null,null);
		Test.stopTest();
		
		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(resp);
		System.assertNotEquals(null,m.get('convertedCustomer'));
	}

	@isTest static void searchCustomerByIdentNotExist(){
		ManualConvertCustomerApexController.ResultResponse expectedResponse = new ManualConvertCustomerApexController.ResultResponse();
		Account expectedAccount = new Account(Encrypt_Identification_No__c='1231231231231',LastName='AccountName',Birthdate_Registration_Date__c=Date.valueOf('1995-05-05'));
		mockWebservice(expectedAccount, 'NOT_EXIST','I');
		Test.startTest();
		String resp = ManualConvertCustomerApexController.searchCustomerByCriteria(null,'1231231231231','1995-05-05');
		Test.stopTest();
		
		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(resp);
		System.assertNotEquals(null,m.get('convertedCustomer'));
	}

	
	@isTest static void repairCustomerWithAccountIndividual(){
		
		Account accObj = [SELECT Id, CIS__c, RecordTypeId, Birthdate_Registration_Date__c, Encrypt_Identification_No__c FROM Account WHERE CIS__c = '12131244'];
		Test.startTest();
		String resp = ManualConvertCustomerApexController.repairCustomerWithAccount(JSON.serialize(accObj));
		Test.stopTest();
		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(resp);
		System.assertNotEquals(null,m.get('convertedCustomer'));
	
	}
		
	@isTest static void repairCustomerWithAccountOrganization(){
		
		Account accObj = [SELECT Id, CIS__c, RecordTypeId, Birthdate_Registration_Date__c, Encrypt_Identification_No__c FROM Account WHERE CIS__c = '2141515'];
		Test.startTest();
		String resp = ManualConvertCustomerApexController.repairCustomerWithAccount(JSON.serialize(accObj));
		Test.stopTest();
		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(resp);
		System.assertNotEquals(null,m.get('convertedCustomer'));
	
	}

	@isTest static void fixedAccountEncryptFieldI() {
		ManualConvertCustomerApexController.ResultResponse resp = new ManualConvertCustomerApexController.ResultResponse();
		Account existingAccount = [SELECT Id, CIS__c, RecordTypeId, Birthdate_Registration_Date__c, Encrypt_Identification_No__c FROM Account WHERE CIS__c = '12131244'];
		CreateProspect_Webservice.CustomerInfo customerInfo = new CreateProspect_Webservice.CustomerInfo();
    	customerInfo.EN_TTL = '';
        customerInfo.TH_TTL = 'นาย';
		customerInfo.EN_FRST_NM = '';
		customerInfo.TH_FRST_NM = 'จัตุรถาภรณ์';
        customerInfo.EN_MDL_NM = '';
        customerInfo.TH_MDL_NM = '';
		customerInfo.EN_SURNM = '';
		customerInfo.TH_SURNM = 'ยุตตพล';
		customerInfo.IDENT_NO = '3610107733691';
		customerInfo.BRTH_ESTB_DT = '1951-01-01';
		customerInfo.IP_TP_CD = 'I';
		ManualConvertCustomerApexController.fixedAccountEncryptField(existingAccount, customerInfo,resp);
    }

    @isTest static void fixedAccountEncryptFieldO() {
		ManualConvertCustomerApexController.ResultResponse resp = new ManualConvertCustomerApexController.ResultResponse();
		Account existingAccount = [SELECT Id, CIS__c, RecordTypeId, Birthdate_Registration_Date__c, Encrypt_Identification_No__c FROM Account WHERE CIS__c = '2141515'];
		CreateProspect_Webservice.CustomerInfo customerInfo = new CreateProspect_Webservice.CustomerInfo();
    	customerInfo.EN_TTL = '';
        customerInfo.TH_TTL = 'นาย';
		customerInfo.EN_FRST_NM = '';
		customerInfo.TH_FRST_NM = 'จัตุรถาภรณ์';
        customerInfo.EN_MDL_NM = '';
        customerInfo.TH_MDL_NM = '';
		customerInfo.EN_SURNM = '';
		customerInfo.TH_SURNM = 'ยุตตพล';
		customerInfo.IDENT_NO = '3610107733691';
		customerInfo.BRTH_ESTB_DT = '1951-01-01';
		customerInfo.IP_TP_CD = 'O';
		ManualConvertCustomerApexController.fixedAccountEncryptField(existingAccount, customerInfo,resp);
		System.assertEquals(existingAccount.Encrypt_Identification_No__c,customerInfo.IDENT_NO);
    }

    @isTest static void fixedAccountEncryptFieldENG() {
		ManualConvertCustomerApexController.ResultResponse resp = new ManualConvertCustomerApexController.ResultResponse();
		Account existingAccount = [SELECT Id, CIS__c, RecordTypeId, Birthdate_Registration_Date__c, Encrypt_Identification_No__c FROM Account WHERE CIS__c = '2141515'];
		CreateProspect_Webservice.CustomerInfo customerInfo = new CreateProspect_Webservice.CustomerInfo();
    	customerInfo.EN_TTL = 'Mr';
        customerInfo.TH_TTL = '';
		customerInfo.EN_FRST_NM = 'Test';
		customerInfo.TH_FRST_NM = '';
        customerInfo.EN_MDL_NM = '';
        customerInfo.TH_MDL_NM = '';
		customerInfo.EN_SURNM = 'Last';
		customerInfo.TH_SURNM = '';
		customerInfo.IDENT_NO = '3610107733691';
		customerInfo.BRTH_ESTB_DT = '1951-01-01';
		customerInfo.IP_TP_CD = 'O';
		ManualConvertCustomerApexController.fixedAccountEncryptField(existingAccount, customerInfo,resp);
				System.assertEquals(existingAccount.Encrypt_Identification_No__c,customerInfo.IDENT_NO);
    }

	private static void mockWebservice(Account requestAccount, String testMode, String customerType){
		String jsonString = '';
		if(testMode=='NOT_EXIST') {
			jsonString = '{"customerModel":null,"customerAddresses":[]}';
		} else if(testMode == 'WITHCIS'){
			jsonString = '{"customerModel":{"IP_ID":"' + requestAccount.CIS__c + '","TH_FRST_NM":"AccountName","TH_SURNM":"AccountName","PRVN_F":"C","IP_TP_CD":"'+customerType+'","BRTH_ESTB_DT":"","DOC_ITM_CD":"11","IP_PERF_ST_CD":"G","PRIM_SEG_CD":"LM","PRIM_SUB_SEG_CD":"01","DUAL_SEG_CD":"","DUAL_SUB_SEG_CD":"","KBNK_IDY_CL_CD":"","CO_IDY_CL_CD":""},"customerAddresses":[]}';
		} else if(testMode=='WITH_IDENT') {
			jsonString = '{"customerModel":{"IP_ID":"","PRVN_F":"C","IP_TP_CD":"'  + customerType + '","TH_FRST_NM":"AccountName","TH_SURNM":"AccountName","BRTH_ESTB_DT":"'+ requestAccount.Birthdate_Registration_Date__c +'","DOC_ITM_CD":"11","IP_PERF_ST_CD":"G","PRIM_SEG_CD":"UM","PRIM_SUB_SEG_CD":"02","DUAL_SEG_CD":"","DUAL_SUB_SEG_CD":"","KBNK_IDY_CL_CD":"","CO_IDY_CL_CD":"","IDENT_NO":"'+ requestAccount.Encrypt_Identification_No__c +'"},"customerAddresses":[]}';
		}	
		CreateProspect_Webservice.mockJSONResponse = jsonString;
	}

}