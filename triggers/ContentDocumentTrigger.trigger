trigger ContentDocumentTrigger on ContentDocument (
    before delete,
    after insert, 
    after update) {
    new ContentDocumentTriggerHandler().run();
}