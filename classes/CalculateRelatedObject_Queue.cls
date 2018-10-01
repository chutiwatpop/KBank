public without sharing class CalculateRelatedObject_Queue implements Queueable {
    public Map<Id, Bulk_Assignment__c> assignMapByCurrentUser;
    public Map<Id, User> newUserMap;

    public CalculateRelatedObject_Queue(Map<Id, Bulk_Assignment__c> assignMapByCurrentUser, Map<Id, User> newUserMap) {
        //this.assignMapByCurrentUser = assignMapByCurrentUser;
        //this.newUserMap = newUserMap;
    }

    public void execute(QueueableContext context) {
        //if(assignMapByCurrentUser!=null && !assignMapByCurrentUser.isEmpty()) {
        //    ApprovalProcess_Service.reassignApproval(assignMapByCurrentUser);
        //    Task_Service.reassignTask(assignMapByCurrentUser);
        //    TeamStructure_Service.reassignOwner(assignMapByCurrentUser, newUserMap);
        //}
    }
}