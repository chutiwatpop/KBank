/**
* @author noppawit.h@beryl8.com
* @10/07/2015 createddate
*/
trigger OpportunityTrigger on Opportunity (before update,before insert,after insert,after update) {
    if(!TriggerHandler.isBypassed('OpportunityTriggerHandler')){
        new OpportunityTriggerHandler().run();
    }
}