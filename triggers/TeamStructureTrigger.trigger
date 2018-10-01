trigger TeamStructureTrigger on Team_Structure__c(before insert,after insert, before update, after update, after delete) {
    new TeamStructureTriggerHandler().run(); 
}