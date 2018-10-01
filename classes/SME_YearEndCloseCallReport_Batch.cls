/**
 * @author charnun.t@beryl8.com
 * @16/07/2016 create new
 */

global class SME_YearEndCloseCallReport_Batch implements Database.Batchable<sObject>, Database.Stateful {

    public List<Id> yearendNotUpdateList;
    public List<Id> cisrelatedUpdateList;

    global SME_YearEndCloseCallReport_Batch(List<Id> yearendNotUpdateListInput,Set<Id>  relatedUpdateSetInput){
        if(!yearendNotUpdateListInput.isEmpty()) yearendNotUpdateList = new List<Id>(yearendNotUpdateListInput);
        if(!relatedUpdateSetInput.isEmpty()) cisrelatedUpdateList = new List<Id>(relatedUpdateSetInput);
    }

    public String query(){
        String queryString = '';
        if(yearendNotUpdateList != null && yearendNotUpdateList.size() > 0 && cisrelatedUpdateList !=null && cisrelatedUpdateList.size() >0){
            System.debug('yearendNotUpdateList:'+yearendNotUpdateList);
            queryString = 'SELECT Id,CIS_ID__c,Status__c,Contact__c FROM Call_Report__c WHERE Status__c = \'' + GlobalConstants.CONTACTED + '\' AND CIS_ID__c IN(SELECT CIS_ID__c FROM Year_End_Assignment__c WHERE Status__c=\'Submitted\' and CIS_ID__c != null and CIS_ID__c IN (\''+ String.join(cisrelatedUpdateList,'\',\'') +'\') and Id NOT IN (\'' + String.join(yearendNotUpdateList,'\',\'') + '\'))';
        }else{
            queryString = '';
        }
        System.debug('queryString:'+queryString);
        return queryString;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(this.query()!=''){
            return Database.getQueryLocator(this.query());
        }
        return null;
    }

    global void execute(Database.BatchableContext BC, List<Call_Report__c> callReport){
        for(Call_Report__c eachCallReport : callReport){
            eachCallReport.Status__c = 'Closed';
        }
        TriggerHandler.bypass('CallReportTriggerHandler');
        update callReport;
        TriggerHandler.clearBypass('CallReportTriggerHandler');
    }

    global void finish(Database.BatchableContext BC){

    }
}