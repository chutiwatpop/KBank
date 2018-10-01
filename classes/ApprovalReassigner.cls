public without sharing class ApprovalReassigner  {
	private Map<Id,User> assignedUserMap;
	private Map<String, User> userMapByNewRoleRC;
	private Map<String,Team_Structure__c> teamStructureMapByRc;

	public ApprovalReassigner(Map<Id,User> assignedUserMap,Map<String, User> userMapByNewRoleRC, Map<String,Team_Structure__c> teamStructureMapByRc) {
		this.assignedUserMap = assignedUserMap;
		this.userMapByNewRoleRC = userMapByNewRoleRC;
		this.teamStructureMapByRc = teamStructureMapByRc;
	}

	public ApprovalReassigner() {}

	//public abstract void setOwnershipRequestInfo(Customer_Ownership_Request__c ownerReq);

	public void cancelCustomerOwnership(Customer_Ownership_Request__c ownerReq){
		setOwnershipRequestStatus(ownerReq,GlobalConstants.CANCEL);
	}

	public void setReAssignCurrentOwner(Customer_Ownership_Request__c reqs,User_MaskModel userMask){
		if(userMask.isChangeToInactive || userMask.isChangeRCCode){
			User replaceUser = OwnershipAssignmentManager.getUserForReplacement(userMask, userMapByNewRoleRc);
			if(replaceUser == null){
				replaceUser = OwnershipAssignmentManager.getAssignedUserWhenOneLevelUp(teamStructureMapByRc, assignedUserMap, userMask.userObj);
			}
			reqs.Current_Owner__c = replaceUser.id;
		}
	}

	public void setReAssignApprover(Customer_Ownership_Request__c reqs,User_MaskModel userMask){
		if(userMask.isChangeToInactive || userMask.isChangeRCCode){
			if(cancelRequestWhenProfileInActiveChangeTeam(userMask.profileName)){
				cancelCustomerOwnership(reqs);
			}
		}
	}

	private Boolean cancelRequestWhenProfileInActiveChangeTeam(String profileName){
		Set<String> profileSet = new Set<String>{GlobalConstants.RBS_TM, GlobalConstants.RBS_AH, GlobalConstants.RBS_NH, GlobalConstants.RBS_ADMIN};
		return profileSet.contains(profileName);
	}
	
	private void setOwnershipRequestStatus(Customer_Ownership_Request__c ownerReq, String status){
		ownerReq.Approval_Status__c = status;
	}

	

}