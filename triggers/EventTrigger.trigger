trigger EventTrigger on Event (before insert, before update, after insert,after update) {
    if(!TriggerHandler.isBypassed('EventTriggerHandler')){
        new EventTriggerHandler().run(); 
    }
}