@isTest
private class ManageSharing_Service_Test {
	public static String accountNameRM = 'rmCreatedAccountName';
	public static String tmANUser_1_FirstName = Mockup_Test.tmANUserFirstName+'1';
	public static String tmANUser_1_LastName = Mockup_Test.tmANUserLastName+'1';

	public static String tmANUser_2_FirstName = Mockup_Test.tmANUserFirstName+'2';
	public static String tmANUser_2_LastName = Mockup_Test.tmANUserLastName+'2';

	@testSetup static void setupUser(){
        Mockup_Test mt = new Mockup_Test().setUpTestAdmin();

        System.runAs(new User(Id=UserInfo.getUserId())){
        	Profile goodRmProfile = Mockup_Test.mapProfileByName.get(GlobalConstants.SME_RM);
        	
        	UserRole tmRole = Mockup_Test.newRole(Mockup_Test.RC_CODE, 'RC' + Mockup_Test.RC_CODE, null);
            insert tmRole;
            UserRole rmRole = Mockup_Test.newRole(Mockup_Test.RC_CODE, 'RCRM' + Mockup_Test.RC_CODE, null);
            insert rmRole;

        	Profile badTmProfile = Mockup_Test.mapProfileByName.get(GlobalConstants.AN_TM);

            User rmUser = Mockup_Test.newUser(
                    Mockup_Test.userFirstNameRM,
                    Mockup_Test.userLastNameRM,
                    true,
                    Mockup_Test.userFirstNameRM+'@mail.com',
                    Mockup_Test.userFirstNameRM+'@mail.com',
                    Mockup_Test.userFirstNameRM.substring(0, 4),
                    goodRmProfile.Id,
                    rmRole.Id,
                    null,
                    Mockup_Test.userEmpIdRM
             );
            rmUser.Current_Opportunity_Approval__c = null;
            rmUser.Job_Code__c = 'ME4A';
            rmUser.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
            rmUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
            rmUser.RC_Code__c = Mockup_Test.RC_CODE;
            rmUser.Status__c = 'A';
            rmUser.Segment__c = 'ME';

            insert rmUser;

            User tmANUser_1 = Mockup_Test.newUser(
                    tmANUser_1_FirstName,
                    tmANUser_1_LastName,
                    true,
                    tmANUser_1_FirstName+'@mail.com',
                    tmANUser_1_FirstName+'@mail.com',
                    tmANUser_1_FirstName.substring(0, 4),
                    badTmProfile.Id,
                    tmRole.Id,
                    null,
                    Mockup_Test.tmANEmpId+'1'
             );
            tmANUser_1.Current_Opportunity_Approval__c = null;
            tmANUser_1.Job_Code__c = 'AN3A';
            tmANUser_1.AH_RC_Code__c = Mockup_Test.ahANRCCode;
            tmANUser_1.NH_RC_Code__c = Mockup_Test.nhANRCCode;
            tmANUser_1.RC_Code__c = Mockup_Test.tmANRCCode;
            tmANUser_1.Status__c = 'A';
            tmANUser_1.Segment__c = 'AN';
            insert tmANUser_1;

            User tmANUser_2 = Mockup_Test.newUser(
                    tmANUser_2_FirstName,
                    tmANUser_2_LastName,
                    true,
                    tmANUser_2_FirstName+'@mail.com',
                    tmANUser_2_FirstName+'@mail.com',
                    tmANUser_2_FirstName.substring(0, 4),
                    badTmProfile.Id,
                    tmRole.Id,
                    null,
                    Mockup_Test.tmANEmpId+'2'
             );
            tmANUser_2.Current_Opportunity_Approval__c = null;
            tmANUser_2.Job_Code__c = 'AN3A';
            tmANUser_2.AH_RC_Code__c = Mockup_Test.ahANRCCode;
            tmANUser_2.NH_RC_Code__c = Mockup_Test.nhANRCCode;
            tmANUser_2.RC_Code__c = Mockup_Test.tmANRCCode;
            tmANUser_2.Status__c = 'A';
            tmANUser_2.Segment__c = 'AN';
            insert tmANUser_2; 
        }

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
    }

