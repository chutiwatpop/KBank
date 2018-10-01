@isTest
private class ProductUsageController_Test {
	@TestSetup
	static void makeData(){
		createAccount();
		createSiteMap();
	}

	private static void createAccount(){
		List<Account> accountList = new List<Account>();
		accountList.add(newAccount('name001','3003851'));
		accountList.add(newAccount('name002','11'));
		accountList.add(newAccount('name003','454059'));
		accountList.add(newAccount('name004','3661252'));
		accountList.add(newAccount('name005','21027657'));
		accountList.add(newAccount('name006','1626994'));
		accountList.add(newAccount('name007','17272004'));
		accountList.add(newAccount('name008','17835994'));
		accountList.add(newAccount('name009','3281732'));
		accountList.add(newAccount('name010','12792873'));
		accountList.add(newAccount('name011','4133681'));
		insert accountList;
	}

	private static void createSiteMap(){
		List<Product_Usage_Site_Map__c> siteMapList = new List<Product_Usage_Site_Map__c>();
		siteMapList.add(newSiteMap('PS-0001', 'CRCARD', 'Label Credit Card'));
		siteMapList.add(newSiteMap('PS-0002', 'FND', 'Label Mutual Fund'));
		siteMapList.add(newSiteMap('PS-0003', 'ATM', 'Label ATM'));
		siteMapList.add(newSiteMap('PS-0004', 'SA', 'Label Savings'));
		siteMapList.add(newSiteMap('PS-0005', 'FIX', 'Label Fixed'));
		siteMapList.add(newSiteMap('PS-0006', 'TWD', 'Label Taweesub'));
		siteMapList.add(newSiteMap('PS-0007', 'FCD', 'Label FCD'));
		siteMapList.add(newSiteMap('PS-0008', 'CRN', 'Label Current'));
		siteMapList.add(newSiteMap('PS-0009', 'HL', 'Label Home Loan'));
		siteMapList.add(newSiteMap('PS-0010', 'ADV', 'Label Advancement'));
		siteMapList.add(newSiteMap('PS-0011', 'KPL', 'Label Personal Loan'));
		siteMapList.add(newSiteMap('PS-0012', 'COM', 'Label Commercial Loan'));
		siteMapList.add(newSiteMap('PS-0013', 'PN', 'Label Promissory Note'));
		siteMapList.add(newSiteMap('PS-0014', 'AV', 'Label Aval'));
		siteMapList.add(newSiteMap('PS-0015', 'ACPT', 'Label Acceptance'));
		siteMapList.add(newSiteMap('PS-0016', 'LG', 'Label Letter of Guarantee'));
		insert siteMapList;
	}

	private static Account newAccount(String name,String cisId){
		Account accountObj = new Account();
		accountObj.Name = name;
		accountObj.CIS__c = cisId;
		return accountObj;
	}

	private static Product_Usage_Site_Map__c newSiteMap(String name, String code, String label){
		return new Product_Usage_Site_Map__c(
            Name = name,
            Product_Code__c = code,
            TH_Label__c = label,
            EN_Label__c = label,
            Level__c = 1
        );
	}

