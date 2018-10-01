/**
* @author komsan.wi@beryl8.com
* @11/04/2015 created new
*/
public class MonthlyPerformanceTriggerHandler extends TriggerHandler{
	public Decimal calculate(Decimal val1,Decimal val2){
		Decimal x1 = (val1!=null)?val1:0;
		Decimal x2 = (val2!=null)?val2:0;
		return x1+x2;
	}
	public override void beforeUpdate(){
		//if(!GlobalUtility.resetStatement){
			//Monthly_Performance__c eachOldMonthly;
			//for(Monthly_Performance__c eachMonthly : (List<Monthly_Performance__c>)Trigger.new){
				// eachOldMonthly = (Monthly_Performance__c)Trigger.oldMap.get(eachMonthly.Id);
				// eachMonthly.Call_Report__c = calculate(eachMonthly.Call_Report__c,eachOldMonthly.Call_Report__c);
				// eachMonthly.Call_Report_Customer_Port__c = calculate(eachMonthly.Call_Report_Customer_Port__c,eachOldMonthly.Call_Report_Customer_Port__c);
				// eachMonthly.Call_Report_Customer_Pool__c = calculate(eachMonthly.Call_Report_Customer_Pool__c,eachOldMonthly.Call_Report_Customer_Pool__c);
				// eachMonthly.Call_Report_Customer_Others__c = calculate(eachMonthly.Call_Report_Customer_Others__c,eachOldMonthly.Call_Report_Customer_Others__c);
				// eachMonthly.Call_Report_for_Sales__c = calculate(eachMonthly.Call_Report_for_Sales__c,eachOldMonthly.Call_Report_for_Sales__c);
				// eachMonthly.Call_Report_for_Relationship__c = calculate(eachMonthly.Call_Report_for_Relationship__c,eachOldMonthly.Call_Report_for_Relationship__c);
				// eachMonthly.Face_to_Face__c = calculate(eachMonthly.Face_to_Face__c,eachOldMonthly.Face_to_Face__c);
				// eachMonthly.Phone_Call__c = calculate(eachMonthly.Phone_Call__c,eachOldMonthly.Phone_Call__c);
				//eachMonthly.Total_visited_Customer__c = calculate(eachMonthly.Total_visited_Customer__c,eachOldMonthly.Total_visited_Customer__c);
				//eachMonthly.Contacted_Customer_Other__c = calculate(eachMonthly.Contacted_Customer_Other__c,eachOldMonthly.Contacted_Customer_Other__c);
				//eachMonthly.Contacted_Customer_Pool__c = calculate(eachMonthly.Contacted_Customer_Pool__c,eachOldMonthly.Contacted_Customer_Pool__c);
				//eachMonthly.Contacted_Customer_Port__c = calculate(eachMonthly.Contacted_Customer_Port__c,eachOldMonthly.Contacted_Customer_Port__c);
				//eachMonthly.Customer_Other__c = calculate(eachMonthly.Customer_Other__c,eachOldMonthly.Customer_Other__c);
				//eachMonthly.Customer_Pool__c = calculate(eachMonthly.Customer_Pool__c,eachOldMonthly.Customer_Pool__c);
				//eachMonthly.Customer_Port__c = calculate(eachMonthly.Customer_Port__c,eachOldMonthly.Customer_Port__c);
			//}
		//}
	}
}