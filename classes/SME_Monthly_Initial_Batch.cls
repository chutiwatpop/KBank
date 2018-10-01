/**
* @29/03/2017 anan.b Edit for Fix testclass #Edit1
*/
global class SME_Monthly_Initial_Batch implements Database.Batchable<sObject> ,Database.Stateful{
    public String query;
    private Map<String,Team_Structure__c> teamMap;
 
    private Date todayDateFromNow;
    private Integer currentYear;
    global SME_Monthly_Initial_Batch() {
        this.query = 'SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Face_to_Face__c,Months__c,Phone_Call__c,Team_Structure__c,User__r.ProfileId,User__r.Profile.Name,User__r.Employee_Id__c,User__r.RC_Code__c,Number_of_RM_under_Team__c,Last_Month_Stamp__c,User__r.IsActive FROM User_Extension__c WHERE Team_Structure__c!=null and User__r.IsActive = true';
        teamMap = new Map<String,Team_Structure__c>([SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Face_to_Face__c,Months__c,Phone_Call__c,Name,AH_Name__c,NH_Name__c,RC_Code__c,Number_of_RM_under_Team__c,AH_RC_Code__c,NH_RC_Code__c FROM Team_Structure__c]);
        DateTime dT = System.now();
        todayDateFromNow = date.newinstance(dT.year(), dT.month()-1, dT.day());
        currentYear = GlobalUtility.getYearInBuddhistCalendar(todayDateFromNow);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<User_Extension__c> userExList) {
        Map<String,User_Extension__c> userExMap = new Map<String,User_Extension__c>(userExList);

        Map<String,Monthly_Performance__c> monthlyMap = new Map<String,Monthly_Performance__c>();
            
        String exKey;
        String teamKey;
        Integer numberOfDays;
        for(User_Extension__c eachExt : userExMap.values()){
            for(Integer i = 1;i<System.now().month();i++){
                exKey = eachExt.User__r.Employee_Id__c + ' ' + i + ' ' + currentYear;
                teamKey = eachExt.User__r.RC_Code__c + ' ' + i + ' ' + currentYear;
                numberOfDays = Date.daysInMonth(todayDateFromNow.year(), i);
                if(!monthlyMap.containsKey(exKey)){
                    monthlyMap.put(exKey,new Monthly_Performance__c(
                        External_ID__c = exKey,
                        Name = GlobalConstants.monthThaiNameList.get(i-1) +' '+currentYear,
                        User__c = eachExt.Id,
                        //Team__c = eachExt.Team_Structure__c,
                        Call_Report__c = 0,
                        Call_Report_Customer_Port__c = 0,
                        Call_Report_Customer_Pool__c = 0,
                        Call_Report_Customer_Others__c = 0,
                        Call_Report_for_Sales__c = 0,
                        Call_Report_for_Relationship__c = 0,
                        Face_to_Face__c = 0,
                        Phone_Call__c = 0,
                        Contacted_Customer_Other_My_Penetrate__c = 0,
                        Contacted_Customer_Pool_My_Penetrate__c = 0,
                        Contacted_Customer_Port_My_Penetrate__c = 0,
                        //Total_Call_Report__c = 0,
                        //Total_Face_to_Face_Call__c = 0,
                        //Total_Sales_Relationship__c = 0,
                        Date__c = Date.newInstance(todayDateFromNow.year(), i, numberOfDays),
                        Months__c = i
                    ));
                }
                if(!monthlyMap.containsKey(teamKey)){
                    monthlyMap.put(teamKey,new Monthly_Performance__c(
                        External_ID__c = teamKey,
                        Name = GlobalConstants.monthThaiNameList.get(i-1) +' '+currentYear,
                        //User__c = eachExt.Id,
                        Team__c = eachExt.Team_Structure__c,
                        Call_Report__c = 0,
                        Call_Report_Customer_Port__c = 0,
                        Call_Report_Customer_Pool__c = 0,
                        Call_Report_Customer_Others__c = 0,
                        Call_Report_for_Sales__c = 0,
                        Call_Report_for_Relationship__c = 0,
                        Face_to_Face__c = 0,
                        Phone_Call__c = 0,
                        Contacted_Customer_Other_My_Penetrate__c = 0,
                        Contacted_Customer_Pool_My_Penetrate__c = 0,
                        Contacted_Customer_Port_My_Penetrate__c = 0,
                        //Total_Call_Report__c = 0,
                        //Total_Face_to_Face_Call__c = 0,
                        //Total_Sales_Relationship__c = 0,
                        Date__c = Date.newInstance(todayDateFromNow.year(), i, numberOfDays),
                        Months__c = i
                    ));
                }
            }
        }
        GlobalUtility.initialMonthly = true;
        upsert monthlyMap.values() External_ID__c;
    }

    global void finish(Database.BatchableContext BC) {
        GlobalUtility.initialMonthly = false;
        DateTime dT = System.now();
        if(dT.month()!=1){
            //#Edit1
            Database.executeBatch(new SME_Performance_Batch(1).runMontly(true,dT.month()-1).runSummaryAtTheEnd().noFlag());
        }
    }
}