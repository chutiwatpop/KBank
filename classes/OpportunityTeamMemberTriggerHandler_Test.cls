@isTest
private class OpportunityTeamMemberTriggerHandler_Test {
	
	@isTest
	static void test_CreateBellNotificationWhenDeleteOppTeamMember() {
		
		String accountNameTM = 'tmCreatedAccountName';
		new Mockup_Test().newAccount(accountNameTM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));		      

		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id, RC_Code__c');
		Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOPP1', GlobalConstants.WAITING_FOR_CREDIT_APPROVAL, GlobalConstants.NON_CMAS);
		insert targetOpp;

		OpportunityTeamMember oppTeam = new OpportunityTeamMember();
		oppTeam.OpportunityId = targetOpp.Id;
		oppTeam.UserId = UserInfo.getUserId();
		insert oppTeam;

		//Act
		OpportunityTeamMember dataOppTeam = [SELECT Id from OpportunityTeamMember where Id =: oppTeam.Id limit 1];
		delete dataOppTeam;

	}

	@isTest
	static void test_InsertOppTeamMemberWhenAfterInsertFlagHasJobTeamMemberMustBeTrue() {

		String accountNameTM = 'tmCreatedAccountName';
		new Mockup_Test().newAccount(accountNameTM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));		      

		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id, RC_Code__c');
		Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOPP1', GlobalConstants.WAITING_FOR_CREDIT_APPROVAL, GlobalConstants.NON_CMAS);
		insert targetOpp;

 		//Act
		OpportunityTeamMember oppTeam = new OpportunityTeamMember();
		oppTeam.OpportunityId = targetOpp.Id;
		oppTeam.UserId = UserInfo.getUserId();
		insert oppTeam;

		//Assert
		Opportunity resultValue = [Select Id, Name, HasJobTeamMember__c From Opportunity where Name = 'TestOPP1' limit 1];
		System.assertEquals(true, resultValue.HasJobTeamMember__c);
	}

	@isTest
	static void test_DeleteOppTeamMemberWhenAfterDeleteFlagHasJobTeamMemberMustBeFalse() {

		String accountNameTM = 'tmCreatedAccountName';
		new Mockup_Test().newAccount(accountNameTM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));		      

		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountNameTM, 'Id, RC_Code__c');
		Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOPP1', GlobalConstants.WAITING_FOR_CREDIT_APPROVAL, GlobalConstants.NON_CMAS);
		insert targetOpp;

		OpportunityTeamMember oppTeam = new OpportunityTeamMember();
		oppTeam.OpportunityId = targetOpp.Id;
		oppTeam.UserId = UserInfo.getUserId();
		insert oppTeam;

		//Act
		OpportunityTeamMember dataOppTeam = [SELECT Id from OpportunityTeamMember where Id =: oppTeam.Id limit 1];
		delete dataOppTeam;

		//Assert
		Opportunity resultValue = [Select Id, Name, HasJobTeamMember__c From Opportunity where Name = 'TestOPP1' limit 1];
		System.assertEquals(False, resultValue.HasJobTeamMember__c);
	}
	
}