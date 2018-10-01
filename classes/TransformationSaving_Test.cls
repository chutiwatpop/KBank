@isTest
private class TransformationSaving_Test {
	@testSetup
	static void setupMockData() {
		Id accountRecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account',GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME);
		List<Account> accounts = new List<Account>();
			
        Account account = new Account(
            Firstname = '11',
            Lastname = '11',
            CIS__c = '11',
            Port_Pool__c = GlobalConstants.PORT,
            RecordTypeId = accountRecordTypeId,
            Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
            Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_SM,
            Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_SM,
            Is_createby_Integration__c = true
        );

        Account accountPersonKbank = new Account(
            Firstname = '11',
            Lastname = '11',
            CIS__c = '00009',
            Port_Pool__c = GlobalConstants.PORT,
            RecordTypeId = accountRecordTypeId,
            Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
            Primary_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_SM,
            Customer_Segment_Code__c = GlobalConstants.PRIMARY_SEGMENT_CODE_SM,
            Person_Type__c = ProductUsageSummaryController.PERSONTYPE_KBANK,
            Is_createby_Integration__c = true
        );
        accounts.add(account);
        accounts.add(accountPersonKbank);
	    System.runAs(new User(Id=UserInfo.getUserId())) {
            TriggerHandler.bypass('AccountTriggerHandler');
            	insert accounts;
            TriggerHandler.clearbypass('AccountTriggerHandler');
		}
	}

	@isTest
	static void test_TransformationSaving() {
		HttpCalloutMock custWealthResponse = new SingleRequestMock(200,'Complete',savingResponse(),null);
		Test.setMock(HttpCalloutMock.class, custWealthResponse);

		Test.startTest();
		String cisId = '11';
		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation productUsageTransformer = new TransformationSaving(cisId, 'SA', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsages = productUsageTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsages.productUsageTables.get('SA_0');
		Test.stopTest();

		system.assertEquals(1, productUsages.productUsageTables.size());
		system.assertEquals(1, productUsageTable.body.size());
		//system.assertEquals('093-2-XXX13-8', productUsageTable.body[0][0]);
		system.assertEquals('บัญชีร่วมรอง', productUsageTable.body[0][8]); 
		system.assertEquals(0, productUsageTable.columnHeaders.size());
	}

	@isTest
	static void testKbankEmployeeShouldNotDisplaySaving(){
		//Given
		Account account = [SELECT Id,CIS__C,Person_Type__c From Account WHERE CIS__C = '00009' Limit 1];

		HttpCalloutMock custWealthResponse = new SingleRequestMock(200,'Complete',savingResponse(),null);
		Test.setMock(HttpCalloutMock.class, custWealthResponse);
		//When
		Test.startTest();

		IProductUsageConfig productUsageConfig = new ProductUsageConfig();
		IProductUsageTransformation productUsageTransformer = new TransformationSaving(account.CIS__c, 'SA', productUsageConfig);
		ProductUsageController.ProductUsageModel productUsages = productUsageTransformer.transform();
		ProductUsageController.ProductUsageTable productUsageTable = productUsages.productUsageTables.get('SA_0');
		Test.stopTest();
		//Then
		System.assertEquals(null,productUsageTable);
	}

	private static String savingResponse() {
		String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_CST_WLTH","RQS_UNQ_ID":"2018-07-31T12:08:54+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180731_e905d2c5a57449c7ad0f8f6d7b01f04b","RSP_TMS":"2018-07-31T12:09:08.218","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"1"},"Detail":{"IP_ID":"11","CIS_SRC_STM_CD":"72","AR_DTL_LIST":{"AR_DTL_INF":[{"POS_DT":"2018-02-01","AR_ID":"0932556138","AR_NM_EN":"HOWWONG KULU","AR_NM_TH":"หาววงษ์ กุลุ","AR_OWN_TP_CD":"0","PD_DSC_EN":"Savings (KB)","SUM_CRN_BAL":"1155.41","SUM_HOLD_BAL_AMT":"0.00","OD_LMT_AMT":"0.00","DOMC_BR_NO":"0093","DOMC_BR_NM":"สาขาถนนประชาชื่น","AR_LCS_TP_CD":"4","OPN_DT":"2014-04-24","CLS_DT":"","EFF_RATE_PCT":"0.50000","SUB_AR_DTL_LIST":null,"AR_ST_LIST":null}]}}}}';
		return response;
	}
}