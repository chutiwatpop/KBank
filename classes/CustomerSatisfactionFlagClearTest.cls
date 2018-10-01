@isTest
private class CustomerSatisfactionFlagClearTest
{
	// Given
	@testSetup static void setupUser(){
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
		Account targetAccount_1 = Mockup_Test.newAccountWithSegment('NameContact1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),GlobalConstants.PRIMARY_SEGMENT_CODE_CB);  	
		Account targetAccount_2 = Mockup_Test.newAccountWithSegment('RelatedContact1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),GlobalConstants.PRIMARY_SEGMENT_CODE_CB);
		Account targetAccount_3 = Mockup_Test.newAccountWithSegment('BothContact1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),GlobalConstants.PRIMARY_SEGMENT_CODE_CB);
		targetAccount_1.Incorrect_Phone_Number__c = 'Done';
		targetAccount_2.Incorrect_Name__c = 'Done';
		targetAccount_3.Incorrect_Phone_Number__c = 'Done';
		targetAccount_3.Incorrect_Name__c = 'Done';
		insert targetAccount_1;
        insert targetAccount_2;
        insert targetAccount_3;
    }

	@isTest
	static void itShould() {
		// When
		Test.startTest();
            Database.executeBatch(new CustomerSatisfactionFlagClear_Batch());
        Test.stopTest();

		// Then
		Date curDate = date.today();
		Date dateFrom = date.newInstance(curDate.year()-1, 1, 1);
		Date dateTo = date.newInstance(curDate.year(), 1, 1);
		List<Account> targets = [SELECT Id, CIS__c, Temporary_Customer__c, Incorrect_Phone_Number__c, Incorrect_Name__c FROM Account WHERE  CreatedDate >= :dateFrom and CreatedDate < :dateTo  and (Incorrect_Name__c = 'Done' or Incorrect_Phone_Number__c = 'Done')];
		System.assertEquals(0, targets.size());
		for(Account eachAccount : [SELECT Incorrect_Phone_Number__c, Incorrect_Name__c FROM Account]) {
			System.assertEquals(null, eachAccount.Incorrect_Phone_Number__c);
			System.assertEquals(null, eachAccount.Incorrect_Name__c);
		}
	}
}