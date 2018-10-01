public without sharing class ApprovalProcessResult_Service {

    @future
    public static void processSubmitRequests(String bulkToSendToFuture){
        List<Bulk_Assignment__c>  bulkAssignmentToPassToApproval = (List<Bulk_Assignment__c>) JSON.deserialize(bulkToSendToFuture, List<Bulk_Assignment__c>.class);
        List<Approval.ProcessSubmitRequest> approvalSubmitRequestList = new List<Approval.ProcessSubmitRequest>();
        Id userOrGroupId = [SELECT Id FROM Group WHERE Name = :GlobalConstants.CBS_ADMIN].Id;

        for(Bulk_Assignment__c eachBulk : bulkAssignmentToPassToApproval){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval from Bulk.');
            req.setObjectId(eachBulk.Id);
            req.setSubmitterId(UserInfo.getUserId());
            req.setProcessDefinitionNameOrId('Request_Bulk_Assignment_CBS');
            req.setSkipEntryCriteria(true);
            req.setNextApproverIds(new Id[]{userOrGroupId});

            approvalSubmitRequestList.add(req);
        }

        try{
            Approval.ProcessResult[] result;
            if(!approvalSubmitRequestList.isEmpty()){
                result = Approval.process(approvalSubmitRequestList);
            }
        }catch (Exception e){

        }
 
    }

    @future
    public static void processWorkItems(String pendingBulkToSendToFuture, String handleApproval){
        List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
        List<ProcessInstanceWorkitem>  pendingBulkToRecallList = (List<ProcessInstanceWorkitem>) JSON.deserialize(pendingBulkToSendToFuture, List<ProcessInstanceWorkitem>.class);
        for(ProcessInstanceWorkitem eachPendingBulk : pendingBulkToRecallList){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(eachPendingBulk.Id);
            
            if(handleApproval == 'RECALL'){
                req.setComments('Recalled by bulk');
                req.setAction('Removed');
            }else if(handleApproval == 'APPROVE'){
                req.setComments('Approved by bulk');
                req.setAction('Approve');
            }else if(handleApproval == 'REJECT'){
                req.setComments('Rejected by bulk');
                req.setAction('Reject');
            }
            
            approvalRequestList.add(req);
        }

        try{
            Approval.ProcessResult[] result;
            if(!approvalRequestList.isEmpty()){
                result = Approval.process(approvalRequestList);
            }
        }catch (Exception e){

        }
    }

    
    public static void processWorkItems(String pendingBulkToSendToFuture, String handleApproval, String comments){
        List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
        List<ProcessInstanceWorkitem>  pendingBulkToRecallList = (List<ProcessInstanceWorkitem>) JSON.deserialize(pendingBulkToSendToFuture, List<ProcessInstanceWorkitem>.class);
        for(ProcessInstanceWorkitem eachPendingBulk : pendingBulkToRecallList){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(eachPendingBulk.Id);
            
            if(handleApproval == 'RECALL'){
                req.setComments(comments);
                req.setAction('Removed');
            }else if(handleApproval == 'APPROVE'){
                req.setComments(comments);
                req.setAction('Approve');
            }else if(handleApproval == 'REJECT'){
                req.setComments(comments);
                req.setAction('Reject');
            }
            
            approvalRequestList.add(req);
        }

        try{
            Approval.ProcessResult[] result;
            if(!approvalRequestList.isEmpty()){
                result = Approval.process(approvalRequestList);
            }
        }catch (Exception e){

        }
    }
}