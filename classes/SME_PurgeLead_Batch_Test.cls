@isTest
private class SME_PurgeLead_Batch_Test {
	
	public static String accountNameTM = 'tmCreatedAccountName';
	public static String campaignExpired = 'TestCampaignExp';
	public static String campaignNotExpired = 'TestCampaignNotExp';
	public static String external1 = 'external1';
	public static String external2 = 'external2';

	@testSetup static void setupAccount(){
		TriggerHandler.bypass('UserTriggerHandler');
		Mockup_Test mt = new Mockup_Test().setUpTest();
		
		Test.startTest();
		Campaign campNotExpired = Mockup_Test.newCampaign(UserInfo.getUserId(), campaignNotExpired, System.now().addDays(-10), System.now().addDays(-4), System.now().addDays(-11), GlobalConstants.PLANNED, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES);
        Campaign campExpired = Mockup_Test.newCampaign(UserInfo.getUserId(), campaignExpired, System.now().addDays(-10), System.now().addDays(-5), System.now().addDays(-11), GlobalConstants.PLANNED, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES);
        Account accountTm = Mockup_Test.newAccountObj(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
	        
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
	        List<Account> listAccount = new List<Account>();
	        listAccount.add(accountTm);
	        insert listAccount;
        }

        List<Campaign> listCampaign = new List<Campaign>();
        listCampaign.add(campNotExpired);
        listCampaign.add(campExpired);
        insert listCampaign;

        Target_List__c targetListCampNotExpired = Mockup_Test.newTargetList(accountTm.Id,campNotExpired.Id,external1,'New');
        Target_List__c targetListCampExpired = Mockup_Test.newTargetList(accountTm.Id,campExpired.Id,external2,'New');
        List<Target_List__c> listTargetList = new List<Target_List__c>();
        listTargetList.add(targetListCampNotExpired);
        listTargetList.add(targetListCampExpired);
        insert listTargetList;
        Test.stopTest();
        TriggerHandler.clearBypass('UserTriggerHandler');
	}

	@isTest static void testPurgeLeadExpiredMoreThan4DayThenDeleteLeadAndTargetListExpired() {
		System.assertEquals(2, [SELECT Count() FROM Target_List__c]);
		System.assertEquals(2, [SELECT Count() FROM Campaign]);

		Test.startTest();
			Database.executeBatch(new SME_PurgeLead_Batch('4'));
		Test.stopTest();

		System.assertEquals(1, [SELECT Count() FROM Target_List__c]);
		System.assertEquals(1, [SELECT Count() FROM Campaign]);		
		System.assertNotEquals(Null, [SELECT Id FROM Target_List__c WHERE External_ID__c = :external1]);
		System.assertNotEquals(Null, [SELECT Id FROM Campaign WHERE Name = :campaignNotExpired]);
	}
}