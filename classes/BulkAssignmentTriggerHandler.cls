public without sharing class BulkAssignmentTriggerHandler extends TriggerHandler
{
    public override void beforeInsert(){

    }

    public override void afterInsert(){
        List<Bulk_Assignment__c> bulkAssignmentList = [SELECT Id,Status__c, BulkAssignmentQueue__r.CBS_Admin_To_Approve__c FROM Bulk_Assignment__c WHERE Id IN: Trigger.newMap.keySet() AND Status__c =: GlobalConstants.STATUS_NEW AND BulkAssignmentQueue__r.CBS_Admin_To_Approve__c = true];
        List<Bulk_Assignment__c> bulkAssignmentToPassToApproval = new List<Bulk_Assignment__c>();
        
        if(!bulkAssignmentList.isEmpty()){
            String bulkToSendToFuture = JSON.serialize(bulkAssignmentList);
            ApprovalProcessResult_Service.processSubmitRequests(bulkToSendToFuture);
        }
    }

    public override void beforeUpdate(){
        List<Bulk_Assignment__c> bulkAssignmentListToUpdate = new List<Bulk_Assignment__c>();
        bulkAssignmentListToUpdate = Trigger.new;

        for(Bulk_Assignment__c eachBulk : bulkAssignmentListToUpdate){
            if(eachBulk.Status__c != GlobalConstants.WAITING_FOR_APPROVAL && eachBulk.Status__c != GlobalConstants.COMPLETE && eachBulk.Status__c != GlobalConstants.PROCESSING){
                eachBulk.Process__c = true;
            }
        }

    }

    public override void afterUpdate(){
        List<Bulk_Assignment__c> bulkAssignmentListToUpdate = new List<Bulk_Assignment__c>();
        bulkAssignmentListToUpdate = [SELECT Id, Status__c, Process__c, BulkAssignmentQueue__c FROM Bulk_Assignment__c WHERE Id IN: Trigger.newMap.keySet()];
        Set<Id> bulkQueueIds = new Set<Id>();

        for(Bulk_Assignment__c eachBulk : bulkAssignmentListToUpdate){
            if(eachBulk.Status__c != GlobalConstants.WAITING_FOR_APPROVAL && eachBulk.Status__c != GlobalConstants.COMPLETE && eachBulk.Status__c != GlobalConstants.PROCESSING){
                bulkQueueIds.add(eachBulk.BulkAssignmentQueue__c);
            }
        }

        List<Bulk_Assignment_Queue__c> bulkQueueToUpdateList = new List<Bulk_Assignment_Queue__c>();
        if(!bulkQueueIds.isEmpty()){
            bulkQueueToUpdateList = [SELECT Id, Status__c FROM Bulk_Assignment_Queue__c WHERE Id IN: bulkQueueIds];

            for(Bulk_Assignment_Queue__c eachBulkQueue : bulkQueueToUpdateList){
                eachBulkQueue.Status__c = 'Execute';
            }
            update bulkQueueToUpdateList;


        }
        
    }
}