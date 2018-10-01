@isTest
private class OpportunityLead_Test {
	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    public static Map<String,String> mapStageOppWithTranslatedValue = new Map<String,String>();

	@testSetup static void setupUser(){
		TriggerHandler.bypass('UserTriggerHandler');
		Mockup_Test mt = new Mockup_Test().setUpTest();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        TriggerHandler.clearBypass('UserTriggerHandler');
	}

	public static Map<String,String> mockDataForNewOppStage (String campaignType, Boolean campaignIsActive, Boolean hasTargetList, String campaignStatus){
		Map<String,String> resultIdMap = new Map<String,String>();
		
		Account targetAccount = [SELECT Id, OwnerId FROM Account WHERE Name = :OpportunityLead_Test.accountNameRM LIMIT 1];
		resultIdMap.put('accountId',targetAccount.Id);

        Campaign mockCampaign = Mockup_Test.newCampaign(UserInfo.getUserId(),'CampanignTest', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-2), campaignStatus, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES);
        if(campaignIsActive || campaignStatus == GlobalConstants.ACTIVE) {
        	mockCampaign.IsActive = true;
        	mockCampaign.StartDate = System.today() - 1;
        } else {
        	mockCampaign.IsActive = false;
        	mockCampaign.StartDate = System.today() + 1;
        }
        insert mockCampaign;
		resultIdMap.put('campaignId',mockCampaign.Id);
		
		if(hasTargetList){
			Target_List__c mockTargetList = new Target_List__c();
			mockTargetList.Lead_Campaign__c = mockCampaign.Id;
			mockTargetList.CIS_ID_Prospect_Name__c = targetAccount.Id;
			mockTargetList.Status__c = GlobalConstants.STATUS_NEW;
			insert mockTargetList;
			resultIdMap.put('targetListId',mockTargetList.Id);
		}		

		List<Schema.PicklistEntry> picklistValues = Opportunity.StageName.getDescribe().getPicklistValues();

		for (Schema.PicklistEntry pe: picklistValues) {
			mapStageOppWithTranslatedValue.put(pe.getValue(), pe.getLabel());
		}

