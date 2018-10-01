@isTest
private class SME_CallReportPerformance_Batch_Test {

     public static String accountNameRM = 'rmCreatedAccountName';
     public static String accountNameTM = 'tmCreatedAccountName';
     public static String accountNameAH = 'ahCreatedAccountName';
     public static String accountNameNH = 'nhCreatedAccountName';



    @testSetup static void setupUser(){
          Mockup_Test mt = new Mockup_Test().setUpTestWithExtension();


        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH LIMIT 1][0]){
            mt.newAccount(accountNameNH,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }

        Performance_Config__c perfConfigObj = new Performance_Config__c(Date__c = 25,Reset_Date__c = Date.newInstance(System.today().year(), 1, 1));
        System.runAs(new User(Id=UserInfo.getUserId())){
        insert perfConfigObj;
        }
        

    }

    
    @isTest static void positiveCaseNumberCallreportMatchUserExtTeamStrucMonthlyPerf() {

        Account targetAccount = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        System.assertEquals('Permanent',targetAccount.Ownership__c);
        User_Extension__c userNHExt = [SELECT Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];
        User_Extension__c userAHExt = [SELECT Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];   
        User_Extension__c userTMExt = [SELECT Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User_Extension__c userRMExt = [SELECT Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Team_Structure__c teamStrucObj = [SELECT RC_Code__c,AH_RC_Code__c,NH_RC_Code__c FROM Team_Structure__c WHERE id =:userTMExt.Team_Structure__c LIMIT 1];
        
        Date thisDay = System.today();
        Integer thisMonth = thisDay.month();  
        Integer thisYear;
        thisYear = GlobalUtility.getYearInBuddhistCalendar(thisDay);
   
         //7 records, 3 for teamstruc, 4 for users
        List<Monthly_Performance__c> monthlyPerfList = new List<Monthly_Performance__c>{
            new Monthly_Performance__c(
                External_ID__c = userNHExt.Employee_ID__c +' '+thisMonth+' '+thisYear,
                User__c = userNHExt.Id
                ),
            new Monthly_Performance__c(
                External_ID__c = userAHExt.Employee_ID__c +' '+thisMonth+' '+thisYear,
                User__c = userAHExt.Id
                ),
            new Monthly_Performance__c(
                External_ID__c = userTMExt.Employee_ID__c +' '+thisMonth+' '+thisYear,
                User__c = userTMExt.Id
                ),
            new Monthly_Performance__c(
                External_ID__c = userRMExt.Employee_ID__c +' '+thisMonth+' '+thisYear,
                User__c = userRMExt.Id
                ),
            new Monthly_Performance__c(
                External_ID__c = teamStrucObj.RC_Code__c+' '+thisMonth+' '+thisYear,
                Team__c = userTMExt.Team_Structure__c
                ),
            new Monthly_Performance__c(
                External_ID__c = teamStrucObj.AH_RC_Code__c+' '+thisMonth+' '+thisYear,
                Team__c = userAHExt.Team_Structure__c
                ),
            new Monthly_Performance__c(
                External_ID__c = teamStrucObj.NH_RC_Code__c+' '+thisMonth+' '+thisYear,
                Team__c = userNHExt.Team_Structure__c
                )

        };


        /// 4 report , 1 Sell report for each RM TM, 1 Relation report for AH,NH
        List<Call_Report__c> callReportList = new List<Call_Report__c>{
            new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Offer_Interest__c = 'Interest and can apply',
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Face to Face',
                //Call_Result_Activity__c = 'Offer Credit Product',
                Current_Owner_Extension__c = userRMExt.Id,
                Current_Team_Name__c = userTMExt.Team_Structure__c,
                Current_AH_Name__c   = userAHExt.Team_Structure__c,
                Current_NH_Name__c   = userNHExt.Team_Structure__c
            ),
            new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Offer_Credit_Product__c  = true,
                Offer_Interest__c = 'Interest and can apply',
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Phone Call',
               // Call_Result_Activity__c = 'Collect Documents',
                Collect_Documents__c = true,
                Non_Credit__c = true,
                Current_Owner_Extension__c = userTMExt.Id,
                Current_Team_Name__c = userTMExt.Team_structure__c,
                Current_AH_Name__c   = userAHExt.Team_Structure__c,
                Current_NH_Name__c   = userNHExt.Team_Structure__c
            ),
            new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Visit_Objective__c = 'Relationship',
                Plan_Amount__c = 5000,
                Complete_Monthly__c = true,
                Offer_Interest__c = null,
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Face to Face',
                //Call_Result_Activity__c = 'Not in three fields',
                Pain__c = true,
                Current_Owner_Extension__c = userAHExt.Id,
                Current_Team_Name__c = null,
                Current_AH_Name__c   = userAHExt.Team_Structure__c,
                Current_NH_Name__c   = userNHExt.Team_Structure__c
            ),
            new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Visit_Objective__c = 'Relationship',
                Plan_Amount__c = 5000,
                Offer_Interest__c = null,
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Phone Call',
                // Call_Result_Activity__c = 'Not in three fields',
                Non_Credit__c = true,
                Current_Owner_Extension__c = userNHExt.Id,
                Current_Team_Name__c = null,
                Current_AH_Name__c   = null,
                Current_NH_Name__c   = userNHExt.Team_Structure__c
            )
        };

        TriggerHandler.bypass('MonthlyPerformanceTriggerHandler');
        insert monthlyPerfList;
        TriggerHandler.clearBypass('MonthlyPerformanceTriggerHandler');
        TriggerHandler.bypass('CallReportTriggerHandler');
        insert callReportList;
        TriggerHandler.clearBypass('CallReportTriggerHandler');
        

        Test.startTest();
           Database.executeBatch(new SME_CallReportPerformance_Batch());
        Test.stopTest();

        User_Extension__c userNHExt1 = [SELECT Employee_ID__c,Team_Structure__c,CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM User_Extension__c WHERE Id = :userNHExt.Id LIMIT 1];
           // System.debug('userTMExt1 : '+userTMExt1);
            System.assertEquals(1.0, userNHExt1.CRTotal_Call_Report__c);
            System.assertEquals(0.0, userNHExt1.CRCall_Report_for_Sales__c);
            System.assertEquals(1.0, userNHExt1.CRCall_Report_for_Relationship__c);
            System.assertEquals(0.0, userNHExt1.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(0.0, userNHExt1.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(0.0, userNHExt1.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(1.0, userNHExt1.CRCall_Report_Relationship_Phone_Call__c);

        User_Extension__c userAHExt1 = [SELECT Employee_ID__c,Team_Structure__c,CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM User_Extension__c WHERE Id = :userAHExt.Id LIMIT 1];
           // System.debug('userTMExt1 : '+userTMExt1);
            System.assertEquals(1.0, userAHExt1.CRTotal_Call_Report__c);
            System.assertEquals(0.0, userAHExt1.CRCall_Report_for_Sales__c);
            System.assertEquals(1.0, userAHExt1.CRCall_Report_for_Relationship__c);
            System.assertEquals(0.0, userAHExt1.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(0.0, userAHExt1.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(1.0, userAHExt1.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(0.0, userAHExt1.CRCall_Report_Relationship_Phone_Call__c);

        User_Extension__c userTMExt1 = [SELECT Employee_ID__c,Team_Structure__c,CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM User_Extension__c WHERE Id = :userTMExt.Id LIMIT 1];
           // System.debug('userTMExt1 : '+userTMExt1);
            System.assertEquals(1.0, userTMExt1.CRTotal_Call_Report__c);
            System.assertEquals(1.0, userTMExt1.CRCall_Report_for_Sales__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_for_Relationship__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(1.0, userTMExt1.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Relationship_Phone_Call__c);
        User_Extension__c userRMExt1 = [SELECT Employee_ID__c,CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM User_Extension__c WHERE Id = :userRMExt.Id LIMIT 1];
           // System.debug('userRMExt : '+userRMExt1);
            System.assertEquals(1.0, userRMExt1.CRTotal_Call_Report__c);
            System.assertEquals(1.0, userRMExt1.CRCall_Report_for_Sales__c);
            System.assertEquals(0.0, userRMExt1.CRCall_Report_for_Relationship__c);
            System.assertEquals(1.0, userRMExt1.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(0.0, userRMExt1.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(0.0, userRMExt1.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(0.0, userRMExt1.CRCall_Report_Relationship_Phone_Call__c);
        
        Team_Structure__c teamStrucTMLevel = [SELECT RC_Code__c,CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM Team_Structure__c WHERE Id = :userTMExt.Team_Structure__c LIMIT 1];
            System.assertEquals(2.0, teamStrucTMLevel.CRTotal_Call_Report__c);
            System.assertEquals(2.0, teamStrucTMLevel.CRCall_Report_for_Sales__c);
            System.assertEquals(0.0, teamStrucTMLevel.CRCall_Report_for_Relationship__c);
            System.assertEquals(1.0, teamStrucTMLevel.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(1.0, teamStrucTMLevel.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(0.0, teamStrucTMLevel.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(0.0, teamStrucTMLevel.CRCall_Report_Relationship_Phone_Call__c);
        
        Team_Structure__c teamStrucAHLevel = [SELECT RC_Code__c,CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM Team_Structure__c WHERE Id = :userAHExt.Team_Structure__c LIMIT 1];
            System.assertEquals(3.0, teamStrucAHLevel.CRTotal_Call_Report__c);
            System.assertEquals(2.0, teamStrucAHLevel.CRCall_Report_for_Sales__c);
            System.assertEquals(1.0, teamStrucAHLevel.CRCall_Report_for_Relationship__c);
            System.assertEquals(1.0, teamStrucAHLevel.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(1.0, teamStrucAHLevel.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(1.0, teamStrucAHLevel.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(0.0, teamStrucAHLevel.CRCall_Report_Relationship_Phone_Call__c);
       
        Team_Structure__c teamStrucNHLevel = [SELECT RC_Code__c,CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM Team_Structure__c WHERE Id = :userNHExt.Team_Structure__c LIMIT 1];
            System.assertEquals(4.0, teamStrucNHLevel.CRTotal_Call_Report__c);
            System.assertEquals(2.0, teamStrucNHLevel.CRCall_Report_for_Sales__c);
            System.assertEquals(2.0, teamStrucNHLevel.CRCall_Report_for_Relationship__c);
            System.assertEquals(1.0, teamStrucNHLevel.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(1.0, teamStrucNHLevel.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(1.0, teamStrucNHLevel.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(1.0, teamStrucNHLevel.CRCall_Report_Relationship_Phone_Call__c);
       
        String externalId = userNHExt1.Employee_ID__c+' '+thisMonth+' '+thisYear;
        Monthly_Performance__c monthlyOfNHExt = [SELECT CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM Monthly_Performance__c WHERE External_ID__c=:externalId LIMIT 1];
            System.assertEquals(userNHExt1.CRTotal_Call_Report__c, monthlyOfNHExt.CRTotal_Call_Report__c);
            System.assertEquals(userNHExt1.CRCall_Report_for_Sales__c, monthlyOfNHExt.CRCall_Report_for_Sales__c);
            System.assertEquals(userNHExt1.CRCall_Report_for_Relationship__c, monthlyOfNHExt.CRCall_Report_for_Relationship__c);
            System.assertEquals(userNHExt1.CRCall_Report_Sales_Face_to_Face__c, monthlyOfNHExt.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(userNHExt1.CRCall_Report_Sales_Phone_Call__c, monthlyOfNHExt.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(userNHExt1.CRCall_Report_Relationship_Face_to_Face__c, monthlyOfNHExt.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(userNHExt1.CRCall_Report_Relationship_Phone_Call__c, monthlyOfNHExt.CRCall_Report_Relationship_Phone_Call__c);
        
        externalId = userAHExt1.Employee_ID__c+' '+thisMonth+' '+thisYear;
        Monthly_Performance__c monthlyOfANExt = [SELECT CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM Monthly_Performance__c WHERE External_ID__c=:externalId LIMIT 1];
            System.assertEquals(userAHExt1.CRTotal_Call_Report__c, monthlyOfANExt.CRTotal_Call_Report__c);
            System.assertEquals(userAHExt1.CRCall_Report_for_Sales__c, monthlyOfANExt.CRCall_Report_for_Sales__c);
            System.assertEquals(userAHExt1.CRCall_Report_for_Relationship__c, monthlyOfANExt.CRCall_Report_for_Relationship__c);
            System.assertEquals(userAHExt1.CRCall_Report_Sales_Face_to_Face__c, monthlyOfANExt.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(userAHExt1.CRCall_Report_Sales_Phone_Call__c, monthlyOfANExt.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(userAHExt1.CRCall_Report_Relationship_Face_to_Face__c, monthlyOfANExt.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(userAHExt1.CRCall_Report_Relationship_Phone_Call__c, monthlyOfANExt.CRCall_Report_Relationship_Phone_Call__c);
        
        externalId = userTMExt1.Employee_ID__c+' '+thisMonth+' '+thisYear;
        Monthly_Performance__c monthlyOfTMExt = [SELECT CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM Monthly_Performance__c WHERE External_ID__c=:externalId LIMIT 1];
            System.assertEquals(userTMExt1.CRTotal_Call_Report__c, monthlyOfTMExt.CRTotal_Call_Report__c);
            System.assertEquals(userTMExt1.CRCall_Report_for_Sales__c, monthlyOfTMExt.CRCall_Report_for_Sales__c);
            System.assertEquals(userTMExt1.CRCall_Report_for_Relationship__c, monthlyOfTMExt.CRCall_Report_for_Relationship__c);
            System.assertEquals(userTMExt1.CRCall_Report_Sales_Face_to_Face__c, monthlyOfTMExt.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(userTMExt1.CRCall_Report_Sales_Phone_Call__c, monthlyOfTMExt.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(userTMExt1.CRCall_Report_Relationship_Face_to_Face__c, monthlyOfTMExt.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(userTMExt1.CRCall_Report_Relationship_Phone_Call__c, monthlyOfTMExt.CRCall_Report_Relationship_Phone_Call__c);
        
        externalId = userRMExt1.Employee_ID__c+' '+thisMonth+' '+thisYear;
        Monthly_Performance__c monthlyOfRMExt = [SELECT CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM Monthly_Performance__c WHERE External_ID__c=:externalId LIMIT 1];
            System.assertEquals(userRMExt1.CRTotal_Call_Report__c, monthlyOfRMExt.CRTotal_Call_Report__c);
            System.assertEquals(userRMExt1.CRCall_Report_for_Sales__c, monthlyOfRMExt.CRCall_Report_for_Sales__c);
            System.assertEquals(userRMExt1.CRCall_Report_for_Relationship__c, monthlyOfRMExt.CRCall_Report_for_Relationship__c);
            System.assertEquals(userRMExt1.CRCall_Report_Sales_Face_to_Face__c, monthlyOfRMExt.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(userRMExt1.CRCall_Report_Sales_Phone_Call__c, monthlyOfRMExt.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(userRMExt1.CRCall_Report_Relationship_Face_to_Face__c, monthlyOfRMExt.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(userRMExt1.CRCall_Report_Relationship_Phone_Call__c, monthlyOfRMExt.CRCall_Report_Relationship_Phone_Call__c);
        
        externalId = teamStrucNHLevel.RC_Code__c+' '+thisMonth+' '+thisYear;
        Monthly_Performance__c monthlyOfTeamNHLevel = [SELECT CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM Monthly_Performance__c WHERE External_ID__c=:externalId LIMIT 1];
            System.assertEquals(teamStrucNHLevel.CRTotal_Call_Report__c, monthlyOfTeamNHLevel.CRTotal_Call_Report__c);
            System.assertEquals(teamStrucNHLevel.CRCall_Report_for_Sales__c, monthlyOfTeamNHLevel.CRCall_Report_for_Sales__c);
            System.assertEquals(teamStrucNHLevel.CRCall_Report_for_Relationship__c, monthlyOfTeamNHLevel.CRCall_Report_for_Relationship__c);
            System.assertEquals(teamStrucNHLevel.CRCall_Report_Sales_Face_to_Face__c, monthlyOfTeamNHLevel.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(teamStrucNHLevel.CRCall_Report_Sales_Phone_Call__c, monthlyOfTeamNHLevel.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(teamStrucNHLevel.CRCall_Report_Relationship_Face_to_Face__c, monthlyOfTeamNHLevel.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(teamStrucNHLevel.CRCall_Report_Relationship_Phone_Call__c, monthlyOfTeamNHLevel.CRCall_Report_Relationship_Phone_Call__c);
        
        externalId = teamStrucAHLevel.RC_Code__c+' '+thisMonth+' '+thisYear;
        Monthly_Performance__c monthlyOfTeamAHLevel = [SELECT CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM Monthly_Performance__c WHERE External_ID__c=:externalId LIMIT 1];
            System.assertEquals(teamStrucAHLevel.CRTotal_Call_Report__c, monthlyOfTeamAHLevel.CRTotal_Call_Report__c);
            System.assertEquals(teamStrucAHLevel.CRCall_Report_for_Sales__c, monthlyOfTeamAHLevel.CRCall_Report_for_Sales__c);
            System.assertEquals(teamStrucAHLevel.CRCall_Report_for_Relationship__c, monthlyOfTeamAHLevel.CRCall_Report_for_Relationship__c);
            System.assertEquals(teamStrucAHLevel.CRCall_Report_Sales_Face_to_Face__c, monthlyOfTeamAHLevel.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(teamStrucAHLevel.CRCall_Report_Sales_Phone_Call__c, monthlyOfTeamAHLevel.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(teamStrucAHLevel.CRCall_Report_Relationship_Face_to_Face__c, monthlyOfTeamAHLevel.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(teamStrucAHLevel.CRCall_Report_Relationship_Phone_Call__c, monthlyOfTeamAHLevel.CRCall_Report_Relationship_Phone_Call__c);
       
        externalId = teamStrucTMLevel.RC_Code__c+' '+thisMonth+' '+thisYear;
        Monthly_Performance__c monthlyOfTeamTMLevel = [SELECT CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM Monthly_Performance__c WHERE External_ID__c=:externalId LIMIT 1];
            System.assertEquals(teamStrucTMLevel.CRTotal_Call_Report__c, monthlyOfTeamTMLevel.CRTotal_Call_Report__c);
            System.assertEquals(teamStrucTMLevel.CRCall_Report_for_Sales__c, monthlyOfTeamTMLevel.CRCall_Report_for_Sales__c);
            System.assertEquals(teamStrucTMLevel.CRCall_Report_for_Relationship__c, monthlyOfTeamTMLevel.CRCall_Report_for_Relationship__c);
            System.assertEquals(teamStrucTMLevel.CRCall_Report_Sales_Face_to_Face__c, monthlyOfTeamTMLevel.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(teamStrucTMLevel.CRCall_Report_Sales_Phone_Call__c, monthlyOfTeamTMLevel.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(teamStrucTMLevel.CRCall_Report_Relationship_Face_to_Face__c, monthlyOfTeamTMLevel.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(teamStrucTMLevel.CRCall_Report_Relationship_Phone_Call__c, monthlyOfTeamTMLevel.CRCall_Report_Relationship_Phone_Call__c);

    }

    @isTest static void negativeCaseCallReportOlderThanAYear() {
        //Performance_Config__c perfConfigObj = new Performance_Config__c(Date__c = null);
        //System.runAs(new User(Id=UserInfo.getUserId())){
        //insert perfConfigObj;
        //}
        Account targetAccount = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        System.assertEquals('Permanent',targetAccount.Ownership__c);
        User_Extension__c userTMExt = [SELECT Id,Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
       
        Date thisDay = System.today();
        Integer thisMonth = thisDay.month();  
        Integer thisYear;
        thisYear = GlobalUtility.getYearInBuddhistCalendar(thisDay);

        Monthly_Performance__c monthlyPerfObj =  new Monthly_Performance__c(
                External_ID__c = userTMExt.Employee_ID__c+' '+thisMonth+' '+thisYear,
                Team__c = userTMExt.Team_Structure__c
                );
        Call_Report__c callReportObj =   new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Offer_Interest__c = 'Interest and can apply',
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today().addyears(-1),
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Face to Face',
                //Call_Result_Activity__c = 'Offer Credit Product',
                Current_Owner_Extension__c = userTMExt.Id,
                Current_Team_Name__c = userTMExt.Team_Structure__c
            );
        TriggerHandler.bypass('MonthlyPerformanceTriggerHandler');
        insert monthlyPerfObj;
        TriggerHandler.clearBypass('MonthlyPerformanceTriggerHandler');
        TriggerHandler.bypass('CallReportTriggerHandler');
        insert callReportObj;
        TriggerHandler.clearBypass('CallReportTriggerHandler');
        Test.startTest();
           Database.executeBatch(new SME_CallReportPerformance_Batch());
        Test.stopTest();
            

        User_Extension__c userTMExt1 = [SELECT Employee_ID__c,Team_Structure__c,CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM User_Extension__c WHERE Id = :userTMExt.Id];
            System.assertEquals(0.0, userTMExt1.CRTotal_Call_Report__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_for_Sales__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_for_Relationship__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Relationship_Phone_Call__c);

        String externalId = userTMExt1.Employee_ID__c+ ' '+ thisMonth + ' '+ thisYear;
        Monthly_Performance__c monthlyOfTMExt = [SELECT CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM Monthly_Performance__c WHERE External_ID__c = :externalId];
            System.assertEquals(0.0, monthlyOfTMExt.CRTotal_Call_Report__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_for_Sales__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_for_Relationship__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_Relationship_Phone_Call__c);
    }

    @isTest static void negativeCaseCallReportWithoutMonthlyPerformanceInitialized(){
        //Performance_Config__c perfConfigObj = new Performance_Config__c(Date__c = 25);
        //System.runAs(new User(Id=UserInfo.getUserId())){
        //insert perfConfigObj;
        //}
        Account targetAccount = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        System.assertEquals('Permanent',targetAccount.Ownership__c);
        User_Extension__c userTMExt = [SELECT Id,Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        Date thisDay = System.today();
        Integer thisMonth = thisDay.month();  
        Integer thisYear;
        thisYear = GlobalUtility.getYearInBuddhistCalendar(thisDay);

        Call_Report__c callReportObj =   new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Offer_Interest__c = 'Interest and can apply',
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Face to Face',
                //Call_Result_Activity__c = 'Offer Credit Product',
                Current_Owner_Extension__c = userTMExt.Id,
                Current_Team_Name__c = userTMExt.Team_Structure__c
            );

        TriggerHandler.bypass('CallReportTriggerHandler');
        insert callReportObj;
        TriggerHandler.clearBypass('CallReportTriggerHandler');
        Test.startTest();
           Database.executeBatch(new SME_CallReportPerformance_Batch());
        Test.stopTest();

        User_Extension__c userTMExt1 = [SELECT Employee_ID__c,Team_Structure__c,CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM User_Extension__c WHERE Id = :userTMExt.Id];
            System.assertEquals(1.0, userTMExt1.CRTotal_Call_Report__c);
            System.assertEquals(1.0, userTMExt1.CRCall_Report_for_Sales__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_for_Relationship__c);
            System.assertEquals(1.0, userTMExt1.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Relationship_Phone_Call__c);
        String externalId = userTMExt1.Employee_ID__c+ ' '+ thisMonth + ' '+ thisYear;
        Monthly_Performance__c monthlyOfTMExt = [SELECT CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM Monthly_Performance__c WHERE External_ID__c = :externalId];
            System.assertEquals(1.0, monthlyOfTMExt.CRTotal_Call_Report__c);
            System.assertEquals(1.0, monthlyOfTMExt.CRCall_Report_for_Sales__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_for_Relationship__c);
            System.assertEquals(1.0, monthlyOfTMExt.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_Relationship_Phone_Call__c);
         
    }

    @isTest static void negativeCaseCurrentOwnerExtIsNull(){
        //Performance_Config__c perfConfigObj = new Performance_Config__c(Date__c = 25);
        //System.runAs(new User(Id=UserInfo.getUserId())){
        //insert perfConfigObj;
        //}
        Account targetAccount = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        System.assertEquals('Permanent',targetAccount.Ownership__c);
        User_Extension__c userTMExt = [SELECT Id,Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
       
        Date thisDay = System.today();
        Integer thisMonth = thisDay.month();  
        Integer thisYear;
        thisYear = GlobalUtility.getYearInBuddhistCalendar(thisDay);

        Monthly_Performance__c monthlyPerfObj =  new Monthly_Performance__c(
                External_ID__c = userTMExt.Employee_ID__c+' '+thisMonth+' '+thisYear,
                Team__c = userTMExt.Team_Structure__c
                );
        Call_Report__c callReportObj =   new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Offer_Interest__c = 'Interest and can apply',
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Face to Face',
                //Call_Result_Activity__c = 'Offer Credit Product',
                Current_Owner_Extension__c = null,
                Current_Team_Name__c = userTMExt.Team_Structure__c
            );
        TriggerHandler.bypass('MonthlyPerformanceTriggerHandler');
        insert monthlyPerfObj;
        TriggerHandler.clearBypass('MonthlyPerformanceTriggerHandler');
        TriggerHandler.bypass('CallReportTriggerHandler');
        insert callReportObj;
        TriggerHandler.clearBypass('CallReportTriggerHandler');
        Test.startTest();
           Database.executeBatch(new SME_CallReportPerformance_Batch());
        Test.stopTest();
            

        User_Extension__c userTMExt1 = [SELECT Employee_ID__c,Team_Structure__c,CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM User_Extension__c WHERE Id = :userTMExt.Id];
            System.assertEquals(0.0, userTMExt1.CRTotal_Call_Report__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_for_Sales__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_for_Relationship__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Relationship_Phone_Call__c);

        String externalId = userTMExt1.Employee_ID__c+ ' '+ thisMonth + ' '+ thisYear;
        Monthly_Performance__c monthlyOfTMExt = [SELECT CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM Monthly_Performance__c WHERE External_ID__c = :externalId];
            System.assertEquals(0.0, monthlyOfTMExt.CRTotal_Call_Report__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_for_Sales__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_for_Relationship__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(0.0, monthlyOfTMExt.CRCall_Report_Relationship_Phone_Call__c);

    }

    @isTest static void UserExtInactiveAndNotCreatMonthlyPerf(){
        //Performance_Config__c perfConfigObj = new Performance_Config__c(Date__c = 25);
        //System.runAs(new User(Id=UserInfo.getUserId())){
        //insert perfConfigObj;
        //}
        Account targetAccount = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        System.assertEquals('Permanent',targetAccount.Ownership__c);
        User_Extension__c userTMExt = [SELECT Id,Team_Structure__c,Employee_ID__c,Active__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User userTM = [SELECT Id,IsActive FROM User WHERE Employee_ID__c = :userTMExt.Employee_ID__c];
        userTM.IsActive = false;
        System.runAs(new User(Id=UserInfo.getUserId())){
        update userTM;
        }
        Date thisDay = System.today();
        Integer thisMonth = thisDay.month();  
        Integer thisYear;
        thisYear = GlobalUtility.getYearInBuddhistCalendar(thisDay);

        
        Date actualVisitDate = System.today();
        if(thisDay.month() != 1) actualVisitDate = actualVisitDate.addMonths(-1);

        Call_Report__c callReportObj =   new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Offer_Interest__c = 'Interest and can apply',
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = actualVisitDate,
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Face to Face',
                //Call_Result_Activity__c = 'Offer Credit Product',
                Current_Owner_Extension__c = userTMExt.Id,
                Current_Team_Name__c = userTMExt.Team_Structure__c
            );


        TriggerHandler.bypass('CallReportTriggerHandler');
        insert callReportObj;
        TriggerHandler.clearBypass('CallReportTriggerHandler');
        Test.startTest();
           Database.executeBatch(new SME_CallReportPerformance_Batch());
        Test.stopTest();
        
        User_Extension__c userTMExt1 = [SELECT Employee_ID__c,Team_Structure__c,CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM User_Extension__c WHERE Id = :userTMExt.Id];
        System.assertEquals(1.0, userTMExt1.CRTotal_Call_Report__c);
        System.assertEquals(1.0, userTMExt1.CRCall_Report_for_Sales__c);
        System.assertEquals(0.0, userTMExt1.CRCall_Report_for_Relationship__c);
        System.assertEquals(1.0, userTMExt1.CRCall_Report_Sales_Face_to_Face__c);
        System.assertEquals(0.0, userTMExt1.CRCall_Report_Sales_Phone_Call__c);
        System.assertEquals(0.0, userTMExt1.CRCall_Report_Relationship_Face_to_Face__c);
        System.assertEquals(0.0, userTMExt1.CRCall_Report_Relationship_Phone_Call__c);

        String externalId = userTMExt1.Employee_ID__c+ ' '+ thisMonth + ' '+ thisYear;
        List<Monthly_Performance__c> listofMonthyPerf = [SELECT Id FROM Monthly_Performance__c WHERE External_ID__c = :externalId];
        if(thisDay.month() != 1) System.assertEquals(true,listofMonthyPerf.isEmpty());

    }
    @isTest static void UserExtInactiveAndCreatCallReportThisMonth(){
        //Performance_Config__c perfConfigObj = new Performance_Config__c(Date__c = 25,Reset_Date__c = Date.newInstance(2017, 1, 1));
        //System.runAs(new User(Id=UserInfo.getUserId())){
        //insert perfConfigObj;
        //}
        Account targetAccount = [SELECT Id,Delete_Flag__c,Ownership__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        System.assertEquals('Permanent',targetAccount.Ownership__c);
        User_Extension__c userTMExt = [SELECT Id,Team_Structure__c,Employee_ID__c,Active__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User userTM = [SELECT Id,IsActive FROM User WHERE Employee_ID__c = :userTMExt.Employee_ID__c];
        userTM.IsActive = false;
        System.runAs(new User(Id=UserInfo.getUserId())){
        update userTM;
        }
        
        Date thisDay = System.today();
        Integer thisMonth = thisDay.month();  
        Integer thisYear;
        thisYear = GlobalUtility.getYearInBuddhistCalendar(thisDay);


        Call_Report__c callReportObj =   new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Status__c = 'Contacted',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Plan_Date__c = System.now(),
                Offer_Credit_Product__c = true,
                Visit_Objective__c = 'Sell',
                Plan_Amount__c = 5000,
                Offer_Interest__c = 'Interest and can apply',
                Port_Pool__c = 'Port',
                Ownership__c = 'Permanent',
                Expected_Credit_Amount__c =5000,
                Actual_Visit_Date__c = System.today(),
                Primary_Call_Report__c = true,
                Contact_Channel__c = 'Face to Face',
                //Call_Result_Activity__c = 'Offer Credit Product',
                Current_Owner_Extension__c = userTMExt.Id,
                Current_Team_Name__c = userTMExt.Team_Structure__c
            );


        TriggerHandler.bypass('CallReportTriggerHandler');
        insert callReportObj;
        TriggerHandler.clearBypass('CallReportTriggerHandler');
        Test.startTest();
           Database.executeBatch(new SME_CallReportPerformance_Batch());
        Test.stopTest();

          User_Extension__c userTMExt1 = [SELECT Employee_ID__c,Team_Structure__c,CRCall_Report_Sales_Phone_Call__c,CRTotal_Call_Report__c,CRCall_Report_Sales_Face_to_Face__c,CRCall_Report_for_Sales__c,CRCall_Report_for_Relationship__c,CRCall_Report_Relationship_Phone_Call__c,CRCall_Report_Relationship_Face_to_Face__c FROM User_Extension__c WHERE Id = :userTMExt.Id];
            System.assertEquals(1.0, userTMExt1.CRTotal_Call_Report__c);
            System.assertEquals(1.0, userTMExt1.CRCall_Report_for_Sales__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_for_Relationship__c);
            System.assertEquals(1.0, userTMExt1.CRCall_Report_Sales_Face_to_Face__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Sales_Phone_Call__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Relationship_Face_to_Face__c);
            System.assertEquals(0.0, userTMExt1.CRCall_Report_Relationship_Phone_Call__c);

        String externalId = userTMExt1.Employee_ID__c+ ' '+ thisMonth + ' '+ thisYear;
        System.assertNotEquals(null, [SELECT Id FROM Monthly_Performance__c WHERE External_ID__c = :externalId]);


    }
 
    
    
}