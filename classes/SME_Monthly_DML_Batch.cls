global class SME_Monthly_DML_Batch implements Database.Batchable<Monthly_Performance__c> ,Database.Stateful{
    private List<Monthly_Performance__c> dmlList;
    private Boolean runReorder;
    global SME_Monthly_DML_Batch(List<Monthly_Performance__c> dmlList) {
        this.dmlList = dmlList;
        this.runReorder = false;
    }
    global SME_Monthly_DML_Batch(List<Monthly_Performance__c> dmlList,Boolean shouldRunReorder) {
        this.dmlList = dmlList;
        this.runReorder = true;
    }
    global List<Monthly_Performance__c> start(Database.BatchableContext bc) {
        return dmlList;
    }
    
    global void execute(Database.BatchableContext BC, list<Monthly_Performance__c> partialList) {
        //List<Monthly_Performance__c> partialToUpdateList = new List<Monthly_Performance__c>();
        // for(Monthly_Performance__c eachPartial : partialList){
        //     partialToUpdateList.add(new Monthly_Performance__c(
        //         External_ID__c = eachPartial.External_ID,
        //         Name = eachPartial.MName,
        //         User__c = eachPartial.MUser,
        //         Team__c = eachPartial.MTeam,
        //         Call_Report__c = eachPartial.Call_Report,
        //         Call_Report_Customer_Port__c = eachPartial.Call_Report_Customer_Port,
        //         Call_Report_Customer_Pool__c = eachPartial.Call_Report_Customer_Pool,
        //         Call_Report_Customer_Others__c = eachPartial.Call_Report_Customer_Others,
        //         Call_Report_for_Sales__c = eachPartial.Call_Report_for_Sales,
        //         Call_Report_for_Relationship__c = eachPartial.Call_Report_for_Relationship,
        //         Face_to_Face__c = eachPartial.Face_to_Face,
        //         Phone_Call__c = eachPartial.Phone_Call,
        //         Total_visited_Customer__c = eachPartial.Total_visited_Customer,
        //         Contacted_Customer_Other__c = eachPartial.Contacted_Customer_Other,
        //         Contacted_Customer_Pool__c = eachPartial.Contacted_Customer_Pool,
        //         Contacted_Customer_Port__c = eachPartial.Contacted_Customer_Port,
        //         Customer_Other__c = eachPartial.Customer_Other,
        //         Customer_Pool__c = eachPartial.Customer_Pool,
        //         Customer_Port__c = eachPartial.Customer_Port,
        //         Contacted_Customer_Other_My_Penetrate__c = eachPartial.Contacted_Customer_Other_My_Penetrate,
        //         Contacted_Customer_Pool_My_Penetrate__c = eachPartial.Contacted_Customer_Pool_My_Penetrate,
        //         Contacted_Customer_Port_My_Penetrate__c = eachPartial.Contacted_Customer_Port_My_Penetrate,
        //         Date__c = eachPartial.MDate,
        //         Months__c = eachPartial.MMonths
        //     ));
        // }
        

        upsert partialList External_ID__c;
    }

    global void finish(Database.BatchableContext BC) {
        if(this.runReorder) Database.executeBatch(new SME_MonthlyReorder_Batch());
    }
}