		return resultIdMap;
	}
  /*Being of NewOpportunity_Stage Test LEAD_FOR_SALES */
	@isTest static void testStatus_LeadForSale_NewOpportunity_StageStockNegotiation() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		
		Test.startTest();
			Opportunity targetOpportunity = Mockup_Test.newOpportunity(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
			insert targetOpportunity;
		Test.stopTest();

		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		// WORKFLOW Update to "Stage 2: Create Write Up"
		System.assertEquals(GlobalConstants.STOCK_NEGOTIATION ,actualOppLead.Opportunity_Lead_Status__c);
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.STOCK_NEGOTIATION) ,actualOppLead.Status__c);
	}

	@isTest static void testStatus_LeadForSale_NewOpportunity_StageCreateWriteUp() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		
		Test.startTest();
			Opportunity targetOpportunity = Mockup_Test.newOpportunityWithAppHis(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			//insert targetOpportunity;
		Test.stopTest();

		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c,Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.CREATE_WRITE_UP ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.CREATE_WRITE_UP) ,actualOppLead.Status__c);
	}

	@isTest static void testStatus_LeadForSale_NewOpportunity_StageWaitingForCreditApproval() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		
		Test.startTest();
			Opportunity targetOpportunity = Mockup_Test.newOpportunityWithAppHis(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.WAITING_FOR_CREDIT_APPROVAL, GlobalConstants.NON_CMAS);
			//insert targetOpportunity;
			targetOpportunity.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
			update targetOpportunity;
		Test.stopTest();

		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.WAITING_FOR_CREDIT_APPROVAL ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.WAITING_FOR_CREDIT_APPROVAL) ,actualOppLead.Status__c);
	}

	@isTest static void testStatus_LeadForSale_NewOpportunity_StageCaseIsRejected() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		
		Test.startTest();
			Opportunity targetOpportunity = Mockup_Test.newOpportunityWithAppHis(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
			//insert targetOpportunity;
			targetOpportunity.StageName = GlobalConstants.CASE_IS_REJECT;
			update targetOpportunity;
		Test.stopTest();

		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.CASE_IS_REJECT ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.CASE_IS_REJECT) ,actualOppLead.Status__c);
	}

	@isTest static void testStatus_LeadForSale_NewOpportunity_StageWaitingForCreditSetup() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		
		Test.startTest();
			Opportunity targetOpportunity = Mockup_Test.newOpportunityWithAppHis(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
			//insert targetOpportunity;
			targetOpportunity.StageName = GlobalConstants.WAITING_FOR_CREDIT_SETUP;
			update targetOpportunity;
		Test.stopTest();

		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.WAITING_FOR_CREDIT_SETUP ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.WAITING_FOR_CREDIT_SETUP) ,actualOppLead.Status__c);
	}	

	@isTest static void testStatus_LeadForSale_NewOpportunity_StagePartialLoanSetup() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		
		Test.startTest();
			Opportunity targetOpportunity = Mockup_Test.newOpportunityWithAppHis(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
			//insert targetOpportunity;
			targetOpportunity.StageName = GlobalConstants.PARTIAL_LOAN_SETUP;
		Test.stopTest();

		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		// WORK FLOW Update to "Stage 5: Waiting for Credit Setup"
		System.assertEquals(GlobalConstants.CREATE_WRITE_UP ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.CREATE_WRITE_UP) ,actualOppLead.Status__c);
	}

	@isTest static void testStatus_LeadForSale_NewOpportunity_StageClosedWon() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		TriggerHandler.bypass('CampaignTriggerHandler');
		TriggerHandler.bypass('TargetListTriggerHandler');
		TriggerHandler.bypass('ContactTriggerHandler');
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		
		Test.startTest();
			Opportunity targetOpportunity = Mockup_Test.newOpportunityWithAppHis(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			targetOpportunity.StageName = GlobalConstants.ALL_LOAN_SETUP;
			update targetOpportunity;
		Test.stopTest();
		TriggerHandler.clearAllBypasses();
		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.ALL_LOAN_SETUP ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.ALL_LOAN_SETUP) ,actualOppLead.Status__c);
	}

	@isTest static void testStatus_LeadForSale_NewOpportunity_StageClosedLost() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		Opportunity targetOpportunity;
		Test.startTest();
			targetOpportunity = Mockup_Test.newOpportunity(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.CLOSE_LOST, GlobalConstants.NON_CMAS);
			targetOpportunity.Lost_reason__c = 'สนใจแต่ติดปัญหาเรื่องหลักประกัน';
			insert targetOpportunity;
		Test.stopTest();
		TriggerHandler.bypass('OpportunityTriggerHandler');
		targetOpportunity.StageName = GlobalConstants.CLOSE_LOST;
		update targetOpportunity;
		TriggerHandler.clearbypass('OpportunityTriggerHandler');
		
		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.CLOSE_LOST ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.CLOSE_LOST) ,actualOppLead.Status__c);
	}

	@isTest static void testStatus_LeadForSale_NewOpportunity_StageAutoClosed() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		
		Test.startTest();
			Opportunity targetOpportunity = Mockup_Test.newOpportunity(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.AUTO_CLOSED, GlobalConstants.NON_CMAS);
			insert targetOpportunity;
		Test.stopTest();

		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.AUTO_CLOSED ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.AUTO_CLOSED) ,actualOppLead.Status__c);
	}
 /* End of NewOpportunity_Stage Test LEAD_FOR_SALES */

  /*Being of UpdateOpportunity_Stage Test LEAD_FOR_SALES */
	@isTest static void testStatus_LeadForSale_UpdateOpp_StageStockNegotiation_ToCreateWriteUp() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		TriggerHandler.bypass('CampaignTriggerHandler');
		TriggerHandler.bypass('TargetListTriggerHandler');
		TriggerHandler.bypass('ContactTriggerHandler');
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		TriggerHandler.clearAllBypasses();
		Opportunity targetOpportunity = Mockup_Test.newOpportunity(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
		insert targetOpportunity;

		Test.startTest();
			targetOpportunity.StageName = GlobalConstants.CREATE_WRITE_UP;
			update targetOpportunity;
		Test.stopTest();

		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.CREATE_WRITE_UP ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.CREATE_WRITE_UP) ,actualOppLead.Status__c);
	}

	@isTest static void testStatus_LeadForSale_UpdateOpp_StageCreateWriteUp_ToWaitingForCreditApproval() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		TriggerHandler.bypass('CampaignTriggerHandler');
		TriggerHandler.bypass('TargetListTriggerHandler');
		TriggerHandler.bypass('ContactTriggerHandler');
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		TriggerHandler.clearAllBypasses();
		Opportunity targetOpportunity = Mockup_Test.newOpportunity(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
		insert targetOpportunity;

		Test.startTest();
			targetOpportunity.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
			update targetOpportunity;
		Test.stopTest();

		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c,Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.WAITING_FOR_CREDIT_APPROVAL ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.WAITING_FOR_CREDIT_APPROVAL) ,actualOppLead.Status__c);
	}

	@isTest static void testStatus_LeadForSale_UpdateOpp_StageWaitingForCreditApproval_ToCaseIsRejected() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		TriggerHandler.bypass('CampaignTriggerHandler');
		TriggerHandler.bypass('TargetListTriggerHandler');
		TriggerHandler.bypass('ContactTriggerHandler');
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		
		Opportunity targetOpportunity = Mockup_Test.newOpportunityWithAppHis(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.WAITING_FOR_CREDIT_APPROVAL, GlobalConstants.NON_CMAS);

		Test.startTest();
			targetOpportunity.StageName = GlobalConstants.CASE_IS_REJECT;
			update targetOpportunity;
		Test.stopTest();
		TriggerHandler.clearAllBypasses();
		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.CASE_IS_REJECT ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.CASE_IS_REJECT) ,actualOppLead.Status__c);
	}

	@isTest static void testStatus_LeadForSale_UpdateOpp_StageCaseIsRejected_ToWaitingForCreditSetup() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		TriggerHandler.bypass('CampaignTriggerHandler');
		TriggerHandler.bypass('TargetListTriggerHandler');
		TriggerHandler.bypass('ContactTriggerHandler');
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		TriggerHandler.clearAllBypasses();
		Opportunity targetOpportunity = Mockup_Test.newOpportunityWithAppHis(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);

		Test.startTest();
			targetOpportunity.StageName = GlobalConstants.WAITING_FOR_CREDIT_SETUP;
			update targetOpportunity;
		Test.stopTest();

		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.WAITING_FOR_CREDIT_SETUP ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.WAITING_FOR_CREDIT_SETUP) ,actualOppLead.Status__c);
	}

	@isTest static void testStatus_LeadForSale_UpdateOpp_StageWaitingForCreditSetup_ToPartialLoanSetup() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		TriggerHandler.bypass('CampaignTriggerHandler');
		TriggerHandler.bypass('TargetListTriggerHandler');
		TriggerHandler.bypass('ContactTriggerHandler');
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		TriggerHandler.clearAllBypasses();
		Opportunity targetOpportunity = Mockup_Test.newOpportunityWithAppHis(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
		//insert targetOpportunity;		
		Test.startTest();
			targetOpportunity.StageName = GlobalConstants.PARTIAL_LOAN_SETUP;
			update targetOpportunity;
		Test.stopTest();

		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.PARTIAL_LOAN_SETUP ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.PARTIAL_LOAN_SETUP) ,actualOppLead.Status__c);
	}	

	@isTest static void testStatus_LeadForSale_UpdateOpp_StagePartialLoanSetup_ToAllLoanSetup() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		TriggerHandler.bypass('CampaignTriggerHandler');
		TriggerHandler.bypass('TargetListTriggerHandler');
		TriggerHandler.bypass('ContactTriggerHandler');
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		TriggerHandler.clearAllBypasses();
		Opportunity targetOpportunity = Mockup_Test.newOpportunityWithAppHis(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
		//insert targetOpportunity;
		TriggerHandler.clearAllBypasses();
		Test.startTest();
			targetOpportunity.StageName = GlobalConstants.ALL_LOAN_SETUP;
			update targetOpportunity;
		Test.stopTest();

		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.ALL_LOAN_SETUP ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.ALL_LOAN_SETUP) ,actualOppLead.Status__c);
	}

	@isTest static void testStatus_LeadForSale_UpdateOpp_StageAllLoanSetup_ToClosedLost() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		TriggerHandler.bypass('CampaignTriggerHandler');
		TriggerHandler.bypass('TargetListTriggerHandler');
		TriggerHandler.bypass('ContactTriggerHandler');
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		Opportunity targetOpportunity = Mockup_Test.newOpportunityWithAppHis(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
		targetOpportunity.StageName = GlobalConstants.ALL_LOAN_SETUP;
		update targetOpportunity;
		Test.startTest();
			targetOpportunity.StageName = GlobalConstants.CLOSE_LOST;
			targetOpportunity.Lost_reason__c = 'สนใจแต่ติดปัญหาเรื่องหลักประกัน';
			update targetOpportunity;
		Test.stopTest();
		TriggerHandler.clearAllBypasses();
		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.CLOSE_LOST ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.CLOSE_LOST) ,actualOppLead.Status__c);
	}

	@isTest static void testStatus_LeadForSale_UpdateOpp_StageClosedLost_ToWaitingForCreditSetup() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		TriggerHandler.bypass('CampaignTriggerHandler');
		TriggerHandler.bypass('TargetListTriggerHandler');
		TriggerHandler.bypass('ContactTriggerHandler');
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		
		Opportunity targetOpportunity = Mockup_Test.newOpportunityWithAppHis(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
		targetOpportunity.Lost_reason__c = 'สนใจแต่ติดปัญหาเรื่องหลักประกัน';
		targetOpportunity.StageName = GlobalConstants.CLOSE_LOST;
		update targetOpportunity;

		Test.startTest();
			targetOpportunity.StageName = GlobalConstants.WAITING_FOR_CREDIT_SETUP;
			targetOpportunity.Lost_reason__c = '';
			update targetOpportunity;
		Test.stopTest();
		TriggerHandler.clearAllBypasses();
		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.WAITING_FOR_CREDIT_SETUP ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.WAITING_FOR_CREDIT_SETUP) ,actualOppLead.Status__c);
	}
	// Current Fixing
	@isTest static void testStatus_LeadForSale_UpdateOpportunity_StageAutoClosed_ToCaseIsRejected() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		TriggerHandler.bypass('CampaignTriggerHandler');
		TriggerHandler.bypass('TargetListTriggerHandler');
		TriggerHandler.bypass('ContactTriggerHandler');
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		TriggerHandler.clearAllBypasses();
		//Opportunity targetOpportunity = Mockup_Test.newOpportunity(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.AUTO_CLOSED, GlobalConstants.NON_CMAS);
		//insert targetOpportunity;
		Opportunity targetOpportunity = Mockup_Test.newOpportunityWithAppHis(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.AUTO_CLOSED, GlobalConstants.NON_CMAS);
		Test.startTest();
			targetOpportunity.StageName = GlobalConstants.CASE_IS_REJECT;
			update targetOpportunity;
		Test.stopTest();

		System.assertEquals(1 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Opportunity_Lead__c actualOppLead = [SELECT Id, Opportunity_Lead_Status__c, Status__c FROM Opportunity_Lead__c WHERE Opportunity__c = :targetOpportunity.Id];
		System.assertEquals(GlobalConstants.CASE_IS_REJECT ,actualOppLead.Opportunity_Lead_Status__c);		
		//System.assertEquals(mapStageOppWithTranslatedValue.get(GlobalConstants.CASE_IS_REJECT) ,actualOppLead.Status__c);
	}
 /* End of UpdateOpportunity_Stage Test LEAD_FOR_SALES */

