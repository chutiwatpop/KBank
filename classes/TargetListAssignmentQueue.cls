public without sharing class TargetListAssignmentQueue extends OwnershipAssignmentManager implements Queueable {
	@TestVisible
	private static Boolean doChainJob = true;

	private Map<Id, User_MaskModel> userMaskMapByUserId;

	private User_Admin__c userAdmin;
	private Map<String, Team_Structure__c> teamMapByRc;
	private Map<Id, User> assignedUserMap;
	private Set<String> reAssignRCCodes;

	public TargetListAssignmentQueue(Map<Id, User_MaskModel> userMaskMapByUserId) {
		this.userMaskMapByUserId = userMaskMapByUserId;
		init();
	}

	public void init() {
		this.userAdmin 	 	 = User_Admin__c.getOrgDefaults();
		this.teamMapByRc 	 = super.getTeamStructureMapByRCCode();
		Set<Id> targetUserIds = super.getTeamOwnerIds(this.teamMapByRc.values());
		targetUserIds.addAll(super.getAdminIds(userAdmin));
		this.assignedUserMap = super.getUsersMap(targetUserIds);
		this.reAssignRCCodes = super.getReAssignUserRCCode(userMaskMapByUserId.values());
	}

	public void execute(QueueableContext context) {
		try {
			List<Target_List__c> targetLists = getObjectList();
			if(!targetLists.isEmpty()) {
				setOwnership(targetLists);
				executeUpdate(targetLists, false);
			}
	        if(doChainJob && GlobalUtility.isApexClassConfigActive('JobAssignmentQueue')) {
	        	System.enqueueJob(new JobAssignmentQueue(userMaskMapByUserId));
	        }
	    } catch(Exception ex) {
	    	generateLog(ex.getMessage());
	    }
	}

	public void generateLog(String errorMsg) {
		generateLog(userMaskMapByUserId.values(), 'TargetListAssignmentQueue', errorMsg);
	}

	public override List<SObject> getObjectList() {
		List<Target_List__c> targetLists = new List<Target_List__c>();
		if(reAssignRCCodes == null) {
			targetLists = [SELECT Id, Branch_RBS__c, Branch_RBS__r.RC_Code__c, Re_Assigned_To_UserEx__c, Re_Assigned_To_UserEx__r.User__c FROM Target_List__c 
				WHERE Re_Assigned_To_UserEx__r.User__c IN :userMaskMapByUserId.keySet()];
		} else {
			targetLists = [SELECT Id, Branch_RBS__c, Branch_RBS__r.RC_Code__c, Re_Assigned_To_UserEx__c, Re_Assigned_To_UserEx__r.User__c FROM Target_List__c 
				WHERE Re_Assigned_To_UserEx__r.User__c IN :userMaskMapByUserId.keySet() OR Branch_RBS__r.RC_Code__c IN :reAssignRCCodes];
		}

		return targetLists;
	}

	private void setOwnership(List<SObject> sObjectList){
		for(Target_List__c eachTargetList : (List<Target_List__c>) sObjectList) {
			if(eachTargetList.Branch_RBS__r.RC_Code__c != null && teamMapByRc.containsKey(eachTargetList.Branch_RBS__r.RC_Code__c)) {
				if(setReAssignUser(eachTargetList)) {
					continue;
				}
			}
			if(eachTargetList.Re_Assigned_To_UserEx__r.User__c != null && userMaskMapByUserId.containsKey(eachTargetList.Re_Assigned_To_UserEx__r.User__c)) {
				setAssignNewUser(eachTargetList);
			}
		}
	}

	private Boolean setReAssignUser(Target_List__c eachTargetList) {
		Boolean isReAssignOwner = false;
		Team_Structure__c eachTeam = teamMapByRc.get(eachTargetList.Branch_RBS__r.RC_Code__c);
		if(userMaskMapByUserId.containsKey(eachTeam.OwnerId)) {
			User_MaskModel userMask = userMaskMapByUserId.get(eachTeam.OwnerId);
			if(userMask.isChangeToActive || userMask.isChangeRCCode || userMask.isReCalculateOwnership) {
				if(assignedUserMap.containsKey(userMask.userId) && !assignedUserMap.get(userMask.userId).User_Extension__r.isEmpty()) {
					eachTargetList.Re_Assigned_To_UserEx__c = assignedUserMap.get(userMask.userId).User_Extension__r[0].Id;
					isReAssignOwner = true;
				}
			}
		}
		return isReAssignOwner;
	}

	private void setAssignNewUser(Target_List__c eachTargetList) {
		User_MaskModel userMask = userMaskMapByUserId.get(eachTargetList.Re_Assigned_To_UserEx__r.User__c);
		String oldProfileName = userMask.getProfileName();
		User assignedUser;

		if(userMask.isChangeToInactive || userMask.isChangeRCCode) {
			if(GlobalConstants.PROFILE_RBS_SET.contains(oldProfileName) || 
				GlobalConstants.PROFILE_AF_SET.contains(oldProfileName)) {
				//assignedUser = getAssignedUserWhenOneLevelUp(teamMapByRc, assignedUserMap, userMask.userObj);
				String rcCode = eachTargetList.Branch_RBS__r.RC_Code__c;
				if(rcCode != null) {
					assignedUser = getTeamManagerFromRC(teamMapByRc, assignedUserMap, rcCode);
				}
				if(assignedUser == null) {
					assignedUser = getAdminFromUserMask(userMask, userAdmin, assignedUserMap);
				}
			}
		}

		if(assignedUser != null && !assignedUser.User_Extension__r.isEmpty()) {
			eachTargetList.Re_Assigned_To_UserEx__c = assignedUser.User_Extension__r[0].Id;
		}
	}
}