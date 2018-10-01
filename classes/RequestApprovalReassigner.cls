public with sharing class RequestApprovalReassigner implements IObjectApprovalReassigner {
	private Map<Id,Customer_Ownership_Request__c> ownerRequestMap;

	private Map<id,User_MaskModel> userMaskMapByUserId;
	private Map<String, User> userMapByNewRoleRC;
	private Map<Id, User> assignedUserMap;
	private Map<String,Team_Structure__c> teamStructureMapByRc;
	private User_Admin__c userAdmin;

	public RequestApprovalReassigner(Map<Id,Customer_Ownership_Request__c> ownerRequestMap,
		Map<Id,User> assignedUserMap,Map<String, User> userMapByNewRoleRC, Map<String,Team_Structure__c> teamStructureMapByRc,
		User_Admin__c userAdmin,Map<id,User_MaskModel> userMaskMapByUserId ) {
		
		this.ownerRequestMap = ownerRequestMap;
		this.assignedUserMap = assignedUserMap;
		this.userMapByNewRoleRC = userMapByNewRoleRC;
		this.teamStructureMapByRc = teamStructureMapByRc;
		this.userAdmin = userAdmin;
		this.userMaskMapByUserId = userMaskMapByUserId;
	}


	public ApprovalWrapper getReAssign(ProcessInstanceWorkitem workItem){
		ApprovalWrapper approvalWrapper;
		User replaceUser;
		User_MaskModel userMask;
		Approval.ProcessWorkitemRequest workItemRequest;
		if(ownerRequestMap.containsKey(workItem.ProcessInstance.TargetObjectId)) {
			Customer_Ownership_Request__c ownerReq = ownerRequestMap.get(workItem.ProcessInstance.TargetObjectId);
			if(userMaskMapByUserId.containsKey(ownerReq.OwnerId)){
				userMask = userMaskMapByUserId.get(ownerReq.OwnerId);
				setReAssignRequestor(ownerReq,userMask);
				if(userMask.isOldSMEProfile || userMask.isOldCBSProfile){
					workItemRequest = ApprovalProcess_Service.newProcessWorkitemRequest(workItem.id,'Cancel request/release customer',ApprovalProcess_Service.WORKITEM_ACTION.REJECT);
				}else if(userMask.isOldRBSProfile){
					workItemRequest = ApprovalProcess_Service.newProcessWorkitemRequest(workItem.id,Label.ClosenessBranchRequestorIsInactive,ApprovalProcess_Service.WORKITEM_ACTION.REJECT);
				}
				approvalWrapper = new ApprovalWrapper(workItemRequest);
			}else if(userMaskMapByUserId.containsKey(ownerReq.Approver__c)){
				userMask = userMaskMapByUserId.get(ownerReq.Approver__c);
				if(userMask.isOldRBSProfile){
					setReAssignApprover(ownerReq, userMask);
					workItemRequest = ApprovalProcess_Service.newProcessWorkitemRequest(workItem.id,Label.ClosenessBranchApproverIsInactive,ApprovalProcess_Service.WORKITEM_ACTION.REJECT);
					approvalWrapper = new ApprovalWrapper(workItemRequest);
				}
			}else if(userMaskMapByUserId.containsKey(ownerReq.Current_Owner__c)){
				userMask = userMaskMapByUserId.get(ownerReq.Current_Owner__c);
				if(userMask.isOldSMEProfile){
					setReAssignCurrentOwner(ownerReq, userMask);
				}
			}else if(userMaskMapByUserId.containsKey(workItem.ActorId)){
				userMask = userMaskMapByUserId.get(workItem.ActorId);
				if(userMask.isOldSMEProfile){
					replaceUser = OwnershipAssignmentManager.getUserForReplacement(userMask, userMapByNewRoleRc);
					if(replaceUser == null){
						replaceUser = OwnershipAssignmentManager.getAssignedUserWhenOneLevelUp(teamStructureMapByRc, assignedUserMap, userMask.userObj);
					}
					if(replaceUser != null){
						workItem.ActorId = replaceUser.id;
						approvalWrapper = new ApprovalWrapper(workItem);
					}
				}
			}
		}
		return approvalWrapper;
	}

	public List<sObject> getAllObjectToUpdate(){
		return (List<sObject>)this.ownerRequestMap.values();
	}

	private void setReAssignRequestor(Customer_Ownership_Request__c reqs,User_MaskModel userMask){
		if(userMask.isChangeToInactive || userMask.isChangeRCCode){
			if(userMask.isOldRBSProfile){
				rejectCustomerOwnership(reqs);
			}else{
				cancelCustomerOwnership(reqs);
			}
		}
	}

	private void setReAssignApprover(Customer_Ownership_Request__c reqs,User_MaskModel userMask){
		if(userMask.isChangeToInactive || userMask.isChangeRCCode){
			if(cancelWhenApproverProfileInActiveChangeTeam(userMask.profileName)){
				rejectCustomerOwnership(reqs);
				setApproverIsChangeTeamOrInActive(reqs);
			}
		}
	}

	private void setReAssignCurrentOwner(Customer_Ownership_Request__c reqs,User_MaskModel userMask){
		if(userMask.isChangeToInactive || userMask.isChangeRCCode){
			User replaceUser = OwnershipAssignmentManager.getUserForReplacement(userMask, userMapByNewRoleRc);
			if(replaceUser == null){
				replaceUser = OwnershipAssignmentManager.getAssignedUserWhenOneLevelUp(teamStructureMapByRc, assignedUserMap, userMask.userObj);
			}
			reqs.Current_Owner__c = replaceUser.id;
		}
	}

	private void setApproverIsChangeTeamOrInActive(Customer_Ownership_Request__c ownerReq) {
		ownerReq.Approver_Changed_Team_Inactive__c = true;
	}

	private Boolean cancelWhenApproverProfileInActiveChangeTeam(String profileName){
		Set<String> profileSet = new Set<String>{GlobalConstants.RBS_TM, GlobalConstants.RBS_AH, GlobalConstants.RBS_NH, GlobalConstants.RBS_ADMIN};
		return profileSet.contains(profileName);
	}
	
	private void cancelCustomerOwnership(Customer_Ownership_Request__c ownerReq){
		setOwnershipRequestStatus(ownerReq,GlobalConstants.CANCEL);
	}

	private void rejectCustomerOwnership(Customer_Ownership_Request__c ownerReq){
		setOwnershipRequestStatus(ownerReq,GlobalConstants.REJECTED);
	}

	private void setOwnershipRequestStatus(Customer_Ownership_Request__c ownerReq, String status){
		ownerReq.Approval_Status__c = status;
	}
}