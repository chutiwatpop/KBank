@isTest
private class FinancialInformation_Remote_Test {
	
	@testSetup static void setupAccount(){
        Account account = new Account();
        account.CIS__c = '123';
        account.Name = 'AccountName';
        account.Is_createby_Integration__c = true;
        insert account;
    }

	/*@isTest static void testRetrieveCurrentDetailData() {
        Map<String, List<List<String>>> dataResponse;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
			dataResponse = FinancialInformation_Remote.retrieveNonCreditDetailData('123', 'Current');
		Test.stopTest();

		System.assertEquals('0011004482', dataResponse.get('Current').get(0).get(0));
		System.assertEquals('10,000.00', dataResponse.get('Current').get(0).get(2));
	}
	@isTest static void testRetrieveFixedDetailData() {
        Map<String, List<List<String>>> dataResponse;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
			dataResponse = FinancialInformation_Remote.retrieveNonCreditDetailData('123', 'Fixed_Deposit');
		Test.stopTest();	

		System.assertEquals('0011004482', dataResponse.get('Fixed_Deposit').get(0).get(0));
		System.assertEquals('0011004482-2', dataResponse.get('Fixed_Deposit').get(0).get(1));
		System.assertEquals('10.00', dataResponse.get('Fixed_Deposit').get(0).get(3));
	}

	@isTest static void testRetrieveSavingDetailData() {
        Map<String, List<List<String>>> dataResponse;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
			dataResponse = FinancialInformation_Remote.retrieveNonCreditDetailData('123', 'Saving');
		Test.stopTest();	

		System.assertEquals('XXX-2-0033-X', dataResponse.get('Saving').get(0).get(0));
		System.assertEquals('4,138,436.96', dataResponse.get('Saving').get(0).get(2));
		System.assertEquals('XXX-2-9459-X', dataResponse.get('Saving').get(1).get(0));
		System.assertEquals('2,664,630.23', dataResponse.get('Saving').get(1).get(2));
	}

	@isTest static void testRetrieveTaweesupDetailData() {
        Map<String, List<List<String>>> dataResponse;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
			dataResponse = FinancialInformation_Remote.retrieveNonCreditDetailData('123', 'Taweesup');
		Test.stopTest();	
		System.debug('dataResponse :'+dataResponse);
		System.assertEquals('XXX-2-0033-X', dataResponse.get('Taweesup').get(0).get(0));
		System.assertEquals('4,138,436.96', dataResponse.get('Taweesup').get(0).get(3));
	}

	@isTest static void testRetrieveMutual_FundDetailData() {
        Map<String, List<List<String>>> dataResponse;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
			dataResponse = FinancialInformation_Remote.retrieveNonCreditDetailData('123', 'Mutual_Fund');
		Test.stopTest();	

		System.assertEquals('0011004482', dataResponse.get('Mutual_Fund').get(0).get(0));
		System.assertEquals('0011004482-2', dataResponse.get('Mutual_Fund').get(0).get(1));
		System.assertEquals('10.00', dataResponse.get('Mutual_Fund').get(0).get(5));
	}

	@isTest static void testRetrieveCreditData() {
		Map<String, String> dataResponse;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
			dataResponse = FinancialInformation_Remote.retrieveCreditData('123');
		Test.stopTest();

		System.assertEquals('12,395,320.34', dataResponse.get('LN_Outstanding'));
		System.assertEquals('20,000.00', dataResponse.get('TP_Outstanding'));
	}

	@isTest static void testRetrieveNonCreditData() {
		Map<String, String> dataResponse;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
			dataResponse = FinancialInformation_Remote.retrieveNonCreditData('123');
		Test.stopTest();

		System.assertEquals('12,395,320.34', dataResponse.get('Saving_Outstanding'));
		System.assertEquals('20,000.00', dataResponse.get('Current_Outstanding'));
	}*/

