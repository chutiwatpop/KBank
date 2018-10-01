@isTest
private class SME_UserExtensionOwnerInitial_Test {
	
	@testSetup static void setupTest(){
		Mockup_Test mt = new Mockup_Test().setUpTest();
	}
	
	@isTest	static void testInitial(){
		Test.startTest();
			Database.executeBatch(new SME_UserExtensionOwnerInitial_Batch());
		Test.stopTest();
				
		User_Extension__c targetRMUser = [SELECT Id, OwnerId FROM User_Extension__c WHERE External_ID__c=:Mockup_Test.userEmpIdRM LIMIT 1];
		User_Extension__c targetTMUser = [SELECT Id, OwnerId FROM User_Extension__c WHERE External_ID__c=:Mockup_Test.userEmpIdTM LIMIT 1];

		User targetOwnerRM = [SELECT Id FROM User WHERE Employee_Id__c = :Mockup_Test.userEmpIdRM];
		User targetOwnerTM = [SELECT Id FROM User WHERE Employee_Id__c = :Mockup_Test.userEmpIdTM];

		System.assertEquals(targetOwnerRM.Id,targetRMUser.OwnerId);
		System.assertEquals(targetOwnerTM.Id,targetTMUser.OwnerId);
	}
}