@isTest
private class SME_Performance_Batch_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    @testSetup static void setupAccount(){
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestAdmin().setUpTestWithExtension();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        Test.stopTest();
    }
    @isTest static void initialCase(){
        
        String expectedNote = 'expected';
        Account targetAccount = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        System.assertEquals('Permanent',targetAccount.Ownership__c);
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User_Extension__c userRMExt = [SELECT Id FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];

        Call_Report__c callreportObj;
        System.runAs(userRM){
            TriggerHandler.bypass('CallReportTriggerHandler');
            callreportObj = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Complete_Monthly__c = true,
                Offer_Interest__c = 'Interest and can apply',
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Customer_Important_Note__c = expectedNote,
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Face to Face',
                Current_Owner_Extension__c = userRMExt.Id
            );
            insert callreportObj;
            callreportObj = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Complete_Monthly__c = true,
                Offer_Interest__c = 'Interest and can apply',
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Customer_Important_Note__c = expectedNote,
                Primary_Call_Report__c = false,
                Contact_Channel__c = 'Face to Face',
                Current_Owner_Extension__c = userRMExt.Id
            );
            insert callreportObj;
            callreportObj = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Complete_Monthly__c = true,
                Offer_Interest__c = 'Interest and can apply',
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Customer_Important_Note__c = expectedNote,
                Primary_Call_Report__c = false,
                Contact_Channel__c = GlobalConstants.PHONE_CALL,
                Current_Owner_Extension__c = userRMExt.Id
            );
            insert callreportObj;
        }
        Test.startTest();
            Database.executeBatch(new SME_Initial_ContactedAccount_Batch());
        Test.stopTest();
        account accountResult = [select id,Count_Contacted_Call_Report__c,Count_Contacted_Call_Report_F2F__c,Count_Contacted_Call_Report_Phone_Call__c,Count_Contacted_Call_Report_My_Pen_F2F__c,Count_Contacted_Call_Report_My_Pen_Call__c,Count_Contacted_CR_My_Pen_Service_F2F__c,Count_Contacted_CR_My_Pen_Service_Call__c from account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        
        system.debug('Count_Contacted_Call_Report_F2F__c :: ' +accountResult.Count_Contacted_Call_Report_F2F__c);
        system.debug('Count_Contacted_Call_Report_Phone_Call__c :: ' +accountResult.Count_Contacted_Call_Report_Phone_Call__c);
        system.debug('Count_Contacted_Call_Report_My_Pen_F2F__c :: ' +accountResult.Count_Contacted_Call_Report_My_Pen_F2F__c);
        system.debug('Count_Contacted_Call_Report_My_Pen_Call__c :: ' +accountResult.Count_Contacted_Call_Report_My_Pen_Call__c);
        system.debug('Count_Contacted_CR_My_Pen_Service_F2F__c :: ' +accountResult.Count_Contacted_CR_My_Pen_Service_F2F__c);
        system.debug('Count_Contacted_CR_My_Pen_Service_Call__c :: ' +accountResult.Count_Contacted_CR_My_Pen_Service_Call__c);
        System.assertEquals(2,accountResult.Count_Contacted_Call_Report_F2F__c);
        System.assertEquals(2,accountResult.Count_Contacted_Call_Report_My_Pen_F2F__c);
        System.assertEquals(1,accountResult.Count_Contacted_Call_Report_Phone_Call__c);
        System.assertEquals(1,accountResult.Count_Contacted_Call_Report_My_Pen_Call__c);
        System.assertEquals(3,accountResult.Count_Contacted_Call_Report__c);
    }
    @isTest static void positiveCase(){
        insert new Performance_Config__c(Date__c = System.now().day(),Reset_Date__c = Date.newInstance(System.today().year(), 1, 1));
        Performance_Config__c perfConfig = Performance_Config__c.getOrgDefaults();
        system.assert(System.now().day() == perfConfig.Date__c);

        String expectedNote = 'expected';
        Account targetAccount = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        System.assertEquals('Permanent',targetAccount.Ownership__c);
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User_Extension__c userRMExt = [SELECT Id,Team_Structure__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];

        Call_Report__c callreportObj;
        System.runAs(userRM){
            TriggerHandler.bypass('CallReportTriggerHandler');
            callreportObj = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Complete_Monthly__c = true,
                Offer_Interest__c = 'Interest and can apply',
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Customer_Important_Note__c = expectedNote,
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Face to Face',
                Current_Owner_Extension__c = userRMExt.Id,
                Current_Team_Name__c = userRMExt.Team_Structure__c
            );
            insert callreportObj;

            Call_Report__c callreportObj2 = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Complete_Monthly__c = true,
                Offer_Interest__c = 'Interest and can apply',
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Customer_Important_Note__c = expectedNote,
                Primary_Call_Report__c = false,
                Contact_Channel__c = 'Face to Face',
                Current_Owner_Extension__c = userRMExt.Id,
                Current_Team_Name__c = userRMExt.Team_Structure__c
            );
            insert callreportObj2;

            Call_Report__c callreportObj3 = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Relationship',
                Plan_Amount__c = 5000,
                Complete_Monthly__c = true,
                Offer_Interest__c = 'Interest and can apply',
                Port_Pool__c = null,
                Ownership__c = null,
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Customer_Important_Note__c = expectedNote,
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Phone Call',
                Current_Owner_Extension__c = userRMExt.Id,
                Current_Team_Name__c = userRMExt.Team_Structure__c
            );
            insert callreportObj3;
        }
        targetAccount.Count_Contacted_Call_Report__c = 3;
        update targetAccount;
        callreportObj = [SELECT Id,CIS_ID__c,Current_Owner_Extension__c,Current_Owner_Extension__r.User__r.RC_Code__c,Current_Team_Name__c,Ownership__c,Port_Pool__c,Status__c,Completed__c FROM Call_Report__c LIMIT 1];
        //WHERE Status__c=\'Contacted\' AND Primary_Call_Report__c=true AND Completed__c=false 
        System.assert(callreportObj!=null);

        targetAccount = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        System.assertEquals('Permanent',targetAccount.Ownership__c);

        Test.startTest();
            Database.executeBatch(new SME_Monthly_Initial_Batch());
            String sch = '0 0 23 * * ?';
            SchedulableContext sc = null;
            SME_Performance_Schedule tsc = new SME_Performance_Schedule();
            tsc.execute(sc);
            system.schedule('Test check', sch, tsc);
        Test.stopTest();

        //userRMExt = [SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Face_to_Face__c,Months__c,Phone_Call__c,Number_of_RM_under_Team__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];

        //System.assertEquals(2.0,userRMExt.Number_of_RM_under_Team__c);
        //System.assertEquals(2.0,userRMExt.Call_Report__c);
        //System.assertEquals(1.0,userRMExt.Call_Report_Customer_Others__c);
        //System.assertEquals(0.0,userRMExt.Call_Report_Customer_Pool__c);
        //System.assertEquals(1.0,userRMExt.Call_Report_Customer_Port__c);
        //System.assertEquals(0.0,userRMExt.Call_Report_for_Relationship__c);
        //System.assertEquals(2.0,userRMExt.Call_Report_for_Sales__c);
        //System.assertEquals(0.0,userRMExt.Contacted_Customer_Other__c);
        //System.assertEquals(0.0,userRMExt.Contacted_Customer_Pool__c);
        //System.assertEquals(1.0,userRMExt.Contacted_Customer_Port__c);
        //System.assertEquals(0.0,userRMExt.Customer_Other__c);
        //System.assertEquals(0.0,userRMExt.Customer_Pool__c);
        //System.assertEquals(1.0,userRMExt.Customer_Port__c);
        //System.assertEquals(1.0,userRMExt.Face_to_Face__c);
        //System.assertEquals(System.now().month(),userRMExt.Months__c);
        //System.assertEquals(1.0,userRMExt.Phone_Call__c);

        //userRMExt = [SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Face_to_Face__c,Months__c,Phone_Call__c,Number_of_RM_under_Team__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];

        //System.assertEquals(2.0,userRMExt.Number_of_RM_under_Team__c);
        //System.assertEquals(0.0,userRMExt.Call_Report__c);
        //System.assertEquals(0.0,userRMExt.Call_Report_Customer_Others__c);
        //System.assertEquals(0.0,userRMExt.Call_Report_Customer_Pool__c);
        //System.assertEquals(0.0,userRMExt.Call_Report_Customer_Port__c);
        //System.assertEquals(0.0,userRMExt.Call_Report_for_Relationship__c);
        //System.assertEquals(0.0,userRMExt.Call_Report_for_Sales__c);
        //System.assertEquals(0.0,userRMExt.Contacted_Customer_Other__c);
        //System.assertEquals(0.0,userRMExt.Contacted_Customer_Pool__c);
        //System.assertEquals(0.0,userRMExt.Contacted_Customer_Port__c);
        //System.assertEquals(0.0,userRMExt.Customer_Other__c);
        //System.assertEquals(0.0,userRMExt.Customer_Pool__c);
        //System.assertEquals(0.0,userRMExt.Customer_Port__c);
        //System.assertEquals(0.0,userRMExt.Face_to_Face__c);
        //System.assertEquals(System.now().month(),userRMExt.Months__c);
        //System.assertEquals(0.0,userRMExt.Phone_Call__c);

        //Team_Structure__c teamNh = [SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Face_to_Face__c,Months__c,Phone_Call__c,Number_of_RM_under_Team__c FROM Team_Structure__c WHERE External_ID__c =:Mockup_Test.NH_RC_CODE LIMIT 1];

        //System.assertEquals(2.0,teamNh.Number_of_RM_under_Team__c);
        //System.assertEquals(2.0,teamNh.Call_Report__c);
        //System.assertEquals(1.0,teamNh.Call_Report_Customer_Others__c);
        //System.assertEquals(0.0,teamNh.Call_Report_Customer_Pool__c);
        //System.assertEquals(1.0,teamNh.Call_Report_Customer_Port__c);
        //System.assertEquals(0.0,teamNh.Call_Report_for_Relationship__c);
        //System.assertEquals(2.0,teamNh.Call_Report_for_Sales__c);
        //System.assertEquals(0.0,teamNh.Contacted_Customer_Other__c);
        //System.assertEquals(0.0,teamNh.Contacted_Customer_Pool__c);
        //System.assertEquals(1.0,teamNh.Contacted_Customer_Port__c);
        //System.assertEquals(0.0,teamNh.Customer_Other__c);
        //System.assertEquals(1.0,teamNh.Customer_Pool__c);
        //System.assertEquals(1.0,teamNh.Customer_Port__c);
        //System.assertEquals(1.0,teamNh.Face_to_Face__c);
        //System.assertEquals(System.now().month(),teamNh.Months__c);
        //System.assertEquals(1.0,teamNh.Phone_Call__c);

        //monthly specific
        //String externalId = Mockup_Test.userEmpIdRM + ' ' + System.now().month() + ' ' + System.now().year();
        //Monthly_Performance__c perfObj = [SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Face_to_Face__c,Months__c,Phone_Call__c,Number_of_RM_under_Team__c FROM Monthly_Performance__c WHERE External_ID__c=:externalId LIMIT 1];

        //System.assertEquals(2.0,perfObj.Number_of_RM_under_Team__c);
        //System.assertEquals(0.0,perfObj.Call_Report__c);
        //System.assertEquals(0.0,perfObj.Call_Report_Customer_Others__c);
        //System.assertEquals(0.0,perfObj.Call_Report_Customer_Pool__c);
        //System.assertEquals(0.0,perfObj.Call_Report_Customer_Port__c);
        //System.assertEquals(0.0,perfObj.Call_Report_for_Relationship__c);
        //System.assertEquals(0.0,perfObj.Call_Report_for_Sales__c);
        //System.assertEquals(0.0,perfObj.Contacted_Customer_Other__c);
        //System.assertEquals(0.0,perfObj.Contacted_Customer_Pool__c);
        //System.assertEquals(1.0,perfObj.Contacted_Customer_Port__c);
        //System.assertEquals(0.0,perfObj.Customer_Other__c);
        //System.assertEquals(0.0,perfObj.Customer_Pool__c);
        //System.assertEquals(1.0,perfObj.Customer_Port__c);
        //System.assertEquals(0.0,perfObj.Face_to_Face__c);
        //System.assertEquals(System.now().month(),perfObj.Months__c);
        //System.assertEquals(0.0,perfObj.Phone_Call__c);

        //team
        //externalId = Mockup_Test.RC_CODE + ' ' + System.now().month() + ' ' + System.now().year();
        //perfObj = [SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Face_to_Face__c,Months__c,Phone_Call__c,Number_of_RM_under_Team__c FROM Monthly_Performance__c WHERE External_ID__c=:externalId LIMIT 1];

        //System.assertEquals(2.0,perfObj.Number_of_RM_under_Team__c);
        //System.assertEquals(0.0,perfObj.Call_Report__c);
        //System.assertEquals(0.0,perfObj.Call_Report_Customer_Others__c);
        //System.assertEquals(0.0,perfObj.Call_Report_Customer_Pool__c);
        //System.assertEquals(0.0,perfObj.Call_Report_Customer_Port__c);
        //System.assertEquals(0.0,perfObj.Call_Report_for_Relationship__c);
        //System.assertEquals(0.0,perfObj.Call_Report_for_Sales__c);
        //System.assertEquals(0.0,perfObj.Contacted_Customer_Other__c);
        //System.assertEquals(0.0,perfObj.Contacted_Customer_Pool__c);
        //System.assertEquals(1.0,perfObj.Contacted_Customer_Port__c);
        //System.assertEquals(0.0,perfObj.Customer_Other__c);
        //System.assertEquals(1.0,perfObj.Customer_Pool__c);
        //System.assertEquals(1.0,perfObj.Customer_Port__c);
        //System.assertEquals(0.0,perfObj.Face_to_Face__c);
        //System.assertEquals(System.now().month(),perfObj.Months__c);
        //System.assertEquals(0.0,perfObj.Phone_Call__c);

        //nh team
        //externalId = Mockup_Test.NH_RC_CODE + ' ' + System.now().month() + ' ' + System.now().year();
        //perfObj = [SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Face_to_Face__c,Months__c,Phone_Call__c,Number_of_RM_under_Team__c FROM Monthly_Performance__c WHERE External_ID__c=:externalId LIMIT 1];

        //System.assertEquals(2.0,perfObj.Number_of_RM_under_Team__c);
        //System.assertEquals(0.0,perfObj.Call_Report__c);
        //System.assertEquals(0.0,perfObj.Call_Report_Customer_Others__c);
        //System.assertEquals(0.0,perfObj.Call_Report_Customer_Pool__c);
        //System.assertEquals(0.0,perfObj.Call_Report_Customer_Port__c);
        //System.assertEquals(0.0,perfObj.Call_Report_for_Relationship__c);
        //System.assertEquals(0.0,perfObj.Call_Report_for_Sales__c);
        //System.assertEquals(0.0,perfObj.Contacted_Customer_Other__c);
        //System.assertEquals(0.0,perfObj.Contacted_Customer_Pool__c);
        //System.assertEquals(1.0,perfObj.Contacted_Customer_Port__c);
        //System.assertEquals(0.0,perfObj.Customer_Other__c);
        //System.assertEquals(1.0,perfObj.Customer_Pool__c);
        //System.assertEquals(1.0,perfObj.Customer_Port__c);
        //System.assertEquals(0.0,perfObj.Face_to_Face__c);
        //System.assertEquals(System.now().month(),perfObj.Months__c);
        //System.assertEquals(0.0,perfObj.Phone_Call__c);
    }    
    @isTest static void monthlyInitialCase(){
        insert new Performance_Config__c(Date__c = System.now().day(),Reset_Date__c = Date.newInstance(System.today().year(), 1, 1));
        Performance_Config__c perfConfig = Performance_Config__c.getOrgDefaults();
        system.assert(System.now().day() == perfConfig.Date__c);

        String expectedNote = 'expected';
        Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User_Extension__c userRMExt = [SELECT Id FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];

        Call_Report__c callreportObj;
        System.runAs(userRM){
            
            callreportObj = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Offer_Interest__c = GlobalConstants.INTEREST_WITH_CONDITION,
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Customer_Important_Note__c = expectedNote,
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Face to Face',
                Current_Owner_Extension__c = userRMExt.Id
            );
            insert callreportObj;
        }
        callreportObj = [SELECT Id,CIS_ID__c,Current_Owner_Extension__c,Current_Owner_Extension__r.User__r.RC_Code__c,Current_Team_Name__c,Ownership__c,Port_Pool__c,Status__c,Completed__c FROM Call_Report__c LIMIT 1];
        //WHERE Status__c=\'Contacted\' AND Primary_Call_Report__c=true AND Completed__c=false 
        System.debug(callreportObj);
        System.assert(callreportObj!=null);

        List<Monthly_Performance__c> monthlyList = new List<Monthly_Performance__c>();
        Test.startTest();
            
            Database.executeBatch(new SME_Monthly_Initial_Batch());
            
        Test.stopTest();

        monthlyList = [SELECT Id,External_ID__c,User__c from Monthly_Performance__c WHERE User__c =:userRMExt.Id];
        System.assertEquals(System.now().month() - 1,monthlyList.size());

    }
     @isTest static void monthlyInactiveCase(){
        insert new Performance_Config__c(Date__c = System.now().day(),Reset_Date__c = Date.newInstance(System.today().year(), 1, 1));
        Performance_Config__c perfConfig = Performance_Config__c.getOrgDefaults();
        system.assert(System.now().day() == perfConfig.Date__c);

        String expectedNote = 'expected';
        Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
        User_Extension__c userRMExt = [SELECT Id FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];

        Call_Report__c callreportObj;
        System.runAs(userRM){
            
            callreportObj = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Offer_Interest__c = GlobalConstants.INTEREST_WITH_CONDITION,
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Customer_Important_Note__c = expectedNote,
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Face to Face',
                Current_Owner_Extension__c = userRMExt.Id
            );
            insert callreportObj;
        }
        Test.startTest();
        System.runAs(userAdmin){
            update new User(isActive=false,Id=userRM.Id);
        }
        callreportObj = [SELECT Id,CIS_ID__c,Current_Owner_Extension__c,Current_Owner_Extension__r.User__r.RC_Code__c,Current_Team_Name__c,Ownership__c,Port_Pool__c,Status__c,Completed__c FROM Call_Report__c LIMIT 1];
        //WHERE Status__c=\'Contacted\' AND Primary_Call_Report__c=true AND Completed__c=false 
        System.debug(callreportObj);
        System.assert(callreportObj!=null);

        List<Monthly_Performance__c> monthlyList = new List<Monthly_Performance__c>();
        SME_Performance_Batch sbatch = new SME_Performance_Batch();

        //Test.startTest();
            Database.executeBatch(sbatch);
        Test.stopTest();

        Integer currentmonth = sbatch.todayDateFromNow.month();

        userRMExt = [SELECT Id,Months__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        DateTime dT = System.now();
        System.assertEquals(dT.month(),userRMExt.Months__c);

        if(currentmonth!=1){
            insert new Monthly_Performance__c(External_ID__c=Mockup_Test.userEmpIdRM + ' ' + (currentmonth-1) + ' ' + sbatch.currentYear,User__c=userRMExt.Id,Date__c=System.today().addMonths(-1));
        
            monthlyList = [SELECT Id,Months__c from Monthly_Performance__c WHERE User__c =:userRMExt.Id ORDER BY Date__c DESC];
            userRMExt = [SELECT Id,Months__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];

            System.assertEquals(2,monthlyList.size());
            System.assertEquals(1,monthlyList.get(0).Months__c); // still the same
            System.assertEquals(dT.month(),userRMExt.Months__c);
        }

    }    
}