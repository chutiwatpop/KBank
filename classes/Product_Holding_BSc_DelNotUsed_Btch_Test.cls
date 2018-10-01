@isTest
private class Product_Holding_BSc_DelNotUsed_Btch_Test {
	
	@isTest static void testDefault() {
		Account testCustomer1 = new Account(Name='Customer1',Is_createby_Integration__c = true);
		insert testCustomer1;
		List<LPM__c> lpms = Mockup_Test.newLPM();
		Behaviour_Score__c testBScore1 = new Behaviour_Score__c();
		testBScore1.CIS__c = testCustomer1.Id;
		testBScore1.External_ID__c = '12345-2011-1';
		testBScore1.LPM__c = lpms[0].Id;
		insert testBScore1;
		Test.startTest();
		Database.executeBatch(new Product_Holding_BScore_DelNotUsed_Batch());
		Test.stopTest();
	}
	
	@isTest static void testDeleteBetweenFixedMonth() {
		Account testCustomer1 = new Account(Name='Customer1',Is_createby_Integration__c = true);
		insert testCustomer1;
		List<LPM__c> lpms = Mockup_Test.newLPM();
		Behaviour_Score__c testBScore1 = new Behaviour_Score__c();
		testBScore1.CIS__c = testCustomer1.Id;
		testBScore1.External_ID__c = '12345-2017-2';
		testBScore1.LPM__c = lpms[0].Id;
		insert testBScore1;
		Test.startTest();
		Database.executeBatch(new Product_Holding_BScore_DelNotUsed_Batch('2017-1','2017-3'));
		Test.stopTest();
	}
	
}