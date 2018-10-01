@isTest
private class CBS_GroupSubGroup_Transaction_Batch_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';

    @testSetup static void setupUser(){
        Test.startTest();
            Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
            User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1];
            Campaign mockLeadToDo;
            Account account1;
            System.runAs(userTM){
                Group__c group1 = new Group__c(
                    Group_Name__c = 'group1',
                    External_ID__c = 'g1',
                    Number_of_Group__c = 1
                );
                insert group1;
                Sub_Group__c subGroup1 = new Sub_Group__c(
                    Sub_Group_Name__c = 'subGroup1',
                    External_ID__c = 'sg1',
                    Number_of_Sub_Group__c = 1
                );
                insert subGroup1;
                Group_Sub_Group__c groupSubGroup = new Group_Sub_Group__c(
                    Group_Lookup__c = group1.Id,
                    Sub_Group_Lookup__c = subGroup1.Id,
                    Group__c = 'g1',
                    Sub_Group__c = 'sb1'
                );
                insert groupSubGroup;

                account1 = new Account(
                    Name = 'account1',
                    Port_Pool__c = GlobalConstants.PORT,
                    RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
                    Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
                    OwnerId = userTM.Id,
                    Primary_Segment_Code__c = 'CB',
                    Customer_Segment_Code__c = 'CB',
                    OwnerChangeExecutedByTrigger__c = true,
                    Group_Sub_Group__c = groupSubGroup.Id,
                    Is_createby_Integration__c  = true
                );
                insert account1;

                mockLeadToDo = new Campaign();
                mockLeadToDo.Lead_Campaign_Event_Code__c = 'leadToDo';
                mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
                mockLeadToDo.Sub_Type__c = 'เพื่อทราบ';
                mockLeadToDo.Name = 'leadToDo';
                mockLeadToDo.Status = GlobalConstants.ACTIVE;
                mockLeadToDo.IsActive = true;
                mockLeadToDo.StartDate = System.today() - 1;
                mockLeadToDo.EndDate = System.Today() + 1;
                mockLeadToDo.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
                TriggerHandler.bypass('CampaignTriggerHandler');
                insert mockLeadToDo;
                TriggerHandler.clearBypass('CampaignTriggerHandler');



                TriggerHandler.bypass('CallReportTriggerHandler');
                Call_Report__c callReport = new Call_Report__c();
                callReport.Actual_Visit_Date__c = System.today() - 3;
                callReport.Plan_Amount__c = 6000;
                callReport.CIS_ID__c = account1.Id;
                callReport.Offer_Credit_Product__c = true;
                callReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY;
                callReport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
                callReport.Expected_Credit_Amount__c = 5000;
                callReport.Contact_Firstname__c = 'abc';
                callReport.Contact_Lastname__c = 'def';
                callReport.Contact_Phone__c = '123456789';
                insert callReport;
                TriggerHandler.clearBypass('CallReportTriggerHandler');

                String oppPlannignProductList = 'IPO,EDC,M&A';
                Opportunity_Planning__c targetOppPlanning = new Opportunity_Planning__c(
                    CIS_ID__c = account1.Id,
                    Product_Type__c = GlobalConstants.OPP_PLAN_CREDIT,
                    Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
                    Project_Size__c = 100000,
                    Expected_Income_to_KBank__c = 100000,
                    Expected_LimitVolume_Amount__c = 100000,
                    Remark__c = 'Test Remark',
                    Product_List_CBS__c = oppPlannignProductList
                );
                insert targetOppPlanning;
                Opportunity opportunityTest = new Opportunity();
                opportunityTest = Mockup_Test.newOpportunity(account1.Id, 'TestOPP1', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
                insert opportunityTest;
            }
            Target_List__c targetList = new Target_List__c();
            targetList.Lead_Campaign__c = mockLeadToDo.Id;
            targetList.CIS_ID_Prospect_Name__c = account1.Id;
            targetList.Status__c = GlobalConstants.STATUS_NEW;
            insert targetList;
        Test.stopTest();

    }
    
    @isTest static void initialTransaction() {
        Test.startTest();
            Database.executeBatch(new CBS_GroupSubGroup_Transaction_Batch(true));
        Test.stopTest();
    }

    /*@isTest static void dailyTransactionCallReport(){
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1];
        //Account account1 = [SELECT Id FROM Account WHERE Name = 'account1' LIMIT 1];
        Account account1 = Mockup_Test.getFirstAccountFromName('account1', 'Id,Name,CIS__c');
        String accountId;
        Test.startTest();
            System.runAs(userTM){
                TriggerHandler.bypass('CallReportTriggerHandler');
                Call_Report__c newCallReport = new Call_Report__c();
                newCallReport.Actual_Visit_Date__c = System.today() - 2;
                newCallReport.Plan_Amount__c = 7000;
                newCallReport.CIS_ID__c = account1.Id;
                newCallReport.Offer_Credit_Product__c = true;
                newCallReport.Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY;
                newCallReport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
                newCallReport.Expected_Credit_Amount__c = 5000;
                newCallReport.Contact_Firstname__c = 'abc';
                newCallReport.Contact_Lastname__c = 'def';
                newCallReport.Contact_Phone__c = '123456789';
                insert newCallReport;
                TriggerHandler.clearBypass('CallReportTriggerHandler');
                accountId = newCallReport.Id;
            }
        
            Database.executeBatch(new CBS_GroupSubGroup_Transaction_Batch());
        Test.stopTest();
        List<Group_Sub_Group_Transaction__c> customerGSubGList = [SELECT Id FROM Group_Sub_Group_Transaction__c WHERE Call_Plan_Call_Report_Lookup__c = :accountId];
        System.assertEquals(1,customerGSubGList.size());
    }*/
    /*@isTest static void dailyTransactionOppPlanning(){
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1];
        //Account account1 = [SELECT Id FROM Account WHERE Name = 'account1' LIMIT 1];
        Account account1 = Mockup_Test.getFirstAccountFromName('account1', 'Id,Name,CIS__c');
        String accountId;
        Test.startTest();
            System.runAs(userTM){
                String oppPlannignProductList = 'IPO';
                Opportunity_Planning__c targetOppPlanning = new Opportunity_Planning__c(
                    CIS_ID__c = account1.Id,
                    Product_Type__c = GlobalConstants.OPP_PLAN_CREDIT,
                    Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
                    Project_Size__c = 200000,
                    Expected_Income_to_KBank__c = 200000,
                    Expected_LimitVolume_Amount__c = 200000,
                    Remark__c = 'Test Remark IPO',
                    Product_List_CBS__c = oppPlannignProductList
                );
                insert targetOppPlanning;
                accountId = targetOppPlanning.Id;
            }
        
            Database.executeBatch(new CBS_GroupSubGroup_Transaction_Batch());
        Test.stopTest();
        List<Group_Sub_Group_Transaction__c> customerGSubGList = [SELECT Id FROM Group_Sub_Group_Transaction__c WHERE Opportunity_Planning_Lookup__c = :accountId];
        System.assertEquals(1,customerGSubGList.size());
    }*/
    @isTest static void dailyTransactionTargetList(){

        Test.startTest();
            Campaign mockLead = new Campaign();
             mockLead.Lead_Campaign_Event_Code__c = 'leadForSales';
             mockLead.Type__c = 'Campaign';
             mockLead.Name = 'leadForSales';
             mockLead.Status = GlobalConstants.ACTIVE;
             mockLead.StartDate = system.today();
             mockLead.IsActive = true;
             mockLead.Address_Registration__c = 'Yes';

             TriggerHandler.bypass('CampaignTriggerHandler');
                insert mockLead;
             TriggerHandler.clearBypass('CampaignTriggerHandler');

            User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1];
            Account account1 = Mockup_Test.getFirstAccountFromName('account1', 'Id,Name,CIS__c');

            Target_List__c newTargetList = new Target_List__c(
                CIS_ID_Prospect_Name__c = account1.Id,
                Lead_Campaign__c = mockLead.Id
            );

            insert newTargetList;
            String accountId = newTargetList.Id;
            Database.executeBatch(new CBS_GroupSubGroup_Transaction_Batch());

        Test.stopTest();
        List<Group_Sub_Group_Transaction__c> customerGSubGList = [SELECT Id FROM Group_Sub_Group_Transaction__c WHERE Target_List_Lookup__c = :accountId];
        System.assertEquals(1,customerGSubGList.size());
    }
    @isTest static void dailyTransactionOpp(){
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1];
        //Account account1 = [SELECT Id FROM Account WHERE Name = 'account1' LIMIT 1];
        Account account1 = Mockup_Test.getFirstAccountFromName('account1', 'Id,Name,CIS__c');
        String accountId;
        Test.startTest();
            System.runAs(userTM){
                Opportunity opportunityTest = new Opportunity();
                opportunityTest = Mockup_Test.newOpportunity(account1.Id, 'TestOPP2', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
                insert opportunityTest;
                accountId = opportunityTest.Id;

                Event eventTest = new Event();
                eventTest.Status__c = 'Contacted';
                eventTest.WhatId = opportunityTest.Id;
                eventTest.DurationInMinutes = 100;
                eventTest.ActivityDateTime = Datetime.now();

                insert eventTest;
            }
        
            Database.executeBatch(new CBS_GroupSubGroup_Transaction_Batch());
        Test.stopTest();
        List<Group_Sub_Group_Transaction__c> customerGSubGList = [SELECT Id FROM Group_Sub_Group_Transaction__c WHERE Opportunity_Lookup__c = :accountId];
        System.assertEquals(1,customerGSubGList.size());
    }
    @isTest static void transactionDeActive() {
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1];
        //Account account1 = [SELECT Id FROM Account WHERE Name = 'account1' LIMIT 1];
        Account account1 = Mockup_Test.getFirstAccountFromName('account1', 'Id,Name,CIS__c');
        List<Customer_Group_Sub_Group__c> customerGSubGDeActiveList = [SELECT Id,Is_Active__c FROM Customer_Group_Sub_Group__c WHERE Is_Active__c = true];
        List<Customer_Group_Sub_Group__c> updateCustomerGSubGList = new List<Customer_Group_Sub_Group__c>();
            
        System.runAs(userTM){
            Opportunity opportunityTest = new Opportunity();
            opportunityTest = Mockup_Test.newOpportunity(account1.Id, 'TestOPP3', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
            insert opportunityTest;
        }
        for(Customer_Group_Sub_Group__c customerGSubG :customerGSubGDeActiveList){
            customerGSubG.Is_Active__c = false;
            updateCustomerGSubGList.add(customerGSubG);
        }
        update updateCustomerGSubGList;
        Integer sizeTransaction = [SELECT Count() FROM Group_Sub_Group_Transaction__c];
        Test.startTest();
            Database.executeBatch(new CBS_GroupSubGroup_Transaction_Batch());
        Test.stopTest();

        System.assertEquals(sizeTransaction,[SELECT Count() FROM Group_Sub_Group_Transaction__c]);
    }
    
}