trigger UserStructureTrigger on User_Structure__c (before insert,after insert, before update, after update) {
    if(!TriggerHandler.isBypassed('UserStructureTriggerHandler')){
        new UserStructureTriggerHandler().run(); 
    }
}