/* Being of NewOpportunity_Stage NegativeCase Test LEAD_FOR_SALES */
 @isTest static void testStatus_LeadForSale_NewOpportunity_Negative_InActive_StageStockNegotiation() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = false, hasTargetList = true;
		String campaignStatus = GlobalConstants.PLANNED;
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		Test.startTest();
			Opportunity targetOpportunity = Mockup_Test.newOpportunity(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.STOCK_NEGOTIATION, GlobalConstants.NON_CMAS);
			insert targetOpportunity;
		Test.stopTest();

		System.assertEquals(0 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Target_List__c actualTarget = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :mockIdMap.get('accountId') LIMIT 1];
		System.assertEquals(GlobalConstants.STATUS_NEW ,actualTarget.Status__c);
	}

	@isTest static void testStatus_LeadForSale_NewOpportunity_Negative_Expired_StageCreateWriteUp() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = false, hasTargetList = true;
		String campaignStatus = GlobalConstants.EXPIRED;
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		
		Test.startTest();
			Opportunity targetOpportunity = Mockup_Test.newOpportunity(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			insert targetOpportunity;
		Test.stopTest();

		System.assertEquals(0 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Target_List__c actualTarget = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :mockIdMap.get('accountId') LIMIT 1];
		System.assertEquals(GlobalConstants.STATUS_NEW ,actualTarget.Status__c);
	}

	@isTest static void testStatus_LeadForSale_NewOpportunity_Negative_NoTargetList_StageWaitingForCreditApproval() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = false;
		String campaignStatus = GlobalConstants.ACTIVE;
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		
		Test.startTest();
			Opportunity targetOpportunity = Mockup_Test.newOpportunity(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.WAITING_FOR_CREDIT_APPROVAL, GlobalConstants.NON_CMAS);
			insert targetOpportunity;
		Test.stopTest();

		System.assertEquals(0 ,[SELECT Count() FROM Opportunity_Lead__c]);
	}

	@isTest static void testStatus_LeadForSale_NewOpportunity_Negative_ExpiredStageCaseIsRejected() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = false, hasTargetList = true;
		String campaignStatus = GlobalConstants.EXPIRED;
		mockIdMap = mockDataForNewOppStage(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		
		Test.startTest();
			Opportunity targetOpportunity = Mockup_Test.newOpportunity(mockIdMap.get('accountId'), 'OppTest1', GlobalConstants.CASE_IS_REJECT, GlobalConstants.NON_CMAS);
			insert targetOpportunity;
		Test.stopTest();

		System.assertEquals(0 ,[SELECT Count() FROM Opportunity_Lead__c]);
		Target_List__c actualTarget = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :mockIdMap.get('accountId') LIMIT 1];
		System.assertEquals(GlobalConstants.STATUS_NEW ,actualTarget.Status__c);
	}
/* End of NewOpportunity_Stage NegativeCase Test LEAD_FOR_SALES */
}