@isTest
private class Campaign_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';

    @testSetup static void setupAccount(){
        TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test mt = new Mockup_Test().setUpTest();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        TriggerHandler.clearBypass('UserTriggerHandler');
    }

    public static Map<String,String> mockCreateContact(){
        Map<String,String> mockIdMap = new Map<String,String>();
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Campaign_Test.accountNameRM, 'Id');
        Contact mockContact = new Contact(
                LastName = 'lastname',
                Contact_Firstname__c = 'Firstname',
                AccountId = targetAccount.Id,
                Phone_Numbers__c = '023450789'
            );
        insert mockContact;
        mockIdMap.put('accountId', targetAccount.Id);
        mockIdMap.put('contactId', mockContact.Id);
        return mockIdMap;
    }

    public static Campaign mockCreateCampaign(String campaignName, String campaignType, Boolean campaignIsActive, String campaignStatus){
        Campaign mockCampaign = new Campaign();
        mockCampaign.Lead_Campaign_Event_Code__c = campaignName;
        mockCampaign.Type__c = campaignType;
        mockCampaign.Name = campaignName;
        mockCampaign.Status = campaignStatus;

        if(campaignIsActive || campaignStatus == GlobalConstants.ACTIVE) {
            mockCampaign.IsActive = true;
            mockCampaign.StartDate = System.today() - 1;
        } else {
            mockCampaign.IsActive = false;
            mockCampaign.StartDate = System.today() + 1;
        }

        mockCampaign.EndDate = System.Today() + 1;
        mockCampaign.Effective_Date__c = System.Today() - 10;
        mockCampaign.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
        return mockCampaign;
    }

    public static Target_List__c mockCreateTargetList(String accountId, String campaignId){
        Target_List__c eachTargetList = new Target_List__c();
        eachTargetList.CIS_ID_Prospect_Name__c = accountId;
        eachTargetList.Lead_Campaign__c = campaignId;
        eachTargetList.Status__c = GlobalConstants.STATUS_NEW;
        return eachTargetList;
    }

    @isTest static void testUpdateCampaign() {
        User rmUser = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];

        System.runAs([SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]) {
            Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'TestCampaign', System.now().addDays(1), System.now().addDays(2), System.now(), GlobalConstants.PLANNED, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_TO_INFORM);
            insert camp;

            CampaignShare cmpShare = new CampaignShare();
            cmpShare.CampaignAccessLevel = GlobalConstants.READ;
            cmpShare.UserOrGroupId = rmUser.Id;
            cmpShare.CampaignId = camp.Id;
            insert cmpShare;

            RecordType rt = [select Id from RecordType where Name = :GlobalConstants.SME_EVENT and SobjectType = 'Campaign' LIMIT 1];
            camp.RecordTypeId = rt.Id;
            camp.Start_Date_Time__c = System.now();
            camp.End_Date_Time__c = System.now().addDays(2);
            camp.Status = GlobalConstants.ACTIVE;
            camp.Reason_for_Change__c = 'Test Class';

            Test.startTest();
            GlobalUtility.runOnce = false;
            update camp;
            Test.stopTest();

            Campaign updatedCampaign = [SELECT Id, Start_Date_Time__c, End_Date_Time__c, Attendee_Confirmation_Date__c FROM Campaign WHERE OwnerID = :UserInfo.getUserId()][0];
            System.assertEquals(updatedCampaign.Id, camp.Id);

            Event newEvent = [SELECT StartDateTime, EndDateTime FROM Event WHERE WhatId = :updatedCampaign.Id AND Subject = 'Start New Event'][0];
            System.assertEquals(updatedCampaign.Start_Date_Time__c, newEvent.StartDateTime);

            Event inviteEvent = [SELECT StartDateTime, EndDateTime FROM Event WHERE WhatId = :updatedCampaign.Id AND Subject = 'Confirmation Date'][0];
            System.assertEquals(updatedCampaign.Attendee_Confirmation_Date__c, inviteEvent.StartDateTime);

            updatedCampaign.Reason_for_Cancellation__c = 'test Cancel';
            updatedCampaign.Status = GlobalConstants.CANCEL;
            update updatedCampaign;
        }  
    }

    @isTest static void testCancelCampaign() {
        User rmUser = [SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];

        System.runAs([SELECT Id, UserRoleId FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]) {
            TriggerHandler.bypass('CampaignTriggerHandler');
            Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'TestCampaign', System.now().addDays(1), System.now().addDays(2), System.now(), GlobalConstants.PLANNED, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_TO_INFORM);
            insert camp;
            String recordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.EVENT);
            Event newEvent = new Event(RecordTypeId = recordTypeId, WhatId = camp.Id, Subject = 'Start New Event',StartDateTime = camp.Start_Date_Time__c, EndDateTime = camp.Start_Date_Time__c, OwnerID = camp.OwnerID);
            Event attendeeEvent = new Event(RecordTypeId = recordTypeId, WhatId = camp.Id, Subject = 'Confirmation Date',StartDateTime = camp.Attendee_Confirmation_Date__c, EndDateTime = camp.Attendee_Confirmation_Date__c, OwnerID = camp.OwnerID);
            Event endEvent = new Event(RecordTypeId = recordTypeId, WhatId = camp.Id, Subject = 'End New Event',StartDateTime = camp.End_Date_Time__c, EndDateTime = camp.End_Date_Time__c, OwnerID = camp.OwnerID);

            List<Event> eventList = new List<Event>();
            eventList.add(newEvent);
            eventList.add(attendeeEvent);
            eventList.add(endEvent);
            insert eventList;
            
            EventRelation eventRelation = new EventRelation();
            eventRelation.EventId = newEvent.Id;
            eventRelation.RelationId = rmUser.Id;
            insert eventRelation;

            CampaignShare cmpShare = new CampaignShare();
            cmpShare.CampaignAccessLevel = GlobalConstants.READ;
            cmpShare.UserOrGroupId = rmUser.Id;
            cmpShare.CampaignId = camp.Id;
            insert cmpShare;

            GlobalUtility.runOnce = false;
           
            Campaign cancelCampaign = [SELECT Id, Start_Date_Time__c, End_Date_Time__c, Attendee_Confirmation_Date__c FROM Campaign WHERE OwnerID = :UserInfo.getUserId()][0];
            cancelCampaign.Reason_for_Cancellation__c = 'test Cancel';
            cancelCampaign.Status = GlobalConstants.CANCEL;

            TriggerHandler.clearBypass('CampaignTriggerHandler');
            Test.startTest();
            GlobalUtility.runOnce = false;
            update cancelCampaign;
            Test.stopTest();

            System.assertEquals(0, ((List<Event>) [SELECT Id FROM Event WHERE WhatId = :camp.Id]).size());   
        }
    }

    @isTest static void testActiveCampaignStampAccount() {
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Campaign_Test.accountNameRM, 'Id');
        targetAccount.CIS__c = '555555555';
        TriggerHandler.bypass('AccountTriggerHandler');
        update targetAccount;
        TriggerHandler.clearbypass('AccountTriggerHandler');
        Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.PLANNED, 'SME- Lead / Campaign', GlobalConstants.LEAD_FOR_SALES);
        camp.StartDate = System.Today() - 1;
        camp.EndDate = System.Today() + 1;
        camp.IsActive = false;
        insert camp;

        Target_List__c tl = new Target_List__c();
        tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
        tl.Lead_Campaign__c = camp.Id;
        tl.Status__c = GlobalConstants.STATUS_NEW;
        insert tl;

        Test.startTest();
            GlobalUtility.runOnce = false;
            Campaign targetCamp = [SELECT Id FROM Campaign WHERE Name = 'Campaign1' LIMIT 1];
            targetCamp.Status = 'Active';
            update targetCamp;
            Database.executeBatch(new AccountLeadInitial_Batch(), 2000);
        Test.stopTest();

        Account finalAcc = [SELECT Id, Lead_To_Do__c, Lead_To_Inform__c,Lead_for_Sales__c FROM Account WHERE Id = :targetAccount.Id LIMIT 1];
        System.assertEquals(camp.Name, finalAcc.Lead_for_Sales__c);
    }

    @isTest static void testStampAccountLead() {
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Campaign_Test.accountNameRM, 'Id');
        targetAccount.CIS__c = '555555555';
        TriggerHandler.bypass('AccountTriggerHandler');
        update targetAccount;
        TriggerHandler.clearbypass('AccountTriggerHandler');
        Test.startTest();
            Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, 'SME- Lead / Campaign', GlobalConstants.LEAD_TO_INFORM);
            camp.StartDate = System.Today() - 1;
            camp.EndDate = System.Today() + 1;
            camp.IsActive = true;
            insert camp;

            Target_List__c tl = new Target_List__c();
            tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
            tl.Lead_Campaign__c = camp.Id;
            tl.Status__c = GlobalConstants.STATUS_NEW;
            insert tl;

            Database.executeBatch(new AccountLeadInitial_Batch(), 2000);
        Test.stopTest();

        Account finalAcc = [SELECT Id, Lead_To_Inform__c FROM Account WHERE Id = :targetAccount.Id LIMIT 1];
        System.assertEquals(camp.Name, finalAcc.Lead_To_Inform__c);
    }

    @isTest static void testStampAccountCampaignToLeadToInform() {
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Campaign_Test.accountNameRM, 'Id');
        targetAccount.CIS__c = '555555555';
        TriggerHandler.bypass('AccountTriggerHandler');
        update targetAccount;
        TriggerHandler.clearbypass('AccountTriggerHandler');
        Test.startTest();

            Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, 'SME- Lead / Campaign', GlobalConstants.CAMPAIGN);
            camp.StartDate = System.Today() - 1;
            camp.EndDate = System.Today() + 1;
            camp.IsActive = true;
            camp.Address_Registration__c = 'Yes';
            insert camp;

            Target_List__c tl = new Target_List__c();
            tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
            tl.Lead_Campaign__c = camp.Id;
            tl.Status__c = GlobalConstants.STATUS_NEW;
            insert tl;

            Database.executeBatch(new AccountLeadInitial_Batch(), 2000);
        Test.stopTest();

        Account finalAcc = [SELECT Id, Lead_To_Inform__c FROM Account WHERE Id = :targetAccount.Id LIMIT 1];
        System.assertEquals(camp.Name, finalAcc.Lead_To_Inform__c);
    }

    @isTest static void testStampAccountLeadCancel() {
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Campaign_Test.accountNameRM, 'Id');
        targetAccount.CIS__c = '555555555';
        TriggerHandler.bypass('AccountTriggerHandler');
        update targetAccount;
        TriggerHandler.clearbypass('AccountTriggerHandler');
        Test.startTest();

            Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, 'SME- Lead / Campaign', GlobalConstants.LEAD_TO_INFORM);
            camp.StartDate = System.Today() - 1;
            camp.EndDate = System.Today() + 1;
            camp.IsActive = true;
            insert camp;

            Target_List__c tl = new Target_List__c();
            tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
            tl.Lead_Campaign__c = camp.Id;
            tl.Status__c = GlobalConstants.CANCEL_LEAD;
            tl.In_Call_Plan__c = false;
            insert tl;

            Campaign camp2 = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign2', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, 'SME- Lead / Campaign', GlobalConstants.LEAD_TO_INFORM);
            camp2.StartDate = System.Today() - 1;
            camp2.EndDate = System.Today() + 1;
            camp2.IsActive = true;
            insert camp2;

            Target_List__c tl2 = new Target_List__c();
            tl2.CIS_ID_Prospect_Name__c = targetAccount.Id;
            tl2.Lead_Campaign__c = camp2.Id;
            tl2.Status__c = GlobalConstants.STATUS_NEW;
            tl2.In_Call_Plan__c = false;
            insert tl2;

            Campaign camp3 = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign3', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, 'SME- Lead / Campaign', GlobalConstants.LEAD_TO_INFORM);
            camp3.StartDate = System.Today() - 1;
            camp3.EndDate = System.Today() + 1;
            camp3.IsActive = true;
            insert camp3;

            Target_List__c tl3 = new Target_List__c();
            tl3.CIS_ID_Prospect_Name__c = targetAccount.Id;
            tl3.Lead_Campaign__c = camp3.Id;
            tl3.Status__c = GlobalConstants.STATUS_NEW;
            tl3.In_Call_Plan__c = false;
            insert tl3;

            Campaign camp4 = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign4', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, 'SME- Lead / Campaign', GlobalConstants.LEAD_FOR_SALES);
            camp4.StartDate = System.Today() - 1;
            camp4.EndDate = System.Today() + 1;
            camp4.IsActive = true;
            insert camp4;

            Target_List__c tl4 = new Target_List__c();
            tl4.CIS_ID_Prospect_Name__c = targetAccount.Id;
            tl4.Lead_Campaign__c = camp4.Id;
            tl4.Status__c = GlobalConstants.STATUS_NEW;
            tl4.In_Call_Plan__c = false;
            insert tl4;
            
            GlobalUtility.runOnce = false;
            
            Campaign editCamp1 = [SELECT Id FROM Campaign WHERE Id = :camp.Id];
            editCamp1.Status = GlobalConstants.CANCEL_PROCESS;
            update editCamp1;

            Campaign expectCamp1 = [SELECT Id, Status FROM Campaign WHERE Id = :camp.Id];
            System.assertEquals(GlobalConstants.CANCEL_PROCESS, expectCamp1.Status);
            Database.executeBatch(new AccountLeadInitial_Batch(), 2000);
        Test.stopTest();

        Campaign finalCamp1 = [SELECT Id, Status FROM Campaign WHERE Id = :camp.Id];
        System.assertEquals(GlobalConstants.CANCEL, finalCamp1.Status);

        Account finalAcc = [SELECT Id, Lead_To_Inform__c, Lead_for_Sales__c FROM Account WHERE Id = :targetAccount.Id LIMIT 1];
        System.assertEquals(camp.Name + ',' + camp2.Name + ',' + camp3.Name, finalAcc.Lead_To_Inform__c);
        System.assertEquals(camp4.Name, finalAcc.Lead_for_Sales__c);
    }

    @isTest static void testStampAccountLeadExpire() {
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Campaign_Test.accountNameRM, 'Id');
        targetAccount.CIS__c = '555555555';
        TriggerHandler.bypass('AccountTriggerHandler');
        update targetAccount;
        TriggerHandler.clearbypass('AccountTriggerHandler');
        Test.startTest();

            Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, 'SME- Lead / Campaign', GlobalConstants.LEAD_TO_DO, GlobalConstants.LEAD_SUB_TYPE_TO_INFORM);
            camp.StartDate = System.Today() - 1;
            camp.EndDate = System.Today() + 1;
            camp.IsActive = true;
            insert camp;

            Target_List__c tl = new Target_List__c();
            tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
            tl.Lead_Campaign__c = camp.Id;
            tl.Status__c = GlobalConstants.STATUS_NEW;
            tl.In_Call_Plan__c = false;
            insert tl;

            Campaign camp2 = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign2', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, 'SME- Lead / Campaign', GlobalConstants.LEAD_TO_DO, GlobalConstants.LEAD_SUB_TYPE_TO_INFORM);
            camp2.StartDate = System.Today() - 1;
            camp2.EndDate = System.Today() + 1;
            camp2.IsActive = true;
            insert camp2;

            Target_List__c tl2 = new Target_List__c();
            tl2.CIS_ID_Prospect_Name__c = targetAccount.Id;
            tl2.Lead_Campaign__c = camp2.Id;
            tl2.Status__c = GlobalConstants.STATUS_NEW;
            tl2.In_Call_Plan__c = false;
            insert tl2;

            Campaign camp3 = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign3', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, 'SME- Lead / Campaign', GlobalConstants.LEAD_TO_DO, GlobalConstants.LEAD_SUB_TYPE_TO_INFORM);
            camp3.StartDate = System.Today() - 1;
            camp3.EndDate = System.Today() + 1;
            camp3.IsActive = true;
            insert camp3;

            Target_List__c tl3 = new Target_List__c();
            tl3.CIS_ID_Prospect_Name__c = targetAccount.Id;
            tl3.Lead_Campaign__c = camp3.Id;
            tl3.Status__c = GlobalConstants.STATUS_NEW;
            tl3.In_Call_Plan__c = false;
            insert tl3;

            GlobalUtility.runOnce = false;
            
            Campaign editCamp1 = [SELECT Id FROM Campaign WHERE Id = :camp.Id];
            editCamp1.IsActive = false;
            editCamp1.Status = GlobalConstants.EXPIRE_PROCESS;
            update editCamp1;

            Database.executeBatch(new AccountLeadInitial_Batch(), 2000);

        Test.stopTest();

        Campaign finalCamp1 = [SELECT Id, Status FROM Campaign WHERE Id = :camp.Id];
        System.assertEquals(GlobalConstants.EXPIRED, finalCamp1.Status);

        Account finalAcc = [SELECT Id, Lead_To_Do__c FROM Account WHERE Id = :targetAccount.Id LIMIT 1];
        System.assertEquals(camp.Name + ',' + camp2.Name + ',' + camp3.Name, finalAcc.Lead_To_Do__c); 
    }

    @isTest static void testCancelCampaignBlockLead() {
        Boolean expectedTargetListFlag = true;

        Account targetAccount = Mockup_Test.getFirstAccountFromName(Campaign_Test.accountNameRM, 'Id');
        Campaign cm = new Campaign();
        cm.Lead_Campaign_Event_Code__c = 'TestCampaign';
        cm.Type__c = GlobalConstants.LEAD_FOR_SALES;
        cm.Sub_Type__c = 'Strong Formula';
        cm.Name = 'TestCampaign';
        cm.IsActive = true;
        cm.Status = 'Active';
        cm.StartDate = System.Today() - 1;
        cm.EndDate = System.Today() + 1;
        cm.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('SME- Lead / Campaign');
        insert cm;

        Target_List__c tl = new Target_List__c();
        tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
        tl.Lead_Campaign__c = cm.Id;
        tl.Status__c = GlobalConstants.STATUS_NEW;
        tl.In_Call_Plan__c = true;
        insert tl;

        Campaign updatedCampaign = [SELECT Id, Start_Date_Time__c, End_Date_Time__c, Attendee_Confirmation_Date__c FROM Campaign WHERE Id = :cm.Id][0];
            
        updatedCampaign.Reason_for_Cancellation__c = 'test Cancel';
        updatedCampaign.Status = GlobalConstants.CANCEL;

        Test.startTest();
            GlobalUtility.runOnce = false;
            update updatedCampaign;
        Test.stopTest();

        Target_List__c finalTarget = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :targetAccount.Id AND Id = :tl.Id];
        System.assertEquals(GlobalConstants.STATUS_NEW, finalTarget.Status__c);
    }

    @isTest static void testCancelCampaignNotBlockLead() {
        Boolean expectedTargetListFlag = true;

        Account targetAccount = Mockup_Test.getFirstAccountFromName(Campaign_Test.accountNameRM, 'Id');
        Campaign cm = new Campaign();
        cm.Lead_Campaign_Event_Code__c = 'TestCampaign';
        cm.Type__c = GlobalConstants.LEAD_FOR_SALES;
        cm.Sub_Type__c = 'Strong Formula';
        cm.Name = 'TestCampaign';
        cm.IsActive = true;
        cm.Status = 'Active';
        cm.StartDate = System.Today() - 1;
        cm.EndDate = System.Today() + 1;
        cm.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('SME- Lead / Campaign');
        insert cm;

        Target_List__c tl = new Target_List__c();
        tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
        tl.Lead_Campaign__c = cm.Id;
        tl.Status__c = GlobalConstants.STATUS_NEW;
        insert tl;

        Campaign updatedCampaign = [SELECT Id, Start_Date_Time__c, End_Date_Time__c, Attendee_Confirmation_Date__c FROM Campaign WHERE Id = :cm.Id][0];
            
        updatedCampaign.Reason_for_Cancellation__c = 'test Cancel';
        updatedCampaign.Status = GlobalConstants.CANCEL_PROCESS;

        Test.startTest();
            GlobalUtility.runOnce = false;
            update updatedCampaign;
        Test.stopTest();

        Target_List__c finalTarget = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :targetAccount.Id AND Id = :tl.Id];
        System.assertEquals(GlobalConstants.CANCEL_LEAD, finalTarget.Status__c);
    }

    @isTest static void testManyLeadExpire() {
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Campaign_Test.accountNameRM, 'Id');
        Test.startTest();

            Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, 'SME- Lead / Campaign', GlobalConstants.LEAD_TO_DO, GlobalConstants.LEAD_SUB_TYPE_TO_INFORM);
            camp.StartDate = System.Today() - 1;
            camp.EndDate = System.Today() + 1;
            camp.IsActive = true;
            insert camp;

            Target_List__c tl = new Target_List__c();
            tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
            tl.Lead_Campaign__c = camp.Id;
            tl.Status__c = GlobalConstants.STATUS_NEW;
            tl.In_Call_Plan__c = false;
            insert tl;

            Campaign camp2 = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign2', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, 'SME- Lead / Campaign', GlobalConstants.LEAD_TO_DO, GlobalConstants.LEAD_SUB_TYPE_TO_INFORM);
            camp2.StartDate = System.Today() - 1;
            camp2.EndDate = System.Today() + 1;
            camp2.IsActive = true;
            insert camp2;

            Target_List__c tl2 = new Target_List__c();
            tl2.CIS_ID_Prospect_Name__c = targetAccount.Id;
            tl2.Lead_Campaign__c = camp2.Id;
            tl2.Status__c = GlobalConstants.STATUS_NEW;
            tl2.In_Call_Plan__c = false;
            insert tl2;

            Campaign camp3 = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign3', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, 'SME- Lead / Campaign', GlobalConstants.LEAD_TO_DO, GlobalConstants.LEAD_SUB_TYPE_TO_INFORM);
            camp3.StartDate = System.Today() - 1;
            camp3.EndDate = System.Today() + 1;
            camp3.IsActive = true;
            insert camp3;

            Target_List__c tl3 = new Target_List__c();
            tl3.CIS_ID_Prospect_Name__c = targetAccount.Id;
            tl3.Lead_Campaign__c = camp3.Id;
            tl3.Status__c = GlobalConstants.STATUS_NEW;
            tl3.In_Call_Plan__c = false;
            insert tl3;

            GlobalUtility.runOnce = false;
            
            Campaign editCamp1 = [SELECT Id FROM Campaign WHERE Name = 'Campaign1'];
            editCamp1.Status = GlobalConstants.EXPIRE_PROCESS;
            update editCamp1;

            Campaign editCamp2 = [SELECT Id FROM Campaign WHERE Name = 'Campaign2'];
            editCamp2.Status = GlobalConstants.EXPIRE_PROCESS;
            update editCamp2;

            Campaign editCamp3 = [SELECT Id FROM Campaign WHERE Name = 'Campaign3'];
            editCamp3.Status = GlobalConstants.EXPIRE_PROCESS;
            update editCamp3;

        Test.stopTest();

        Campaign finalCamp1 = [SELECT Id, Status FROM Campaign WHERE Name = 'Campaign1'];
        System.assertEquals(GlobalConstants.EXPIRED, finalCamp1.Status);

        Campaign finalCamp2 = [SELECT Id, Status FROM Campaign WHERE Name = 'Campaign2'];
        System.assertEquals(GlobalConstants.EXPIRED, finalCamp2.Status);

        Campaign finalCamp3 = [SELECT Id, Status FROM Campaign WHERE Name = 'Campaign3'];
        System.assertEquals(GlobalConstants.EXPIRED, finalCamp3.Status);
    }

    @isTest static void testActiveCampaignForActionStampAccountCBS() {
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Campaign_Test.accountNameRM, 'Id');
        targetAccount.CIS__c = '555555555';
        TriggerHandler.bypass('AccountTriggerHandler');
        update targetAccount;
        TriggerHandler.clearbypass('AccountTriggerHandler');
        Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.PLANNED, 'CBS - Lead', GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER);
        camp.StartDate = System.Today() - 1;
        camp.EndDate = System.Today() + 1;
        camp.IsActive = false;
        camp.Sub_Type_CBS__c = 'PN Unused';
        insert camp;

        Target_List__c tl = new Target_List__c();
        tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
        tl.Lead_Campaign__c = camp.Id;
        tl.Status__c = GlobalConstants.STATUS_NEW;
        insert tl;

        Test.startTest();
            GlobalUtility.runOnce = false;
            Campaign targetCamp = [SELECT Id FROM Campaign WHERE Name = 'Campaign1' LIMIT 1];
            targetCamp.Status = 'Active';
            update targetCamp;

            Database.executeBatch(new AccountLeadInitial_Batch(), 2000);
        Test.stopTest();

        Account finalAcc = [SELECT Id, Lead_To_Do__c, Lead_To_Inform__c,Lead_for_Sales__c,Lead_for_Feedback_CBS__c,Lead_for_Action_with_Customer_CBS__c FROM Account WHERE Id = :targetAccount.Id LIMIT 1];
        System.assertEquals(camp.Name, finalAcc.Lead_for_Action_with_Customer_CBS__c);
    }
    @isTest static void testActiveCampaignForFeedbackStampAccountCBS() {
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Campaign_Test.accountNameRM, 'Id');
        targetAccount.CIS__c = '555555555';
        TriggerHandler.bypass('AccountTriggerHandler');
        update targetAccount;
        TriggerHandler.clearbypass('AccountTriggerHandler');
        Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.PLANNED, 'CBS - Lead', GlobalConstants.LEAD_FOR_FEEDBACK);
        camp.StartDate = System.Today() - 1;
        camp.EndDate = System.Today() + 1;
        camp.IsActive = false;
        camp.Sub_Type_CBS__c = 'PN Unused';
        insert camp;

        Target_List__c tl = new Target_List__c();
        tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
        tl.Lead_Campaign__c = camp.Id;
        tl.Status__c = GlobalConstants.STATUS_NEW;
        insert tl;

        Test.startTest();
            GlobalUtility.runOnce = false;
            Campaign targetCamp = [SELECT Id FROM Campaign WHERE Name = 'Campaign1' LIMIT 1];
            targetCamp.Status = 'Active';
            update targetCamp;

            Database.executeBatch(new AccountLeadInitial_Batch(), 2000);
        Test.stopTest();

        Account finalAcc = [SELECT Id, Lead_To_Do__c, Lead_To_Inform__c,Lead_for_Sales__c,Lead_for_Feedback_CBS__c,Lead_for_Action_with_Customer_CBS__c FROM Account WHERE Id = :targetAccount.Id LIMIT 1];
        System.assertEquals(camp.Name, finalAcc.Lead_for_Feedback_CBS__c);
    }

    @isTest static void testActiveCampaignByBatch() {
        Account targetAccount = Mockup_Test.getFirstAccountFromName(Campaign_Test.accountNameRM, 'Id');
        Campaign camp1 = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.PLANNED,GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_FEEDBACK);
        camp1.StartDate = System.Today() - 1;
        camp1.EndDate = System.Today() + 1;
        camp1.IsActive = false;
        TriggerHandler.bypass('CampaignTriggerHandler');
        insert camp1;
        TriggerHandler.clearbypass('CampaignTriggerHandler');

        Target_List__c tl1 = new Target_List__c();
        tl1.CIS_ID_Prospect_Name__c = targetAccount.Id;
        tl1.Lead_Campaign__c = camp1.Id;
        tl1.Status__c = GlobalConstants.STATUS_NEW;
        insert tl1;

        Campaign camp2 = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign2', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.PLANNED,GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_FEEDBACK);
        camp2.StartDate = System.Today() + 1;
        camp2.EndDate = System.Today() + 2;
        camp2.IsActive = false;
        TriggerHandler.bypass('CampaignTriggerHandler');
        insert camp2;
        TriggerHandler.clearbypass('CampaignTriggerHandler');

        Target_List__c tl2 = new Target_List__c();
        tl2.CIS_ID_Prospect_Name__c = targetAccount.Id;
        tl2.Lead_Campaign__c = camp2.Id;
        tl2.Status__c = GlobalConstants.STATUS_NEW;
        insert tl2;

        Test.startTest();
            Database.executeBatch(new CampaignActive_Batch(), 2000);
        Test.stopTest();

        Campaign finalCam1 = [SELECT Id, Status, IsActive FROM Campaign WHERE Name = 'Campaign1' LIMIT 1];
        System.assertEquals(GlobalConstants.ACTIVE, finalCam1.Status);
        System.assertEquals(true, finalCam1.IsActive);

        Campaign finalCam2 = [SELECT Id, Status, IsActive FROM Campaign WHERE Name = 'Campaign2' LIMIT 1];
        System.assertEquals(GlobalConstants.PLANNED, finalCam2.Status);
        System.assertEquals(false, finalCam2.IsActive);
    }
}