	@isTest static void testRetrieveInteractionHistory() {
		Map<String, String> dataResponse;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
			dataResponse = FinancialInformation_Remote.retrieveInteractionHistory('123');
		Test.stopTest();

		System.debug(dataResponse);

		System.assertEquals('70.00', dataResponse.get('salesCredit'));
		System.assertEquals('60.00', dataResponse.get('salesCash'));
		System.assertEquals('90.00', dataResponse.get('purchaseCredit'));
		System.assertEquals('80.00', dataResponse.get('purchaseCash'));
	}
	
	/*@isTest static void testRetrieveTotalDebt() {
		Account account = [SELECT Id FROM Account WHERE CIS__c = '123' LIMIT 1];

        Financial_Information__c financialInfo = new Financial_Information__c();
        financialInfo.PN_Limit__c = 10;
        financialInfo.OD_Limit__c = 20;
        financialInfo.TF_Limit__c = 30;
        financialInfo.CIS_ID__c = account.Id;
        insert financialInfo;

		Utilization__c utilization1 = new Utilization__c();
		utilization1.CIS_ID__c = account.Id;
		utilization1.Name = '01';
		utilization1.OD_Limit__c = 1;
		utilization1.OD_AVG_OUT__c = 2;
		utilization1.OD_Utilization__c = 3;
		utilization1.PN_Limit__c = 4;
		utilization1.PN_AVG_OUT__c = 5;
		utilization1.PN_Utilization__c = 6;
		utilization1.TF_Limit__c = 7;
		utilization1.TF_AVG_OUT__c = 8;
		utilization1.TF_Utilization__c = 9;
		insert utilization1;

		Utilization__c utilization2 = new Utilization__c();
		utilization2.CIS_ID__c = account.Id;
		utilization2.Name = '02';
		utilization2.OD_Limit__c = 1;
		utilization2.OD_AVG_OUT__c = 2;
		utilization2.OD_Utilization__c = 3;
		utilization2.PN_Limit__c = 4;
		utilization2.PN_AVG_OUT__c = 5;
		utilization2.PN_Utilization__c = 6;
		utilization2.TF_Limit__c = 7;
		utilization2.TF_AVG_OUT__c = 8;
		utilization2.TF_Utilization__c = 9;
		insert utilization2;

		Utilization__c utilization3 = new Utilization__c();
		utilization3.CIS_ID__c = account.Id;
		utilization3.Name = '03';
		utilization3.OD_Limit__c = 1;
		utilization3.OD_AVG_OUT__c = 2;
		utilization3.OD_Utilization__c = 3;
		utilization3.PN_Limit__c = 4;
		utilization3.PN_AVG_OUT__c = 5;
		utilization3.PN_Utilization__c = 6;
		utilization3.TF_Limit__c = 7;
		utilization3.TF_AVG_OUT__c = 8;
		utilization3.TF_Utilization__c = 9;
		insert utilization3;

        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
			Map<String, List<String>> data = FinancialInformation_Remote.retrieveTotalDebt('123');
		Test.stopTest();

		System.assertEquals('60.00', data.get('total_limit').get(0));
		System.assertEquals('10', data.get('pn_limit').get(0));
		System.assertEquals('20', data.get('od_limit').get(0));
		System.assertEquals('30', data.get('tf_limit').get(0));

        System.assertEquals(12, data.get('od_header_list').size());
        System.assertEquals(12, data.get('pn_header_list').size());
        System.assertEquals(12, data.get('tf_header_list').size());
        System.assertEquals(12, data.get('od_limit_list').size());
        System.assertEquals(12, data.get('pn_limit_list').size());
        System.assertEquals(12, data.get('tf_limit_list').size());
        System.assertEquals(12, data.get('od_outstanding_list').size());
        System.assertEquals(12, data.get('pn_outstanding_list').size());
        System.assertEquals(12, data.get('tf_outstanding_list').size());
        System.assertEquals(12, data.get('od_limit_value_list').size());
        System.assertEquals(12, data.get('pn_limit_value_list').size());
        System.assertEquals(12, data.get('tf_limit_value_list').size());
        System.assertEquals(12, data.get('od_outstanding_value_list').size());
        System.assertEquals(12, data.get('pn_outstanding_value_list').size());
        System.assertEquals(12, data.get('tf_outstanding_value_list').size());

	}*/
	
}