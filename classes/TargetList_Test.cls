@isTest
private class TargetList_Test {
    
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
    public static String eventName = 'eventName';

    @testSetup static void setupAccount(){
        TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test mt = new Mockup_Test().setUpTest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
            TargetList_Test.setupCampaign();
            TargetList_Test.setupLeadAndCampaign();
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

      Campaign mockEvent = new Campaign();
      mockEvent.Lead_Campaign_Event_Code__c = eventName;
      mockEvent.Type__c = GlobalConstants.CAMPAIGN;
      mockEvent.Name = eventName;
      mockEvent.Status = GlobalConstants.ACTIVE;
      mockEvent.IsActive = true;
      mockEvent.StartDate = System.today() - 1;
      mockEvent.EndDate = System.Today() + 1;
      mockEvent.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.SME_EVENT);
      mockEvent.Objective__c = 'Others';
      leadToInsertList.add(mockEvent);
    
      TriggerHandler.bypass('CampaignTriggerHandler');
        insert leadToInsertList;
      TriggerHandler.clearBypass('CampaignTriggerHandler');
    }

    @isTest static void testLeadForSaleActiveInsertTargetList(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

      Test.startTest();
      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c,Event_Target_Lists__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);
      System.assertEquals(null, targetList.Event_Target_Lists__c);
    }

    @isTest static void testLeadForSalePlannedInsertTargetList(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];
      lead.Status = GlobalConstants.PLANNED;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Test.startTest();
      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);
    }

    @isTest static void testLeadToDoActiveInsertTargetList(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadToDo];

      Test.startTest();
      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);
    }

    @isTest static void testLeadToDoPlannedInsertTargetList(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadToDo];
      lead.Status = GlobalConstants.PLANNED;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Test.startTest();
      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);
    }

    @isTest static void testCampaignActiveInsertTargetList(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaign];

      Test.startTest();
      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);
    }

    @isTest static void testCampaignPlannedInsertTargetList(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: campaign];
      lead.Status = GlobalConstants.PLANNED;
      TriggerHandler.bypass('CampaignTriggerHandler');
      update lead;
      TriggerHandler.clearBypass('CampaignTriggerHandler');

      Test.startTest();
      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Active_Target_List__c);
    }

    @isTest static void testCreateTargetlistAndHaveStatusNewAndExpDate_StatusShouldbeExpired(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

      Test.startTest();
      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetlist.Expiry_Date__c = System.today().addDays(-1);
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;
      Test.stopTest();

      targetList = [SELECT Id, Status__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(GlobalConstants.TG_EXPIRED, targetList.Status__c);
    }

    @isTest static void testCreateTargetlistAndHaveStatusNew_StatusShouldbeNew(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];

      Test.startTest();
      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;
      Test.stopTest();

      targetList = [SELECT Id, Status__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(GlobalConstants.STATUS_NEW, targetList.Status__c);
    }

    static testMethod void notConcatForNewBooking() {
        Account testAcc = Mockup_Test.getFirstAccountFromName(TargetList_Test.accountNameAH, 'Id,CIS__c');
        Campaign targetCampaign = [SELECT Id, Lead_Campaign_Event_Code__c FROM Campaign WHERE Name = 'NEWBOOKING'];
        Test.startTest();                   
            insert new Target_List__c(
                Lead_Campaign__c = targetCampaign.Id, 
                CIS_ID_Prospect_Name__c = testAcc.Id);
        Test.stopTest();
        
        Target_List__c finalTarget =[SELECT Id, External_Id__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strNewBooking LIMIT 1];

        System.assertEquals(null, finalTarget.External_ID__c);
    }

    static testMethod void testConcatExternalId() {
        String campaignName = 'Test';
        Account testAcc = Mockup_Test.getFirstAccountFromName(TargetList_Test.accountNameAH, 'Id,CIS__c');
        RecordType smeLeadCampaignRecType = [SELECT Id FROM RecordType WHERE DeveloperName =: GlobalConstants.SME_LEAD_CAMPAIGN_DEVNAME];
        Campaign targetCampaign = new Campaign();
        targetCampaign.Lead_Campaign_Event_Code__c = campaignName;
        targetCampaign.Type__c = GlobalConstants.LEAD_FOR_SALES;
        targetCampaign.Name = campaignName;
        targetCampaign.Status = GlobalConstants.ACTIVE;
        targetCampaign.StartDate = System.today() - 1;
        targetCampaign.EndDate = System.Today() + 1;
        targetCampaign.Effective_Date__c = System.Today() - 10;
        targetCampaign.RecordtypeId = smeLeadCampaignRecType.Id;
        insert targetCampaign;
        Test.startTest();                   
            insert new Target_List__c(
                Lead_Campaign__c = targetCampaign.Id, 
                CIS_ID_Prospect_Name__c = testAcc.Id);
        Test.stopTest();
        
        Target_List__c finalTarget =[SELECT Id, External_Id__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :campaignName LIMIT 1];
        System.assertEquals(targetCampaign.Lead_Campaign_Event_Code__c + ':' + testAcc.Id, finalTarget.External_ID__c);
    }

    @isTest static void Given_TargetListFlagCreateNewJobAndHasRelatedJob_When_Insert_Then_ErrorPleaseChooseNewOrExistingJob(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Name,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];
      Opportunity opp =new Opportunity(
                Name = account.Name,
                AccountId = account.Id,
                CloseDate = System.today(),
                StageName = GlobalConstants.STOCK_NEGOTIATION,
                Amount = 1000,
                IsConvertFromCallReport__c = true,
                Submit_Issue__c = GlobalConstants.NEW_CREDIT
            );
      insert opp;
      Test.startTest();
      try{
        Target_List__c targetList = new Target_List__c();
        targetList.Lead_Campaign__c = lead.Id;
        targetList.CIS_ID_Prospect_Name__c = account.Id;
        targetList.Status__c = GlobalConstants.STATUS_NEW;
        targetList.Create_New_Job__c = true;
        targetList.Opportunity__c = opp.Id;
        insert targetList;
      }catch(Exception e){
        System.assert(e.getMessage().contains(LABEL.PLEASE_CHOOSE_NEW_OR_EXISTING_JOB));
      }
      Test.stopTest();
    }

    @isTest static void Given_TargetListFlagCreateNewJob_When_Update_Then_CreateJobRelateToTargetList(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Name,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];
      Date currentDate = System.today();
      Integer year = currentDate.year();
      Integer month = currentDate.month();
      Integer day = currentDate.day();
      String stringMonth;
      if(month < 10){
          stringMonth = '0'+month;
      }

      Test.startTest();
        Target_List__c targetList = new Target_List__c();
        targetList.Lead_Campaign__c = lead.Id;
        targetList.CIS_ID_Prospect_Name__c = account.Id;
        targetList.Status__c = GlobalConstants.STATUS_NEW;
        insert targetList;
        targetList.Create_New_Job__c = true;
        update targetList;
      Test.stopTest();
      Target_List__c finalTarget =[SELECT Id, External_Id__c,Create_New_Job__c,DoneCreateJob__c,Opportunity__c FROM Target_List__c WHERE Id =:targetList.Id LIMIT 1];
      System.assertEquals(false,finalTarget.Create_New_Job__c);
      System.assertEquals(true,finalTarget.DoneCreateJob__c);
      System.assertNotEquals(null,finalTarget.Opportunity__c);

      Opportunity relatedJob = [SELECT Id,AccountId,Name,StageName,CloseDate FROM Opportunity WHERE Id = :finalTarget.Opportunity__c];
      System.assertEquals(account.Id,relatedJob.AccountId);
      System.assertEquals(year+'/'+stringMonth+'/'+day+'_'+ account.Name,relatedJob.Name);
      System.assertEquals(Globalconstants.STATUS_OPEN,relatedJob.StageName);
      System.assertEquals(System.today() + Integer.valueOf(Label.Default_Job_CloseDate),relatedJob.CloseDate);
    }

    @isTest static void Given_TargetListStatusNew_When_UpdateStatus_Then_SetResponseDateField(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Name,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];
      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;
      Test.startTest();
        targetList.Status__c = GlobalConstants.STATUS_DONE;
        update targetList;
      Test.stopTest();
      Target_List__c finalTarget =[SELECT Id, Response_Date__c,External_Id__c,Create_New_Job__c,DoneCreateJob__c,Opportunity__c FROM Target_List__c WHERE Id =:targetList.Id LIMIT 1];
      System.assertEquals(System.today(),finalTarget.Response_Date__c);
    }

    @isTest static void Given_TargetListCreatedByOther_When_RmDeleteTargetList_Then_Error(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Name,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];
      //User smeAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin];
      User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM];
      
      Target_List__c targetList = new Target_List__c();
      //System.runAs(smeAdmin){
        targetList.Lead_Campaign__c = lead.Id;
        targetList.CIS_ID_Prospect_Name__c = account.Id;
        targetList.Status__c = GlobalConstants.STATUS_NEW;
        insert targetList;
      //}
      
      Test.startTest();
        System.runAs(rmUser){
          try{
            delete targetlist;
          }catch(Exception e){
            System.assert(e.getMessage().contains(TargetList_Service.ERROR_DELETE_MSG));
          }
        }
      Test.stopTest();
    }

    @isTest static void Given_TargetListCreatedByOther_When_AdminDeleteTargetList_Then_Success(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Name,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: leadForSales];
      Id solarProfileId = Mockup_Test.getMapProfileByName('Solar').Id;
      User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
      userAdmin.ProfileId = solarProfileId;
      update userAdmin;
      User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM];
      Target_List__c targetList;
      System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]){
      targetList = new Target_List__c();
        targetList.Lead_Campaign__c = lead.Id;
        targetList.CIS_ID_Prospect_Name__c = account.Id;
        targetList.Status__c = GlobalConstants.STATUS_NEW;
        insert targetList;
      }
      
      Test.startTest();
        System.runAs(userAdmin){
          delete targetlist;
        }
      Test.stopTest();
      List<Target_List__c> listResult = [SELECT Id FROM Target_List__c];
      System.assertEquals(0,listResult.size());
    }

    @isTest static void Given_ActiveEvent_When_InsertTargetList_Then_FieldEventTargetListNotNull(){
      Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c');
      Campaign lead = [SELECT Id FROM Campaign WHERE Name =: eventName];

      Test.startTest();
      Target_List__c targetList = new Target_List__c();
      targetList.Lead_Campaign__c = lead.Id;
      targetList.CIS_ID_Prospect_Name__c = account.Id;
      targetList.Status__c = GlobalConstants.STATUS_NEW;
      insert targetList;
      Test.stopTest();

      targetList = [SELECT Id, Lead_Type__c, Lead_Subtype__c, Lead_Status__c, Status__c,Event_Target_Lists__c, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
      System.assertEquals(account.Id, targetList.Event_Target_Lists__c);
      System.assertEquals(null, targetList.Active_Target_List__c);
    }
}