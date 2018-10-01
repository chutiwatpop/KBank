@isTest
private class BusinessCodeTriggerHandler_Test {
	
	@isTest static void test_UpdateBusinessCode_MustBeUpdate(){
		// Given
		Business_Code__c businessCodeData = new Business_Code__c();
		businessCodeData.Keyword__c = 'testKey123';
		businessCodeData.Business_Code_Description__c = 'testCode123';
		insert businessCodeData;

		Account dataAccount = new Account();
		dataAccount.Name = 'Test123';
		dataAccount.Is_createby_Integration__c = true;
		insert dataAccount;

		Customer_Business_Code__c customerCodeData = new Customer_Business_Code__c();
		customerCodeData.Business_Code__c = businessCodeData.Id;
		customerCodeData.CIS__c = dataAccount.Id;
		insert customerCodeData;

		// When
		Business_Code__c queryData = [Select Id, Keyword__c, Business_Code_Description__c from Business_Code__c where Id =: businessCodeData.Id limit 1];
		queryData.Keyword__c = 'testChangeKey123';
		queryData.Business_Code_Description__c = 'tesChangetCode123';
		update queryData;

		// Then
		Customer_Business_Code__c customerBusinessCodeResult = [SELECT Id,Keyword_Text__c,Business_Code__c,Description_Text__c From Customer_Business_Code__c where id =: customerCodeData.Id limit 1];
		System.assertEquals(queryData.Keyword__c, customerBusinessCodeResult.Keyword_Text__c);
		System.assertEquals(queryData.Business_Code_Description__c, customerBusinessCodeResult.Description_Text__c);


	}
	
}