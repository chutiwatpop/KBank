/**
* @author komsan.wi@beryl8.com
* @16/07/2015 createddate
*/
trigger UserTrigger on User(before insert,after insert, before update, after update) {
    if(!TriggerHandler.isBypassed('UserTriggerHandler')){
        new UserTriggerHandler().run(); 
    }
}