@isTest
private class Purge_Contacted_AccountTest {
	
	 @testSetup static void setupAccount(){
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestAdmin().setUpTestWithExtension();
        Test.stopTest();

        System.runAs(new User(Id = UserInfo.getUserId())){
            User userRM = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
            userRM.Segment__c  = 'SE';
            TriggerHandler.bypass('UserTriggerHandler');
            update userRM;
            TriggerHandler.clearbypass('UserTriggerHandler');
        }
    }

	@isTest static void Given_5RecordsOfContactedAccount_When_RunBatchPurge_Then_DeleteAllRecord() {
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        List<Contacted_Account__c> listContactedAccount = new List<Contacted_Account__c>();
        Account accountPerPort;
        System.runAs(userRM){
            accountPerPort = Mockup_Test.newAccountWithSegment('testAccount', GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT), GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
            insert accountPerPort;
        }

        for(Integer i = 0;i<5;i++){
	        Contacted_Account__c newContactedAccount = new Contacted_Account__c();
	        newContactedAccount.Lookup_Customer__c = accountPerPort.Id;
	        newContactedAccount.Count_Contacted_Call_Report_F2F__c           = 2;
	        newContactedAccount.Count_Contacted_Call_Report_Phone_Call__c    = 2;
	        newContactedAccount.Count_Contacted_Call_Report_My_Pen_F2F__c    = 2;
	        newContactedAccount.Count_Contacted_Call_Report_My_Pen_Call__c   = 1;
	        newContactedAccount.Count_Contacted_CR_My_Pen_Service_F2F__c     = 2;
	        newContactedAccount.Count_Contacted_CR_My_Pen_Service_Call__c    = 1;
	        newContactedAccount.Count_Contacted_Call_Report__c               = 5;
	        listContactedAccount.add(newContactedAccount);
	    }
	    insert listContactedAccount;

	    Test.startTest();
            Database.executeBatch(new Purge_Contacted_Account_Batch());
        Test.stopTest();

        List<Contacted_Account__c> listResultContactedAccount = [SELECT Id FROM Contacted_Account__c];
        System.assertEquals(0,listResultContactedAccount.size());
	}
}