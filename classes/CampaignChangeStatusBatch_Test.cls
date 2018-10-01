@isTest
private class CampaignChangeStatusBatch_Test {
	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    public static string strNewBooking='NEWBOOKING';
    public static string strThankyou='THANKYOU';

    public static String leadForSales = 'leadForSales';
    public static String leadForSalesExpired = 'leadForSalesExpired';
    public static String leadForSalesCancel = 'leadForSalesCancel';

    public static String leadForFeedback = 'leadForFeedback';
    
    public static String leadToDo = 'leadToDo';
    public static String leadToDoExpired = 'leadToDoExpired';
    public static String leadToDoCancel = 'leadToDoCancel';

    public static String campaign = 'campaign';
    public static String campaignExpired = 'campaignExpired';
    public static String campaignCancel = 'campaignCancel';

	@testSetup static void setupAccount(){
        TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test mt = new Mockup_Test().setUpTest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            CampaignChangeStatusBatch_Test.setupCampaign();
            CampaignChangeStatusBatch_Test.setupLeadAndCampaign();
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        TriggerHandler.clearBypass('UserTriggerHandler');
    }
    
    public static void setupCampaign(){
            List<Campaign> campaignList = new List<Campaign>();
            Campaign_Setting__c cSetting = new Campaign_Setting__c();
            cSetting.NewBooking_Code__c= strNewBooking;
            cSetting.ThankYou_Code__c= strThankyou;
            cSetting.Register_Period__c=30;
            insert cSetting;
        
            Campaign CampaignNewBooking = new Campaign();
            CampaignNewBooking.name=strNewBooking;
            CampaignNewBooking.type__c='Campaign';
            CampaignNewBooking.Lead_Campaign_Event_Code__c=strNewBooking;
            CampaignNewBooking.StartDate=system.today();
            CampaignNewBooking.status='Active';
            CampaignNewBooking.IsActive=true;           
            campaignList.add(CampaignNewBooking);
        
            Campaign CampaignThankyou = new Campaign();
            CampaignThankyou.name=strThankyou;
            CampaignThankyou.type__c='Campaign';
            CampaignThankyou.Lead_Campaign_Event_Code__c=strThankyou;
            CampaignThankyou.StartDate=system.today();
            CampaignThankyou.status='Active';
            CampaignThankyou.IsActive=true;
            CampaignThankyou.Address_Registration__c = 'Yes';
            campaignList.add(CampaignThankyou);    
            insert campaignList;
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

      Campaign mockLeadForFeedback = new Campaign();
      mockLeadForFeedback.Lead_Campaign_Event_Code__c = leadForFeedback;
      mockLeadForFeedback.Type__c = GlobalConstants.LEAD_FOR_FEEDBACK;
      //mockLeadForFeedback.Sub_Type__c = 'เพื่อทราบ';
      mockLeadForFeedback.Sub_Type_CBS__c = GlobalConstants.LEAD_SUB_TYPE_PN_UN_USED;
      mockLeadForFeedback.Name = leadForFeedback;
      mockLeadForFeedback.Status = GlobalConstants.ACTIVE;
      mockLeadForFeedback.IsActive = true;
      mockLeadForFeedback.StartDate = System.today() - 1;
      mockLeadForFeedback.EndDate = System.Today() + 1;
      mockLeadForFeedback.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_CBS_REC);
      leadToInsertList.add(mockLeadForFeedback);

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
      mockCampaign.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
      mockCampaign.Address_Registration__c = 'Yes';
      leadToInsertList.add(mockCampaign);

      Campaign mockCampaignExpired = new Campaign();
      mockCampaignExpired.Lead_Campaign_Event_Code__c = campaignExpired;
      mockCampaignExpired.Type__c = GlobalConstants.CAMPAIGN;
      mockCampaignExpired.Name = campaignExpired;
      mockCampaignExpired.Status = GlobalConstants.EXPIRED;
      mockCampaignExpired.IsActive = false;
      mockCampaignExpired.StartDate = System.today() - 1;
      mockCampaignExpired.EndDate = System.Today() - 1;
      mockCampaignExpired.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
      mockCampaignExpired.Address_Registration__c = 'Yes';
      leadToInsertList.add(mockCampaignExpired);

      Campaign mockCampaignCancel = new Campaign();
      mockCampaignCancel.Lead_Campaign_Event_Code__c = campaignCancel;
      mockCampaignCancel.Type__c = GlobalConstants.CAMPAIGN;
      mockCampaignCancel.Name = campaignCancel;
      mockCampaignCancel.Status = GlobalConstants.CANCEL;
      mockCampaignCancel.IsActive = false;
      mockCampaignCancel.StartDate = System.today() - 1;
      mockCampaignCancel.EndDate = System.Today() + 1;
      mockCampaignCancel.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
      mockCampaignCancel.Address_Registration__c = 'Yes';
      leadToInsertList.add(mockCampaignCancel);
    
