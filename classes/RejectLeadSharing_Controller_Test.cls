@isTest
private class RejectLeadSharing_Controller_Test {
	public static String accountNameRMPort = 'accountNameRMPort';
	public static String userFirstNameMockupBad = 'userFirstNameMockupBad';
	public static String userLastNameMockupBad = 'userLastNameMockupBad';
	public static String userBadEmpId = 'MOCKBAD01';

	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();

		System.runAs(new User(Id=UserInfo.getUserId())){
			UserRole anRole = [SELECT Id, Name, DeveloperName FROM UserRole WHERE Name =: GlobalConstants.AN_TEAM_NAME];
			User badUser = Mockup_Test.newUser(
	                userFirstNameMockupBad,
	                userLastNameMockupBad,
	                true,
	                userFirstNameMockupBad+'@mail.com',
	                userFirstNameMockupBad+'@mail.com',
	                userFirstNameMockupBad.substring(0, 4),
	                Mockup_Test.mapProfileByName.get(GlobalConstants.AN_TM).Id,
	                anRole.Id,
	                null,
	                userBadEmpId
	         );
	        badUser.Job_Code__c = 'ME3A';
	        badUser.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
	        badUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
	        badUser.RC_Code__c = Mockup_Test.RC_CODE;
	        badUser.Status__c = 'A';

	        insert badUser;
	    }

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRMPort,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
	}

	@isTest static void BadRejectLeadSharingThenDeleteShareAndUpdateTargetListStatusRejectedToNewAndUpdateTargetListSharingStatusRejectedToNew() {
		Account shareAccount = [SELECT Id FROM Account WHERE Name = :accountNameRMPort LIMIT 1];
		User badUser = [SELECT Id FROM User WHERE Firstname = :userFirstNameMockupBad LIMIT 1];

		list<Campaign> listCampaign = new List<Campaign>();
		list<Target_List__c> listTargetList = new List<Target_List__c>();

		Campaign campaignActiveNotShare_1 = Mockup_Test.newCampaign(UserInfo.getUserId(),'campaignActiveNotShare_1', System.now().addDays(-1), System.now().addDays(10), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES, null);
		listCampaign.add(campaignActiveNotShare_1);

		Campaign campaignActiveNotShare_2 = Mockup_Test.newCampaign(UserInfo.getUserId(),'campaignActiveNotShare_2', System.now().addDays(-1), System.now().addDays(10), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES, null);
		listCampaign.add(campaignActiveNotShare_2);

		Campaign campaignActiveNotShare_3 = Mockup_Test.newCampaign(UserInfo.getUserId(),'campaignActiveNotShare_3', System.now().addDays(-1), System.now().addDays(10), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES, null);
		listCampaign.add(campaignActiveNotShare_3);

		Campaign campaignExpiredNotShare_1 = Mockup_Test.newCampaign(UserInfo.getUserId(),'campaignExpiredNotShare_1', System.now().addDays(-2), System.now().addDays(10), System.now().addDays(-2), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES, null);
		listCampaign.add(campaignExpiredNotShare_1);

		Campaign campaignActiveShare_1 = Mockup_Test.newCampaign(UserInfo.getUserId(),'campaignActiveShare_1', System.now().addDays(-1), System.now().addDays(10), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES, null);
		campaignActiveShare_1.Sharing__c = GlobalConstants.LEAD_SHARING;
		listCampaign.add(campaignActiveShare_1);

		Campaign campaignActiveShare_2 = Mockup_Test.newCampaign(UserInfo.getUserId(),'campaignActiveShare_2', System.now().addDays(-1), System.now().addDays(10), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES, null);
		campaignActiveShare_2.Sharing__c = GlobalConstants.LEAD_SHARING;
		listCampaign.add(campaignActiveShare_2);

		Campaign campaignActiveShare_3 = Mockup_Test.newCampaign(UserInfo.getUserId(),'campaignActiveShare_3', System.now().addDays(-1), System.now().addDays(10), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES, null);
		campaignActiveShare_3.Sharing__c = GlobalConstants.LEAD_SHARING;
		listCampaign.add(campaignActiveShare_3);

		Campaign campaignExpiredShare_1 = Mockup_Test.newCampaign(UserInfo.getUserId(),'campaignExpiredShare_1', System.now().addDays(-2), System.now().addDays(10), System.now().addDays(-2), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES, null);
		campaignExpiredShare_1.Sharing__c = GlobalConstants.LEAD_SHARING;
		listCampaign.add(campaignExpiredShare_1);

		TriggerHandler.bypass('CampaignTriggerHandler');
		insert listCampaign;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		Target_List__c targetListOfCampaignActiveNotShare_1 = Mockup_Test.newTargetList(shareAccount.Id,campaignActiveNotShare_1.Id,'campaignActiveNotShare_1'+shareAccount.Id,GlobalConstants.STATUS_NEW);
		listTargetList.add(targetListOfCampaignActiveNotShare_1);

		Target_List__c targetListOfCampaignActiveNotShare_2 = Mockup_Test.newTargetList(shareAccount.Id,campaignActiveNotShare_2.Id,'campaignActiveNotShare_2'+shareAccount.Id,GlobalConstants.REJECTED);
		listTargetList.add(targetListOfCampaignActiveNotShare_2);

		Target_List__c targetListOfCampaignActiveNotShare_3 = Mockup_Test.newTargetList(shareAccount.Id,campaignActiveNotShare_3.Id,'campaignActiveNotShare_3'+shareAccount.Id,GlobalConstants.PLAN);
		listTargetList.add(targetListOfCampaignActiveNotShare_3);

		Target_List__c targetListOfCampaignExpiredNotShare_1 = Mockup_Test.newTargetList(shareAccount.Id,campaignExpiredNotShare_1.Id,'campaignExpiredNotShare_1'+shareAccount.Id,GlobalConstants.STATUS_NEW);
		listTargetList.add(targetListOfCampaignExpiredNotShare_1);

		Target_List__c targetListOfCampaignActiveShare_1 = Mockup_Test.newTargetList(shareAccount.Id,campaignActiveShare_1.Id,'campaignActiveShare_1'+shareAccount.Id,GlobalConstants.STATUS_NEW);
		targetListOfCampaignActiveShare_1.Share_with__c = badUser.Id;
		listTargetList.add(targetListOfCampaignActiveShare_1);

		Target_List__c targetListOfCampaignActiveShare_2 = Mockup_Test.newTargetList(shareAccount.Id,campaignActiveShare_2.Id,'campaignActiveShare_2'+shareAccount.Id,GlobalConstants.REJECTED);
		targetListOfCampaignActiveShare_2.Share_with__c = badUser.Id;
		listTargetList.add(targetListOfCampaignActiveShare_2);

		Target_List__c targetListOfCampaignActiveShare_3 = Mockup_Test.newTargetList(shareAccount.Id,campaignActiveShare_3.Id,'campaignActiveShare_3'+shareAccount.Id,GlobalConstants.CONTACTED);
		targetListOfCampaignActiveShare_3.Share_with__c = badUser.Id;
		listTargetList.add(targetListOfCampaignActiveShare_3);

		Target_List__c targetListOfCampaignExpiredShare_1 = Mockup_Test.newTargetList(shareAccount.Id,campaignExpiredShare_1.Id,'campaignExpiredShare_1'+shareAccount.Id,GlobalConstants.STATUS_NEW);
		targetListOfCampaignExpiredShare_1.Share_with__c = badUser.Id;
		listTargetList.add(targetListOfCampaignExpiredShare_1);

		insert listTargetList;

		Test.startTest();
			campaignExpiredShare_1.Status = GlobalConstants.EXPIRE_PROCESS;
			campaignExpiredNotShare_1.Status = GlobalConstants.EXPIRE_PROCESS;
			List<Campaign> listUpdateCampaign = new List<Campaign>{campaignExpiredShare_1,campaignExpiredNotShare_1};
			update listUpdateCampaign;
			//update campaignExpiredShare_1;
			//update campaignExpiredNotShare_1;
		Test.stopTest();
		
		Map<Id,Target_List__c> mapTargetListAfterUpdate = new Map<Id,Target_List__c>([SELECT Id,Status__c FROM Target_List__c WHERE Lead_Campaign__r.Id IN :listCampaign]);
		
		System.assertEquals(8,mapTargetListAfterUpdate.size());
		System.assertEquals(GlobalConstants.STATUS_NEW,mapTargetListAfterUpdate.get(targetListOfCampaignActiveNotShare_1.Id).Status__c);
		System.assertEquals(GlobalConstants.REJECTED,mapTargetListAfterUpdate.get(targetListOfCampaignActiveNotShare_2.Id).Status__c);
		System.assertEquals(GlobalConstants.PLAN,mapTargetListAfterUpdate.get(targetListOfCampaignActiveNotShare_3.Id).Status__c);
		System.assertEquals(GlobalConstants.LEAD_EXPIRED,mapTargetListAfterUpdate.get(targetListOfCampaignExpiredNotShare_1.Id).Status__c);

		System.assertEquals(GlobalConstants.STATUS_NEW,mapTargetListAfterUpdate.get(targetListOfCampaignActiveShare_1.Id).Status__c);
		System.assertEquals(GlobalConstants.REJECTED,mapTargetListAfterUpdate.get(targetListOfCampaignActiveShare_2.Id).Status__c);
		System.assertEquals(GlobalConstants.CONTACTED,mapTargetListAfterUpdate.get(targetListOfCampaignActiveShare_3.Id).Status__c);
		System.assertEquals(GlobalConstants.LEAD_EXPIRED,mapTargetListAfterUpdate.get(targetListOfCampaignExpiredShare_1.Id).Status__c);

		List<AccountShare> listAccountShare = [SELECT Id,Account.Share_with__c,Account.Sharing_Status__c FROM AccountShare WHERE AccountId = :shareAccount.Id AND UserOrGroupId = :badUser.Id AND RowCause = 'Manual'];
		System.assertEquals(1,listAccountShare.size());
		System.assertEquals(badUser.Id,listAccountShare[0].Account.Share_with__c);
		System.assertEquals(GlobalConstants.SHARING_WITH_AN,listAccountShare[0].Account.Sharing_Status__c);

		System.runAs(badUser){
			RejectLeadSharing_Controller.Response res = RejectLeadSharing_Controller.deleteAccountShare(badUser.Id,shareAccount.Id);
			System.assertEquals(true,res.success);
		}

		List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :shareAccount.Id AND UserOrGroupId = :badUser.Id AND RowCause = 'Manual'];
			
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterStopSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRMPort LIMIT 1];
		System.assertEquals(null,shareAccountAfterStopSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterStopSharing.Sharing_Status__c);

		Map<Id,Target_List__c> mapTargetListAfterStopSharing = new Map<Id,Target_List__c>([SELECT Id,Status__c FROM Target_List__c WHERE Lead_Campaign__r.Id IN :listCampaign]);
		System.assertEquals(8,mapTargetListAfterStopSharing.size());
		System.assertEquals(GlobalConstants.STATUS_NEW,mapTargetListAfterStopSharing.get(targetListOfCampaignActiveNotShare_1.Id).Status__c);
		System.assertEquals(GlobalConstants.STATUS_NEW,mapTargetListAfterStopSharing.get(targetListOfCampaignActiveNotShare_2.Id).Status__c);
		System.assertEquals(GlobalConstants.PLAN,mapTargetListAfterStopSharing.get(targetListOfCampaignActiveNotShare_3.Id).Status__c);
		System.assertEquals(GlobalConstants.LEAD_EXPIRED,mapTargetListAfterStopSharing.get(targetListOfCampaignExpiredNotShare_1.Id).Status__c);

		System.assertEquals(GlobalConstants.STATUS_NEW,mapTargetListAfterStopSharing.get(targetListOfCampaignActiveShare_1.Id).Status__c);
		System.assertEquals(GlobalConstants.STATUS_NEW,mapTargetListAfterStopSharing.get(targetListOfCampaignActiveShare_2.Id).Status__c);
		System.assertEquals(GlobalConstants.CONTACTED,mapTargetListAfterStopSharing.get(targetListOfCampaignActiveShare_3.Id).Status__c);
		System.assertEquals(GlobalConstants.LEAD_EXPIRED,mapTargetListAfterStopSharing.get(targetListOfCampaignExpiredShare_1.Id).Status__c);

	}
	
}