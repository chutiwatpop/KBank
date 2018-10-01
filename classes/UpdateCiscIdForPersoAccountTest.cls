@isTest
private class UpdateCiscIdForPersoAccountTest
{
	// Given
	@testSetup static void setupUser(){
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			mt.newAccount('NameContact1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
			mt.newAccount('RelatedContact1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
			Account nameAccount_1 = Mockup_Test.getFirstAccountFromName('NameContact1', 'Id');
			Account relatedAccount_1 = Mockup_Test.getFirstAccountFromName('RelatedContact1', 'Id');

			Contact mockBaseContact_1 = new Contact(
	                LastName = 'Lastname',
	                Contact_Firstname__c = 'BaseContact',
	                AccountId = nameAccount_1.Id,
	                Primary_Contact__c = true
	            );
			Contact mockRelatedContact_2 = new Contact(
	                LastName = 'Lastname',
	                Contact_Firstname__c = 'RelatedContact',
	                AccountId = relatedAccount_1.Id,
                Primary_Contact__c = false
            );
		mockBaseContact_1.Phone_Number__c = '0823450789';
			mockRelatedContact_2.Phone_Number__c = '0823450789';
			mockBaseContact_1.Phone_Numbers__c = '0823450789';
			mockRelatedContact_2.Phone_Numbers__c = '0823450789';

			insert mockBaseContact_1;
	        insert mockRelatedContact_2;
	    }
	}

	@isTest
	static void itShould()
	{
		Account nameAccount_1 = Mockup_Test.getFirstAccountFromName('NameContact1', 'Id');
		Account relatedAccount_1 = Mockup_Test.getFirstAccountFromName('RelatedContact1', 'Id');
		Contact mockBaseContact_1 = [select Id, Contact_Firstname__c from Contact where AccountId = :nameAccount_1.Id];
		Contact mockRelatedContact_2 = [select Id, Contact_Firstname__c from Contact where AccountId = :relatedAccount_1.Id];

		if(mockBaseContact_1 == null || mockRelatedContact_2 == null){
			System.assertNotEquals(null, mockBaseContact_1);
			System.assertNotEquals(null, mockRelatedContact_2);
			return;
		}
        FinServ__ContactContactRelation__c relations = new FinServ__ContactContactRelation__c(
        		FinServ__Contact__c = mockBaseContact_1.Id,
        		FinServ__RelatedContact__c = mockRelatedContact_2.Id
        	);
		// When

		Test.startTest();
            Database.executeBatch(new UpdateCiscIdForPersoAccount_Batch());
        Test.stopTest();

		// Then
		List<Contact> noCisIdContacts = [SELECT Id From Contact where CIS_ID__c = Null];
		List<FinServ__ContactContactRelation__c> targets = [SELECT FinServ__Contact__c, FinServ__RelatedContact__c From FinServ__ContactContactRelation__c where FinServ__RelatedContact__c in :noCisIdContacts];

		System.assertEquals(0, targets.size());
	}
}