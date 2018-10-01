@isTest
private class SME_Initial_ContactedAccount_Test {
    
    public static String O_CUSTOMER_RM_TEMP_POOL    = 'A';
    public static String O_CUSTOMER_RM_PER_PORT     = 'B';
    public static String I_PROSPECT_RM_TEMP         = 'C';
    public static String O_CUSTOMER_TM_PORT_PER     = 'D';
    public static String O_CUSTOMER_ADMIN_PER       = 'E';
    @testSetup static void setupAccount(){
        // Given
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestAdmin().setUpTestWithExtension();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            insert Mockup_Test.newAccountWithSegment(O_CUSTOMER_TM_PORT_PER, GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER), GlobalConstants.PRIMARY_SEGMENT_CODE_UM);
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            insert Mockup_Test.newAccountWithSegment(O_CUSTOMER_RM_TEMP_POOL, GlobalConstants.POOL, GlobalConstants.OWNERSHIP_TEMPORARY, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER), GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
            insert Mockup_Test.newAccountWithSegment(I_PROSPECT_RM_TEMP, '', GlobalConstants.OWNERSHIP_TEMPORARY, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.INDIVIDUAL_PROSPECT), GlobalConstants.PRIMARY_SEGMENT_CODE_UM);
            Account accountPortPer = Mockup_Test.newAccountWithSegment(O_CUSTOMER_RM_PER_PORT, GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT), GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
            accountPortPer.Service_RM__c = UserInfo.getUserId();
            insert accountPortPer;
            Opportunity oppPortPer = Mockup_Test.newOpportunity(accountPortPer.Id, 'OppPortPer', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
            insert oppPortPer;
        }
        Test.stopTest();

        System.runAs(new User(Id = UserInfo.getUserId())){
            User userRM = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
            userRM.Segment__c  = 'SE';
            TriggerHandler.bypass('UserTriggerHandler');
            update userRM;
            TriggerHandler.clearbypass('UserTriggerHandler');
        }
    }
    @isTest static void initialCase(){
        // Given
        Account targetAccount = Mockup_Test.getFirstAccountFromName(O_CUSTOMER_RM_PER_PORT, 'Id,Delete_Flag__c,Ownership_Text__c');
        System.assertEquals('Permanent',targetAccount.Ownership_Text__c);
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        TriggerHandler.bypass('EventTriggerHandler');
        System.runAs(userRM){
            Opportunity oppPortPer = [SELECT Id FROM Opportunity WHERE Name = 'OppPortPer'];
            List<Event> listRmEvent = new List<Event>();
            listRmEvent.add(new Event(
                WhatId = oppPortPer.Id,
                Job__c = oppPortPer.Id,
                OwnerId = userRM.Id,
                StartDateTime = System.now(),
                EndDateTime = System.now(),
                RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
                Visit_Objective__c = 'เพื่อขาย',
                Servicing__c = true,
                Offer_Credit_Product__c = false,
                Status__c = 'Contacted',
                Contact_Channel__c = GlobalConstants.FACE_TO_FACE
            ));
            listRmEvent.add(new Event(
                WhatId = oppPortPer.Id,
                Job__c = oppPortPer.Id,
                OwnerId = userRM.Id,
                StartDateTime = System.now(),
                EndDateTime = System.now(),
                RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
                Visit_Objective__c = 'เพื่อขาย',
                Servicing__c = true,
                Offer_Credit_Product__c = false,
                Status__c = 'Contacted',
                Contact_Channel__c = GlobalConstants.FACE_TO_FACE
            ));
            listRmEvent.add(new Event(
                WhatId = oppPortPer.Id,
                Job__c = oppPortPer.Id,
                OwnerId = userRM.Id,
                StartDateTime = System.now(),
                EndDateTime = System.now(),
                RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
                Visit_Objective__c = 'เพื่อขาย',
                Servicing__c = true,
                Offer_Credit_Product__c = false,
                Status__c = 'Contacted',
                Contact_Channel__c = GlobalConstants.PHONE_CALL
            ));
            insert listRmEvent;
        }

        System.runAs(userTM){
            Opportunity oppPortPer = [SELECT Id FROM Opportunity WHERE Name = 'OppPortPer'];
            List<Event> listTmEvent = new List<Event>();
            listTmEvent.add(new Event(
                WhatId = oppPortPer.Id,
                Job__c = oppPortPer.Id,
                OwnerId = userTM.Id,
                StartDateTime = System.now(),
                EndDateTime = System.now(),
                RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
                Visit_Objective__c = 'เพื่อขาย',
                Servicing__c = true,
                Offer_Credit_Product__c = false,
                Status__c = 'Contacted',
                Contact_Channel__c = GlobalConstants.PHONE_CALL
            ));
            listTmEvent.add(new Event(
                WhatId = oppPortPer.Id,
                Job__c = oppPortPer.Id,
                OwnerId = userTM.Id,
                StartDateTime = System.now(),
                EndDateTime = System.now(),
                RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_PLAN_DEVNAME),
                Visit_Objective__c = 'เพื่อขาย',
                Plan_Amount__c = 100000,
                Status__c = 'Plan',
                Contact_Channel__c = GlobalConstants.PHONE_CALL
            ));
            insert listTmEvent;
        }
        TriggerHandler.clearbypass('EventTriggerHandler');
        //When
        Test.startTest();
            Database.executeBatch(new SME_Initial_ContactedAccount_Batch());
        Test.stopTest();

        //Then
        //Account accountResult = Mockup_Test.getFirstAccountFromName(O_CUSTOMER_RM_PER_PORT, 'Id,Count_Call_Report_RM__c,Count_Contacted_Call_Report__c,Count_Contacted_Call_Report_F2F__c,Count_Contacted_Call_Report_Phone_Call__c,Count_Contacted_Call_Report_My_Pen_F2F__c,Count_Contacted_Call_Report_My_Pen_Call__c,Count_Contacted_CR_My_Pen_Service_F2F__c,Count_Contacted_CR_My_Pen_Service_Call__c');
        Contacted_Account__c accountResult = [SELECT Count_Call_Report_RM__c,Count_Contacted_Call_Report__c,Count_Contacted_Call_Report_F2F__c,Count_Contacted_Call_Report_Phone_Call__c,Count_Contacted_Call_Report_My_Pen_F2F__c,Count_Contacted_Call_Report_My_Pen_Call__c,Count_Contacted_CR_My_Pen_Service_F2F__c,Count_Contacted_CR_My_Pen_Service_Call__c FROM Contacted_Account__c WHERE Lookup_Customer__r.Id = :targetAccount.Id];
        System.assertEquals(2,accountResult.Count_Contacted_Call_Report_F2F__c);
        System.assertEquals(2,accountResult.Count_Contacted_Call_Report_My_Pen_F2F__c);
        System.assertEquals(2,accountResult.Count_Contacted_Call_Report_Phone_Call__c);
        System.assertEquals(1,accountResult.Count_Contacted_Call_Report_My_Pen_Call__c);
        System.assertEquals(3,accountResult.Count_Call_Report_RM__c);
        System.assertEquals(5,accountResult.Count_Contacted_Call_Report__c);
        System.assertEquals(2, accountResult.Count_Contacted_CR_My_Pen_Service_F2F__c);
        System.assertEquals(1, accountResult.Count_Contacted_CR_My_Pen_Service_Call__c);
    }
}