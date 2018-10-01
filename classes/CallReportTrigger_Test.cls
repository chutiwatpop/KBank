@isTest
//@21/06/2016 Nareerat.wo@kbtg.tech   Add test code for Test method insertingTask_InterestWithCondition at class CallReportTriggerHandler .
private class CallReportTrigger_Test {
    
    @isTest static void testFirstReschedule() {
        Integer expectedNumOfReschedule = 1;
        // Implement test code
        Account acc = new Account();
        //acc.RecordTypeId = CustomerRecordTypeId;
        acc.Name = 'TestName';
        insert acc;

        Call_Report__c callReport = new Call_Report__c();
        callReport.CIS_ID__c = acc.Id;
        insert callReport;

        Test.startTest();
        callReport.Plan_Date__c = Date.today();
        update callReport;
        Test.stopTest();

        Call_Report__c actualQueryReport = [SELECT Id,Number_of_Reschedule__c FROM Call_Report__c WHERE Id = :callReport.Id];
        System.assertEquals(expectedNumOfReschedule,actualQueryReport.Number_of_Reschedule__c);
    }    

    @isTest static void testSecondReschedule() {
        Integer expectedNumOfReschedule = 2;
        // Implement test code
        Account acc = new Account();
        //acc.RecordTypeId = CustomerRecordTypeId;
        acc.Name = 'TestName';
        insert acc;

        Call_Report__c callReport = new Call_Report__c();
        callReport.CIS_ID__c = acc.Id;
        callReport.Number_of_Reschedule__c = 1;
        insert callReport;

        Test.startTest();
        callReport.Plan_Date__c = Date.today();
        update callReport;
        Test.stopTest();

        Call_Report__c actualQueryReport = [SELECT Id,Number_of_Reschedule__c FROM Call_Report__c WHERE Id = :callReport.Id];
        System.assertEquals(expectedNumOfReschedule,actualQueryReport.Number_of_Reschedule__c);
    }

    @isTest static void testRescheduleResetDate() {
        Integer expectedNumOfReschedule = 3;
        // Implement test code
        Account acc = new Account();
        //acc.RecordTypeId = CustomerRecordTypeId;
        acc.Name = 'TestName';
        insert acc;

        Call_Report__c callReport = new Call_Report__c();
        callReport.CIS_ID__c = acc.Id;
        callReport.Number_of_Reschedule__c = 2;
        callReport.Plan_Date__c = Date.today();
        insert callReport;

        Test.startTest();
        callReport.Plan_Date__c = null;
        update callReport;
        Test.stopTest();

        Call_Report__c actualQueryReport = [SELECT Id,Number_of_Reschedule__c FROM Call_Report__c WHERE Id = :callReport.Id];
        System.assertEquals(expectedNumOfReschedule,actualQueryReport.Number_of_Reschedule__c);
    }
    
    @isTest static void testInsertCallReport_CreateReminderTask() {
        /*
         * Created by: nareerat.wo@kbtg.tech
         * Created date: 21-Jun-2016
         * Description: Test code for Test method insertingTask_InterestWithCondition at class CallReportTriggerHandler when insert call report.
        */
        //Setup custom setting
        CallReport_Task_Setting__c cSetting = new CallReport_Task_Setting__c();
        cSetting.ReminderTask_NumOfDays__c= 30;
        cSetting.ReminderTask_Subject__c='Please takecare customer';
        cSetting.ReminderTask_TimeReminder__c='08:30';
        insert cSetting;
        
        Account acc = new Account();
        acc.Name = 'TestAcc1';
        insert acc;

        Call_Report__c callReport = new Call_Report__c();
        callReport.CIS_ID__c = acc.Id;
        callReport.Actual_Visit_Date__c = Date.today();
        callReport.Contact_Channel__c = 'Phone Call';
        callReport.Offer_Credit_Product__c = true;
        callReport.Offer_Interest__c = 'Interest with condition';
        callReport.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';           

        Test.startTest();
            insert callReport;
        Test.stopTest();

        task reminderTask = [SELECT Id, WhatId, Subject, OwnerId FROM Task WHERE WhatId = :callReport.Id];
        list<task> listreminderTask = [SELECT Id, WhatId, Subject, OwnerId FROM Task WHERE WhatId = :callReport.Id];
        System.assertEquals(listreminderTask.size(), 1);
        System.assertEquals(reminderTask.Subject, 'Please takecare customer');
        
    }
    
