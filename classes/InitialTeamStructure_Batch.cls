global class InitialTeamStructure_Batch implements Database.Batchable<sObject>, Database.Stateful {
    IInitialTeamStructure initialTeamStructure;

    global InitialTeamStructure_Batch(IInitialTeamStructure initialTeamStructure) {
        this.initialTeamStructure = initialTeamStructure;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(initialTeamStructure.getQuery());
    }
    
    global void execute(Database.BatchableContext BC, List<Team_Structure__c> listTeamStructure) {
        initialTeamStructure.calculateInitialTeamStructure(listTeamStructure);
    }
    
    global void finish(Database.BatchableContext BC) {
        if(initialTeamStructure instanceof AFInitialTeamStructure){
            if(GlobalUtility.isApexClassConfigActive('OwnershipAssignment_Batch')){
                Database.executeBatch(new OwnershipAssignment_Batch());
            }
        }
    }
}