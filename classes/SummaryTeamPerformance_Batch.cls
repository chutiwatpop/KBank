global class SummaryTeamPerformance_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	private Map<String,Team_Structure__c> teamMap;

	global SummaryTeamPerformance_Batch() {
		teamMap = new Map<String,Team_Structure__c>([SELECT Id,Customer_Contacted__c,Call_Report_Product_Interested__c,Product_Interested__c,Product_Final_Approved__c,Product_Set_Up__c,Call_Report_Credit_for_Sales__c,Call_Report_Credit_Product_Interested__c,Credit_Product_Interested__c,Total_Opportunity_App_In__c,Total_Opportunity_Setup__c,Total_Opportunity_Close_Lost__c,Number_of_RM_under_Team__c,Call_Report__c,Call_Report_Customer_Port__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Others__c,CRTotal_Call_Report__c,Call_Report_for_Sales__c,CRCall_Report_for_Sales__c,Call_Report_for_Relationship__c,CRCall_Report_for_Relationship__c,Phone_Call__c,Face_to_Face__c,Customer_Port__c,Customer_Pool__c,Customer_Other__c,Contacted_Customer_Port__c,Contacted_Customer_Pool__c,Contacted_Customer_Other__c,Contacted_Customer_Port_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Other_CustCall__c,Contacted_Other_CustF2F__c,Contacted_Pool_CustCall__c,Contacted_Pool_CustF2F__c,Contacted_Port_CustCall__c,Contacted_Port_CustF2F__c,My_Penetrate_Contacted_Other_CustCall__c,My_Penetrate_Contacted_Other_CustF2F__c,My_Penetrate_Contacted_Pool_CustCall__c,My_Penetrate_Contacted_Pool_CustF2F__c,My_Penetrate_Contacted_Port_CustCall__c,My_Penetrate_Contacted_Port_CustF2F__c FROM Team_Structure__c]);
		for(Team_Structure__c eachTeam : teamMap.values()){
			clearConversionRatioFieldValue(eachTeam);
			clearPenetrateFieldValue(eachTeam);
		}
		query = 'SELECT Id,User__r.IsActive,User__r.Profile.Name,Customer_Contacted__c,My_Penetrate_Contacted_Port_CustF2F__c,My_Penetrate_Contacted_Port_CustCall__c,My_Penetrate_Contacted_Pool_CustF2F__c,My_Penetrate_Contacted_Pool_CustCall__c,My_Penetrate_Contacted_Other_CustF2F__c,My_Penetrate_Contacted_Other_CustCall__c,Contacted_Port_CustF2F__c,Contacted_Port_CustCall__c,Contacted_Pool_CustF2F__c,Contacted_Pool_CustCall__c,Contacted_Other_CustF2F__c,Contacted_Other_CustCall__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Port_My_Penetrate__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Face_to_Face__c,Phone_Call__c,CRCall_Report_for_Relationship__c,Call_Report_for_Relationship__c,CRCall_Report_for_Sales__c,CRTotal_Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report__c,Call_Report_for_Sales__c,Call_Report_Product_Interested__c,Product_Interested__c,Product_Final_Approved__c,Product_Set_Up__c,Call_Report_Credit_for_Sales__c,Call_Report_Credit_Product_Interested__c,Credit_Product_Interested__c,Total_Opportunity_App_In__c,Total_Opportunity_Setup__c,Total_Opportunity_Close_Lost__c,Team_Structure__c,Team_Structure__r.AH_Name__c ,Team_Structure__r.NH_Name__c FROM User_Extension__c WHERE (User__r.SME_User__c = true OR User__r.Is_RBS_User__c  = true) AND Team_Structure__c != null';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<User_Extension__c> listUserExtension) {
		for(User_Extension__c eachUserEx : listUserExtension){
			sumTeamPerformance(eachUserEx.Team_Structure__c,eachUserEx);
			sumTeamPerformance(eachUserEx.Team_Structure__r.AH_Name__c,eachUserEx);
			sumTeamPerformance(eachUserEx.Team_Structure__r.NH_Name__c,eachUserEx);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		update teamMap.values();
	}

	private void sumTeamPerformance(Id teamId, User_Extension__c userEx){
		if(!String.isBlank(teamId) && teamMap.containsKey(teamId)){
			Team_Structure__c team = teamMap.get(teamId);
			sumConversionRatioFieldValue(userEx,team);
			sumPenetrateFieldValue(userEx,team);
		}
	}

	private void sumConversionRatioFieldValue(User_Extension__c userEx,Team_Structure__c team){
		team.Customer_Contacted__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Customer_Contacted__c));
		team.Call_Report_for_Sales__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Call_Report_for_Sales__c));
		team.Call_Report_Product_Interested__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Call_Report_Product_Interested__c));
		team.Product_Interested__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Product_Interested__c));
		team.Product_Final_Approved__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Product_Final_Approved__c));
		team.Product_Set_Up__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Product_Set_Up__c));
		team.Call_Report_Credit_for_Sales__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Call_Report_Credit_for_Sales__c));
		team.Call_Report_Credit_Product_Interested__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Call_Report_Credit_Product_Interested__c));
		team.Credit_Product_Interested__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Credit_Product_Interested__c));
		team.Total_Opportunity_App_In__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Total_Opportunity_App_In__c));
		team.Total_Opportunity_Setup__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Total_Opportunity_Setup__c));
		team.Total_Opportunity_Close_Lost__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Total_Opportunity_Close_Lost__c));
	}

	private void sumPenetrateFieldValue(User_Extension__c userEx,Team_Structure__c team){
		if(userEx.User__r.IsActive) team.Number_of_RM_under_Team__c++;

		team.Call_Report__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Call_Report__c));
		team.Call_Report_Customer_Port__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Call_Report_Customer_Port__c));
		team.Call_Report_Customer_Pool__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Call_Report_Customer_Pool__c));
		team.Call_Report_Customer_Others__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Call_Report_Customer_Others__c));
		team.CRTotal_Call_Report__c += Integer.valueOf(GlobalUtility.toNumber(userEx.CRTotal_Call_Report__c));
		team.CRCall_Report_for_Sales__c += Integer.valueOf(GlobalUtility.toNumber(userEx.CRCall_Report_for_Sales__c));
		team.Call_Report_for_Relationship__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Call_Report_for_Relationship__c));
		team.CRCall_Report_for_Relationship__c += Integer.valueOf(GlobalUtility.toNumber(userEx.CRCall_Report_for_Relationship__c));
		team.Phone_Call__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Phone_Call__c));
		team.Face_to_Face__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Face_to_Face__c));
		team.Customer_Port__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Customer_Port__c));
		team.Customer_Pool__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Customer_Pool__c));
		team.Customer_Other__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Customer_Other__c));
		team.Contacted_Customer_Port__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Contacted_Customer_Port__c));
		team.Contacted_Customer_Pool__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Contacted_Customer_Pool__c));
		team.Contacted_Customer_Other__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Contacted_Customer_Other__c));
		team.Contacted_Customer_Port_My_Penetrate__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Contacted_Customer_Port_My_Penetrate__c));
		team.Contacted_Customer_Pool_My_Penetrate__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Contacted_Customer_Pool_My_Penetrate__c));
		team.Contacted_Customer_Other_My_Penetrate__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Contacted_Customer_Other_My_Penetrate__c));

		team.Contacted_Other_CustCall__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Contacted_Other_CustCall__c));
        team.Contacted_Other_CustF2F__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Contacted_Other_CustF2F__c));
        team.Contacted_Pool_CustCall__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Contacted_Pool_CustCall__c));
        team.Contacted_Pool_CustF2F__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Contacted_Pool_CustF2F__c));
        team.Contacted_Port_CustCall__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Contacted_Port_CustCall__c));
        team.Contacted_Port_CustF2F__c += Integer.valueOf(GlobalUtility.toNumber(userEx.Contacted_Port_CustF2F__c));
        team.My_Penetrate_Contacted_Other_CustCall__c += Integer.valueOf(GlobalUtility.toNumber(userEx.My_Penetrate_Contacted_Other_CustCall__c));
        team.My_Penetrate_Contacted_Other_CustF2F__c += Integer.valueOf(GlobalUtility.toNumber(userEx.My_Penetrate_Contacted_Other_CustF2F__c));
        team.My_Penetrate_Contacted_Pool_CustCall__c += Integer.valueOf(GlobalUtility.toNumber(userEx.My_Penetrate_Contacted_Pool_CustCall__c));
        team.My_Penetrate_Contacted_Pool_CustF2F__c += Integer.valueOf(GlobalUtility.toNumber(userEx.My_Penetrate_Contacted_Pool_CustF2F__c));
        team.My_Penetrate_Contacted_Port_CustCall__c += Integer.valueOf(GlobalUtility.toNumber(userEx.My_Penetrate_Contacted_Port_CustCall__c));
        team.My_Penetrate_Contacted_Port_CustF2F__c += Integer.valueOf(GlobalUtility.toNumber(userEx.My_Penetrate_Contacted_Port_CustF2F__c));
	}

	private void clearConversionRatioFieldValue(Team_Structure__c team){
		team.Customer_Contacted__c = 0;
		team.Call_Report_for_Sales__c = 0;
		team.Call_Report_Product_Interested__c = 0;
		team.Product_Interested__c = 0;
		team.Product_Final_Approved__c = 0;
		team.Product_Set_Up__c = 0;
		team.Call_Report_Credit_for_Sales__c = 0;
		team.Call_Report_Credit_Product_Interested__c = 0;
		team.Credit_Product_Interested__c = 0;
		team.Total_Opportunity_App_In__c = 0;
		team.Total_Opportunity_Setup__c = 0;
		team.Total_Opportunity_Close_Lost__c = 0;
	}

	private void clearPenetrateFieldValue(Team_Structure__c team){
		team.Number_of_RM_under_Team__c = 0;

		team.Call_Report__c = 0;
		team.Call_Report_Customer_Port__c = 0;
		team.Call_Report_Customer_Pool__c = 0;
		team.Call_Report_Customer_Others__c = 0;
		team.CRTotal_Call_Report__c = 0;
		team.CRCall_Report_for_Sales__c = 0;
		team.Call_Report_for_Relationship__c = 0;
		team.CRCall_Report_for_Relationship__c = 0;
		team.Phone_Call__c = 0;
		team.Face_to_Face__c = 0;
		team.Customer_Port__c = 0;
		team.Customer_Pool__c = 0;
		team.Customer_Other__c = 0;
		team.Contacted_Customer_Port__c = 0;
		team.Contacted_Customer_Pool__c = 0;
		team.Contacted_Customer_Other__c = 0;
		team.Contacted_Customer_Port_My_Penetrate__c = 0;
		team.Contacted_Customer_Pool_My_Penetrate__c = 0;
		team.Contacted_Customer_Other_My_Penetrate__c = 0;

		team.Contacted_Other_CustCall__c = 0;
        team.Contacted_Other_CustF2F__c = 0;
        team.Contacted_Pool_CustCall__c = 0;
        team.Contacted_Pool_CustF2F__c = 0;
        team.Contacted_Port_CustCall__c = 0;
        team.Contacted_Port_CustF2F__c = 0;
        team.My_Penetrate_Contacted_Other_CustCall__c = 0;
        team.My_Penetrate_Contacted_Other_CustF2F__c = 0;
        team.My_Penetrate_Contacted_Pool_CustCall__c = 0;
        team.My_Penetrate_Contacted_Pool_CustF2F__c = 0;
        team.My_Penetrate_Contacted_Port_CustCall__c = 0;
        team.My_Penetrate_Contacted_Port_CustF2F__c = 0;
	}
}