public with sharing class ApprovalManager extends OwnershipAssignmentManager{

	private Map<id,User_MaskModel> userMaskMapByUserId;
	private Map<String, User> userMapByNewRoleRC;
	private Map<Id, User> assignedUserMap;
	private Map<String,Team_Structure__c> teamStructureMapByRc;
	private User_Admin__c userAdmin;
  	
	private Map<Id,Customer_Ownership_Request__c> ownerRequestMap;
	private List<ProcessInstanceWorkitem> workItemsList;

	private List<ProcessInstanceWorkitem> workItemListToUpdate;
	private List<Approval.ProcessWorkitemRequest> workItemRequestListToUpdate;
	private Map<String,IObjectApprovalReAssigner> objectApprovaReAssignerMap;

	public ApprovalManager(Map<id,User_MaskModel> userMaskMapByUserId){
		this.userMaskMapByUserId = userMaskMapByUserId;
		this.ownerRequestMap = new Map<Id,Customer_Ownership_Request__c>();
		this.workItemListToUpdate = new List<ProcessInstanceWorkitem>();
		this.workItemRequestListToUpdate = new List<Approval.ProcessWorkItemRequest>();
		init();
	}

	private void init(){
		this.userAdmin = User_Admin__c.getOrgDefaults();
		queryCustomerOwnerShipRequest();
		this.workItemsList = getObjectList();
		this.userMapByNewRoleRC = super.getUserMapByNewRoleRC(this.userMaskMapByUserId);
		this.teamStructureMapByRc = super.getTeamStructureMapByRCCode();
		Set<Id> userIds = super.getTeamOwnerIds(this.teamStructureMapByRc.values());
		userIds.addAll(getAdminIds(userAdmin));
		this.assignedUserMap = super.getUsersMap(userIds);
	}

	private void queryCustomerOwnerShipRequest(){
		this.ownerRequestMap = new Map<Id, Customer_Ownership_Request__c>([SELECT Id, Approval_Status__c, OwnerId, Current_Owner__c,
			Requestor__c,Approver__c
			FROM Customer_Ownership_Request__c 
			WHERE Approval_Status__c IN (:GlobalConstants.STATUS_OPEN,:GlobalConstants.APPROVAL_IN_PROGRESS) AND
				(
					OwnerId IN :this.userMaskMapByUserId.keySet() OR //requestor and ownerid should be the same
					Current_Owner__c IN :this.userMaskMapByUserId.keySet() OR 
					Approver__c IN :this.userMaskMapByUserId.keySet()
				)
			]);
	}

	public override List<SObject> getObjectList(){
		List<ProcessInstanceWorkitem> workItems = [
			SELECT id, ProcessInstance.CreatedById, CreatedBy.Profile.Name , ActorId, Actor.Profile.Name,
				ProcessInstance.CreatedBy.Current_Opportunity_Approval__c,
				ProcessInstance.TargetObjectId ,ProcessInstance.TargetObject.Type
			From ProcessInstanceWorkitem 
			WHERE ProcessInstance.Status = 'Pending' AND
				(
					(ProcessInstance.TargetObject.Type = 'Customer_Ownership_Request__c' AND ProcessInstance.TargetObjectId IN :ownerRequestMap.keySet()) 
					OR
					(ProcessInstance.TargetObject.Type = 'Lead' AND ActorId IN :this.userMaskMapByUserId.keySet()) 
					OR
					(ProcessInstance.TargetObject.Type = 'Opportunity' AND (CreatedById IN :this.userMaskMapByUserId.keySet() OR ActorId IN :this.userMaskMapByUserId.keySet()))
				)
			];
		return workItems;
	}

	private List<Id> getTargetObjectIdFromObjectType(String objectType){
		List<Id> targetIds = new List<Id>();
		for(ProcessInstanceWorkitem workItem : workItemsList){
			if(workItem.ProcessInstance.TargetObject.Type == objectType){
				targetIds.add(workItem.ProcessInstance.TargetObjectId);
			}
		}
		return targetIds;
	}

	private Map<Id,Opportunity> queryOpportunity(){
		List<Id> targetIds = getTargetObjectIdFromObjectType('Opportunity');
		Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([SELECT Id,OwnerId,StageName,Resubmit_Approval__c  
			From Opportunity 
			WHERE Id IN :targetIds AND StageName = :GlobalConstants.REOPEN]);
		return opportunityMap;
	}

	public void initObjectReAssigner(){
		this.objectApprovaReAssignerMap = new Map<String,IObjectApprovalReAssigner>();
		this.objectApprovaReAssignerMap.put('Customer_Ownership_Request__c',initRequestReAssigner());
		this.objectApprovaReAssignerMap.put('Opportunity',initOpportunityReAssigner());
		this.objectApprovaReAssignerMap.put('Lead',initLeadReAssigner());
	} 

	private IObjectApprovalReassigner initRequestReAssigner(){
		RequestApprovalReassigner requestReAssigner = new RequestApprovalReassigner(ownerRequestMap,assignedUserMap, userMapByNewRoleRC, teamStructureMapByRc, userAdmin, userMaskMapByUserId);
		return requestReAssigner;
	}

	private IObjectApprovalReassigner initOpportunityReAssigner(){
		Map<Id,Opportunity> opportunityMap = queryOpportunity();
		OpportunityApprovalReassigner opportunityReAssigner = new OpportunityApprovalReassigner(opportunityMap,assignedUserMap, userMapByNewRoleRC, teamStructureMapByRc, userAdmin, userMaskMapByUserId);
		return opportunityReAssigner;
	}

	private IObjectApprovalReassigner initLeadReAssigner(){
		LeadApprovalReassigner leadReAssigner = new LeadApprovalReassigner(assignedUserMap, userMapByNewRoleRC, teamStructureMapByRc, userAdmin, userMaskMapByUserId);
		return leadReAssigner;
	}

	public void reAssignProcessInstance(){
		for(ProcessInstanceWorkitem workItem : workItemsList){
			IObjectApprovalReassigner objectApprovalReAssigner;
			ApprovalWrapper approvalWrapper;
			if(this.objectApprovaReAssignerMap.containsKey(workItem.ProcessInstance.TargetObject.Type)){
				objectApprovalReAssigner = this.objectApprovaReAssignerMap.get(workItem.ProcessInstance.TargetObject.Type);
				approvalWrapper = objectApprovalReAssigner.getReAssign(workItem);
				if(approvalWrapper != null){
					if(approvalWrapper.isSetWorkItem){
						workItemListToUpdate.add(approvalWrapper.getWorkItem());
					}else if(approvalWrapper.isSetworkItemRequest){
						workItemRequestListToUpdate.add(approvalWrapper.getWorkItemRequest());
					}
				}
			}
		}
	}

	public void updateAllWork(){
		List<SObject> objToUpdate = new List<SObject>();
		for(IObjectApprovalReassigner objApprovalReAssigner : objectApprovaReAssignerMap.values()){
			List<SObject> objs = objApprovalReAssigner.getAllObjectToUpdate();
			if(objs != null && !objs.isEmpty()){
				objToUpdate.addALL(objs);
			}
		}
		try{
			if(!objToUpdate.isEmpty()){
				TriggerHandler.bypass('CustomerOwnershipRequestTriggerHandler');
				Database.update(objToUpdate,false);
				TriggerHandler.clearBypass('CustomerOwnershipRequestTriggerHandler');
			}
			if(!workItemRequestListToUpdate.isEmpty()) {
	        	Approval.ProcessResult[] appResult = Approval.process(workItemRequestListToUpdate);
	        }
	        if(!workItemListToUpdate.isEmpty()){
	        	Database.update(workItemListToUpdate,false);
	        }
	        
	    }catch(Exception e) {
           System.debug('ApprovalManager Class the following exception has occurred: ' + e.getMessage());
        }
	}

}