    @isTest static void testUpdateCallReport_CreateReminderTask() {
         /*
         * Created by: nareerat.wo@kbtg.tech
         * Created date: 21-Jun-2016
         * Description: Test code for Test method insertingTask_InterestWithCondition at class CallReportTriggerHandler when update call report.
        */
        //Setup custom setting
        CallReport_Task_Setting__c cSetting = new CallReport_Task_Setting__c();
        cSetting.ReminderTask_NumOfDays__c= 30;
        cSetting.ReminderTask_Subject__c='Please takecare customer';
        insert cSetting;
        
        Account acc = new Account();
        acc.Name = 'TestAcc1';
        acc.CIS__c = '1111';
        acc.Birthdate_Registration_Date__c = system.today() - 9000;
        acc.Identification_No_Prospect__c='1234567890123';
        
        
        insert acc;
        
        Contact contact1 = new Contact();
        contact1.Accountid = acc.id;
        contact1.Phone_Number__c = '1234567890';
        contact1.lastname='BB';
        insert contact1;

        Call_Report__c callReport = new Call_Report__c();
        callReport.CIS_ID__c = acc.Id;
        callReport.Actual_Visit_Date__c = Date.today();
        callReport.Contact_Channel__c = 'Phone Call';
        callReport.Offer_Credit_Product__c = true;
        callReport.Offer_Interest__c = GlobalConstants.CUSTOMER_INTERESTED;       
        callReport.Expected_Credit_Amount__c = 100000;
        insert callReport;
                
        Test.startTest();
            callReport.Contact__c=contact1.id;
            callReport.Offer_Interest__c = 'Interest with condition';
            callReport.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';  
            update callReport;
            
        Test.stopTest();

        task reminderTask = [SELECT Id, WhatId, Subject, OwnerId FROM Task WHERE WhatId = :callReport.Id];
        list<task> listreminderTask = [SELECT Id, WhatId, Subject, OwnerId FROM Task WHERE WhatId = :callReport.Id];
        System.assertEquals(listreminderTask.size(), 1);
        System.assertEquals(reminderTask.Subject, 'Please takecare customer');
        
    }
    
    @isTest static void testCreateOppCreditByCallReport(){

        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'CBS-RM'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        User userSale = new User(alias = 'standt',
        email='standarduser@testorg.com',
        emailencodingkey='UTF-8',
        lastname='LastTest', languagelocalekey='en_US',
        localesidkey='en_US',
        profileid = profiles.get('CBS-RM'),
        timezonesidkey='America/Los_Angeles',
        username='saleuser@testorg.com',
        Segment__c = 'ME');
        insert userSale;

        System.runAs(userSale){
        Account account = new Account();
        account.Name = 'TestAc1';
        account.CIS__c = 'tt111';
        account.Birthdate_Registration_Date__c = system.today() - 9000;
        account.Identification_No_Prospect__c='1234567890123';
        insert account;

        Contact contact = new Contact();
        contact.Accountid = account.id;
        contact.Phone_Number__c = '1234567890';
        contact.Lastname='BB';
        contact.Email = 'test@email.com';
        contact.Title = 'Gate Keeper';
        insert contact;

        Business_Code__c bc = new Business_Code__c();
        bc.Name = '111111';
        bc.Segment__c = 'ME';
        bc.External_ID__c = '111111:ME';
        upsert bc External_ID__c;

        Customer_Business_Code__c customerBusinessCode = new Customer_Business_Code__c();
        customerBusinessCode.Name=Customer_BusinessCode_Service.getDefaultValue();
        customerBusinessCode.Business_Code__c = bc.id;
        customerBusinessCode.CIS__c = account.id;
        customerBusinessCode.Account_Owner_Segment__c = userSale.Segment__c;
        customerBusinessCode.External__c = account.CIS__c+':'+bc.External_ID__c;
        upsert customerBusinessCode External__c;

        List<RecordType> recordTypeList = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Call_Report__c' AND DeveloperName = 'CallReportNoPlan'];

        Call_Report__c callReport = new Call_Report__c();
        callReport.CIS_ID__c = account.Id;
        callReport.Actual_Visit_Date__c = Date.today();
        callReport.Plan_Date__c = System.today();
        callReport.Visit_Objective_CBS__c = 'Sell';
        callReport.Product_Service__c = 'Credit';
        callReport.Contact_Channel__c = 'Phone Call';
        callReport.Offer_Credit_Product__c = true;
        //callReport.Product_Long_Term_Loan__c = true;
       // callReport.Expected_Limit_Amount_Baht_CBS__c = 10000;
          
        callReport.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';
        callReport.RecordTypeId = recordTypeList.get(0).Id;

        callReport.Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY;
        callReport.Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL;
        callReport.Customer_Business_Code__c =customerBusinessCode.id;
        callReport.Expected_Credit_Amount__c = 9000;
        callReport.Contact__c = contact.Id;
        insert callReport;
        }

    }
    
    
}