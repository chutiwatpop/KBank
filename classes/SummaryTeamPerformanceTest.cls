@isTest
private class SummaryTeamPerformanceTest {
	
	@testSetup static void setupAccount(){
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestAdmin().setUpTestWithExtension();
        User userRm1 = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userRm2 = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM2 LIMIT 1];
        User userTm = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User userAh = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        User userNh = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];
        userRm1.Segment__c = 'SE';
		userRm2.Segment__c = 'SE';
		userTm.Segment__c = 'SE';
		userAh.Segment__c = 'SE';
		userNh.Segment__c = 'SE';
		List<User> listUser = new List<User>();
		listUser.add(userRm1);
		listUser.add(userRm2);
		listUser.add(userTm);
		listUser.add(userAh);
		listUser.add(userNh);
        Test.stopTest();
        User currentUser = new User(Id=UserInfo.getUserId());
        System.runAs(currentUser){
        	TriggerHandler.bypass('UserTriggerHandler');
        	update listUser;
        	TriggerHandler.clearbypass('UserTriggerHandler');
        }
    }

    private static void changeUserExFieldValue(User_Extension__c userEx,Integer newVal){
    	userEx.Customer_Contacted__c = newVal;
		userEx.Call_Report_for_Sales__c = newVal;
		userEx.Call_Report_Product_Interested__c = newVal;
		userEx.Product_Interested__c = newVal;
		userEx.Product_Final_Approved__c = newVal;
		userEx.Product_Set_Up__c = newVal;
		userEx.Call_Report_Credit_for_Sales__c = newVal;
		userEx.Call_Report_Credit_Product_Interested__c = newVal;
		userEx.Credit_Product_Interested__c = newVal;
		userEx.Total_Opportunity_App_In__c = newVal;
		userEx.Total_Opportunity_Setup__c = newVal;
		userEx.Total_Opportunity_Close_Lost__c = newVal;
		userEx.Call_Report__c = newVal;
		userEx.Call_Report_Customer_Port__c = newVal;
		userEx.Call_Report_Customer_Pool__c = newVal;
		userEx.Call_Report_Customer_Others__c = newVal;
		userEx.CRTotal_Call_Report__c = newVal;
		userEx.CRCall_Report_for_Sales__c = newVal;
		userEx.Call_Report_for_Relationship__c = newVal;
		userEx.CRCall_Report_for_Relationship__c = newVal;
		userEx.Phone_Call__c = newVal;
		userEx.Face_to_Face__c = newVal;
		userEx.Customer_Port__c = newVal;
		userEx.Customer_Pool__c = newVal;
		userEx.Customer_Other__c = newVal;
		userEx.Contacted_Customer_Port__c = newVal;
		userEx.Contacted_Customer_Pool__c = newVal;
		userEx.Contacted_Customer_Other__c = newVal;
		userEx.Contacted_Customer_Port_My_Penetrate__c = newVal;
		userEx.Contacted_Customer_Pool_My_Penetrate__c = newVal;
		userEx.Contacted_Customer_Other_My_Penetrate__c = newVal;
		userEx.Contacted_Other_CustCall__c = newVal;
		userEx.Contacted_Other_CustF2F__c = newVal;
		userEx.Contacted_Pool_CustCall__c = newVal;
		userEx.Contacted_Pool_CustF2F__c = newVal;
		userEx.Contacted_Port_CustCall__c = newVal;
		userEx.Contacted_Port_CustF2F__c = newVal;
		userEx.My_Penetrate_Contacted_Other_CustCall__c = newVal;
		userEx.My_Penetrate_Contacted_Other_CustF2F__c = newVal;
		userEx.My_Penetrate_Contacted_Pool_CustCall__c = newVal;
		userEx.My_Penetrate_Contacted_Pool_CustF2F__c = newVal;
		userEx.My_Penetrate_Contacted_Port_CustCall__c = newVal;
		userEx.My_Penetrate_Contacted_Port_CustF2F__c = newVal;
    }

	@isTest static void Given_2UserExtensionSameTeam_When_RunBatch_Then_SumPerformanceToSameTeam() {
		User_Extension__c userExRm1 = [SELECT Id,Customer_Contacted__c,Call_Report_for_Sales__c,Call_Report_Product_Interested__c,Product_Interested__c,Product_Final_Approved__c,Product_Set_Up__c,Call_Report_Credit_for_Sales__c,Call_Report_Credit_Product_Interested__c,Credit_Product_Interested__c,Total_Opportunity_App_In__c,Total_Opportunity_Setup__c,Total_Opportunity_Close_Lost__c,Number_of_RM_under_Team__c,Call_Report__c,Call_Report_Customer_Port__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Others__c,CRTotal_Call_Report__c,CRCall_Report_for_Sales__c,Call_Report_for_Relationship__c,CRCall_Report_for_Relationship__c,Phone_Call__c,Face_to_Face__c,Customer_Port__c,Customer_Pool__c,Customer_Other__c,Contacted_Customer_Port__c,Contacted_Customer_Pool__c,Contacted_Customer_Other__c,Contacted_Customer_Port_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Other_CustCall__c,Contacted_Other_CustF2F__c,Contacted_Pool_CustCall__c,Contacted_Pool_CustF2F__c,Contacted_Port_CustCall__c,Contacted_Port_CustF2F__c,My_Penetrate_Contacted_Other_CustCall__c,My_Penetrate_Contacted_Other_CustF2F__c,My_Penetrate_Contacted_Pool_CustCall__c,My_Penetrate_Contacted_Pool_CustF2F__c,My_Penetrate_Contacted_Port_CustCall__c,My_Penetrate_Contacted_Port_CustF2F__c FROM User_Extension__c WHERE External_ID__c = :Mockup_Test.userEmpIdRM];
		User_Extension__c userExRm2 = [SELECT Id,Customer_Contacted__c,Call_Report_for_Sales__c,Call_Report_Product_Interested__c,Product_Interested__c,Product_Final_Approved__c,Product_Set_Up__c,Call_Report_Credit_for_Sales__c,Call_Report_Credit_Product_Interested__c,Credit_Product_Interested__c,Total_Opportunity_App_In__c,Total_Opportunity_Setup__c,Total_Opportunity_Close_Lost__c,Number_of_RM_under_Team__c,Call_Report__c,Call_Report_Customer_Port__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Others__c,CRTotal_Call_Report__c,CRCall_Report_for_Sales__c,Call_Report_for_Relationship__c,CRCall_Report_for_Relationship__c,Phone_Call__c,Face_to_Face__c,Customer_Port__c,Customer_Pool__c,Customer_Other__c,Contacted_Customer_Port__c,Contacted_Customer_Pool__c,Contacted_Customer_Other__c,Contacted_Customer_Port_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Other_CustCall__c,Contacted_Other_CustF2F__c,Contacted_Pool_CustCall__c,Contacted_Pool_CustF2F__c,Contacted_Port_CustCall__c,Contacted_Port_CustF2F__c,My_Penetrate_Contacted_Other_CustCall__c,My_Penetrate_Contacted_Other_CustF2F__c,My_Penetrate_Contacted_Pool_CustCall__c,My_Penetrate_Contacted_Pool_CustF2F__c,My_Penetrate_Contacted_Port_CustCall__c,My_Penetrate_Contacted_Port_CustF2F__c FROM User_Extension__c WHERE External_ID__c = :Mockup_Test.userEmpIdRM2];
		changeUserExFieldValue(userExRm1,1);
		changeUserExFieldValue(userExRm2,2);
		List<User_Extension__c> listUserEx = new List<User_Extension__c>();
		listUserEx.add(userExRm1);
		listUserEx.add(userExRm2);
		update listUserEx;

		Test.startTest();
            Database.executeBatch(new SummaryTeamPerformance_Batch());
        Test.stopTest();

        Team_Structure__c sumAhTeam = [SELECT Id,Number_of_RM_under_Team__c FROM Team_Structure__c WHERE Rc_Code__c = :Mockup_Test.AH_RC_CODE];
        System.assertEquals(4,sumAhTeam.Number_of_RM_under_Team__c);
        Team_Structure__c sumNhTeam = [SELECT Id,Number_of_RM_under_Team__c FROM Team_Structure__c WHERE Rc_Code__c = :Mockup_Test.NH_RC_CODE];
        System.assertEquals(5,sumNhTeam.Number_of_RM_under_Team__c);
        Team_Structure__c sumTmTeam = [SELECT Id,Customer_Contacted__c,Call_Report_Product_Interested__c,Product_Interested__c,Product_Final_Approved__c,Product_Set_Up__c,Call_Report_Credit_for_Sales__c,Call_Report_Credit_Product_Interested__c,Credit_Product_Interested__c,Total_Opportunity_App_In__c,Total_Opportunity_Setup__c,Total_Opportunity_Close_Lost__c,Number_of_RM_under_Team__c,Call_Report__c,Call_Report_Customer_Port__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Others__c,CRTotal_Call_Report__c,Call_Report_for_Sales__c,CRCall_Report_for_Sales__c,Call_Report_for_Relationship__c,CRCall_Report_for_Relationship__c,Phone_Call__c,Face_to_Face__c,Customer_Port__c,Customer_Pool__c,Customer_Other__c,Contacted_Customer_Port__c,Contacted_Customer_Pool__c,Contacted_Customer_Other__c,Contacted_Customer_Port_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Other_CustCall__c,Contacted_Other_CustF2F__c,Contacted_Pool_CustCall__c,Contacted_Pool_CustF2F__c,Contacted_Port_CustCall__c,Contacted_Port_CustF2F__c,My_Penetrate_Contacted_Other_CustCall__c,My_Penetrate_Contacted_Other_CustF2F__c,My_Penetrate_Contacted_Pool_CustCall__c,My_Penetrate_Contacted_Pool_CustF2F__c,My_Penetrate_Contacted_Port_CustCall__c,My_Penetrate_Contacted_Port_CustF2F__c FROM Team_Structure__c WHERE Rc_Code__c = :Mockup_Test.RC_CODE];
        System.assertEquals(3,sumTmTeam.Number_of_RM_under_Team__c);
        System.assertEquals(3,sumTmTeam.Customer_Contacted__c);
		System.assertEquals(3,sumTmTeam.Call_Report_for_Sales__c);
		System.assertEquals(3,sumTmTeam.Call_Report_Product_Interested__c);
		System.assertEquals(3,sumTmTeam.Product_Interested__c);
		System.assertEquals(3,sumTmTeam.Product_Final_Approved__c);
		System.assertEquals(3,sumTmTeam.Product_Set_Up__c);
		System.assertEquals(3,sumTmTeam.Call_Report_Credit_for_Sales__c);
		System.assertEquals(3,sumTmTeam.Call_Report_Credit_Product_Interested__c);
		System.assertEquals(3,sumTmTeam.Credit_Product_Interested__c);
		System.assertEquals(3,sumTmTeam.Total_Opportunity_App_In__c);
		System.assertEquals(3,sumTmTeam.Total_Opportunity_Setup__c);
		System.assertEquals(3,sumTmTeam.Total_Opportunity_Close_Lost__c);
		System.assertEquals(3,sumTmTeam.Number_of_RM_under_Team__c);
		System.assertEquals(3,sumTmTeam.Call_Report__c);
		System.assertEquals(3,sumTmTeam.Call_Report_Customer_Port__c);
		System.assertEquals(3,sumTmTeam.Call_Report_Customer_Pool__c);
		System.assertEquals(3,sumTmTeam.Call_Report_Customer_Others__c);
		System.assertEquals(3,sumTmTeam.CRTotal_Call_Report__c);
		System.assertEquals(3,sumTmTeam.Call_Report_for_Sales__c);
		System.assertEquals(3,sumTmTeam.CRCall_Report_for_Sales__c);
		System.assertEquals(3,sumTmTeam.Call_Report_for_Relationship__c);
		System.assertEquals(3,sumTmTeam.CRCall_Report_for_Relationship__c);
		System.assertEquals(3,sumTmTeam.Phone_Call__c);
		System.assertEquals(3,sumTmTeam.Face_to_Face__c);
		System.assertEquals(3,sumTmTeam.Customer_Port__c);
		System.assertEquals(3,sumTmTeam.Customer_Pool__c);
		System.assertEquals(3,sumTmTeam.Customer_Other__c);
		System.assertEquals(3,sumTmTeam.Contacted_Customer_Port__c);
		System.assertEquals(3,sumTmTeam.Contacted_Customer_Pool__c);
		System.assertEquals(3,sumTmTeam.Contacted_Customer_Other__c);
		System.assertEquals(3,sumTmTeam.Contacted_Customer_Port_My_Penetrate__c);
		System.assertEquals(3,sumTmTeam.Contacted_Customer_Pool_My_Penetrate__c);
		System.assertEquals(3,sumTmTeam.Contacted_Customer_Other_My_Penetrate__c);
		System.assertEquals(3,sumTmTeam.Contacted_Other_CustCall__c);
		System.assertEquals(3,sumTmTeam.Contacted_Other_CustF2F__c);
		System.assertEquals(3,sumTmTeam.Contacted_Pool_CustCall__c);
		System.assertEquals(3,sumTmTeam.Contacted_Pool_CustF2F__c);
		System.assertEquals(3,sumTmTeam.Contacted_Port_CustCall__c);
		System.assertEquals(3,sumTmTeam.Contacted_Port_CustF2F__c);
		System.assertEquals(3,sumTmTeam.My_Penetrate_Contacted_Other_CustCall__c);
		System.assertEquals(3,sumTmTeam.My_Penetrate_Contacted_Other_CustF2F__c);
		System.assertEquals(3,sumTmTeam.My_Penetrate_Contacted_Pool_CustCall__c);
		System.assertEquals(3,sumTmTeam.My_Penetrate_Contacted_Pool_CustF2F__c);
		System.assertEquals(3,sumTmTeam.My_Penetrate_Contacted_Port_CustCall__c);
		System.assertEquals(3,sumTmTeam.My_Penetrate_Contacted_Port_CustF2F__c);
	}
}