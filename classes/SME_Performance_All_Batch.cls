global class SME_Performance_All_Batch implements Database.Batchable<sObject>, Database.Stateful{
    private String query;
    private Map<String,User_Extension__c> userMapExt;//user,ext
    private Set<String> userMapExtKeySet{get{return userMapExt.keySet();}}//user,ext
    private Map<String,Team_Structure__c> teamMap;

    private Boolean runMontly = false;
    private Boolean shouldRunMontly = true;
    private Boolean resetStatement = false;
    private Boolean initialMonthly = false;
    private Map<String,Monthly_Performance__c> monthlyMap;

    private Map<String,User_Extension__c> userExMap;
    private Map<String,List<String>> userExIdMapTeam;
    private Date todayDateFromNow;
    private Integer currentYear;
    private Map<String,String> callReportMapOwner;


    private SME_Performance_Util util;

    global SME_Performance_All_Batch() {
        this.query = 'SELECT Id,CIS__c,Port_Pool__c,Ownership__c,Ownership_Text__c,OwnerId,Count_Contacted_CR_My_Pen_Service_Call__c,Count_Contacted_CR_My_Pen_Service_F2F__c,Count_Contacted_Call_Report_My_Pen_Call__c,Count_Contacted_Call_Report_My_Pen_F2F__c,Count_Contacted_Call_Report_Phone_Call__c,Count_Contacted_Call_Report_F2F__c,Count_Call_Report_RM__c,Count_Contacted_Call_Report__c,Owner.ProfileId,Owner.Profile.Name,Service_RM__c,Service_RM__r.RC_Code__c,Service_RM__r.AH_RC_Code__c,Service_RM__r.NH_RC_Code__c,Service_RM__r.ProfileId,Service_RM__r.Profile.Name,Owner.RC_Code__c,Number_of_Visited__c FROM Account WHERE OwnerId IN :userMapExtKeySet';
        userExMap = new Map<String,User_Extension__c>([SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Face_to_Face__c,Months__c,Phone_Call__c,Team_Structure__c,User__c,User__r.ProfileId,User__r.Profile.Name,User__r.RC_Code__c,User__r.Employee_Id__c,User__r.ManagerId,Total_visited_Customer__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Port_My_Penetrate__c FROM User_Extension__c WHERE Team_Structure__c!=null]);

        teamMap = new Map<String,Team_Structure__c>([SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Face_to_Face__c,Months__c,Phone_Call__c,Name,AH_Name__c,NH_Name__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c,Total_visited_Customer__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Port_My_Penetrate__c FROM Team_Structure__c]);

        util = new SME_Performance_Util(userExMap,teamMap);
        userMapExt = util.getUserExt();
    }
    global SME_Performance_All_Batch(Map<String,User_Extension__c> userExMap,Map<String,Team_Structure__c> teamMap) {
        this.query = 'SELECT Id,CIS__c,Port_Pool__c,Ownership__c,Ownership_Text__c,OwnerId,Count_Contacted_CR_My_Pen_Service_Call__c,Count_Contacted_CR_My_Pen_Service_F2F__c,Count_Contacted_Call_Report_My_Pen_Call__c,Count_Contacted_Call_Report_My_Pen_F2F__c,Count_Contacted_Call_Report_Phone_Call__c,Count_Contacted_Call_Report_F2F__c,Count_Call_Report_RM__c,Count_Contacted_Call_Report__c,Owner.ProfileId,Owner.Profile.Name,Service_RM__c,Service_RM__r.RC_Code__c,Service_RM__r.AH_RC_Code__c,Service_RM__r.NH_RC_Code__c,Service_RM__r.ProfileId,Service_RM__r.Profile.Name,Owner.RC_Code__c,Number_of_Visited__c FROM Account WHERE OwnerId IN :userMapExtKeySet AND Owner.isActive=true';
        this.userExMap = userExMap;
        this.teamMap = teamMap;
        util = new SME_Performance_Util(userExMap,teamMap);
        userMapExt = util.getUserExt();
    }
    global SME_Performance_All_Batch noMontly(){
        shouldRunMontly = false;
        return this;
    }
    global SME_Performance_All_Batch runMontly(Map<String,Monthly_Performance__c> monthlyMap,Boolean resetStatement,Boolean initialMonthly){
        runMontly = true;
        this.resetStatement = resetStatement;
        this.initialMonthly = initialMonthly;
        util.setMonthlyMap(monthlyMap);

        return this;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Account> accountList) {
        Map<String,String> callReportMapOwner = new Map<String,String>();
        List<Call_Report__c> callReportList = new List<Call_Report__c>();
        if(isLoadRecordLastYear()){
            callReportList = [SELECT Id,Current_Owner_Extension__c,Current_Owner_Extension__r.User__c,CIS_ID__c,CIS_ID__r.OwnerId FROM Call_Report__c WHERE CIS_ID__c IN :accountList AND Actual_Visit_Date__c = LAST_YEAR];// AND Primary_Call_Report__c=true
        }else{
            callReportList = [SELECT Id,Current_Owner_Extension__c,Current_Owner_Extension__r.User__c,CIS_ID__c,CIS_ID__r.OwnerId FROM Call_Report__c WHERE CIS_ID__c IN :accountList AND Actual_Visit_Date__c = THIS_YEAR];// AND Primary_Call_Report__c=true
        }
  

        callReportMapOwner = util.mappingOwner(callReportList);
       
        util.setCallReportList(callReportList);

        for(Account eachAccount : accountList){
            util.executeAccount(eachAccount,runMontly,callReportMapOwner);
        }
    }

    global void finish(Database.BatchableContext BC) {
        update util.getFinalUserExt();
        util.finalTeamTask();
        if(runMontly) {
            GlobalUtility.resetStatement = resetStatement;
            Database.executeBatch(new SME_Monthly_DML_Batch(util.getMonthly(),true),2000);
        }
        
        update util.getFinalTeam();
    }

    private Boolean isLoadRecordLastYear(){
        if(Label.Last_Year_Performance != null && Label.Last_Year_Performance.equalsIgnoreCase('true') && !Test.isRunningTest()){
            return true;
        }
        return false;
    }
}