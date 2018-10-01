@isTest
private class SME_OpportunityOwnerInitial_Batch_Test {
	
	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';

	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTestWithExtension();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
	}

	@isTest static void oppInitial(){
		//Account targetAccount = [SELECT Id, Owner_Emp_ID__c, RC_Code__c FROM Account WHERE Name = :SME_OpportunityOwnerInitial_Batch_Test.accountNameRM LIMIT 1];
		//List<List<Account>> listTargetAccount = [FIND :SME_OpportunityOwnerInitial_Batch_Test.accountNameRM RETURNING Account(Id, Owner_Emp_ID__c, RC_Code__c LIMIT 1)];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(SME_OpportunityOwnerInitial_Batch_Test.accountNameRM,'Id, Owner_Emp_ID__c, RC_Code__c');
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];

		System.runAs(userRM){

			Opportunity opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'Test1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			insert opp1;	

			Test.startTest();
				Database.executeBatch(new SME_OpportunityOwnerInitial_Batch());
			Test.stopTest();

		}

		Team_Structure__c teamStr = [SELECT Id FROM Team_Structure__c WHERE External_ID__c = :targetAccount.RC_Code__c LIMIT 1];
		User_Extension__c userExt = [SELECT Id FROM User_Extension__c WHERE External_ID__c = :targetAccount.Owner_Emp_ID__c LIMIT 1];
		Opportunity targetOpp = [SELECT Id, Current_Owner_Extension__c, Current_Team_Name__c FROM Opportunity WHERE AccountId = :targetAccount.Id];
        System.assertEquals(userExt.Id, targetOpp.Current_Owner_Extension__c);
        System.assertEquals(teamStr.Id, targetOpp.Current_Team_Name__c);
	}
	
}