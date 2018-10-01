/***********************************************************************
*  Created By       : Chumphon Kaewpraphan
*  Date Created     : 21 April 2016
*
*  Description      : Batch update account first visited date for current year
*
*  Global Variables Used :  None
*
*  Modification List:
*  Name             Date            Modification Description
*  ----------       -----------     ------------------------------
*  Chumphon K.      21-Apr-2016     Initial Code Creation
*  Chumphon K.      08-Jul-2016     Fix error: Aggregate query does not support queryMore(), use LIMIT to restrict the results to a single batch
*  
***********************************************************************/
global class Account_UpdateFirstVisitedDate_Batch implements Database.Batchable<sObject>{
    global final String Query;
    private Map<Id, Date> mapFirstVisitedDate;

    global Account_UpdateFirstVisitedDate_Batch(){
        this.Query = 'Select Id, First_Visited_Date__c From Account Where Id in (Select CIS_ID__c From Call_Report__c Where Actual_Visit_Date__c = THIS_YEAR)';
        
        mapFirstVisitedDate = new Map<Id, Date>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        Date FirstVisitedDate;
        List<Account> updateAccounts = new List<Account>();
        Set<Id> AccountSet = new Set<Id>();
        for(Account eachAccount : accountList){
            AccountSet.add(eachAccount.Id);
        }
        
        for(AggregateResult[] CallReportThisYear : [Select CIS_ID__c, Min(Actual_Visit_Date__c) From Call_Report__c Where Actual_Visit_Date__c = THIS_YEAR and CIS_ID__c in :AccountSet Group By CIS_ID__c]){
            for(AggregateResult ar : CallReportThisYear){
                mapFirstVisitedDate.put((Id)ar.get('CIS_ID__c'), (Date)ar.get('expr0'));
            }
        }

        for(Account eachAccount : accountList) {
            FirstVisitedDate = mapFirstVisitedDate.get(eachAccount.Id);
            if(FirstVisitedDate != null && FirstVisitedDate != eachAccount.First_Visited_Date__c){
                eachAccount.First_Visited_Date__c = FirstVisitedDate;
                updateAccounts.add(eachAccount);
            }
        }
        if(updateAccounts.Size() > 0) update updateAccounts;
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('Account_UpdateFirstVisitedDate_Batch success...');
    }
    
}