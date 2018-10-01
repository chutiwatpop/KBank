/**
 * @author komsan.wi@beryl8.com
 * @12/04/2016 create new
 */
global class SME_MonthlyReorder_Batch implements Database.Batchable<sObject>, Database.Stateful {
    private String query;
    private Map<String,Integer> countMonthlyByUser;
    private Map<String,Decimal> sumMonthlyDevideRMByTeam;
    //private List<Monthly_Performance__c> updateList;
    global SME_MonthlyReorder_Batch() {// AND Team__c=null
        this.query = 'select Id,User__c,Months__c,AVG_Call_Report_RM__c,Number_of_RM_under_Team__c,Call_Report__c,Team__c FROM Monthly_Performance__c WHERE Date__c = THIS_YEAR ORDER BY Date__c ASC';
        countMonthlyByUser = new Map<String,Integer>();
        sumMonthlyDevideRMByTeam = new Map<String,Decimal>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Monthly_Performance__c> scope) {
        List<Monthly_Performance__c> updateList = new List<Monthly_Performance__c>();
        for(Monthly_Performance__c eachMonthly : scope){
            if(eachMonthly.User__c!=null){
                if(!countMonthlyByUser.containsKey(eachMonthly.User__c))
                    countMonthlyByUser.put(eachMonthly.User__c,0);
                if(eachMonthly.Months__c != countMonthlyByUser.get(eachMonthly.User__c)+1){
                    eachMonthly.Months__c = countMonthlyByUser.get(eachMonthly.User__c)+1;
                    updateList.add(eachMonthly);
                }
                countMonthlyByUser.put(eachMonthly.User__c,Integer.valueOf(eachMonthly.Months__c));
            }else if(eachMonthly.Team__c!=null){
                if(!sumMonthlyDevideRMByTeam.containsKey(eachMonthly.Team__c))
                    sumMonthlyDevideRMByTeam.put(eachMonthly.Team__c,0);

                if(eachMonthly.Number_of_RM_under_Team__c!=null && eachMonthly.Number_of_RM_under_Team__c!=0){
                    eachMonthly.AVG_Call_Report_RM__c = eachMonthly.Call_Report__c/eachMonthly.Number_of_RM_under_Team__c;
                    sumMonthlyDevideRMByTeam.put(eachMonthly.Team__c,sumMonthlyDevideRMByTeam.get(eachMonthly.Team__c) + eachMonthly.AVG_Call_Report_RM__c);
                    updateList.add(eachMonthly);
                }
            }
        }

        TriggerHandler.bypass('MonthlyPerformanceTriggerHandler');
        update updateList;
    }

    global void finish(Database.BatchableContext BC) {
        //List<User_Extension__c> userExtList = new List<User_Extension__c>();
        //Map<String,User_Extension__c> extMap = new Map<String,User_Extension__c>([SELECT Id,Team_Structure__c,Months__c,AVG_Call_Report_RM_Month__c FROM User_Extension__c]);

        Map<String,Team_Structure__c> teamMap = new Map<String,Team_Structure__c>([SELECT Id,Months__c,AVG_Call_Report_RM_Month__c FROM Team_Structure__c]);
        system.debug('rrt'+teamMap);
        for(Team_Structure__c teamObj : teamMap.values()){
            if(sumMonthlyDevideRMByTeam.containsKey(teamObj.Id) && teamObj.Months__c!=0)
                teamObj.AVG_Call_Report_RM_Month__c = sumMonthlyDevideRMByTeam.get(teamObj.Id)/teamObj.Months__c; 
        }
        
        //Database.executeBatch(new SME_DML_Batch(teamMap.values()),2000);
        update teamMap.values();

        //for(User_Extension__c eachUserExt : extMap.values()){
        //    //userExtList.add(new User_Extension__c(Id=userExtId,Months__c=countMonthlyByUser.get(userExtId)));
        //    eachUserExt.Months__c = countMonthlyByUser.get(eachUserExt.Id);
        //    //eachUserExt.AVG_Call_Report_RM_Month__c = teamMap.get(eachUserExt.Team_Structure__c).AVG_Call_Report_RM_Month__c;
        //}
        //for(String userExtId : countMonthlyByUser.keySet()){
        //    userExtList.add(new User_Extension__c(Id=userExtId,Months__c=countMonthlyByUser.get(userExtId)));
        //}
        //update userExtList;
    }
}