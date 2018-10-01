/**
 * @author chansak.s@beryl8.com
 * @07/01/2017 create new
 */

global class YearEndAssignmentCalculate_Batch extends ApplicationLog_Service implements Database.Batchable<sObject>, Database.Stateful {
    
    private Set<Id> yearEndSetID;
    private Integer yearEndSeparateSize = 50000;

    global YearEndAssignmentCalculate_Batch(){
        yearEndSetID = new Set<Id>();
    }
    public String query(){
        return 'SELECT Id FROM Year_End_Assignment__c WHERE  Status__c=\'Submitted\' and CIS_ID__c != null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query());
    }
    global void execute(Database.BatchableContext BC, List<Year_End_Assignment__c> yearEndList){
        for(Year_End_Assignment__c eachYearEnd : yearEndList){
            yearEndSetID.add(eachYearEnd.Id);
        }   
    }

    global void finish(Database.BatchableContext BC){
        if(!yearEndSetID.isEmpty()){
            Set<Id> yearEndUpdateSet = new Set<Id>();
            Integer count = 0;
            for(Id eachYearEndId : yearEndSetID){
                count++;
                yearEndUpdateSet.add(eachYearEndId);
                if(count==yearEndSeparateSize){ //yearEndSeparateSize=500000
                     //Call YearEndBatch
                     Database.executeBatch(new YearEndAssignment_Batch(yearEndUpdateSet));
                     yearEndUpdateSet.clear();
                     count = 0;
                }
            }
            if(yearEndUpdateSet.size() > 0){
                //Call YearEndBatch
                Database.executeBatch(new YearEndAssignment_Batch(yearEndUpdateSet));
            }
        }
    }
}