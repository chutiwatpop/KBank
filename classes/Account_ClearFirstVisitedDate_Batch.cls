/***********************************************************************
*  Created By		: Chumphon Kaewpraphan
*  Date Created		: 21 June 2016
*
*  Description		: Batch clear account first visited date
*
*  Global Variables Used :  None
*
*  Modification List:
*  Name         	Date            Modification Description
*  ----------		-----------		------------------------------
*  Chumphon K.		21-Jun-2016 	Initial Code Creation
*  
***********************************************************************/
global class Account_ClearFirstVisitedDate_Batch implements Database.Batchable<sObject>{
	String Query;

    global Account_ClearFirstVisitedDate_Batch(){
        this.Query = 'Select Id, First_Visited_Date__c From Account Where First_Visited_Date__c != null';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        List<Account> updateAccounts = new List<Account>();
        for(Account eachAccount : accountList) {
            eachAccount.First_Visited_Date__c = null;
            updateAccounts.add(eachAccount);
        }
        if(updateAccounts.size() > 0) {
            TriggerHandler.bypass('AccountTriggerHandler');
            update updateAccounts;
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}