	@isTest static void IfCampaignActiveAndTargetListHasOpenCallPlanButNoOpenOpportunityThenNotShareToBadAndStampSharingRemark() {
		Account account = [SELECT Id, CIS__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(1), System.now().addDays(5), System.now().addDays(1), GlobalConstants.PLAN, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		Target_List__c targetList = new Target_List__c();
	    targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    Business_Code__c buCodeTest = new Business_Code__c(Name = '123456',Segment__c = 'ME',External_ID__c='123456:ME');
        insert buCodeTest;

	    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
		    Call_Report__c openCallPlan = new Call_Report__c();
		    openCallPlan.CIS_ID__c = account.Id;
		    openCallPlan.Status__c = GlobalConstants.PLAN;
		    openCallPlan.Plan_Date__c = System.today();
		    openCallPlan.Visit_Objective__c ='Relationship';
		    insert openCallPlan;

		    Opportunity closedOpportunity = new Opportunity();
		    closedOpportunity.Name = 'closedOpp';
		    closedOpportunity.StageName = GlobalConstants.CLOSE_LOST;
		    closedOpportunity.CloseDate = System.today();
		    closedOpportunity.AccountId = account.Id;
		    closedOpportunity.Business_Code__c = buCodeTest.id;
		    insert closedOpportunity;
		}

		Test.startTest();
	    	Campaign updateCampaign = new Campaign();
	    	updateCampaign.Id = leadSharing.Id;
	    	updateCampaign.Name = 'leadSharingAfterUpdate';
	    	updateCampaign.StartDate = System.today() - 1;
	    	updateCampaign.Status = GlobalConstants.ACTIVE;
	    	updateCampaign.IsActive = true;

	    	GlobalUtility.runOnce = false;
	    	update updateCampaign;
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
			
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterStopSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(null,shareAccountAfterStopSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterStopSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterStopSharing = [SELECT Id,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterStopSharing.size());
		System.assertEquals(GlobalConstants.STATUS_NEW,targetListAfterStopSharing[0].Status__c);
		System.assertEquals(null,targetListAfterStopSharing[0].Sharing_Status__c);
		System.assertEquals(false,targetListAfterStopSharing[0].Sharing_Completed__c);
		System.assertNotEquals(null,targetListAfterStopSharing[0].Sharing_Remark__c);
		
	}
	
	@isTest static void IfCampaignActiveAndTargetListNoOpenCallPlanButHasOpenOpportunityThenNotShareToBadAndStampSharingRemark() {
		Account account = [SELECT Id, CIS__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(1), System.now().addDays(5), System.now().addDays(1), GlobalConstants.PLAN, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		Target_List__c targetList = new Target_List__c();
	    targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');
	    Business_Code__c buCodeTest = new Business_Code__c(Name = '123456',Segment__c = 'ME',External_ID__c='123456:ME');
        insert buCodeTest;

	    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
		    Call_Report__c closedCallPlan = new Call_Report__c();
		    closedCallPlan.CIS_ID__c = account.Id;
		    closedCallPlan.Status__c = GlobalConstants.CONTACTED;
		    closedCallPlan.Plan_Date__c = System.today();
		    closedCallPlan.Visit_Objective__c ='Relationship';
		    closedCallPlan.Contact_Firstname__c = 'test share first name';
		    closedCallPlan.Contact_Lastname__c = 'test share last name';
		    closedCallPlan.Contact_Phone__c = '1234567890';
		    insert closedCallPlan;

		    Opportunity openOpportunity = new Opportunity();
		    openOpportunity.Name = 'openOpp';
		    openOpportunity.StageName = GlobalConstants.STOCK_NEGOTIATION;
		    openOpportunity.CloseDate = System.today();
		    openOpportunity.AccountId = account.Id;
		    openOpportunity.Business_Code__c = buCodeTest.Id;
		    insert openOpportunity;
		}

		Test.startTest();
	    	Campaign updateCampaign = new Campaign();
	    	updateCampaign.Id = leadSharing.Id;
	    	updateCampaign.Name = 'leadSharingAfterUpdate';
	    	updateCampaign.StartDate = System.today() - 1;
	    	updateCampaign.Status = GlobalConstants.ACTIVE;
	    	updateCampaign.IsActive = true;

	    	GlobalUtility.runOnce = false;
	    	update updateCampaign;
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
			
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterStopSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(null,shareAccountAfterStopSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterStopSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterStopSharing = [SELECT Id,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterStopSharing.size());
		System.assertEquals(GlobalConstants.STATUS_NEW,targetListAfterStopSharing[0].Status__c);
		System.assertEquals(null,targetListAfterStopSharing[0].Sharing_Status__c);
		System.assertEquals(false,targetListAfterStopSharing[0].Sharing_Completed__c);
		System.assertNotEquals(null,targetListAfterStopSharing[0].Sharing_Remark__c);
	}

	@isTest static void IfCampaignActiveAndTargetListHasOpenCallPlanAndOpenOpportunityThenNotShareToBadAndStampSharingRemark() {
		Account account = [SELECT Id, CIS__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(1), System.now().addDays(5), System.now().addDays(1), GlobalConstants.PLAN, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		Target_List__c targetList = new Target_List__c();
	    targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    Business_Code__c buCodeTest = new Business_Code__c(Name = '123456',Segment__c = 'ME',External_ID__c='123456:ME');
        insert buCodeTest;

	    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
		    Call_Report__c openCallPlan = new Call_Report__c();
		    openCallPlan.CIS_ID__c = account.Id;
		    openCallPlan.Status__c = GlobalConstants.PLAN;
		    openCallPlan.Plan_Date__c = System.today();
		    openCallPlan.Visit_Objective__c ='Relationship';
		    insert openCallPlan;

		    Opportunity openOpportunity = new Opportunity();
		    openOpportunity.Name = 'openOpp';
		    openOpportunity.StageName = GlobalConstants.STOCK_NEGOTIATION;
		    openOpportunity.CloseDate = System.today();
		    openOpportunity.AccountId = account.Id;
		    openOpportunity.Business_Code__c = buCodeTest.Id;
		    insert openOpportunity;
		}

		Test.startTest();
	    	Campaign updateCampaign = new Campaign();
	    	updateCampaign.Id = leadSharing.Id;
	    	updateCampaign.Name = 'leadSharingAfterUpdate';
	    	updateCampaign.StartDate = System.today() - 1;
	    	updateCampaign.Status = GlobalConstants.ACTIVE;
	    	updateCampaign.IsActive = true;

	    	GlobalUtility.runOnce = false;
	    	update updateCampaign;
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
			
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterStopSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(null,shareAccountAfterStopSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterStopSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterStopSharing = [SELECT Id,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterStopSharing.size());
		System.assertEquals(GlobalConstants.STATUS_NEW,targetListAfterStopSharing[0].Status__c);
		System.assertEquals(null,targetListAfterStopSharing[0].Sharing_Status__c);
		System.assertEquals(false,targetListAfterStopSharing[0].Sharing_Completed__c);
		System.assertNotEquals(null,targetListAfterStopSharing[0].Sharing_Remark__c);
	}

	@isTest static void IfCampaignActiveAndTargetListNoOpenCallPlanAndNoOpenOpportunityThenShareToBadAndUpdateSharingInfoInTargetListAndUpdateSharingInfoInAccount() {
		Account account = [SELECT Id, CIS__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(1), System.now().addDays(5), System.now().addDays(1), GlobalConstants.PLAN, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		Target_List__c targetList = new Target_List__c();
	    targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    Business_Code__c buCodeTest = new Business_Code__c(Name = '123456',Segment__c = 'ME',External_ID__c='123456:ME');
        insert buCodeTest;
		Opportunity closedOpportunity;
	    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
		    Call_Report__c closedCallPlan = new Call_Report__c();
		    closedCallPlan.CIS_ID__c = account.Id;
		    closedCallPlan.Status__c = GlobalConstants.CONTACTED;
		    closedCallPlan.Plan_Date__c = System.today();
		    closedCallPlan.Visit_Objective__c ='Relationship';
		    closedCallPlan.Contact_Firstname__c = 'test share first name';
		    closedCallPlan.Contact_Lastname__c = 'test share last name';
		    closedCallPlan.Contact_Phone__c = '1234567890';
		    insert closedCallPlan;

		    closedOpportunity = new Opportunity();
		    closedOpportunity.Name = 'closedOpp';
		    closedOpportunity.StageName = GlobalConstants.CLOSE_LOST;
		    closedOpportunity.CloseDate = System.today();
		    closedOpportunity.AccountId = account.Id;
		    closedOpportunity.Business_Code__c = buCodeTest.Id;
		    insert closedOpportunity;
		}

		Test.startTest();
			TriggerHandler.bypass('OpportunityTriggerHandler');
			closedOpportunity.StageName = GlobalConstants.CLOSE_LOST;
			update closedOpportunity;
			TriggerHandler.clearbypass('OpportunityTriggerHandler');

	    	Campaign updateCampaign = new Campaign();
	    	updateCampaign.Id = leadSharing.Id;
	    	updateCampaign.Name = 'leadSharingAfterUpdate';
	    	updateCampaign.StartDate = System.today() - 1;
	    	updateCampaign.Status = GlobalConstants.ACTIVE;
	    	updateCampaign.IsActive = true;

	    	GlobalUtility.runOnce = false;
	    	update updateCampaign;
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
			
		System.assertEquals(1,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(userBad.Id,shareAccountAfterSharing.Share_with__c);
		System.assertEquals(GlobalConstants.SHARING_WITH_AN,shareAccountAfterSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterSharing = [SELECT Id,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterSharing.size());
		System.assertEquals(GlobalConstants.STATUS_NEW,targetListAfterSharing[0].Status__c);
		System.assertEquals(GlobalConstants.SHARING_WITH_AN,targetListAfterSharing[0].Sharing_Status__c);
		System.assertEquals(true,targetListAfterSharing[0].Sharing_Completed__c);
		System.assertEquals(null,targetListAfterSharing[0].Sharing_Remark__c);
	}
	
	@isTest static void InsertTargetListShareWithBadHasOpenCallPlanThenNotShareToBadAndStampSharingRemark() {
		Account account = [SELECT Id, CIS__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		insert leadSharing;

	    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
		    Call_Report__c openCallPlan = new Call_Report__c();
		    openCallPlan.CIS_ID__c = account.Id;
		    openCallPlan.Status__c = GlobalConstants.PLAN;
		    openCallPlan.Plan_Date__c = System.today();
		    openCallPlan.Visit_Objective__c ='Relationship';
		    insert openCallPlan;
		}

		Test.startTest();
	    	Target_List__c targetList = new Target_List__c();
		    targetList.Lead_Campaign__c = leadSharing.Id;
		    targetList.CIS_ID_Prospect_Name__c = account.Id;
		    targetList.Status__c = GlobalConstants.STATUS_NEW;
		    targetList.Share_With__c = userBad.Id;
		    insert targetList;
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
			
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterStopSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(null,shareAccountAfterStopSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterStopSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterStopSharing = [SELECT Id,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterStopSharing.size());
		System.assertEquals(GlobalConstants.STATUS_NEW,targetListAfterStopSharing[0].Status__c);
		System.assertEquals(null,targetListAfterStopSharing[0].Sharing_Status__c);
		System.assertEquals(false,targetListAfterStopSharing[0].Sharing_Completed__c);
		System.assertNotEquals(null,targetListAfterStopSharing[0].Sharing_Remark__c);
	}

	@isTest static void InsertTargetListShareWithBadHasOpenOpportunityThenNotShareToBadAndStampSharingRemark() {
		Account account = [SELECT Id, CIS__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		insert leadSharing;
		Business_Code__c buCodeTest = new Business_Code__c(Name = '123456',Segment__c = 'ME',External_ID__c='123456:ME');
        insert buCodeTest;
	    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
		    Opportunity openOpportunity = new Opportunity();
		    openOpportunity.Name = 'openOpp';
		    openOpportunity.StageName = GlobalConstants.STOCK_NEGOTIATION;
		    openOpportunity.CloseDate = System.today();
		    openOpportunity.AccountId = account.Id;
		    openOpportunity.Business_Code__c = buCodeTest.Id;
		    insert openOpportunity;
		}
		Test.startTest();
	    	Target_List__c targetList = new Target_List__c();
		    targetList.Lead_Campaign__c = leadSharing.Id;
		    targetList.CIS_ID_Prospect_Name__c = account.Id;
		    targetList.Status__c = GlobalConstants.STATUS_NEW;
		    targetList.Share_With__c = userBad.Id;
		    insert targetList;
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
			
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterStopSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(null,shareAccountAfterStopSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterStopSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterStopSharing = [SELECT Id,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterStopSharing.size());
		System.assertEquals(GlobalConstants.STATUS_NEW,targetListAfterStopSharing[0].Status__c);
		System.assertEquals(null,targetListAfterStopSharing[0].Sharing_Status__c);
		System.assertEquals(false,targetListAfterStopSharing[0].Sharing_Completed__c);
		System.assertNotEquals(null,targetListAfterStopSharing[0].Sharing_Remark__c);
	}

	@isTest static void InsertTargetListShareWithBadHasOpenCallPlanAndOpenOpportunityThenNotShareToBadAndStampSharingRemark() {
		Account account = [SELECT Id, CIS__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		insert leadSharing;
		Business_Code__c buCodeTest = new Business_Code__c(Name = '123456',Segment__c = 'ME',External_ID__c='123456:ME');
        insert buCodeTest;

	    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
		    Call_Report__c openCallPlan = new Call_Report__c();
		    openCallPlan.CIS_ID__c = account.Id;
		    openCallPlan.Status__c = GlobalConstants.PLAN;
		    openCallPlan.Plan_Date__c = System.today();
		    openCallPlan.Visit_Objective__c ='Relationship';
		    insert openCallPlan;

		    Opportunity openOpportunity = new Opportunity();
		    openOpportunity.Name = 'openOpp';
		    openOpportunity.StageName = GlobalConstants.STOCK_NEGOTIATION;
		    openOpportunity.CloseDate = System.today();
		    openOpportunity.AccountId = account.Id;
		    openOpportunity.Business_Code__c = buCodeTest.Id;
		    insert openOpportunity;
		}
		Test.startTest();
	    	Target_List__c targetList = new Target_List__c();
		    targetList.Lead_Campaign__c = leadSharing.Id;
		    targetList.CIS_ID_Prospect_Name__c = account.Id;
		    targetList.Status__c = GlobalConstants.STATUS_NEW;
		    targetList.Share_With__c = userBad.Id;
		    insert targetList;
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
			
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterStopSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(null,shareAccountAfterStopSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterStopSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterStopSharing = [SELECT Id,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterStopSharing.size());
		System.assertEquals(GlobalConstants.STATUS_NEW,targetListAfterStopSharing[0].Status__c);
		System.assertEquals(null,targetListAfterStopSharing[0].Sharing_Status__c);
		System.assertEquals(false,targetListAfterStopSharing[0].Sharing_Completed__c);
		System.assertNotEquals(null,targetListAfterStopSharing[0].Sharing_Remark__c);
	}

	@isTest static void InsertTargetListShareWithBadNoOpenCallPlanAndNoOpenOpportunityThenShareToBadAndUpdateSharingInfoInTargetListAndUpdateSharingInfoInAccount() {
		Account account = [SELECT Id, CIS__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];
		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		insert leadSharing;
		Business_Code__c buCodeTest = new Business_Code__c(Name = '123456',Segment__c = 'ME',External_ID__c='123456:ME');
        insert buCodeTest;
		Opportunity closedOpportunity;
	    System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
		    Call_Report__c closedCallPlan = new Call_Report__c();
		    closedCallPlan.CIS_ID__c = account.Id;
		    closedCallPlan.Status__c = GlobalConstants.CONTACTED;
		    closedCallPlan.Plan_Date__c = System.today();
		    closedCallPlan.Visit_Objective__c ='Relationship';
		    closedCallPlan.Contact_Firstname__c = 'test share first name';
		    closedCallPlan.Contact_Lastname__c = 'test share last name';
		    closedCallPlan.Contact_Phone__c = '1234567890';
		    insert closedCallPlan;

		    closedOpportunity = new Opportunity();
		    closedOpportunity.Name = 'openOpp';
		    closedOpportunity.StageName = GlobalConstants.CLOSE_LOST;
		    closedOpportunity.CloseDate = System.today();
		    closedOpportunity.AccountId = account.Id;
		    closedOpportunity.Business_Code__c = buCodeTest.Id;
		    insert closedOpportunity;
		}
		Test.startTest();
			TriggerHandler.bypass('OpportunityTriggerHandler');
			closedOpportunity.StageName = GlobalConstants.CLOSE_LOST;
			update closedOpportunity;
			TriggerHandler.clearbypass('OpportunityTriggerHandler');
	    	Target_List__c targetList = new Target_List__c();
		    targetList.Lead_Campaign__c = leadSharing.Id;
		    targetList.CIS_ID_Prospect_Name__c = account.Id;
		    targetList.Status__c = GlobalConstants.STATUS_NEW;
		    targetList.Share_With__c = userBad.Id;
		    insert targetList;
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
			
		System.assertEquals(1,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(userBad.Id,shareAccountAfterSharing.Share_with__c);
		System.assertEquals(GlobalConstants.SHARING_WITH_AN,shareAccountAfterSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterSharing = [SELECT Id,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterSharing.size());
		System.assertEquals(GlobalConstants.STATUS_NEW,targetListAfterSharing[0].Status__c);
		System.assertEquals(GlobalConstants.SHARING_WITH_AN,targetListAfterSharing[0].Sharing_Status__c);
		System.assertEquals(true,targetListAfterSharing[0].Sharing_Completed__c);
	}

	@isTest static void UpdateFieldShareWithInTargetListToAnotherBadAndHasCallPlanCallReportThenUpdateAllCallPlanCallReportStatusToClosedAndDeleteOldShareAndInsertNewShare() {
		Target_List__c targetList = new Target_List__c();
		Account account = [SELECT Id, CIS__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];
		User userBad2 = [SELECT Id FROM User WHERE Firstname = :tmANUser_2_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    AccountShare accountShare = new AccountShare();
		accountShare.AccountId = account.Id;
		accountShare.UserOrGroupId = userBad.Id;
		accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
		accountShare.AccountAccessLevel = 'Edit';
		accountShare.OpportunityAccessLevel = 'Read';
		accountShare.CaseAccessLevel = 'none';
		insert accountShare;

		account.Share_With__c = userBad.Id;
		TriggerHandler.bypass('AccountTriggerHandler');
	    update account;
	    TriggerHandler.clearbypass('AccountTriggerHandler');

	    Call_Report__c openCallPlanBad = new Call_Report__c();
		System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
		    openCallPlanBad.CIS_ID__c = account.Id;
		    openCallPlanBad.Status__c = GlobalConstants.PLAN;
		    openCallPlanBad.Plan_Date__c = System.today();
		    openCallPlanBad.Visit_Objective__c ='Relationship';
		    insert openCallPlanBad;
		}

		Test.startTest();
			ManageSharing_Service.listAllCallPlanCallReportByAccountAndOwner = null;
	    	targetList.Share_with__c = userBad2.Id;
	    	update targetList;
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId IN (:userBad2.Id,:userBad.Id) AND RowCause = 'Manual'];
		System.assertEquals(1,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(userBad2.Id,shareAccountAfterSharing.Share_with__c);
		System.assertEquals(GlobalConstants.SHARING_WITH_AN,shareAccountAfterSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterSharing = [SELECT Id,Share_with__c,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterSharing.size());
		System.assertEquals(GlobalConstants.SHARING_WITH_AN,targetListAfterSharing[0].Sharing_Status__c);
		System.assertEquals(userBad2.Id,targetListAfterSharing[0].Share_with__c);
		System.assertEquals(true,targetListAfterSharing[0].Sharing_Completed__c);
		System.assertEquals(null,targetListAfterSharing[0].Sharing_Remark__c);

		List<Call_Report__c> listCallReport = [SELECT Id,Status__c FROM Call_Report__c WHERE Id = :openCallPlanBad.Id LIMIT 1];	    
		System.assertEquals(1,listCallReport.size());
		System.assertEquals(GlobalConstants.CLOSED,listCallReport[0].Status__c);
	}

	@isTest static void UpdateFieldShareWithInTargetListToAnotherBadAndHasOpenOpportunityThenUpdateOpenOpportunityToAutoClosedAndDeleteOldShareAndInsertNewShare() {
		Target_List__c targetList = new Target_List__c();
		Account account = [SELECT Id, CIS__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];
		User userBad2 = [SELECT Id FROM User WHERE Firstname = :tmANUser_2_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    AccountShare accountShare = new AccountShare();
		accountShare.AccountId = account.Id;
		accountShare.UserOrGroupId = userBad.Id;
		accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
		accountShare.AccountAccessLevel = 'Edit';
		accountShare.OpportunityAccessLevel = 'Read';
		accountShare.CaseAccessLevel = 'none';
		insert accountShare;

	    Opportunity openOpportunityBad = new Opportunity();
		System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
		    openOpportunityBad.Name = 'openOpp';
		    openOpportunityBad.StageName = GlobalConstants.STOCK_NEGOTIATION;
		    openOpportunityBad.CloseDate = System.today();
		    openOpportunityBad.AccountId = account.Id;
		    insert openOpportunityBad;
		}

		Test.startTest();
			ManageSharing_Service.listAllOpportunityByAccountAndOwner = null;
	    	targetList.Share_with__c = userBad2.Id;
	    	update targetList;
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId IN (:userBad2.Id,:userBad.Id) AND RowCause = 'Manual'];
		System.assertEquals(1,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(userBad2.Id,shareAccountAfterSharing.Share_with__c);
		System.assertEquals(GlobalConstants.SHARING_WITH_AN,shareAccountAfterSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterSharing = [SELECT Id,Share_with__c,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterSharing.size());
		System.assertEquals(GlobalConstants.SHARING_WITH_AN,targetListAfterSharing[0].Sharing_Status__c);
		System.assertEquals(userBad2.Id,targetListAfterSharing[0].Share_with__c);
		System.assertEquals(true,targetListAfterSharing[0].Sharing_Completed__c);
		System.assertEquals(null,targetListAfterSharing[0].Sharing_Remark__c);

		List<Opportunity> listOpportunity = [SELECT Id,StageName FROM Opportunity WHERE Id = :openOpportunityBad.Id];	    
		System.assertEquals(1,listOpportunity.size());
		System.assertEquals(GlobalConstants.AUTO_CLOSED,listOpportunity[0].StageName);
	}

	@isTest static void DeleteTargetListAndHasOpenOpportunityThenUpdateOpenOpportunityToAutoClosedAndUpdateSharingInfoInAccount() {
		Target_List__c targetList = new Target_List__c();
		Account account = [SELECT Id, CIS__c,Share_With__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		account.Share_With__c = userBad.Id;
		TriggerHandler.bypass('AccountTriggerHandler');
		update account;
		TriggerHandler.clearbypass('AccountTriggerHandler');

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    targetList.Sharing_Status__c = GlobalConstants.SHARING_WITH_AN;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    AccountShare accountShare = new AccountShare();
		accountShare.AccountId = account.Id;
		accountShare.UserOrGroupId = userBad.Id;
		accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
		accountShare.AccountAccessLevel = 'Edit';
		accountShare.OpportunityAccessLevel = 'Read';
		accountShare.CaseAccessLevel = 'none';
		insert accountShare;

	    Opportunity openOpportunityBad = new Opportunity();
		System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
		    openOpportunityBad.Name = 'openOpp';
		    openOpportunityBad.StageName = GlobalConstants.STOCK_NEGOTIATION;
		    openOpportunityBad.CloseDate = System.today();
		    openOpportunityBad.AccountId = account.Id;
		    insert openOpportunityBad;
		}

		Test.startTest();
			ManageSharing_Service.listAllOpportunityByAccountAndOwner = null;
	    	delete targetList;
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(null,shareAccountAfterSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterSharing = [SELECT Id,Share_with__c,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(0,targetListAfterSharing.size());

		List<Opportunity> listOpportunity = [SELECT Id,StageName FROM Opportunity WHERE Id = :openOpportunityBad.Id];	    
		System.assertEquals(1,listOpportunity.size());
		System.assertEquals(GlobalConstants.AUTO_CLOSED,listOpportunity[0].StageName);
	}

	@isTest static void DeleteTargetListAndHasCallPlanCallReportThenUpdateAllCallPlanCallReportStatusToClosedAndUpdateSharingInfoInAccount() {
		Target_List__c targetList = new Target_List__c();
		Account account = [SELECT Id, CIS__c,Share_With__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		account.Share_With__c = userBad.Id;
		TriggerHandler.bypass('AccountTriggerHandler');
		update account;
		TriggerHandler.clearbypass('AccountTriggerHandler');

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    targetList.Sharing_Status__c = GlobalConstants.SHARING_WITH_AN;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    AccountShare accountShare = new AccountShare();
		accountShare.AccountId = account.Id;
		accountShare.UserOrGroupId = userBad.Id;
		accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
		accountShare.AccountAccessLevel = 'Edit';
		accountShare.OpportunityAccessLevel = 'Read';
		accountShare.CaseAccessLevel = 'none';
		insert accountShare;

	    Call_Report__c openCallPlanBad = new Call_Report__c();
		System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
		    openCallPlanBad.CIS_ID__c = account.Id;
		    openCallPlanBad.Status__c = GlobalConstants.PLAN;
		    openCallPlanBad.Plan_Date__c = System.today();
		    openCallPlanBad.Visit_Objective__c ='Relationship';
		    insert openCallPlanBad;
		}

		Test.startTest();
			ManageSharing_Service.listAllCallPlanCallReportByAccountAndOwner = null;
	    	delete targetList;
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(null,shareAccountAfterSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterSharing = [SELECT Id,Share_with__c,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(0,targetListAfterSharing.size());

		List<Call_Report__c> listCallReport = [SELECT Id,Status__c FROM Call_Report__c WHERE Id = :openCallPlanBad.Id LIMIT 1];	    
		System.assertEquals(1,listCallReport.size());
		System.assertEquals(GlobalConstants.CLOSED,listCallReport[0].Status__c);
	}

	@isTest static void UpdateCampaignEndDateOfLeadSharingThenUpdateLeadSharingExpiredDateInAccount() {
		Target_List__c targetList = new Target_List__c();
		Account account = [SELECT Id, CIS__c,Share_With__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    targetList.Sharing_Status__c = GlobalConstants.SHARING_WITH_AN;
	    insert targetList;

	    Account shareAccountBeforeSharing = [SELECT Id,Share_with__c,Sharing_Status__c,Lead_Sharing_Expired_Date__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(userBad.Id,shareAccountBeforeSharing.Share_with__c);
		System.assertEquals(GlobalConstants.SHARING_WITH_AN,shareAccountBeforeSharing.Sharing_Status__c);
		System.assertEquals(System.today() +5,shareAccountBeforeSharing.Lead_Sharing_Expired_Date__c);

		Test.startTest();
			GlobalUtility.runOnce = false;
			Campaign updateLeadSharing = new Campaign();
			updateLeadSharing.Id = leadSharing.Id; 
	    	updateLeadSharing.EndDate = (System.today() +10);
	    	update updateLeadSharing;
	    Test.stopTest();

	    Account shareAccountAfterSharing = [SELECT Id,Share_with__c,Sharing_Status__c,Lead_Sharing_Expired_Date__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
	    System.assertEquals(userBad.Id,shareAccountAfterSharing.Share_with__c);
		System.assertEquals(GlobalConstants.SHARING_WITH_AN,shareAccountAfterSharing.Sharing_Status__c);
		System.assertEquals(System.today() +10,shareAccountAfterSharing.Lead_Sharing_Expired_Date__c);
	}

	@isTest static void LeadIsSharingAndUpdateCallPlanToCloseAndNoOtherOpenCallPlanAndOtherOpenOppAndTodayLessThanLeadSharingExpiredDateThenDoNothing() {
		Target_List__c targetList = new Target_List__c();
		Account account = [SELECT Id, CIS__c, Lead_Sharing_Expired_Date__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    AccountShare accountShare = new AccountShare();
		accountShare.AccountId = account.Id;
		accountShare.UserOrGroupId = userBad.Id;
		accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
		accountShare.AccountAccessLevel = 'Edit';
		accountShare.OpportunityAccessLevel = 'Read';
		accountShare.CaseAccessLevel = 'none';
		insert accountShare;

	    Call_Report__c openCallPlanBad = new Call_Report__c();

		account.Lead_Sharing_Expired_Date__c = System.today() + 5;
		account.Share_With__c = userBad.Id;
		TriggerHandler.bypass('AccountTriggerHandler');
	    update account;
	    TriggerHandler.clearbypass('AccountTriggerHandler');

		Test.startTest();
			System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
				openCallPlanBad.CIS_ID__c = account.Id;
			    openCallPlanBad.Plan_Date__c = System.today();
			    openCallPlanBad.Visit_Objective__c ='Relationship';
		    	openCallPlanBad.Status__c = GlobalConstants.CONTACTED;
		    	openCallPlanBad.Contact_Firstname__c = 'test share first name';
			    openCallPlanBad.Contact_Lastname__c = 'test share last name';
			    openCallPlanBad.Contact_Phone__c = '1234567890';
		    	insert openCallPlanBad;
		    }
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
		System.assertEquals(1,listAccountShareAfterStopSharing.size());
	}

	@isTest static void LeadIsSharingAndUpdateCallPlanToCloseAndNoOtherOpenCallPlanAndNoOtherOpenOppAndTodayMoreThanLeadSharingExpiredDateThenStopSharingAndUpdateSharingInfoInAccountAndTargetList() {
		Target_List__c targetList = new Target_List__c();
		Account account = [SELECT Id, CIS__c, Lead_Sharing_Expired_Date__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    AccountShare accountShare = new AccountShare();
		accountShare.AccountId = account.Id;
		accountShare.UserOrGroupId = userBad.Id;
		accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
		accountShare.AccountAccessLevel = 'Edit';
		accountShare.OpportunityAccessLevel = 'Read';
		accountShare.CaseAccessLevel = 'none';
		insert accountShare;

		account.Share_With__c = userBad.Id;
		account.Lead_Sharing_Expired_Date__c = System.today() - 5;
		TriggerHandler.bypass('AccountTriggerHandler');
	    update account;
	    TriggerHandler.clearbypass('AccountTriggerHandler');

	    Call_Report__c openCallPlanBad = new Call_Report__c();
	    System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
			Account_Service.callReportRunOnce = false;
			openCallPlanBad.CIS_ID__c = account.Id;
			openCallPlanBad.Plan_Date__c = System.today();
			openCallPlanBad.Visit_Objective__c ='Relationship';
	    	openCallPlanBad.Status__c = GlobalConstants.PLAN;
	    	//openCallPlanBad.Contact_Firstname__c = 'test share first name';
		    //openCallPlanBad.Contact_Lastname__c = 'test share last name';
		    //openCallPlanBad.Contact_Phone__c = '1234567890';
	    	TriggerHandler.bypass('CallReportTriggerHandler');
	    	insert openCallPlanBad;
	    	TriggerHandler.clearbypass('CallReportTriggerHandler');
	    }
		Test.startTest();
		    leadSharing.Status = GlobalConstants.LEAD_EXPIRED;
			TriggerHandler.bypass('CampaignTriggerHandler');
			update leadSharing;
			TriggerHandler.clearbypass('CampaignTriggerHandler');

			ManageSharing_Service.listAllCallPlanCallReportByAccountAndOwner = null;
			System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
				Account_Service.callReportRunOnce = false;
		    	openCallPlanBad.Status__c = GlobalConstants.CONTACTED;
		    	openCallPlanBad.Contact_Firstname__c = 'test share first name';
			    openCallPlanBad.Contact_Lastname__c = 'test share last name';
			    openCallPlanBad.Contact_Phone__c = '1234567890';
		    	update openCallPlanBad;
		    }
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(null,shareAccountAfterSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterSharing = [SELECT Id,Share_with__c,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterSharing.size());
		System.assertEquals(null,targetListAfterSharing[0].Sharing_Status__c);
		System.assertEquals(userBad.Id,targetListAfterSharing[0].Share_with__c);
		System.assertEquals(null,targetListAfterSharing[0].Sharing_Remark__c);
	}

	@isTest static void LeadIsSharingAndUpdateCallPlanToCloseAndHasOtherOpenCallPlanAndOtherOpenOppAndTodayLessThanLeadSharingExpiredDateThenDoNothing() {
		Target_List__c targetList = new Target_List__c();
		List<Call_Report__c> listCallPlan = new List<Call_Report__c>();
		Account account = [SELECT Id, CIS__c, Lead_Sharing_Expired_Date__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    AccountShare accountShare = new AccountShare();
		accountShare.AccountId = account.Id;
		accountShare.UserOrGroupId = userBad.Id;
		accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
		accountShare.AccountAccessLevel = 'Edit';
		accountShare.OpportunityAccessLevel = 'Read';
		accountShare.CaseAccessLevel = 'none';
		insert accountShare;

		account.Lead_Sharing_Expired_Date__c = System.today() + 5;
		account.Share_With__c = userBad.Id;
		TriggerHandler.bypass('AccountTriggerHandler');
	    update account;
	    TriggerHandler.clearbypass('AccountTriggerHandler');

	    Call_Report__c openCallPlanBad_1 = new Call_Report__c();
	    Call_Report__c openCallPlanBad_2 = new Call_Report__c();
		System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
		    openCallPlanBad_1.CIS_ID__c = account.Id;
		    openCallPlanBad_1.Status__c = GlobalConstants.PLAN;
		    openCallPlanBad_1.Plan_Date__c = System.today();
		    openCallPlanBad_1.Visit_Objective__c ='Relationship';
		    listCallPlan.add(openCallPlanBad_1);

		    openCallPlanBad_2.CIS_ID__c = account.Id;
		    openCallPlanBad_2.Status__c = GlobalConstants.PLAN;
		    openCallPlanBad_2.Plan_Date__c = System.today();
		    openCallPlanBad_2.Visit_Objective__c ='Relationship';
		    listCallPlan.add(openCallPlanBad_2);

		    insert listCallPlan;
		}

		account.Lead_Sharing_Expired_Date__c = System.today() - 5;
		TriggerHandler.bypass('AccountTriggerHandler');
	    update account;
	    TriggerHandler.clearbypass('AccountTriggerHandler');

		Test.startTest();
			ManageSharing_Service.listAllCallPlanCallReportByAccountAndOwner = null;
			System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
				Account_Service.callReportRunOnce = false;
		    	openCallPlanBad_1.Status__c = GlobalConstants.CONTACTED;
		    	openCallPlanBad_1.Contact_Firstname__c = 'test share first name';
			    openCallPlanBad_1.Contact_Lastname__c = 'test share last name';
			    openCallPlanBad_1.Contact_Phone__c = '1234567890';
		    	update openCallPlanBad_1;
		    }
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
		System.assertEquals(1,listAccountShareAfterStopSharing.size());
	}

	@isTest static void LeadIsSharingAndUpdateOpportunityToCloseAndNoOtherOpenCallPlanAndOtherOpenOppAndTodayLessThanLeadSharingExpiredDateThenDoNothing() {
		Target_List__c targetList = new Target_List__c();
		Account account = [SELECT Id, CIS__c, Lead_Sharing_Expired_Date__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    AccountShare accountShare = new AccountShare();
		accountShare.AccountId = account.Id;
		accountShare.UserOrGroupId = userBad.Id;
		accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
		accountShare.AccountAccessLevel = 'Edit';
		accountShare.OpportunityAccessLevel = 'Read';
		accountShare.CaseAccessLevel = 'none';
		insert accountShare;

	    Opportunity openOppBad = new Opportunity();

		account.Lead_Sharing_Expired_Date__c = System.today() + 5;
		account.Share_With__c = userBad.Id;
		TriggerHandler.bypass('AccountTriggerHandler');
	    update account;
	    TriggerHandler.clearbypass('AccountTriggerHandler');

		Test.startTest();
			System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
			    openOppBad.Name = 'openOppBad';
			    openOppBad.StageName = GlobalConstants.CLOSE_LOST;
			    openOppBad.CloseDate = System.today();
			    openOppBad.AccountId = account.Id;
			    insert openOppBad;
			}
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
		System.assertEquals(1,listAccountShareAfterStopSharing.size());
	}

	@isTest static void LeadIsSharingAndUpdateOpportunityToCloseAndNoOtherOpenCallPlanAndNoOtherOpenOppAndTodayMoreThanLeadSharingExpiredDateThenStopSharingAndUpdateSharingInfoInAccountAndTargetList() {
		Target_List__c targetList = new Target_List__c();
		Account account = [SELECT Id, CIS__c, Lead_Sharing_Expired_Date__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    AccountShare accountShare = new AccountShare();
		accountShare.AccountId = account.Id;
		accountShare.UserOrGroupId = userBad.Id;
		accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
		accountShare.AccountAccessLevel = 'Edit';
		accountShare.OpportunityAccessLevel = 'Read';
		accountShare.CaseAccessLevel = 'none';
		insert accountShare;

		account.Share_With__c = userBad.Id;
		TriggerHandler.bypass('AccountTriggerHandler');
	    update account;
	    TriggerHandler.clearbypass('AccountTriggerHandler');

	    Opportunity openOppBad = new Opportunity();

		account.Lead_Sharing_Expired_Date__c = System.today() - 5;
		TriggerHandler.bypass('AccountTriggerHandler');
	    update account;
	    TriggerHandler.clearbypass('AccountTriggerHandler');

		Test.startTest();
			System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
				openOppBad.Name = 'openOppBad';
			    openOppBad.StageName = GlobalConstants.CLOSE_LOST;
			    openOppBad.CloseDate = System.today();
			    openOppBad.AccountId = account.Id;
			    insert openOppBad;
		    }
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(null,shareAccountAfterSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterSharing = [SELECT Id,Share_with__c,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterSharing.size());
		System.assertEquals(null,targetListAfterSharing[0].Sharing_Status__c);
		System.assertEquals(userBad.Id,targetListAfterSharing[0].Share_with__c);
		System.assertEquals(null,targetListAfterSharing[0].Sharing_Remark__c);
	}

	@isTest static void LeadIsSharingAndUpdateOpportunityToCloseAndHasOtherOpenOppAndTodayMoreThanLeadSharingExpiredDateThenDoNothing() {
		Target_List__c targetList = new Target_List__c();
		List<Opportunity> listOpp = new List<Opportunity>();
		Account account = [SELECT Id, CIS__c, Lead_Sharing_Expired_Date__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    AccountShare accountShare = new AccountShare();
		accountShare.AccountId = account.Id;
		accountShare.UserOrGroupId = userBad.Id;
		accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
		accountShare.AccountAccessLevel = 'Edit';
		accountShare.OpportunityAccessLevel = 'Read';
		accountShare.CaseAccessLevel = 'none';
		insert accountShare;

		account.Lead_Sharing_Expired_Date__c = System.today() + 5;
		account.Share_With__c = userBad.Id;
		TriggerHandler.bypass('AccountTriggerHandler');
	    update account;
	    TriggerHandler.clearbypass('AccountTriggerHandler');

	    Opportunity openOppBad_1 = new Opportunity();
	    Opportunity openOppBad_2 = new Opportunity();
		System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
		    openOppBad_1.Name = 'closedOpp';
		    openOppBad_1.StageName = GlobalConstants.STOCK_NEGOTIATION;
		    openOppBad_1.CloseDate = System.today();
		    openOppBad_1.AccountId = account.Id;
		    listOpp.add(openOppBad_1);

		    openOppBad_2.Name = 'closedOpp';
		    openOppBad_2.StageName = GlobalConstants.STOCK_NEGOTIATION;
		    openOppBad_2.CloseDate = System.today();
		    openOppBad_2.AccountId = account.Id;
		    listOpp.add(openOppBad_2);

		    insert listOpp;
		}

		account.Lead_Sharing_Expired_Date__c = System.today() - 5;
		TriggerHandler.bypass('AccountTriggerHandler');
	    update account;
	    TriggerHandler.clearbypass('AccountTriggerHandler');

		Test.startTest();
			ManageSharing_Service.listAllOpportunityByAccountAndOwner = null;
			System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
			    openOppBad_1.StageName = GlobalConstants.CLOSE_LOST;
			    update openOppBad_1;
		    }
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
		System.assertEquals(1,listAccountShareAfterStopSharing.size());
	}

	@isTest static void CampaignExpiredAndTargetListHasNoOpenCallPlanAndNoOpenOpportunityThenDeleteSharingAndUpdateSharingInfo() {
		Target_List__c targetList = new Target_List__c();
		Account account = [SELECT Id, CIS__c, Lead_Sharing_Expired_Date__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    insert targetList;

		Test.startTest();
			leadSharing.Status = GlobalConstants.EXPIRE_PROCESS;
			leadSharing.EndDate = System.today() -1;
			update leadSharing;
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		Account shareAccountAfterSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(null,shareAccountAfterSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterSharing = [SELECT Id,Share_with__c,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterSharing.size());
		System.assertEquals(null,targetListAfterSharing[0].Sharing_Status__c);
		System.assertEquals(true,targetListAfterSharing[0].Sharing_Completed__c);
		System.assertEquals(userBad.Id,targetListAfterSharing[0].Share_with__c);
		System.assertEquals(null,targetListAfterSharing[0].Sharing_Remark__c);
	}

	@isTest static void LeadIsSharingHasCallPlanAndTodayMoreThanLeadSharingExpiredDateAndLastCallOpptyMoreThan90DaysThenUpdateCallPlanToCloseAndDeleteSharingAndUpdateSharingInfo() {
		Target_List__c targetList = new Target_List__c();
		Account account = [SELECT Id, CIS__c, Lead_Sharing_Expired_Date__c,Owner_Profile__c,Ownership_Text__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		account.Owner_Profile__c = 'SME-TM';
		account.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
		TriggerHandler.bypass('AccountTriggerHandler');
		update account;
		TriggerHandler.clearbypass('AccountTriggerHandler');

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		//leadSharing.Status = GlobalConstants.LEAD_EXPIRED;
		//leadSharing.IsActive = false;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    AccountShare accountShare = new AccountShare();
		accountShare.AccountId = account.Id;
		accountShare.UserOrGroupId = userBad.Id;
		accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
		accountShare.AccountAccessLevel = 'Edit';
		accountShare.OpportunityAccessLevel = 'Read';
		accountShare.CaseAccessLevel = 'none';
		insert accountShare;

		account.Lead_Sharing_Expired_Date__c = System.today() - 1;
		account.Sharing_Status__c = GlobalConstants.SHARING_WITH_AN;
		account.Share_With__c = userBad.Id;
		TriggerHandler.bypass('AccountTriggerHandler');
	    update account;
	    TriggerHandler.clearbypass('AccountTriggerHandler');

	    Call_Report__c openCallPlanBad_1 = new Call_Report__c();
	    System.runAs(userBad){
	    	openCallPlanBad_1.CIS_ID__c = account.Id;
		    openCallPlanBad_1.Status__c = GlobalConstants.PLAN;
		    openCallPlanBad_1.Plan_Date__c = System.today();
		    openCallPlanBad_1.Visit_Objective__c ='Relationship';
	    	insert openCallPlanBad_1;
	    }

		Test.startTest();

		    leadSharing.Status = GlobalConstants.LEAD_EXPIRED;
			TriggerHandler.bypass('CampaignTriggerHandler');
			update leadSharing;
			TriggerHandler.clearbypass('CampaignTriggerHandler');

			//ManageSharing_Service.listAllCallPlanCallReportByAccountAndOwner = null;
			//System.runAs([SELECT Id FROM User WHERE Firstname=:tmANUser_1_FirstName LIMIT 1][0]){
			//	Account_Service.callReportRunOnce = false;
		 //   	openCallPlanBad_1.Status__c = GlobalConstants.CONTACTED;
		 //   	openCallPlanBad_1.Contact_Firstname__c = 'test share first name';
			//    openCallPlanBad_1.Contact_Lastname__c = 'test share last name';
			//    openCallPlanBad_1.Contact_Phone__c = '1234567890';
			//    TriggerHandler.bypass('CallReportTriggerHandler');
		 //   	update openCallPlanBad_1;
		 //   	TriggerHandler.clearbypass('CallReportTriggerHandler');
		 //   }

			account.Last_CallReprt_Opty_Updated_Date__c = System.now().addDays((-2) * Integer.valueOf(Label.Release_Customer_Ownership_for_Call_Plan_Call_Report_ME));
			TriggerHandler.bypass('AccountTriggerHandler');
		    update account;
		    TriggerHandler.clearbypass('AccountTriggerHandler');

		    ManageSharing_Service.listAllCallPlanCallReportByAccountAndOwner = null;
			Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		List<Call_Report__c> listCallReport = [SELECT Id,Status__c FROM Call_Report__c WHERE Id = :openCallPlanBad_1.Id LIMIT 1];	    
		System.assertEquals(1,listCallReport.size());
		System.assertEquals(GlobalConstants.CLOSED,listCallReport[0].Status__c);

		Account shareAccountAfterSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Id = :account.Id LIMIT 1];
		System.assertEquals(null,shareAccountAfterSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterSharing = [SELECT Id,Share_with__c,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterSharing.size());
		System.assertEquals(null,targetListAfterSharing[0].Sharing_Status__c);
		System.assertEquals(userBad.Id,targetListAfterSharing[0].Share_with__c);
		System.assertEquals(GlobalConstants.AUTO_CLOSED,targetListAfterSharing[0].Status__c);
		System.assertEquals(Label.LeadSharing_CallReport_Opp_not_updated,targetListAfterSharing[0].Sharing_Remark__c);
	}

	@isTest static void LeadIsSharingHasOpportunityAndTodayMoreThanLeadSharingExpiredDateAndLastCallOpptyMoreThan90DaysThenUpdateOpportunityToAutoCloseAndDeleteSharingAndUpdateSharingInfo() {
		Target_List__c targetList = new Target_List__c();
		Account account = [SELECT Id, CIS__c, Lead_Sharing_Expired_Date__c FROM Account WHERE Name = :accountNameRM];
		User userBad = [SELECT Id FROM User WHERE Firstname = :tmANUser_1_FirstName];

		account.Owner_Profile__c = 'SME-TM';
		account.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
		TriggerHandler.bypass('AccountTriggerHandler');
		update account;
		TriggerHandler.clearbypass('AccountTriggerHandler');

		Campaign leadSharing = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadSharing', System.now().addDays(-1), System.now().addDays(5), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES,null);
		leadSharing.Sharing__c = GlobalConstants.LEAD_SHARING;
		leadSharing.Status = GlobalConstants.LEAD_EXPIRED;
		leadSharing.IsActive = false;
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadSharing;
		TriggerHandler.clearbypass('CampaignTriggerHandler');

		targetList.Lead_Campaign__c = leadSharing.Id;
	    targetList.CIS_ID_Prospect_Name__c = account.Id;
	    targetList.Status__c = GlobalConstants.STATUS_NEW;
	    targetList.Share_With__c = userBad.Id;
	    TriggerHandler.bypass('TargetListTriggerHandler');
	    insert targetList;
	    TriggerHandler.clearbypass('TargetListTriggerHandler');

	    AccountShare accountShare = new AccountShare();
		accountShare.AccountId = account.Id;
		accountShare.UserOrGroupId = userBad.Id;
		accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
		accountShare.AccountAccessLevel = 'Edit';
		accountShare.OpportunityAccessLevel = 'Read';
		accountShare.CaseAccessLevel = 'none';
		insert accountShare;

		account.Lead_Sharing_Expired_Date__c = System.today() - 1;
		account.Sharing_Status__c = GlobalConstants.SHARING_WITH_AN;
		account.Share_With__c = userBad.Id;
		TriggerHandler.bypass('AccountTriggerHandler');
	    update account;
	    TriggerHandler.clearbypass('AccountTriggerHandler');

	    Opportunity openOppBad = new Opportunity();
	    System.runAs(userBad){
			openOppBad.Name = 'openOppBad';
		    openOppBad.StageName = GlobalConstants.STOCK_NEGOTIATION;
		    openOppBad.CloseDate = System.today();
		    openOppBad.AccountId = account.Id;
		    insert openOppBad;
	    }

		Test.startTest();

			leadSharing.Status = GlobalConstants.LEAD_EXPIRED;
			TriggerHandler.bypass('CampaignTriggerHandler');
			update leadSharing;
			TriggerHandler.clearbypass('CampaignTriggerHandler');
			

			account.Last_CallReprt_Opty_Updated_Date__c = System.now().addDays((-2) * Integer.valueOf(Label.Release_Customer_Ownership_for_Call_Plan_Call_Report_ME));
			TriggerHandler.bypass('AccountTriggerHandler');
		    update account;
		    TriggerHandler.clearbypass('AccountTriggerHandler');

		    ManageSharing_Service.listAllOpportunityByAccountAndOwner = null;
			Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
	    Test.stopTest();

	    List<AccountShare> listAccountShareAfterStopSharing = [SELECT Id FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :userBad.Id AND RowCause = 'Manual'];
		System.assertEquals(0,listAccountShareAfterStopSharing.size());

		List<Opportunity> listOpportunity = [SELECT Id,StageName FROM Opportunity WHERE Id = :openOppBad.Id LIMIT 1];	    
		System.assertEquals(1,listOpportunity.size());
		System.assertEquals(GlobalConstants.AUTO_CLOSED,listOpportunity[0].StageName);

		Account shareAccountAfterSharing = [SELECT Id,Share_with__c,Sharing_Status__c FROM Account WHERE Name = :accountNameRM LIMIT 1];
		System.assertEquals(null,shareAccountAfterSharing.Share_with__c);
		System.assertEquals(null,shareAccountAfterSharing.Sharing_Status__c);

		List<Target_List__c> targetListAfterSharing = [SELECT Id,Share_with__c,Status__c,Sharing_Status__c,Sharing_Completed__c,Sharing_Remark__c FROM Target_List__c WHERE Id = :targetList.Id LIMIT 1];
		System.assertEquals(1,targetListAfterSharing.size());
		System.assertEquals(null,targetListAfterSharing[0].Sharing_Status__c);
		System.assertEquals(userBad.Id,targetListAfterSharing[0].Share_with__c);
		System.assertEquals(GlobalConstants.AUTO_CLOSED,targetListAfterSharing[0].Status__c);
		System.assertEquals(Label.LeadSharing_CallReport_Opp_not_updated,targetListAfterSharing[0].Sharing_Remark__c);
	}
	
}