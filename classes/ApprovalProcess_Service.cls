/**
* @29/12/2016 Fixed INC000000488038 กรณีถ้ามีการ Release Temporary Ownership ไม่ว่าจากการกดปุ่มหรือ batch เมื่อ Customer หรือ Prospect ถูก Release ไปถึง SME Admin ระบบจะเช็คเพิ่มเติมว่ามี Request record อยู่รึป่าว ถ้ามี Request record ที่ Approval Status เป็น Open ระบบจะเปลี่ยน Approval Status เป็น Cancel ถ้ามี Request record ที่ Approval Status เป็น Approval In Process ระบบจะเปลี่ยน Approval Status เป็น Reject และใส่ comment ว่า Cancel by Admin
* @24/01/2017 Fixed INC000000488038 Recall Request Ownership ไม่ได้: Change solution
*/
public without sharing class ApprovalProcess_Service {

	public enum WORKITEM_ACTION {REJECT,APPROVE,REMOVE}

    public static void reassignApproval(Map<Id, Bulk_Assignment__c> assignMapByCurrentUser) {
    	// Requestor
    	Map<Id, Customer_Ownership_Request__c> ownerRequestMap = new Map<Id, Customer_Ownership_Request__c>([SELECT Id, Approval_Status__c, OwnerId, Current_Owner__c FROM Customer_Ownership_Request__c WHERE Approval_Status__c = 'Approval In Progress']);
    	List<Customer_Ownership_Request__c> ownerReqUpdateList = new List<Customer_Ownership_Request__c>();
		for(Customer_Ownership_Request__c ownerReq : ownerRequestMap.values()) {
			if(assignMapByCurrentUser.containsKey(ownerReq.Current_Owner__c)) {
				Bulk_Assignment__c assignment = assignMapByCurrentUser.get(ownerReq.Current_Owner__c);
				ownerReq.Current_Owner__c = assignment.AssignmentOwner__c;
				ownerReqUpdateList.add(ownerReq);
			} else if(assignMapByCurrentUser.containsKey(ownerReq.OwnerId)) {
				//Requestor
				ownerReq.Approval_Status__c = 'Cancel';// Workflow do this
				ownerReqUpdateList.add(ownerReq);
			}
		}
		
		if(ownerReqUpdateList.size() > 0) update ownerReqUpdateList;

		List<ProcessInstanceWorkitem> workItemList = new List<ProcessInstanceWorkitem>();
		List<Approval.ProcessWorkitemRequest> workItemRequestList = New List<Approval.ProcessWorkItemRequest>();
		List<ProcessInstance> processInstanceList = new List<ProcessInstance>();
		processInstanceList = [Select ID, TargetObjectId, TargetObject.Type,
                (SELECT Id, ActorId, OriginalActorId FROM Workitems) From ProcessInstance Where Status = 'Pending' AND (TargetObjectId IN :ownerRequestMap.keySet() OR TargetObject.Type = 'Opportunity' OR TargetObject.Type = 'Opportunity_Request_for_Approval__c')];

        Customer_Ownership_Request__c ownerReq;
        Approval.ProcessWorkitemRequest workItemRequest;
        Bulk_Assignment__c assignment;
		for(ProcessInstance pInstance : processInstanceList){
			if(ownerRequestMap.containsKey(pInstance.TargetObjectId)) {
				ownerReq = ownerRequestMap.get(pInstance.TargetObjectId);
				for(ProcessInstanceWorkItem workItem : pInstance.WorkItems){
					//Requestor
					if(ownerReq.Approval_Status__c == 'Cancel') {
						workItemRequest = new Approval.ProcessWorkitemRequest();
		                workItemRequest.setWorkItemID(workItem.id);
		                workItemRequest.setComments('Cancel request/release customer');
		                workItemRequest.setAction('Reject');
		                workItemRequestList.add(workItemRequest);
		                break;
					}
					// Approver
					if(assignMapByCurrentUser.containsKey(workItem.ActorId)) {
						assignment = assignMapByCurrentUser.get(workItem.ActorId);
						workItem.ActorId = assignment.AssignmentOwner__c;
						//workItem.OriginalActorId = assignment.AssignmentOwner__c;
						workItemList.add(workItem);
						break;
					}
				}
			}else if(pInstance.TargetObject.Type == 'Opportunity'){
				for(ProcessInstanceWorkItem workItem : pInstance.WorkItems){
					// Approver
					if(assignMapByCurrentUser.containsKey(workItem.ActorId)) {
						assignment = assignMapByCurrentUser.get(workItem.ActorId);
						workItem.ActorId = assignment.AssignmentOwner__c;
                        System.debug('new Actor : '+workItem.ActorId);
						//workItem.OriginalActorId = assignment.AssignmentOwner__c;
						workItemList.add(workItem);
						break;
					}
				}
			}else if(pInstance.TargetObject.Type == 'Opportunity_Request_for_Approval__c'){
				for(ProcessInstanceWorkItem workItem : pInstance.WorkItems){
					// Approver
					if(assignMapByCurrentUser.containsKey(workItem.ActorId)) {
						assignment = assignMapByCurrentUser.get(workItem.ActorId);
						workItem.ActorId = assignment.AssignmentOwner__c;
						//workItem.OriginalActorId = assignment.AssignmentOwner__c;
						workItemList.add(workItem);
						break;
					}
				}
			}
        }

        if(!workItemRequestList.isEmpty()) {
        	Approval.ProcessResult[] appResult = Approval.process(workItemRequestList);
        }

        if(!workItemList.isEmpty()){
        	update workItemList;
        }

    }

    // INC000000488038
    public static void closedCustomerOwnershipRequest(Map<Id, Account> accountMap) {
    	Map<Id, Customer_Ownership_Request__c> ownerRequestMap = new Map<Id, Customer_Ownership_Request__c>([SELECT Id, CIS_ID__c, Approval_Status__c, OwnerId, Current_Owner__c FROM Customer_Ownership_Request__c WHERE (Approval_Status__c = :GlobalConstants.APPROVAL_IN_PROGRESS OR Approval_Status__c = :GlobalConstants.STATUS_OPEN) AND CIS_ID__c IN :accountMap.keySet()]);    	
    	List<Customer_Ownership_Request__c> ownerReqUpdateList = new List<Customer_Ownership_Request__c>();
    	Set<Id> rejectedRequestIds = new Set<Id>();
		for(Customer_Ownership_Request__c ownerReq : ownerRequestMap.values()) {
			if(ownerReq.Approval_Status__c == GlobalConstants.STATUS_OPEN) {
            	ownerReq.Approval_Status__c = GlobalConstants.CANCEL;
            	ownerReqUpdateList.add(ownerReq);
            } else if(ownerReq.Approval_Status__c == GlobalConstants.APPROVAL_IN_PROGRESS) {
            	rejectedRequestIds.add(ownerReq.Id);
            }
		}
		if(!ownerReqUpdateList.isEmpty()) {//INC000000770569
			Database.SaveResult[] updateResults = Database.update(ownerReqUpdateList, false);
		}

		List<Approval.ProcessWorkitemRequest> workItemRequestList = New List<Approval.ProcessWorkItemRequest>();
		List<ProcessInstance> processInstanceList = new List<ProcessInstance>();
		processInstanceList = [Select ID, TargetObjectId, TargetObject.Type,
                (SELECT Id, ActorId, OriginalActorId FROM Workitems) From ProcessInstance Where Status = :GlobalConstants.STATUS_PENDING AND TargetObjectId IN :rejectedRequestIds];

        Customer_Ownership_Request__c ownerReq;
        Approval.ProcessWorkitemRequest workItemRequest;
		for(ProcessInstance pInstance : processInstanceList){
			if(ownerRequestMap.containsKey(pInstance.TargetObjectId)) {
				ownerReq = ownerRequestMap.get(pInstance.TargetObjectId);
				for(ProcessInstanceWorkItem workItem : pInstance.WorkItems){
					workItemRequest = new Approval.ProcessWorkitemRequest();
	                workItemRequest.setWorkItemID(workItem.id);
	                workItemRequest.setComments(GlobalConstants.CANCEL_BY_ADMIN);
	                workItemRequest.setAction(GlobalConstants.REJECT);
	                workItemRequestList.add(workItemRequest);
				}
			}
        }

        if(!workItemRequestList.isEmpty()) {
        	Approval.ProcessResult[] appResult = Approval.process(workItemRequestList);
        }
    }

    // INC000000488038 Recall Request Ownership ไม่ได้: Change solution
    public static void approvedCustomerOwnershipRequest(Map<Id,Account> accountMap){
    	Map<Id, Customer_Ownership_Request__c> ownerRequestMap = new Map<Id, Customer_Ownership_Request__c>([SELECT Id, CIS_ID__c, Approval_Status__c, OwnerId, Current_Owner__c FROM Customer_Ownership_Request__c WHERE Approval_Status__c = :GlobalConstants.APPROVAL_IN_PROGRESS AND CIS_ID__c IN :accountMap.keySet()]);
    	List<Customer_Ownership_Request__c> ownerReqUpdateList = new List<Customer_Ownership_Request__c>();
    	Set<Id> approvedRequestIds = new Set<Id>();
		for(Customer_Ownership_Request__c ownerReq : ownerRequestMap.values()) {
   			if(ownerReq.Approval_Status__c == GlobalConstants.APPROVAL_IN_PROGRESS) {
   				ownerReq.Approval_Status__c = GlobalConstants.APPROVED;
   				ownerReqUpdateList.add(ownerReq);
            	approvedRequestIds.add(ownerReq.Id);
            }
		}
		if(!ownerReqUpdateList.isEmpty()) {//INC000000770569
			Database.SaveResult[] updateResults = Database.update(ownerReqUpdateList, false);
		}

		List<Approval.ProcessWorkitemRequest> workItemRequestList = New List<Approval.ProcessWorkItemRequest>();
		List<ProcessInstance> processInstanceList = new List<ProcessInstance>();
		processInstanceList = [Select ID, TargetObjectId, TargetObject.Type,
                (SELECT Id, ActorId, OriginalActorId FROM Workitems) From ProcessInstance Where Status = :GlobalConstants.STATUS_PENDING AND TargetObjectId IN :approvedRequestIds];

        Customer_Ownership_Request__c ownerReq;
        Approval.ProcessWorkitemRequest workItemRequest;
		for(ProcessInstance pInstance : processInstanceList){
			if(ownerRequestMap.containsKey(pInstance.TargetObjectId)) {
				ownerReq = ownerRequestMap.get(pInstance.TargetObjectId);
				if(accountMap.containsKey(ownerReq.CIS_ID__c)) {
					accountMap.remove(ownerReq.CIS_ID__c);
				}
				for(ProcessInstanceWorkItem workItem : pInstance.WorkItems){
					workItemRequest = new Approval.ProcessWorkitemRequest();
	                workItemRequest.setWorkItemID(workItem.id);
	                workItemRequest.setComments('Auto approved by Sales Smart');
	                workItemRequest.setAction('Approve');
	                workItemRequestList.add(workItemRequest);
				}
			}
        }
        
        if(!workItemRequestList.isEmpty()) {
        	Approval.ProcessResult[] appResult = Approval.process(workItemRequestList);
        }
    }

	public void cancelApprovedByOpportunity(Map<Id,Opportunity> cancelApprovalProcessByOpp){
		List<Approval.ProcessWorkitemRequest> workItemRequestList = New List<Approval.ProcessWorkItemRequest>();
		List<ProcessInstance> processInstanceList = new List<ProcessInstance>();
		Approval.ProcessWorkitemRequest workItemRequest;
		processInstanceList = [Select ID, TargetObjectId, TargetObject.Type,
				(SELECT Id, ActorId, OriginalActorId FROM Workitems) From ProcessInstance Where Status = 'Pending' AND (TargetObjectId IN :cancelApprovalProcessByOpp.keySet() OR TargetObject.Type = 'Opportunity')];
		for(ProcessInstance pInstance : processInstanceList){
			for(ProcessInstanceWorkItem workItem : pInstance.WorkItems){
				workItemRequest = new Approval.ProcessWorkitemRequest();
				workItemRequest.setWorkItemID(workItem.id);
				workItemRequest.setComments('Cancel Reopen Job');
				workItemRequest.setAction('Reject');
				workItemRequestList.add(workItemRequest);
				break;
			}
		}

		if(!workItemRequestList.isEmpty()) {
			try{
				TriggerHandler.bypass('OpportunityTriggerHandler');
            	Approval.ProcessResult[] appResult = Approval.process(workItemRequestList);
                TriggerHandler.clearBypass('OpportunityTriggerHandler');
			}catch(Exception e){
				System.debug(e.getMessage());
			}
		}
	}

	public static Approval.ProcessWorkitemRequest newProcessWorkitemRequest(Id workItemid,String comment,WORKITEM_ACTION eAction){
		Approval.ProcessWorkitemRequest workItemRequest = new Approval.ProcessWorkitemRequest();
        workItemRequest.setWorkItemID(workItemid);
        workItemRequest.setComments(comment);
        workItemRequest.setAction(getWormItemAction(eAction));
        return workItemRequest;
	}

	public static String getWormItemAction(WORKITEM_ACTION eAction){
		String action;
		switch on eAction{
			when REJECT{
				action = 'Reject';
			}
			when APPROVE{
				action = 'Approve';
			}
			when REMOVE{
				action = 'Remove';
			}
		}
		return action;
	}
}