@isTest
private class CalculatePerformanceFromAccount_Test {
    public static String O_CUSTOMER_RM_TEMP_POOL    = 'A';
    public static String O_CUSTOMER_RM_PER_PORT     = 'B';
    public static String O_CUSTOMER_RM              = 'C';

    @testSetup static void setupAccount(){
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestAdmin().setUpTestWithExtension();
        Test.stopTest();

        System.runAs(new User(Id = UserInfo.getUserId())){
            User userRM = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
            userRM.Segment__c  = 'SE';
            TriggerHandler.bypass('UserTriggerHandler');
            update userRM;
            TriggerHandler.clearbypass('UserTriggerHandler');
        }
    }

    @isTest static void givenAccountPermanentPortF2F() {
        //Given
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Account accountPerPort;
        System.runAs(userRM){
            accountPerPort = Mockup_Test.newAccountWithSegment(O_CUSTOMER_RM_PER_PORT, GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT), GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
            accountPerPort.Service_RM__c = UserInfo.getUserId();
            insert accountPerPort;

            Opportunity oppPerPort = Mockup_Test.newOpportunity(accountPerPort.Id, 'oppPerPort', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
            insert oppPerPort;

            insert new Event(
                WhatId = oppPerPort.Id,
                Job__c = oppPerPort.Id,
                OwnerId = userRM.Id,
                StartDateTime = System.now(),
                EndDateTime = System.now(),
                RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
                Visit_Objective__c = 'เพื่อขาย',
                Servicing__c = true,
                Offer_Credit_Product__c = false,
                Status__c = 'Contacted',
                Contact_Channel__c = GlobalConstants.FACE_TO_FACE
            );
        }

        Contacted_Account__c newContactedAccount = new Contacted_Account__c();
        newContactedAccount.Lookup_Customer__c = accountPerPort.Id;
        newContactedAccount.Count_Contacted_Call_Report_F2F__c           = 2;
        newContactedAccount.Count_Contacted_Call_Report_Phone_Call__c    = 2;
        newContactedAccount.Count_Contacted_Call_Report_My_Pen_F2F__c    = 2;
        newContactedAccount.Count_Contacted_Call_Report_My_Pen_Call__c   = 1;
        newContactedAccount.Count_Contacted_CR_My_Pen_Service_F2F__c     = 2;
        newContactedAccount.Count_Contacted_CR_My_Pen_Service_Call__c    = 1;
        newContactedAccount.Count_Contacted_Call_Report__c               = 5;
        insert newContactedAccount;

        //When
        Test.startTest();
            Database.executeBatch(new CalculatePerformanceFromAccount_Batch());
        Test.stopTest();

        //Then
        User_Extension__c userExt = [SELECT Id, Contacted_Customer_Other__c, Contacted_Customer_Pool__c, Contacted_Customer_Port__c, Customer_Other__c, Customer_Pool__c, Customer_Port__c, Total_visited_Customer__c, Contacted_Customer_Other_My_Penetrate__c, Contacted_Customer_Pool_My_Penetrate__c, Contacted_Customer_Port_My_Penetrate__c, Contacted_Other_CustCall__c, Contacted_Other_CustF2F__c, Contacted_Pool_CustCall__c, Contacted_Pool_CustF2F__c, Contacted_Port_CustCall__c, Contacted_Port_CustF2F__c, My_Penetrate_Contacted_Other_CustCall__c, My_Penetrate_Contacted_Other_CustF2F__c, My_Penetrate_Contacted_Pool_CustCall__c, My_Penetrate_Contacted_Pool_CustF2F__c, My_Penetrate_Contacted_Port_CustCall__c, My_Penetrate_Contacted_Port_CustF2F__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM];
        System.assertEquals(0, userExt.Customer_Other__c);
        System.assertEquals(0, userExt.Customer_Pool__c);
        System.assertEquals(1, userExt.Customer_Port__c);
        System.assertEquals(0, userExt.Contacted_Customer_Other__c);
        System.assertEquals(0, userExt.Contacted_Customer_Pool__c);
        System.assertEquals(1, userExt.Contacted_Customer_Port__c);
        System.assertEquals(1, userExt.Total_visited_Customer__c);
        System.assertEquals(0, userExt.Contacted_Customer_Other_My_Penetrate__c);
        System.assertEquals(0, userExt.Contacted_Customer_Pool_My_Penetrate__c);
        System.assertEquals(1, userExt.Contacted_Customer_Port_My_Penetrate__c);
        
        System.assertEquals(0, userExt.Contacted_Other_CustCall__c);
        System.assertEquals(0, userExt.Contacted_Other_CustF2F__c);
        System.assertEquals(0, userExt.Contacted_Pool_CustCall__c);
        System.assertEquals(0, userExt.Contacted_Pool_CustF2F__c);
        System.assertEquals(0, userExt.Contacted_Port_CustCall__c);
        System.assertEquals(1, userExt.Contacted_Port_CustF2F__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Other_CustCall__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Other_CustF2F__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Pool_CustCall__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Pool_CustF2F__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Port_CustCall__c);
        System.assertEquals(1, userExt.My_Penetrate_Contacted_Port_CustF2F__c);
    }
    
    @isTest static void givenAccountTemporaryPoolNoF2F() {
        //Given
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Account accountTempPool;
        System.runAs(userRM){
            accountTempPool = Mockup_Test.newAccountWithSegment(O_CUSTOMER_RM_TEMP_POOL, GlobalConstants.POOL, GlobalConstants.OWNERSHIP_TEMPORARY, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER), GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
            insert accountTempPool;

            Opportunity oppTempPool = Mockup_Test.newOpportunity(accountTempPool.Id, 'oppTempPool', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
            insert oppTempPool;

            insert new Event(
                WhatId = oppTempPool.Id,
                Job__c = oppTempPool.Id,
                OwnerId = userRM.Id,
                StartDateTime = System.now(),
                EndDateTime = System.now(),
                RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
                Visit_Objective__c = 'เพื่อขาย',
                Servicing__c = true,
                Offer_Credit_Product__c = false,
                Status__c = 'Contacted',
                Contact_Channel__c = GlobalConstants.FACE_TO_FACE
            );
        }

        Contacted_Account__c newContactedAccount = new Contacted_Account__c();
        newContactedAccount.Lookup_Customer__c = accountTempPool.Id;
        newContactedAccount.Count_Contacted_Call_Report_F2F__c          = 0;
        newContactedAccount.Count_Contacted_Call_Report_Phone_Call__c   = 4;
        newContactedAccount.Count_Contacted_Call_Report_My_Pen_F2F__c   = 0;
        newContactedAccount.Count_Contacted_Call_Report_My_Pen_Call__c  = 2;
        newContactedAccount.Count_Contacted_CR_My_Pen_Service_F2F__c    = 0;
        newContactedAccount.Count_Contacted_CR_My_Pen_Service_Call__c   = 1;
        newContactedAccount.Count_Contacted_Call_Report__c              = 3;
        insert newContactedAccount;

        //When
        Test.startTest();
            Database.executeBatch(new CalculatePerformanceFromAccount_Batch());
        Test.stopTest();

        //Then
        User_Extension__c userExt = [SELECT Id, Contacted_Customer_Other__c, Contacted_Customer_Pool__c, Contacted_Customer_Port__c, Customer_Other__c, Customer_Pool__c, Customer_Port__c, Total_visited_Customer__c, Contacted_Customer_Other_My_Penetrate__c, Contacted_Customer_Pool_My_Penetrate__c, Contacted_Customer_Port_My_Penetrate__c, Contacted_Other_CustCall__c, Contacted_Other_CustF2F__c, Contacted_Pool_CustCall__c, Contacted_Pool_CustF2F__c, Contacted_Port_CustCall__c, Contacted_Port_CustF2F__c, My_Penetrate_Contacted_Other_CustCall__c, My_Penetrate_Contacted_Other_CustF2F__c, My_Penetrate_Contacted_Pool_CustCall__c, My_Penetrate_Contacted_Pool_CustF2F__c, My_Penetrate_Contacted_Port_CustCall__c, My_Penetrate_Contacted_Port_CustF2F__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM];
        System.assertEquals(0, userExt.Customer_Other__c);
        System.assertEquals(1, userExt.Customer_Pool__c);
        System.assertEquals(0, userExt.Customer_Port__c);
        System.assertEquals(0, userExt.Contacted_Customer_Other__c);
        System.assertEquals(1, userExt.Contacted_Customer_Pool__c);
        System.assertEquals(0, userExt.Contacted_Customer_Port__c);
        System.assertEquals(0, userExt.Total_visited_Customer__c);
        System.assertEquals(0, userExt.Contacted_Customer_Other_My_Penetrate__c);
        System.assertEquals(1, userExt.Contacted_Customer_Pool_My_Penetrate__c);
        System.assertEquals(0, userExt.Contacted_Customer_Port_My_Penetrate__c);
        
        System.assertEquals(0, userExt.Contacted_Other_CustCall__c);
        System.assertEquals(0, userExt.Contacted_Other_CustF2F__c);
        System.assertEquals(1, userExt.Contacted_Pool_CustCall__c);
        System.assertEquals(0, userExt.Contacted_Pool_CustF2F__c);
        System.assertEquals(0, userExt.Contacted_Port_CustCall__c);
        System.assertEquals(0, userExt.Contacted_Port_CustF2F__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Other_CustCall__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Other_CustF2F__c);
        System.assertEquals(1, userExt.My_Penetrate_Contacted_Pool_CustCall__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Pool_CustF2F__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Port_CustCall__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Port_CustF2F__c);
    }
    
    @isTest static void givenAccountBlankPortPoolOwnership() {
        //Given
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Account mAccount;
        System.runAs(userRM){
            mAccount = Mockup_Test.newAccountWithSegment(O_CUSTOMER_RM, '', '', Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT), GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
            mAccount.Service_RM__c = UserInfo.getUserId();
            insert mAccount;

            Opportunity mOpp = Mockup_Test.newOpportunity(mAccount.Id, 'mOpp', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
            insert mOpp;

            insert new Event(
                WhatId = mOpp.Id,
                Job__c = mOpp.Id,
                OwnerId = userRM.Id,
                StartDateTime = System.now(),
                EndDateTime = System.now(),
                RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
                Visit_Objective__c = 'เพื่อขาย',
                Servicing__c = true,
                Offer_Credit_Product__c = false,
                Status__c = 'Contacted',
                Contact_Channel__c = GlobalConstants.FACE_TO_FACE
            );
        }

        Contacted_Account__c newContactedAccount = new Contacted_Account__c();
        newContactedAccount.Lookup_Customer__c = mAccount.Id;
        newContactedAccount.Count_Contacted_Call_Report_F2F__c           = 2;
        newContactedAccount.Count_Contacted_Call_Report_Phone_Call__c    = 2;
        newContactedAccount.Count_Contacted_Call_Report_My_Pen_F2F__c    = 2;
        newContactedAccount.Count_Contacted_Call_Report_My_Pen_Call__c   = 1;
        newContactedAccount.Count_Contacted_CR_My_Pen_Service_F2F__c     = 2;
        newContactedAccount.Count_Contacted_CR_My_Pen_Service_Call__c    = 1;
        newContactedAccount.Count_Contacted_Call_Report__c               = 5;
        insert newContactedAccount;
            
        //When
        Test.startTest();
            Database.executeBatch(new CalculatePerformanceFromAccount_Batch());
        Test.stopTest();

        //Then
        User_Extension__c userExt = [SELECT Id, Contacted_Customer_Other__c, Contacted_Customer_Pool__c, Contacted_Customer_Port__c, Customer_Other__c, Customer_Pool__c, Customer_Port__c, Total_visited_Customer__c, Contacted_Customer_Other_My_Penetrate__c, Contacted_Customer_Pool_My_Penetrate__c, Contacted_Customer_Port_My_Penetrate__c, Contacted_Other_CustCall__c, Contacted_Other_CustF2F__c, Contacted_Pool_CustCall__c, Contacted_Pool_CustF2F__c, Contacted_Port_CustCall__c, Contacted_Port_CustF2F__c, My_Penetrate_Contacted_Other_CustCall__c, My_Penetrate_Contacted_Other_CustF2F__c, My_Penetrate_Contacted_Pool_CustCall__c, My_Penetrate_Contacted_Pool_CustF2F__c, My_Penetrate_Contacted_Port_CustCall__c, My_Penetrate_Contacted_Port_CustF2F__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM];
        System.assertEquals(1, userExt.Customer_Other__c);
        System.assertEquals(0, userExt.Customer_Pool__c);
        System.assertEquals(0, userExt.Customer_Port__c);
        System.assertEquals(1, userExt.Contacted_Customer_Other__c);
        System.assertEquals(0, userExt.Contacted_Customer_Pool__c);
        System.assertEquals(0, userExt.Contacted_Customer_Port__c);
        System.assertEquals(1, userExt.Total_visited_Customer__c);
        System.assertEquals(1, userExt.Contacted_Customer_Other_My_Penetrate__c);
        System.assertEquals(0, userExt.Contacted_Customer_Pool_My_Penetrate__c);
        System.assertEquals(0, userExt.Contacted_Customer_Port_My_Penetrate__c);
        
        System.assertEquals(0, userExt.Contacted_Other_CustCall__c);
        System.assertEquals(1, userExt.Contacted_Other_CustF2F__c);
        System.assertEquals(0, userExt.Contacted_Pool_CustCall__c);
        System.assertEquals(0, userExt.Contacted_Pool_CustF2F__c);
        System.assertEquals(0, userExt.Contacted_Port_CustCall__c);
        System.assertEquals(0, userExt.Contacted_Port_CustF2F__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Other_CustCall__c);
        System.assertEquals(1, userExt.My_Penetrate_Contacted_Other_CustF2F__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Pool_CustCall__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Pool_CustF2F__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Port_CustCall__c);
        System.assertEquals(0, userExt.My_Penetrate_Contacted_Port_CustF2F__c);
    }
}