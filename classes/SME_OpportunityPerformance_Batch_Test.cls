@isTest
private class SME_OpportunityPerformance_Batch_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';

    @testSetup static void setupUser(){
        Test.startTest();
            Mockup_Test mt = new Mockup_Test().setUpTestWithExtension();
            System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
                mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            }
            System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
                mt.newAccount(accountNameRM,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            }
            Performance_Config__c perfConfig =  new Performance_Config__c();
            perfConfig.Date__c = System.now().day();
            perfConfig.Reset_Date__c = Date.newInstance(System.today().year(), 1, 1);
            insert perfConfig;

            Application_Number__c appNumConfig = new Application_Number__c();
            appNumConfig.Name = Mockup_Test.RC_CODE;
            appNumConfig.Running_Number__c = 1;
            appNumConfig.Year__c = '2560';
            insert appNumConfig;
        Test.stopTest();

    }

    @isTest static void initialCase() {
    
        Account targetAccount = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        //Account targetAccount2 = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :CallReport_Test.accountNameTM LIMIT 1];
        User userRM = [SELECT Id,Employee_Id__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User_Extension__c userRMExt = [SELECT Id,Team_Structure__c,Team_Structure__r.RC_Code__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        
        User userRM2 = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
        User_Extension__c userRMExt2 = [SELECT Id,Team_Structure__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
       
        Team_Structure__c teamAH = [SELECT Id,External_ID__c FROM Team_Structure__c WHERE RC_Code__c='41400' LIMIT 1];
        Team_Structure__c teamNH = [SELECT Id,External_ID__c FROM Team_Structure__c WHERE RC_Code__c='41201' LIMIT 1];


        Date today = System.today();
        String currentYear;

        currentYear = String.ValueOf(GlobalUtility.getYearInBuddhistCalendar(today));

        String exKeyRM = userRM.Employee_Id__c +' '+today.month()+' '+currentYear;
        String exKeyTeam = userRMExt.Team_Structure__r.RC_Code__c +' '+today.month()+' '+currentYear;

            List<Opportunity> opp_list = new List<Opportunity>();
            TriggerHandler.bypass('OpportunityTriggerHandler');
            Opportunity opp1 = Mockup_Test.newOpportunityWithAppHisWithAppNo(targetAccount.Id, 'TestUW1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS,'0001',null);
            Opportunity opp2 = Mockup_Test.newOpportunityWithAppHisWithAppNo(targetAccount.Id, 'TestUW2', GlobalConstants.WAITING_FOR_CREDIT_SETUP, GlobalConstants.NON_CMAS,'0002',null);
            Opportunity opp3 = Mockup_Test.newOpportunityWithAppHisWithAppNo(targetAccount.Id, 'TestUW3', GlobalConstants.WAITING_FOR_CREDIT_SETUP, GlobalConstants.NON_CMAS,'0003',null);
            Opportunity opp4 = Mockup_Test.newOpportunityWithAppHisWithAppNo(targetAccount.Id, 'TestUW4', GlobalConstants.AUTO_CLOSED, GlobalConstants.NON_CMAS,'0004',null);

            System.debug('CREATE FOUR OPP');
            opp1.Current_Owner_Extension__c = userRMExt.ID;
            opp1.Current_Team_Name__c = userRMExt.Team_Structure__c;
            opp1.Current_AH_Name__c = teamAH.ID;
            opp1.Current_NH_Name__c = teamNH.ID;
            opp1.Previous_Stage__c = GlobalConstants.CREDIT_WRITE_UP;

            opp2.Current_Owner_Extension__c = userRMExt.ID;
            opp2.Current_Team_Name__c = userRMExt.Team_Structure__c;
            opp2.Current_AH_Name__c = teamAH.ID;
            opp2.Current_NH_Name__c = teamNH.ID;
            opp2.Previous_Stage__c = GlobalConstants.STOCK_NEGOTIATION;
            
            opp3.Current_Owner_Extension__c = userRMExt.ID;
            opp3.Current_Team_Name__c = userRMExt.Team_Structure__c;
            opp3.Current_AH_Name__c = teamAH.ID;
            opp3.Current_NH_Name__c = teamNH.ID;
            opp3.Previous_Stage__c = GlobalConstants.WAITING_FOR_CREDIT_SETUP;

            opp4.Current_Owner_Extension__c = userRMExt2.ID;
            opp4.Current_Team_Name__c = userRMExt.Team_Structure__c;
            opp4.Current_AH_Name__c = teamAH.ID;
            opp4.Current_NH_Name__c = teamNH.ID;
            opp4.Previous_Stage__c = GlobalConstants.WAITING_FOR_CREDIT_SETUP;
            System.debug('OPP Previous_Stage__c');


            opp_list.add(opp1);
            opp_list.add(opp2);
            opp_list.add(opp3);
            opp_list.add(opp4);
            update opp_list;
            opp_list.clear();
            System.debug('Insert OPP');

            opp1.Latest_Application_Number__c = 'mock app no';
            opp1.StageName = GlobalConstants.STOCK_NEGOTIATION;
            opp1.Previous_Stage__c = GlobalConstants.CREDIT_WRITE_UP;

            opp2.Approval_Status__c = 'Final Approve';
            opp2.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
            opp2.Request_Process_Name__c = null;
            opp2.Previous_Stage__c = GlobalConstants.STOCK_NEGOTIATION;

            opp3.Approval_Status__c = 'Final Approve';
            opp3.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;
            opp3.Request_Process_Name__c = null;
            opp3.Previous_Stage__c = GlobalConstants.WAITING_FOR_CREDIT_SETUP;


            opp_list.add(opp1);
            opp_list.add(opp2);
            opp_list.add(opp3);
            update opp_list;  
        Test.startTest();
            Database.executeBatch(new SME_OpportunityPerformance_Batch());
        Test.stopTest();


        userRMExt = [SELECT Id,Team_Structure__c,Total_Opportunity_Stock__c,Total_Opportunity_App_In__c,Total_Opportunity_Approve__c,Total_Opportunity_Reject__c,Total_Opportunity_Setup__c,Total_Opportunity_Close_Lost__c,Total_Opportunity_Auto_Closed__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Team_Structure__c teamStrucObj = [SELECT Id,Total_Opportunity_Stock__c,Total_Opportunity_App_In__c,Total_Opportunity_Approve__c,Total_Opportunity_Reject__c,Total_Opportunity_Setup__c,Total_Opportunity_Close_Lost__c,Total_Opportunity_Auto_Closed__c FROM Team_Structure__c WHERE ID = :userRMExt.Team_Structure__c LIMIT 1];

        List<Monthly_Performance__c> monthlyPFList = new List<Monthly_Performance__c>([SELECT ID,External_ID__c,Total_Opportunity_Stock__c,Total_Opportunity_App_In__c,Total_Opportunity_Approve__c,Total_Opportunity_Reject__c,Total_Opportunity_Setup__c,Total_Opportunity_Close_Lost__c,Total_Opportunity_Auto_Closed__c
          FROM Monthly_Performance__c ]);
        for(Monthly_Performance__c eachMonthlyPF : monthlyPFList){
            System.debug('External_ID__c : '+eachMonthlyPF.External_ID__c);
            System.debug('Total_Opportunity_Stock__c : '+eachMonthlyPF.Total_Opportunity_Stock__c);
            System.debug('Total_Opportunity_App_In__c : '+eachMonthlyPF.Total_Opportunity_App_In__c);
            System.debug('Total_Opportunity_Approve__c : '+eachMonthlyPF.Total_Opportunity_Approve__c);
            System.debug('Total_Opportunity_Reject__c : '+eachMonthlyPF.Total_Opportunity_Reject__c);
            System.debug('Total_Opportunity_Setup__c : '+eachMonthlyPF.Total_Opportunity_Setup__c);
            System.debug('Total_Opportunity_Close_Lost__c : '+eachMonthlyPF.Total_Opportunity_Close_Lost__c);
            System.debug('Total_Opportunity_Auto_Closed__c : '+eachMonthlyPF.Total_Opportunity_Auto_Closed__c);
        }

        
        //Check User Extension
        System.debug('stopTest TEST');
        System.assertEquals(4,[SELECT Count() FROM Opportunity ]);
        System.assertEquals(3,userRMExt.Total_Opportunity_Stock__c);
        System.assertEquals(2,userRMExt.Total_Opportunity_App_In__c);
        System.assertEquals(2,userRMExt.Total_Opportunity_Approve__c);
        System.assertEquals(0,userRMExt.Total_Opportunity_Reject__c);
        System.assertEquals(0,userRMExt.Total_Opportunity_Setup__c);
        System.assertEquals(0,userRMExt.Total_Opportunity_Close_Lost__c);
        System.assertEquals(0,userRMExt.Total_Opportunity_Auto_Closed__c);
        

        //Check team Structure 
        System.assertEquals(4,teamStrucObj.Total_Opportunity_Stock__c);
        System.assertEquals(3,teamStrucObj.Total_Opportunity_App_In__c);
        System.assertEquals(3,teamStrucObj.Total_Opportunity_Approve__c);
        System.assertEquals(0,teamStrucObj.Total_Opportunity_Reject__c);
        System.assertEquals(0,teamStrucObj.Total_Opportunity_Setup__c);
        System.assertEquals(0,teamStrucObj.Total_Opportunity_Close_Lost__c);
        System.assertEquals(1,teamStrucObj.Total_Opportunity_Auto_Closed__c);

        System.assertEquals(8,[SELECT Count() FROM Monthly_Performance__c ]);

        //Check Monthly
        Monthly_Performance__c monthlyRM1 = [SELECT ID,Total_Opportunity_Stock__c,Total_Opportunity_App_In__c,Total_Opportunity_Approve__c,Total_Opportunity_Reject__c,Total_Opportunity_Setup__c,Total_Opportunity_Close_Lost__c,Total_Opportunity_Auto_Closed__c
          FROM Monthly_Performance__c WHERE External_ID__c =:exKeyRM ];

        Monthly_Performance__c monthlyTeam = [SELECT ID,Total_Opportunity_Stock__c,Total_Opportunity_App_In__c,Total_Opportunity_Approve__c,Total_Opportunity_Reject__c,Total_Opportunity_Setup__c,Total_Opportunity_Close_Lost__c,Total_Opportunity_Auto_Closed__c
          FROM Monthly_Performance__c WHERE External_ID__c =:exKeyTeam ];

        
        
        System.assertEquals(3,monthlyRM1.Total_Opportunity_Stock__c);
        System.assertEquals(2,monthlyRM1.Total_Opportunity_App_In__c);
        System.assertEquals(2,monthlyRM1.Total_Opportunity_Approve__c);
        System.assertEquals(0,monthlyRM1.Total_Opportunity_Reject__c);
        System.assertEquals(0,monthlyRM1.Total_Opportunity_Setup__c);
        System.assertEquals(0,monthlyRM1.Total_Opportunity_Close_Lost__c);
        System.assertEquals(0,monthlyRM1.Total_Opportunity_Auto_Closed__c);

        System.assertEquals(4,monthlyTeam.Total_Opportunity_Stock__c);
        System.assertEquals(3,monthlyTeam.Total_Opportunity_App_In__c);
        System.assertEquals(3,monthlyTeam.Total_Opportunity_Approve__c);
        System.assertEquals(0,monthlyTeam.Total_Opportunity_Reject__c);
        System.assertEquals(0,monthlyTeam.Total_Opportunity_Setup__c);
        System.assertEquals(0,monthlyTeam.Total_Opportunity_Close_Lost__c);
        System.assertEquals(1,monthlyTeam.Total_Opportunity_Auto_Closed__c);

    
       
    }

     @isTest static void testManualRunWithOpportunityHistory(){

        Account targetAccount = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        //Account targetAccount2 = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :CallReport_Test.accountNameTM LIMIT 1];
        User userRM = [SELECT Id,Employee_Id__c,Job_Code__c,RC_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User_Extension__c userRMExt = [SELECT Id,Team_Structure__c,Team_Structure__r.RC_Code__c,User__r.id FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        
        User userRM2 = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
        User_Extension__c userRMExt2 = [SELECT Id,Team_Structure__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
       
        Team_Structure__c teamAH = [SELECT Id,External_ID__c FROM Team_Structure__c WHERE RC_Code__c='41400' LIMIT 1];
        Team_Structure__c teamNH = [SELECT Id,External_ID__c FROM Team_Structure__c WHERE RC_Code__c='41201' LIMIT 1];


            TriggerHandler.bypass('OpportunityTriggerHandler');
            List<Opportunity> opp_list = new List<Opportunity>();
            Opportunity opp1,opp2,opp3;
            System.runAs(userRM){
                String app1 = '0001';
                String app2 = '0002';
                String app3 = '0003';
                opp1 = Mockup_Test.newOpportunityWithAppHisWithAppNo(targetAccount.Id, 'TestUW1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS,app1,null);
                opp2 = Mockup_Test.newOpportunityWithAppHisWithAppNo(targetAccount.Id, 'TestUW2', GlobalConstants.WAITING_FOR_CREDIT_SETUP, GlobalConstants.NON_CMAS,app2,null);
                opp3 = Mockup_Test.newOpportunityWithAppHisWithAppNo(targetAccount.Id, 'TestUW3', GlobalConstants.WAITING_FOR_CREDIT_SETUP, GlobalConstants.NON_CMAS,app3,null);
            }

            Test.setCreatedDate(opp1.Id, DateTime.newInstance(System.now().year(),1,31));
            Test.setCreatedDate(opp2.Id, DateTime.newInstance(System.now().year(),1,31));
            Test.setCreatedDate(opp2.Id, DateTime.newInstance(System.now().year(),1,31));
            
            opp_list.clear();
            opp1.Current_Owner_Extension__c = userRMExt.ID;
            opp1.Current_Team_Name__c = userRMExt.Team_Structure__c;
            opp1.Current_AH_Name__c = teamAH.ID;
            opp1.Current_NH_Name__c = teamNH.ID;
            opp1.Previous_Stage__c = GlobalConstants.CREDIT_WRITE_UP;

            opp2.Current_Owner_Extension__c = userRMExt.ID;
            opp2.Current_Team_Name__c = userRMExt.Team_Structure__c;
            opp2.Current_AH_Name__c = teamAH.ID;
            opp2.Current_NH_Name__c = teamNH.ID;
            opp2.Previous_Stage__c = GlobalConstants.STOCK_NEGOTIATION;
            
            opp3.Current_Owner_Extension__c = userRMExt.ID;
            opp3.Current_Team_Name__c = userRMExt.Team_Structure__c;
            opp3.Current_AH_Name__c = teamAH.ID;
            opp3.Current_NH_Name__c = teamNH.ID;
            opp3.Previous_Stage__c = GlobalConstants.WAITING_FOR_CREDIT_SETUP;
            opp_list.add(opp1);
            opp_list.add(opp2);
            opp_list.add(opp3);
            update opp_list;
            opp_list.clear();

        TriggerHandler.clearbypass('OpportunityTriggerHandler');
    
        Test.startTest();
            Database.executeBatch(new SME_OpportunityPerformance_Batch(0,1,31));
        Test.stopTest();

        System.assertEquals(3,[SELECT Count() FROM Opportunity ]);

   
     }
    
    
}