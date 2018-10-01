@isTest
private class AnswerLeadListView_Test
{
	private static final String ANSWER1 = 'Answer1';
	private static final String ANSWER2 = 'Answer2';
	private static final String ANSWER2_WITH_MEMO = 'Answer2_MEMO';
	private static final String CAMPAIGN_NAME = 'CampaignName';
	private static final String CBS_LEAD_SUBTYPE = 'SUBTYPE01';

	private static final String USER_EMPOYEEID = '9000000000'; 
	private static final String CIS_ACCOUNT1 = '000001'; 
	@testSetup static void setupData(){
        Mockup_Test.setUpCustomSetting();
		Test.startTest();
        	createListAnswer();
        	createUserAndAccount();
        Test.stopTest();
    }

	public static void createListAnswer(){
		List<Global_Master_Data__c> responseList = new List<Global_Master_Data__c>{
			Mockup_Test.newAllLeadResponse(CAMPAIGN_NAME,CBS_LEAD_SUBTYPE,ANSWER1,NULL,FALSE,FALSE,'CBS'),
			Mockup_Test.newAllLeadResponse(CAMPAIGN_NAME,CBS_LEAD_SUBTYPE,ANSWER1,ANSWER2,TRUE,FALSE,'CBS'),
			Mockup_Test.newAllLeadResponse(CAMPAIGN_NAME,CBS_LEAD_SUBTYPE,ANSWER1,ANSWER2_WITH_MEMO,TRUE,TRUE,'CBS')
		};
		insert responseList;
	}

	public static void createUserAndAccount(){
		Profile cbsRM_Profile = [SELECT Id From Profile  WHERE Name = :GlobalConstants.CBS_RM LIMIT 1];
		User userCBS_RM = Mockup_Test.newUser('fistname','lastname', USER_EMPOYEEID, true, cbsRM_Profile.id, null, null);
		insert userCBS_RM;
		System.runAs(userCBS_RM){
			Account newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
			newAccount1.CIS__c = CIS_ACCOUNT1;
            newAccount1.OwnerId = userCBS_RM.Id;
			insert newAccount1;
		}

	}


	@isTest
	static void loadLeadResponseOnLoad()
	{
		// Given
		Account account = [SELECT Id From Account WHERE CIS__c = :CIS_ACCOUNT1 LIMIT 1];
		User userCBS_RM = [SELECT Id From User WHERE Employee_ID__c = :USER_EMPOYEEID LIMIT 1];

		Campaign leadForFeedBack = Mockup_Test.newCampaignSubTypeCBS(UserInfo.getUserId(),CAMPAIGN_NAME, System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_CBS_REC, 'Advertisement',CBS_LEAD_SUBTYPE);
		insert leadForFeedBack;

		List<Target_List__c> targetLists = new List<Target_List__c>();
		Target_List__c targetListForFeedBack = Mockup_Test.newTargetList(account.Id, leadForFeedBack.Id, 'externalId1', 'New');
		targetLists.add(targetListForFeedBack);

		insert targetLists;
        
		// When
		AnswerLeadController ext;
		//System.runAs(userCBS_RM){
			Test.setCurrentPage(Page.AnswerLeadListView);
	 		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(targetLists);
	  		stdSetController.setSelected(targetLists);
            ext = new AnswerLeadController(stdSetController);
 		//}
		// Then
		
		System.assertEquals(false,ext.hasExpireCampaign);
		System.assertEquals(2,ext.optionLevel1.size());
	}

	@isTest
	static void testChangeResponseLv1AndLv2()
	{
		// Given
		Account account = [SELECT Id From Account WHERE CIS__c = :CIS_ACCOUNT1 LIMIT 1];
		User userCBS_RM = [SELECT Id From User WHERE Employee_ID__c = :USER_EMPOYEEID LIMIT 1];

		Campaign leadForFeedBack = Mockup_Test.newCampaignSubTypeCBS(UserInfo.getUserId(),CAMPAIGN_NAME, System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_CBS_REC, 'Advertisement',CBS_LEAD_SUBTYPE);
		insert leadForFeedBack;

		List<Target_List__c> targetLists = new List<Target_List__c>();
		Target_List__c targetListForFeedBack = Mockup_Test.newTargetList(account.Id, leadForFeedBack.Id, 'externalId1', 'New');
		targetLists.add(targetListForFeedBack);

		insert targetLists;
		// When
		AnswerLeadController ext;
		//System.runAs(userCBS_RM){
			Test.setCurrentPage(Page.AnswerLeadListView);
	 		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(targetLists);
	  		stdSetController.setSelected(targetLists);
	 		ext = new AnswerLeadController(stdSetController);
	 		ext.responseModel.responseLv1 = ANSWER1;
	 		ext.onChangeResponseLevel1();
	 		ext.responseModel.responseLv2 = ANSWER2_WITH_MEMO;
	 		ext.onChangeResponseLevel2();
 		//}
		// Then

		System.assertEquals(true,ext.responseModel.answerObj.isRequireLv2);
		System.assertEquals(true,ext.responseModel.answerObj.isRequireMemo);
	}


	@isTest
	static void testSubmitLeadResponse()
	{
		// Given
		Account account = [SELECT Id From Account WHERE CIS__c = :CIS_ACCOUNT1 LIMIT 1];
		User userCBS_RM = [SELECT Id From User WHERE Employee_ID__c = :USER_EMPOYEEID LIMIT 1];

		Campaign leadForFeedBack = Mockup_Test.newCampaignSubTypeCBS(UserInfo.getUserId(),CAMPAIGN_NAME, System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_CBS_REC, 'Advertisement',CBS_LEAD_SUBTYPE);
		insert leadForFeedBack;

		List<Target_List__c> targetLists = new List<Target_List__c>();
		Target_List__c targetListForFeedBack = Mockup_Test.newTargetList(account.Id, leadForFeedBack.Id, 'externalId1', 'New');
		targetLists.add(targetListForFeedBack);

		insert targetLists;
		// When
		AnswerLeadController ext;
		//System.runAs(userCBS_RM){
			Test.setCurrentPage(Page.AnswerLeadListView);
	 		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(targetLists);
	  		stdSetController.setSelected(targetLists);
	 		ext = new AnswerLeadController(stdSetController);
	 		ext.responseModel.responseLv1 = ANSWER1;
	 		ext.onChangeResponseLevel1();
	 		ext.responseModel.responseLv2 = ANSWER2_WITH_MEMO;
	 		ext.onChangeResponseLevel2();
	 		ext.responseModel.memo = 'memoText';
	 		ext.submitResponse();
 		//}
		// Then
		Target_List__c targetListResult = [SELECT Id,Status__c,Response_Level_1__c,Response_Level_2__c,Memo__c From Target_List__c WHERE Id = :targetListForFeedBack.id];
		System.assertEquals(targetListResult.Status__c,ext.responseModel.responseLv1);
		System.assertEquals(targetListResult.Response_Level_1__c,ext.responseModel.responseLv1);
		System.assertEquals(targetListResult.Response_Level_2__c,ext.responseModel.responseLv2);
		System.assertEquals(targetListResult.Memo__c,ext.responseModel.memo);
	}
}