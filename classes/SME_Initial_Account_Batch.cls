global class SME_Initial_Account_Batch implements Database.Batchable<sObject>, Database.Stateful {
    private String query;

    global SME_Initial_Account_Batch() {

        this.query = 'select id,Count_Contacted_Call_Report__c,Count_Call_Report_RM__c from account'; 
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Account> accountList) {
       
       
        for(Account eachAccount : accountList){

            if(eachAccount.Count_Contacted_Call_Report__c == null ){
                eachAccount.Count_Contacted_Call_Report__c = 0;
            }
            if(eachAccount.Count_Call_Report_RM__c == null){
                eachAccount.Count_Call_Report_RM__c = 0;
            }

        }
        TriggerHandler.bypass('AccountTriggerHandler');
        update accountList;
    }

    global void finish(Database.BatchableContext BC) {

    }
}