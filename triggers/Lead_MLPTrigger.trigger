trigger Lead_MLPTrigger on Lead_MLP__c  (before insert, before update, before delete, after update, after delete) {
    if(!TriggerHandler.isBypassed('MLPTriggerhandler')){
        new MLPTriggerhandler().run();
    }
}