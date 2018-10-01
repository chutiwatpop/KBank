global without sharing class MonthlyModel {
	global String External_ID;
    global String MName;
    global String MUser;
    global String MTeam;
    global Decimal Call_Report;
    global Decimal Call_Report_Customer_Port;
    global Decimal Call_Report_Customer_Pool;
    global Decimal Call_Report_Customer_Others;
    global Decimal Call_Report_for_Sales;
    global Decimal Call_Report_for_Relationship;
    global Decimal Face_to_Face;
    global Decimal Phone_Call;
    global Decimal Total_visited_Customer;
    global Decimal Contacted_Customer_Other;
    global Decimal Contacted_Customer_Pool;
    global Decimal Contacted_Customer_Port;
    global Decimal Customer_Other;
    global Decimal Customer_Pool;
    global Decimal Customer_Port;
    global Decimal Contacted_Customer_Other_My_Penetrate;
    global Decimal Contacted_Customer_Pool_My_Penetrate;
    global Decimal Contacted_Customer_Port_My_Penetrate;
    global Date MDate;
    global Decimal MMonths;
    global Decimal Number_of_RM_under_Team;
    global MonthlyModel(Boolean allPerformance){
        if(allPerformance){
            Contacted_Customer_Other = 0;
            Contacted_Customer_Pool = 0;
            Contacted_Customer_Port = 0;
            Customer_Other = 0;
            Customer_Pool = 0;
            Customer_Port = 0;
            Total_visited_Customer = 0;
            Contacted_Customer_Other_My_Penetrate = 0;
            Contacted_Customer_Pool_My_Penetrate = 0;
            Contacted_Customer_Port_My_Penetrate = 0;
        }
    }
    global MonthlyModel(){
		// Contacted_Customer_Other = 0;
		// Contacted_Customer_Pool = 0;
		// Contacted_Customer_Port = 0;
		// Customer_Other = 0;
		// Customer_Pool = 0;
		// Customer_Port = 0;
		// Contacted_Customer_Other_My_Penetrate = 0;
		// Contacted_Customer_Pool_My_Penetrate = 0;
		// Contacted_Customer_Port_My_Penetrate = 0;
		// Number_of_RM_under_Team = 0;
    }
}