@isTest
public class SME_ActiveTargetListInitial_Test {
	
	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    public static String leadForSales = 'leadForSales';
    public static String leadForSalesExpired = 'leadForSalesExpired';
    public static String leadForSalesCancel = 'leadForSalesCancel';

    public static String leadToDo = 'leadToDo';
    public static String leadToDoExpired = 'leadToDoExpired';
    public static String leadToDoCancel = 'leadToDoCancel';

    public static String campaign = 'campaign';
    public static String campaignExpired = 'campaignExpired';
    public static String campaignCancel = 'campaignCancel';
    
    @testSetup static void setup(){
    	TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test mt = new Mockup_Test().setUpTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            SME_ActiveTargetListInitial_Test.setupLeadAndCampaign();
        }
        TriggerHandler.clearBypass('UserTriggerHandler');
    }

    public static void setupLeadAndCampaign(){
    	List<Campaign> leadToInsertList = new List<Campaign>();
    	
    	Campaign mockLeadForSale = new Campaign();
		mockLeadForSale.Lead_Campaign_Event_Code__c = leadForSales;
		mockLeadForSale.Type__c = GlobalConstants.LEAD_FOR_SALES;
		mockLeadForSale.Name = leadForSales;
		mockLeadForSale.Status = GlobalConstants.ACTIVE;
		mockLeadForSale.IsActive = true;
		mockLeadForSale.StartDate = System.today() - 1;
		mockLeadForSale.EndDate = System.Today() + 1;
		mockLeadForSale.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
		leadToInsertList.add(mockLeadForSale); 

		Campaign mockLeadToDo = new Campaign();
		mockLeadToDo.Lead_Campaign_Event_Code__c = leadToDo;
		mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
		mockLeadToDo.Sub_Type__c = 'เพื่อทราบ';
		mockLeadToDo.Name = leadToDo;
		mockLeadToDo.Status = GlobalConstants.ACTIVE;
		mockLeadToDo.IsActive = true;
		mockLeadToDo.StartDate = System.today() - 1;
		mockLeadToDo.EndDate = System.Today() + 1;
		mockLeadToDo.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
		leadToInsertList.add(mockLeadToDo);

		Campaign mockLeadForSaleExpired = new Campaign();
      	mockLeadForSaleExpired.Lead_Campaign_Event_Code__c = leadForSalesExpired;
      	mockLeadForSaleExpired.Type__c = GlobalConstants.LEAD_FOR_SALES;
      	mockLeadForSaleExpired.Name = leadForSalesExpired;
      	mockLeadForSaleExpired.Status = GlobalConstants.EXPIRED;
      	mockLeadForSaleExpired.IsActive = false;
      	mockLeadForSaleExpired.StartDate = System.today() - 1;
      	mockLeadForSaleExpired.EndDate = System.Today() - 1;
      	mockLeadForSaleExpired.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
      	leadToInsertList.add(mockLeadForSaleExpired); 

      	Campaign mockLeadForSaleCancel = new Campaign();
      	mockLeadForSaleCancel.Lead_Campaign_Event_Code__c = leadForSalesCancel;
      	mockLeadForSaleCancel.Type__c = GlobalConstants.LEAD_FOR_SALES;
      	mockLeadForSaleCancel.Name = leadForSalesCancel;
      	mockLeadForSaleCancel.Status = GlobalConstants.CANCEL;
      	mockLeadForSaleCancel.IsActive = false;
      	mockLeadForSaleCancel.StartDate = System.today() - 1;
      	mockLeadForSaleCancel.EndDate = System.Today() + 1;
      	mockLeadForSaleCancel.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
      	leadToInsertList.add(mockLeadForSaleCancel); 

      	Campaign mockLeadToDoExpired = new Campaign();
      	mockLeadToDoExpired.Lead_Campaign_Event_Code__c = leadToDoExpired;
      	mockLeadToDoExpired.Type__c = GlobalConstants.LEAD_TO_DO;
      	mockLeadToDoExpired.Sub_Type__c = 'เพื่อทราบ';
      	mockLeadToDoExpired.Name = leadToDoExpired;
      	mockLeadToDoExpired.Status = GlobalConstants.EXPIRED;
      	mockLeadToDoExpired.IsActive = false;
      	mockLeadToDoExpired.StartDate = System.today() - 1;
      	mockLeadToDoExpired.EndDate = System.Today() - 1;
      	mockLeadToDoExpired.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
      	leadToInsertList.add(mockLeadToDoExpired);

      	Campaign mockLeadToDoCancel = new Campaign();
      	mockLeadToDoCancel.Lead_Campaign_Event_Code__c = leadToDoCancel;
      	mockLeadToDoCancel.Type__c = GlobalConstants.LEAD_TO_DO;
      	mockLeadToDoCancel.Sub_Type__c = 'เพื่อทราบ';
      	mockLeadToDoCancel.Name = leadToDoCancel;
      	mockLeadToDoCancel.Status = GlobalConstants.CANCEL;
      	mockLeadToDoCancel.IsActive = false;
      	mockLeadToDoCancel.StartDate = System.today() - 1;
      	mockLeadToDoCancel.EndDate = System.Today() + 1;
      	mockLeadToDoCancel.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
      	leadToInsertList.add(mockLeadToDoCancel);

      	Campaign mockCampaign = new Campaign();
      	mockCampaign.Lead_Campaign_Event_Code__c = campaign;
      	mockCampaign.Type__c = GlobalConstants.CAMPAIGN;
      	mockCampaign.Name = campaign;
      	mockCampaign.Status = GlobalConstants.ACTIVE;
      	mockCampaign.IsActive = true;
      	mockCampaign.StartDate = System.today() - 1;
      	mockCampaign.EndDate = System.Today() + 1;
      	mockCampaign.Address_Registration__c = 'No';
      	mockCampaign.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
      	leadToInsertList.add(mockCampaign);

      	Campaign mockCampaignExpired = new Campaign();
      	mockCampaignExpired.Lead_Campaign_Event_Code__c = campaignExpired;
      	mockCampaignExpired.Type__c = GlobalConstants.CAMPAIGN;
      	mockCampaignExpired.Name = campaignExpired;
      	mockCampaignExpired.Status = GlobalConstants.EXPIRED;
      	mockCampaignExpired.IsActive = false;
      	mockCampaignExpired.StartDate = System.today() - 1;
      	mockCampaignExpired.EndDate = System.Today() - 1;
      	mockCampaignExpired.Address_Registration__c = 'No';
      	mockCampaignExpired.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
      	leadToInsertList.add(mockCampaignExpired);

      	Campaign mockCampaignCancel = new Campaign();
      	mockCampaignCancel.Lead_Campaign_Event_Code__c = campaignCancel;
      	mockCampaignCancel.Type__c = GlobalConstants.CAMPAIGN;
      	mockCampaignCancel.Name = campaignCancel;
      	mockCampaignCancel.Status = GlobalConstants.CANCEL;
      	mockCampaignCancel.IsActive = false;
      	mockCampaignCancel.StartDate = System.today() - 1;
      	mockCampaignCancel.EndDate = System.Today() + 1;
      	mockCampaignCancel.Address_Registration__c = 'No';
      	mockCampaignCancel.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
      	leadToInsertList.add(mockCampaignCancel);
		
		TriggerHandler.bypass('CampaignTriggerHandler');
		insert leadToInsertList;
		TriggerHandler.clearBypass('CampaignTriggerHandler');
    }


	@isTest static void testStampActiveLookUpWhenLeadForSaleAndTargetListNotCancelOrExpire() {
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.STATUS_NEW;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(account.Id, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenLeadForSaleAndTargetListIsCancel() {
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.CANCEL_LEAD;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];

		System.assertEquals(null, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenLeadForSaleAndTargetListIsExpired() {
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.LEAD_EXPIRED;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(null, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenLeadForSaleExpiredAndTargetListIsNotExpired() {
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSalesExpired];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.STATUS_NEW;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(account.Id, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenLeadForSaleAndLeadExpiredAndTargetListIsRejected(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSalesExpired];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.REJECTED;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(null, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenLeadForSaleAndLeadCancelAndTargetListIsRejected(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSalesCancel];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.REJECTED;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(null, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenLeadForSaleAndLeadNotExpiredOrCancelAndTargetListIsRejected(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.REJECTED;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(account.Id, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenLeadToDoAndTargetListNotCancelOrExpire() {
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadToDo];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.STATUS_NEW;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(account.Id, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenCampaign(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaign];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.STATUS_NEW;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(account.Id, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenCampaignExpiredAndTargetListExpired(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaignExpired];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.LEAD_EXPIRED;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(null, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenCampaignCancelAndTargetListCancel(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaignCancel];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.CANCEL_CAMPAIGN;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(null, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenLeadForSaleAndTargetListIsAutoClosed(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.AUTO_CLOSED;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(account.Id, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenLeadForSaleAndTargetListIsDeletedOpportunity(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.DELETED_OPPORTUNITY;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(account.Id, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenLeadForSaleExpiredAndTargetListIsAutoClosed(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSalesExpired];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.AUTO_CLOSED;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(null, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenLeadForSaleExpiredAndTargetListIsDeletedOpportunity(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSalesExpired];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.DELETED_OPPORTUNITY;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(null, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenLeadForSaleCancelAndTargetListIsAutoClosed(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSalesCancel];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.AUTO_CLOSED;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(null, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenLeadForSaleCancelAndTargetListIsDeletedOpportunity(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSalesCancel];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.DELETED_OPPORTUNITY;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(null, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenCampaignAndTargetListIsAutoClosed(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaign];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.AUTO_CLOSED;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(account.Id, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenCampaignAndTargetListIsDeletedOpportunity(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaign];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.DELETED_OPPORTUNITY;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(account.Id, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenCampaignExpiredAndTargetListIsAutoClosed(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaignExpired];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.AUTO_CLOSED;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(null, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenCampaignExpiredAndTargetListIsDeletedOpportunity(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaignExpired];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.DELETED_OPPORTUNITY;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(null, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenCampaignCancelAndTargetListIsAutoClosed(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaignCancel];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.AUTO_CLOSED;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(null, targetList.Active_Target_List__c);
	}

	@isTest static void testStampActiveLookUpWhenCampaignCancelAndTargetListIsDeletedOpportunity(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id, CIS__c');
		Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaignCancel];

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = lead.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.DELETED_OPPORTUNITY;
		TriggerHandler.bypass('TargetListTriggerHandler');
		insert targetList;
		TriggerHandler.clearBypass('TargetListTriggerHandler');
		
		Test.startTest();
			Database.executeBatch(new SME_ActiveTargetListInitial_Batch());
		Test.stopTest();

		targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.assertEquals(null, targetList.Active_Target_List__c);
	}


}