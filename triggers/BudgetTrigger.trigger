trigger BudgetTrigger on Budget__c (before insert, before update, before delete, after update) {
    if(!TriggerHandler.isByPassed('BudgetTriggerHandler')){
        new BudgetTriggerHandler().run();
    }
}