      TriggerHandler.bypass('CampaignTriggerHandler');
        insert leadToInsertList;
      TriggerHandler.clearBypass('CampaignTriggerHandler');
    }

	@isTest static void testCampaignExpiredUpdateTargetListActiveTargetListShouldBeNull(){
      //Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaign];

      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;

      targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);

      Test.startTest();
      lead.Status = GlobalConstants.EXPIRE_PROCESS;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Set<Id> setOfCampId = new Set<Id>();
      setOfCampId.add(lead.Id);

      Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(null, targetList.Active_Target_List__c);
    }

    @isTest static void testCampaignExpiredWithTatgetListHasExpiryDateShouldHaveData(){
      //Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaign];

      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      targetlist.Expiry_Date__c = System.today().addDays(-1);
      insert targetList;

      targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);

      Test.startTest();
      lead.Status = GlobalConstants.ACTIVE;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Database.executeBatch(new CampaignChangeStatus_Batch());
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);
    }

    @isTest static void testCampaignExpiredWithTatgetListNotHasExpiryDateShouldBeNull(){
      //Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadToDo];

      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;    
      targetList.Status__c = GlobalConstants.STATUS_NEW;

      insert targetList;

      targetList = [SELECT Id, Active_Target_List__c,Status__c,Expiry_Date__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);
      System.debug('Phon TargetsList2 : '+ targetList);

      Test.startTest();
      lead.Status = GlobalConstants.ACTIVE;
      lead.EndDate = System.today().addDays(-1);
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Database.executeBatch(new CampaignChangeStatus_Batch());
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(null, targetList.Active_Target_List__c);
    }

    @isTest static void testCampaignCancelUpdateTargetListActiveTargetListShouldBeNull(){
      //Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaign];

      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;

      targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);

      Test.startTest();
      lead.Status = GlobalConstants.CANCEL_PROCESS;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Set<Id> setOfCampId = new Set<Id>();
      setOfCampId.add(lead.Id);

      Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
       System.debug('Phon TargetsList2 : '+ targetList);
      System.assertEquals(null, targetList.Active_Target_List__c);
    }

    @isTest static void testLeadForSaleExpiredUpdateTargetListActiveTargetListShouldBeNull(){
      //Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;

      targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);

      Test.startTest();
      lead.Status = GlobalConstants.EXPIRE_PROCESS;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Set<Id> setOfCampId = new Set<Id>();
      setOfCampId.add(lead.Id);

      Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(null, targetList.Active_Target_List__c);
    }

    @isTest static void testLeadForSaleCancelUpdateTargetListActiveTargetListShouldBeNull(){
      //Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;

      targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);

      Test.startTest();
      lead.Status = GlobalConstants.CANCEL_PROCESS;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Set<Id> setOfCampId = new Set<Id>();
      setOfCampId.add(lead.Id);

      Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(null, targetList.Active_Target_List__c);
    }

    @isTest static void testLeadForSaleExpiredUpdateTargetListAsRejectActiveTargetListShouldBeNull(){
      //Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.REJECTED;
      insert targetList;

      targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);

      Test.startTest();
      lead.Status = GlobalConstants.EXPIRE_PROCESS;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Set<Id> setOfCampId = new Set<Id>();
      setOfCampId.add(lead.Id);

      Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(null, targetList.Active_Target_List__c);
    }

    @isTest static void testLeadForSaleCancelUpdateTargetListAsRejectedActiveTargetListShouldBeNull(){
      //Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.REJECTED;
      insert targetList;

      targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);

      Test.startTest();
      lead.Status = GlobalConstants.CANCEL_PROCESS;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Set<Id> setOfCampId = new Set<Id>();
      setOfCampId.add(lead.Id);

      Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(null, targetList.Active_Target_List__c);
    }

    @isTest static void testLeadToDoExpiredUpdateTargetListActiveTargetListShouldBeNull(){
      //Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadToDo];

      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;

      targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);

      Test.startTest();
      lead.Status = GlobalConstants.EXPIRE_PROCESS;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Set<Id> setOfCampId = new Set<Id>();
      setOfCampId.add(lead.Id);

      Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(null, targetList.Active_Target_List__c);
    }

    @isTest static void testLeadToDoCancelUpdateTargetListActiveTargetListShouldBeNull(){
      //Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadToDo];

      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;

      targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);

      Test.startTest();
      lead.Status = GlobalConstants.CANCEL_PROCESS;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Set<Id> setOfCampId = new Set<Id>();
      setOfCampId.add(lead.Id);

      Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(null, targetList.Active_Target_List__c);
    }

    @isTest static void testLeadForSalesExpiredAndTargetListIsAutoClosed(){
      //Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.AUTO_CLOSED;
      insert targetList;

      targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);

      Test.startTest();
      lead.Status = GlobalConstants.CANCEL_PROCESS;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Set<Id> setOfCampId = new Set<Id>();
      setOfCampId.add(lead.Id);

      Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(null, targetList.Active_Target_List__c);
    }

    @isTest static void testLeadForSalesExpiredAndTargetListIsDeletedOpportunity(){
      //Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.DELETED_OPPORTUNITY;
      insert targetList;

      targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);

      Test.startTest();
      lead.Status = GlobalConstants.CANCEL_PROCESS;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Set<Id> setOfCampId = new Set<Id>();
      setOfCampId.add(lead.Id);

      Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(null, targetList.Active_Target_List__c);
    }

    @isTest static void testLeadToDoExpiredAndNoTargetList(){
      //Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadToDo];

      Test.startTest();
      lead.Status = GlobalConstants.EXPIRE_PROCESS;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Set<Id> setOfCampId = new Set<Id>();
      setOfCampId.add(lead.Id);

      Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
      Test.stopTest();

      lead = [SELECT Id, Status FROM Campaign WHERE Name =: leadToDo];
      System.assertEquals(GlobalConstants.EXPIRED,lead.Status);
    }

    @isTest static void testLeadForFeedBackLeadExpire() {
        //Account account = [SELECT Id, CIS__c,OwnerId FROM Account WHERE Name =: accountNameRM];
        Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c,OwnerId');
        Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForFeedback];

        Target_List__c targetList = new Target_List__c();
        targetList.Lead_Campaign__c = lead.Id;
        targetList.CIS_ID_Prospect_Name__c = account.Id;
        targetList.Status__c = GlobalConstants.STATUS_NEW;
        insert targetList;     

        targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
        System.assertEquals(account.Id, targetList.Active_Target_List__c);

        Test.startTest();
        lead.Status = GlobalConstants.EXPIRE_PROCESS;
        TriggerHandler.bypass('CampaignTriggerHandler');
        update lead;
        TriggerHandler.clearBypass('CampaignTriggerHandler');

        Set<Id> setOfCampId = new Set<Id>();
        setOfCampId.add(lead.Id);

        Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
        Test.stopTest();

        targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
        System.assertEquals(null, targetList.Active_Target_List__c);

    }
    @isTest static void testLeadForFeedBackLeadCancel() {
        //Account account = [SELECT Id, CIS__c,OwnerId FROM Account WHERE Name =: accountNameRM];
        Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c,OwnerId');
        Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForFeedback];

        Target_List__c targetList = new Target_List__c();
        targetList.Lead_Campaign__c = lead.Id;
        targetList.CIS_ID_Prospect_Name__c = account.Id;
        targetList.Status__c = GlobalConstants.STATUS_NEW;
        insert targetList;     

        targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
        System.assertEquals(account.Id, targetList.Active_Target_List__c);

        Test.startTest();
        lead.Status = GlobalConstants.CANCEL_PROCESS;
        TriggerHandler.bypass('CampaignTriggerHandler');
        update lead;
        TriggerHandler.clearBypass('CampaignTriggerHandler');

        Set<Id> setOfCampId = new Set<Id>();
        setOfCampId.add(lead.Id);

        Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
        Test.stopTest();

        targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
        System.assertEquals(null, targetList.Active_Target_List__c);

    }
    @isTest static void testLeadForFeedBackTargetListDone() {
        //Account account = [SELECT Id, CIS__c,OwnerId FROM Account WHERE Name =: accountNameRM];
        Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c,OwnerId');
        Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForFeedback];

        Target_List__c targetList = new Target_List__c();
        targetList.Lead_Campaign__c = lead.Id;
        targetList.CIS_ID_Prospect_Name__c = account.Id;
        targetList.Status__c = GlobalConstants.STATUS_DONE;
        insert targetList;     

        targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
        System.assertEquals(account.Id, targetList.Active_Target_List__c);

        Test.startTest();
        lead.Status = GlobalConstants.EXPIRE_PROCESS;
        TriggerHandler.bypass('CampaignTriggerHandler');
        update lead;
        TriggerHandler.clearBypass('CampaignTriggerHandler');

        Set<Id> setOfCampId = new Set<Id>();
        setOfCampId.add(lead.Id);

        Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
        Test.stopTest();

        targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
        System.assertEquals(account.Id, targetList.Active_Target_List__c);

    }
    @isTest static void testLeadForFeedBackLeadCancelTargetListDone() {
        //Account account = [SELECT Id, CIS__c,OwnerId FROM Account WHERE Name =: accountNameRM];
        Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c,OwnerId');
        Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForFeedback];

        Target_List__c targetList = new Target_List__c();
        targetList.Lead_Campaign__c = lead.Id;
        targetList.CIS_ID_Prospect_Name__c = account.Id;
        targetList.Status__c = GlobalConstants.STATUS_DONE;
        insert targetList;     

        targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
        System.assertEquals(account.Id, targetList.Active_Target_List__c);

        Test.startTest();
        lead.Status = GlobalConstants.CANCEL_PROCESS;
        TriggerHandler.bypass('CampaignTriggerHandler');
        update lead;
        TriggerHandler.clearBypass('CampaignTriggerHandler');

        Set<Id> setOfCampId = new Set<Id>();
        setOfCampId.add(lead.Id);

        Database.executeBatch(new CampaignChangeStatus_Batch(setOfCampId));
        Test.stopTest();

        targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
        System.assertEquals(account.Id, targetList.Active_Target_List__c);

    }
}