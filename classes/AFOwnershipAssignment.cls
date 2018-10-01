public with sharing class AFOwnershipAssignment implements IOwnershipAssignment{

	//public static final Set<String> AF_PROFILE_INACTIVE_CHANGE_ACCOUNTOWNER_SET = new Set<String>{GlobalConstants.AF_RM,GlobalConstants.AF_TM,
	//	GlobalConstants.AF_AH,GlobalConstants.AF_NH,GlobalConstants.AF_FSVP};

	//public static final Set<String> AF_PROFILE_CHANGETEAM_CHANGE_ACCOUNTOWNER_SET = new Set<String>{GlobalConstants.AF_TM,
	//	GlobalConstants.AF_AH,GlobalConstants.AF_NH,GlobalConstants.AF_FSVP};


	private Map<Id,User_MaskModel> userMaskMapByUserId;
    private Map<String,Team_Structure__c> teamStructureMapByRc;
    private Map<Id,User> userMap;
    private User_Admin__c userAdmin;
	private Boolean isSetAccount;

	public AFOwnershipAssignment(Map<Id,User_MaskModel> userMaskMapByUserId, Map<String,Team_Structure__c> teamStructureMapByRc, Map<Id,User> userMap,User_Admin__c userAdmin) {
        this.userMaskMapByUserId = userMaskMapByUserId;
        this.teamStructureMapByRc = teamStructureMapByRc;
        this.userAdmin = userAdmin;
        this.userMap = userMap;
        this.isSetAccount = false;
    }

	private Boolean shouldAssignAccountOwner(User_MaskModel userMask){
		Boolean shouldAssignNewOwner = false;
		Profile userProfile = User_Service.allProfileMap.containsKey(userMask.userObj.ProfileId) ? User_Service.allProfileMap.get(userMask.userObj.ProfileId) : null;
		if(userProfile != null){
			if(userMask.isChangeToInactive || (userMask.isChangeRCCode && userMask.isChangeSegment)){
				shouldAssignNewOwner = true;
			}
		}
        return shouldAssignNewOwner;
    }

    private void setCurrentAndAssignedAccountOwner(Bulk_Assignment__c bulkAssignment, Account account){
    	User_MaskModel userMask;
    	if(userMaskMapByUserId.containsKey(account.OwnerId)){
    		userMask = userMaskMapByUserId.get(account.OwnerId);
    		if(shouldAssignAccountOwner(userMask)){
    			User assignedUser = OwnershipAssignmentManager.getAssignedUserWhenOneLevelUp(teamStructureMapByRc,userMap,userMask.userObj);
                if(assignedUser == null){
                    assignedUser = OwnershipAssignmentManager.getAdminFromUserMask(userMask,userAdmin, userMap);
                }
    			bulkAssignment.CurrentOwner__c = account.OwnerId;
    			bulkAssignment.AssignmentOwner__c = assignedUser.id;
    			isSetAccount = true;
    		}
    	}
    }

	private Id getAssignedAccountOwner(User_MaskModel userMask){
		Team_Structure__c teamStructure;
		if(teamStructureMapByRc.containsKey(userMask.previousRCCode)){
			teamStructure = teamStructureMapByRc.get(userMask.previousRCCode);
			return teamStructure.OwnerId;
		}
		return null;
	}

 	public void setBulkAssignmentInfo(BulkAssignmentWrapper bulkWrapper, Account account){
 		setCurrentAndAssignedAccountOwner(bulkWrapper.bulkAssignment,account);
 	}

 	public Boolean isAccountSetted(){
 		return this.isSetAccount;
 	}
}