	private static String emptyDebitCardResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_DC_CARD","RQS_UNQ_ID":"?","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180806_cc413171297e4b8781269d28de3181ca","RSP_TMS":"2018-08-06T18:31:09.057","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"0"},"Detail":{"IP_ID":"","POS_DT":"","DC_DTL_LIST":null}}}';
        return response;
    }

	private static String emptyCreditCardResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_CC_CARD","RQS_UNQ_ID":"2018-08-02T16:21:33+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180802_5841434a4cb644939afcbc96ea466d2f","RSP_TMS":"2018-08-02T16:21:34.986","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"0"},"Detail":{"CC_DTL_LIST":null}}}';
        return response;
    }

	private static String emptyCustWealthResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_CST_WLTH","RQS_UNQ_ID":"2018-07-31T12:08:54+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180731_e905d2c5a57449c7ad0f8f6d7b01f04b","RSP_TMS":"2018-07-31T12:09:08.218","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"0"},"Detail":{"IP_ID":"","CIS_SRC_STM_CD":"","AR_DTL_LIST":null}}}';
        return response;
    }

	private static String emptyFCDResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_FCD_AR_DTL","RQS_UNQ_ID":"?","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180817_1c3a34f0991b4b0381309dc37d8b4367","RSP_TMS":"2018-08-17T12:25:20.321","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"0"},"Detail":{"IP_ID":"","AR_DTL_LIST":null}}}';
        return response;
    }

	private static String emptyFNCResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_FNC_SVC_AR_DTL","RQS_UNQ_ID":"2018-09-20T13:58:59+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180920_eebf2d7f35344eff8dd83a51d1b49837","RSP_TMS":"2018-09-20T13:58:59.817","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"0"},"Detail":{"IP_ID":"","POS_DT":"","PCB_LMT_AR_LIST":null}}}';
        return response;
    }

	private static String emptyODLimitResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_OD_LMT_DTL","RQS_UNQ_ID":"2018-08-21T16:35:08+07:00","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180821_c8b4cf34faee4b9b8e801b91b8851fad","RSP_TMS":"2018-08-21T16:35:08.767","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"0"},"Detail":{"IP_ID":"","POS_DT":"","OD_AR_LIST":null}}}';
        return response;
    }

	private static String emptyLPMResponse() {
        String response = '{"dataResponse":{"Header":{"FCN_NM":"RS_LPM_TDR_DPD","RQS_UNQ_ID":"","RSP_APL_ID":"655","RSP_UNQ_ID":"655_20180823_5fcc580ea843477e8ed9d2678b1b6938","RSP_TMS":"2018-08-23T10:46:24.841","RSP_CD":"00000","RSP_ST":"Success","TOT_RCRD":"0"},"Detail":{"IP_ID":"","LPM_DTL_LIST":null}}}';
        return response;
    }

	private static void setCalloutMock(String productCode) {
		Map<String, HttpCalloutMock> endpointRespMap = new Map<String,HttpCalloutMock>();
		if(productCode.equalsIgnoreCase('ATM')){
			SingleRequestMock debitResponse = new SingleRequestMock(200, 'Complete', emptyDebitCardResponse(), null);
			endpointRespMap.put(SME_CIRestWebservice.ATM_DEBIT_CARD_INFO_ENDPOINT, debitResponse);
		} else if(productCode.equalsIgnoreCase('CRCARD')){
			SingleRequestMock creditResponse = new SingleRequestMock(200, 'Complete', emptyCreditCardResponse(), null);
			endpointRespMap.put(SME_CIRestWebservice.CREDIT_CARD_INFO_ENDPOINT, creditResponse);
		} else if(productCode.equalsIgnoreCase('SA') || productCode.equalsIgnoreCase('FIX') || 
				  productCode.equalsIgnoreCase('TWD') || productCode.equalsIgnoreCase('FND') || 
				  productCode.equalsIgnoreCase('CRN')){
			SingleRequestMock custWealthResponse = new SingleRequestMock(200, 'Complete', emptyCustWealthResponse(), null);
			endpointRespMap.put(SME_CIRestWebservice.CUSTOMER_WEALTH_INFO_ENDPOINT, custWealthResponse);
			if(productCode.equalsIgnoreCase('CRN')) {
				SingleRequestMock lpmResponse = new SingleRequestMock(200, 'Complete', emptyLPMResponse(), null);
				SingleRequestMock odResponse = new SingleRequestMock(200, 'Complete', emptyODLimitResponse(), null);
				endpointRespMap.put(SME_CIRestWebservice.LPM_TDR_ENDPOINT, lpmResponse);
				endpointRespMap.put(SME_CIRestWebservice.OD_LIMIT_ENDPOINT, odResponse);
			}
		} else if(productCode.equalsIgnoreCase('FCD')){
			SingleRequestMock fcdResponse = new SingleRequestMock(200, 'Complete', emptyFCDResponse(), null);
			endpointRespMap.put(SME_CIRestWebservice.FCD_ENDPOINT, fcdResponse);
		} else if(productCode.equalsIgnoreCase('HL') || productCode.equalsIgnoreCase('KPL') || 
				  productCode.equalsIgnoreCase('COM') || productCode.equalsIgnoreCase('ADV') || 
				  productCode.equalsIgnoreCase('PN') || productCode.equalsIgnoreCase('LG') || 
				  productCode.equalsIgnoreCase('AV') || productCode.equalsIgnoreCase('ACPT')){
			SingleRequestMock fncResponse = new SingleRequestMock(200, 'Complete', emptyFNCResponse(), null);
			SingleRequestMock lpmResponse = new SingleRequestMock(200, 'Complete', emptyLPMResponse(), null);
			endpointRespMap.put(SME_CIRestWebservice.FNC_ENDPOINT, fncResponse);
			endpointRespMap.put(SME_CIRestWebservice.LPM_TDR_ENDPOINT, lpmResponse);
		}
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpointRespMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
	}

	private static ProductUsageController.ProductUsageModel testGetProductUsageData(String productCode, String cisId){
		IProductUsageTransformation productUsageTransformer;
		Account accountObj = [SELECT Id FROM Account WHERE CIS__c = :cisId];
		PageReference pageRef = Page.ProductLevel_Page;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController stdController = new ApexPages.StandardController(accountObj);
		ApexPages.currentPage().getParameters().put('productCode',productCode);
		ApexPages.currentPage().getParameters().put('cisId',cisId);

		ProductUsageController productUsageCtrl = new ProductUsageController(stdController);
		
		productUsageCtrl.isVisible = true;
		productUsageCtrl.loadProductUsageData();
		ProductUsageController.ProductUsageModel resultModel;
		try {
			resultModel = (ProductUsageController.ProductUsageModel) JSON.deserialize(productUsageCtrl.productUsageData, ProductUsageController.ProductUsageModel.class);
		} catch(Exception e) {
			System.debug(e.getStackTraceString());
		}
		return resultModel;
	}

	@isTest static void testGetProductUsageDataCRCARD(){
		String productCode = 'CRCARD';
		String cisId = '11';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Credit Card', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataFND(){
		String productCode = 'FND';
		String cisId = '3003851';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Mutual Fund', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataATM(){
		String productCode = 'ATM';
		String cisId = '1626994';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label ATM', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataSA(){
		String productCode = 'SA';
		String cisId = '11';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Savings', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataFIX(){
		String productCode = 'FIX';
		String cisId = '3003851';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Fixed', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataTWD(){
		String productCode = 'TWD';
		String cisId = '17272004';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Taweesub', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataFCD(){
		String productCode = 'FCD';
		String cisId = '17272004';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label FCD', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataCRN(){
		String productCode = 'CRN';
		String cisId = '454059';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Current', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataHL(){
		String productCode = 'HL';
		String cisId = '11';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Home Loan', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataADV(){
		String productCode = 'ADV';
		String cisId = '3661252';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Advancement', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataKPL(){
		String productCode = 'KPL';
		String cisId = '17835994';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Personal Loan', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataCOM(){
		String productCode = 'COM';
		String cisId = '21027657';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Commercial Loan', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataPN(){
		String productCode = 'PN';
		String cisId = '12792873';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Promissory Note', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataAV(){
		String productCode = 'AV';
		String cisId = '4133681';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Aval', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataACPT(){
		String productCode = 'ACPT';
		String cisId = '4133681';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Acceptance', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataLG(){
		String productCode = 'LG';
		String cisId = '3281732';
		Test.StartTest();
		setCalloutMock(productCode);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals('Label Letter of Guarantee', result.siteMap.siteMaps.get('1').label);
	}

	@isTest static void testGetProductUsageDataNull(){
		String productCode = 'Other';
		String cisId = '11';
		Test.StartTest();
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.Assert(result.siteMap.siteMaps.isEmpty());
	}

	@isTest static void testGetPageError(){
		String productCode = 'CRCARD';
		String cisId = '11';
		Test.StartTest();
		SingleRequestMock errorResponse = new SingleRequestMock(500, 'Error', '', null);
		Test.setMock(HttpCalloutMock.class, errorResponse);
		ProductUsageController.ProductUsageModel result = testGetProductUsageData(productCode,cisId);
		Test.StopTest();
		System.AssertEquals(null, result);
		System.Assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
	}
}