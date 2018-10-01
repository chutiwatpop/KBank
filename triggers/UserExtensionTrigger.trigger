trigger UserExtensionTrigger on User_Extension__c (before update,after insert, after update) {
    new UserExtensionTriggerHandler().run();
}