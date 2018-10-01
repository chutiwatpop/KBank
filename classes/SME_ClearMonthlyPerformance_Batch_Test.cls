@isTest
private class SME_ClearMonthlyPerformance_Batch_Test {
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

	}

	@isTest static void possitiveCaseMonthlyPerfDeleteMoreThanTwoYearRecord() {
		User_Extension__c userNHExt = [SELECT Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];
        User_Extension__c userAHExt = [SELECT Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];   
        User_Extension__c userTMExt = [SELECT Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User_Extension__c userRMExt = [SELECT Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Team_Structure__c teamStrucObj = [SELECT RC_Code__c,AH_RC_Code__c,NH_RC_Code__c FROM Team_Structure__c WHERE id =:userTMExt.Team_Structure__c LIMIT 1];

        Date today;
        Integer currentMonth;
        Integer currentYear;
        Integer previosTwoYear;
        today = System.today();
        currentYear = GlobalUtility.getYearInBuddhistCalendar(today); 
        previosTwoYear = currentYear-2;
        currentMonth = today.month();

        List<Monthly_Performance__c> monthlyPerfList = new List<Monthly_Performance__c>{
            new Monthly_Performance__c(
                External_ID__c = userNHExt.Employee_ID__c +' '+currentMonth+' '+previosTwoYear,
                User__c = userNHExt.Id
                ),
            new Monthly_Performance__c(
                External_ID__c = userAHExt.Employee_ID__c +' '+currentMonth+' '+previosTwoYear,
                User__c = userAHExt.Id
                ),
            new Monthly_Performance__c(
                External_ID__c = userTMExt.Employee_ID__c +' '+currentMonth+' '+previosTwoYear,
                User__c = userTMExt.Id
                ),
            new Monthly_Performance__c(
                External_ID__c = userRMExt.Employee_ID__c +' '+currentMonth+' '+previosTwoYear,
                User__c = userRMExt.Id
                ),
            new Monthly_Performance__c(
                External_ID__c = teamStrucObj.RC_Code__c+' '+currentMonth+' '+previosTwoYear,
                Team__c = userTMExt.Team_Structure__c
                ),
            new Monthly_Performance__c(
                External_ID__c = teamStrucObj.AH_RC_Code__c+' '+currentMonth+' '+previosTwoYear,
                Team__c = userAHExt.Team_Structure__c
                ),
            new Monthly_Performance__c(
                External_ID__c = teamStrucObj.NH_RC_Code__c+' '+currentMonth+' '+previosTwoYear,
                Team__c = userNHExt.Team_Structure__c
                )
        };

        TriggerHandler.bypass('MonthlyPerformanceTriggerHandler');
        insert monthlyPerfList;
        TriggerHandler.clearBypass('MonthlyPerformanceTriggerHandler');
        Test.startTest();
	       Database.executeBatch(new SME_ClearMonthlyPerformance_Batch());
	    Test.stopTest();

        Integer totalMonthlyPerf = [SELECT count() FROM Monthly_Performance__c];
        System.assertEquals(0.0,totalMonthlyPerf);
	}
	
    @isTest static void negativeCaseMonthlyPerfWithinTwoYear(){
        User_Extension__c userNHExt = [SELECT Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];
        User_Extension__c userAHExt = [SELECT Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];   
        User_Extension__c userTMExt = [SELECT Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User_Extension__c userRMExt = [SELECT Team_Structure__c,Employee_ID__c  FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Team_Structure__c teamStrucObj = [SELECT RC_Code__c,AH_RC_Code__c,NH_RC_Code__c FROM Team_Structure__c WHERE id =:userTMExt.Team_Structure__c LIMIT 1];

        Date today;
        Integer currentMonth;
        Integer currentYear;
        Integer previosTwoYear;
        today = System.today();
        currentYear = GlobalUtility.getYearInBuddhistCalendar(today);
        previosTwoYear = currentYear-2;
        currentMonth = today.month();
        // 8 records
        List<Monthly_Performance__c> monthlyPerfList = new List<Monthly_Performance__c>{
            new Monthly_Performance__c(
                External_ID__c = userNHExt.Employee_ID__c +' '+currentMonth+' '+currentYear,
                User__c = userNHExt.Id
                ),
            new Monthly_Performance__c(
                External_ID__c = userAHExt.Employee_ID__c +' '+currentMonth+' '+currentYear,
                User__c = userAHExt.Id
                ),
            new Monthly_Performance__c(
                External_ID__c = userTMExt.Employee_ID__c +' '+currentMonth+' '+currentYear,
                User__c = userTMExt.Id
                ),
            new Monthly_Performance__c(
                External_ID__c = userRMExt.Employee_ID__c +' '+currentMonth+' '+currentYear,
                User__c = userRMExt.Id
                ),
            new Monthly_Performance__c(
                External_ID__c = teamStrucObj.RC_Code__c+' '+currentMonth+' '+currentYear,
                Team__c = userTMExt.Team_Structure__c
                ),
            new Monthly_Performance__c(
                External_ID__c = teamStrucObj.AH_RC_Code__c+' '+currentMonth+' '+currentYear,
                Team__c = userAHExt.Team_Structure__c
                ),
            new Monthly_Performance__c(
                External_ID__c = teamStrucObj.NH_RC_Code__c+' '+currentMonth+' '+currentYear,
                Team__c = userNHExt.Team_Structure__c
                )
        };

        TriggerHandler.bypass('MonthlyPerformanceTriggerHandler');
        insert monthlyPerfList;
        TriggerHandler.clearBypass('MonthlyPerformanceTriggerHandler');
        Test.startTest();
           Database.executeBatch(new SME_ClearMonthlyPerformance_Batch());
        Test.stopTest();

        Integer totalMonthlyPerf = [SELECT count() FROM Monthly_Performance__c];
        System.assertEquals(7.0,totalMonthlyPerf);
    }

}