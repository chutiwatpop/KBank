global class SME_CallReport_Initial_Batch implements Database.Batchable<sObject> {
    public String query;

    global SME_CallReport_Initial_Batch() {
        this.query = 'select id,Primary_Call_Report__c from call_report__c where Primary_Call_Report__c=false';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<call_report__c> scope) {
        for(call_report__c each : scope){
            each.Primary_Call_Report__c = true;
        }
        TriggerHandler.bypass('CallReportTriggerHandler');
        update scope;
    }

    global void finish(Database.BatchableContext BC) {

    }
}