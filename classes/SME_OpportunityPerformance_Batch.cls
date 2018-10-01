global class SME_OpportunityPerformance_Batch implements Database.Batchable<sObject>,Database.Stateful {
  String query;
    global SME_OpportunityPerformance_Batch() {}
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> opportunitylist) {
    }
    
    global void finish(Database.BatchableContext BC) {}
}