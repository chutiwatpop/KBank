public with sharing class LeadApprovalReassigner implements IObjectApprovalReassigner {

	private List<ProcessInstanceWorkitem> workItemList;

	private Map<id,User_MaskModel> userMaskMapByUserId;
	private Map<String, User> userMapByNewRoleRC;
	private Map<Id, User> assignedUserMap;
	private Map<String,Team_Structure__c> teamStructureMapByRc;
	private User_Admin__c userAdmin;

	public LeadApprovalReassigner(Map<Id,User> assignedUserMap,Map<String, User> userMapByNewRoleRC, Map<String,Team_Structure__c> teamStructureMapByRc,
		User_Admin__c userAdmin,Map<id,User_MaskModel> userMaskMapByUserId ) {
		
		this.assignedUserMap = assignedUserMap;
		this.userMapByNewRoleRC = userMapByNewRoleRC;
		this.teamStructureMapByRc = teamStructureMapByRc;
		this.userAdmin = userAdmin;
		this.userMaskMapByUserId = userMaskMapByUserId;
	}

	public ApprovalWrapper getReAssign(ProcessInstanceWorkitem workItem){
		ApprovalWrapper approvalWrapper;
		User_MaskModel userMask;
		User replaceUser;
		if(userMaskMapByUserId.containsKey(workItem.ActorId)){
			userMask = userMaskMapByUserId.get(workItem.ActorId);
			if(userMask.isChangeToInactive || userMask.isChangeRCCode){
				if(userMask.isOldRBSProfile || userMask.isOldAFProfile){
					replaceUser = OwnershipAssignmentManager.getAssignedUserWhenOneLevelUp(teamStructureMapByRc, assignedUserMap, userMask.userObj);
					if(replaceUser == null){
						replaceUser = OwnershipAssignmentManager.getAdminFromUserMask(userMask,userAdmin, assignedUserMap);
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
		return null;
	}
}