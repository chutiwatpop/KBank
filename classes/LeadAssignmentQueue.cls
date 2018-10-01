public without sharing class LeadAssignmentQueue extends OwnershipAssignmentManager implements Queueable {
	@TestVisible
	private static Boolean doChainJob = true;

	private Map<Id, User_MaskModel> userMaskMapByUserId;

	private User_Admin__c userAdmin;
	private Map<String, Team_Structure__c> teamMapByRc;
	private Map<Id, User> assignedUserMap;
	private Set<String> reAssignRCCodes;

	public LeadAssignmentQueue(Map<Id, User_MaskModel> userMaskMapByUserId) {
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
			List<Lead> updatedLeadList = getObjectList();
			if(!updatedLeadList.isEmpty()) {
				setOwnership(updatedLeadList);
				executeUpdate(updatedLeadList, false);
			}
	        if(doChainJob && GlobalUtility.isApexClassConfigActive('EventAssignmentQueue')) {
	        	System.enqueueJob(new EventAssignmentQueue(userMaskMapByUserId));
	        }
        } catch (Exception ex) {
        	generateLog(ex.getMessage());
        }
	}

	public void generateLog(String errorMsg) {
		generateLog(userMaskMapByUserId.values(), 'JobAssignmentQueue', errorMsg);
	}

	public override List<SObject> getObjectList() {
		List<Lead> leadList = new List<Lead>();
		if(reAssignRCCodes == null) {
			leadList = [SELECT Id, OwnerId, Refer_To_User__c, Previous_RC_Code__c FROM Lead 
				WHERE Status != :GlobalConstants.CANCELLED AND IsConverted = false AND (Refer_To_User__c IN :userMaskMapByUserId.keySet() OR OwnerId IN :userMaskMapByUserId.keySet())];
		} else {
			leadList = [SELECT Id, OwnerId, Refer_To_User__c, Previous_RC_Code__c FROM Lead 
				WHERE Status != :GlobalConstants.CANCELLED AND IsConverted = false AND (Refer_To_User__c IN :userMaskMapByUserId.keySet() OR OwnerId IN :userMaskMapByUserId.keySet() OR Previous_RC_Code__c IN :reAssignRCCodes)]; 
		}

		return leadList;
	}

	private void setOwnership(List<SObject> sObjectList){
		for(Lead eachLead : (List<Lead>) sObjectList) {
			if(eachLead.Previous_RC_Code__c != null && teamMapByRc.containsKey(eachLead.Previous_RC_Code__c)) {
				if(setReAssignUser(eachLead)) {
					continue;
				}
			}
			if(eachLead.OwnerId != null && userMaskMapByUserId.containsKey(eachLead.OwnerId)) {
				cancelLead(eachLead);
			}
			if(eachLead.Refer_To_User__c != null && userMaskMapByUserId.containsKey(eachLead.Refer_To_User__c)) {
				setAssignNewUser(eachLead);
			}
		}
	}

	private Boolean setReAssignUser(Lead eachLead) {
		Boolean isReAssignOwner = false;
		Team_Structure__c eachTeam = teamMapByRc.get(eachLead.Previous_RC_Code__c);
		if(userMaskMapByUserId.containsKey(eachTeam.OwnerId)) {
			User_MaskModel userMask = userMaskMapByUserId.get(eachTeam.OwnerId);
			if(userMask.isChangeToActive || userMask.isChangeRCCode) {
				if(eachLead.Refer_To_User__c == eachLead.OwnerId) {
					eachLead.OwnerId		 = userMask.userId;
				}
				eachLead.Refer_To_User__c    = userMask.userId;
				eachLead.Previous_RC_Code__c = null;
				isReAssignOwner = true;
			}
		}
		return isReAssignOwner;
	}

	private void setAssignNewUser(Lead eachLead) {
		User_MaskModel userMask = userMaskMapByUserId.get(eachLead.Refer_To_User__c);
		String oldProfileName = userMask.getProfileName();
		User assignedUser;

		if(userMask.isChangeToInactive || userMask.isChangeRCCode) {
			if(GlobalConstants.PROFILE_RBS_SET.contains(oldProfileName) ||
				GlobalConstants.PROFILE_AF_SET.contains(oldProfileName)) {
					assignedUser = getAssignedUserWhenOneLevelUp(teamMapByRc, assignedUserMap, userMask.userObj);
				if(assignedUser == null) {
					assignedUser = getAdminFromUserMask(userMask, userAdmin, assignedUserMap);
				}
			}
		}

		if(assignedUser != null) {
			if(eachLead.Refer_To_User__c == eachLead.OwnerId) {
				eachLead.OwnerId 		 = assignedUser.Id;
			}
			eachLead.Refer_To_User__c    = assignedUser.Id;
			eachLead.Previous_RC_Code__c = userMask.previousRCCode;
		}
	}

	private void cancelLead(Lead eachLead) {
		User_MaskModel userMask = userMaskMapByUserId.get(eachLead.OwnerId);
		String oldProfileName = userMask.getProfileName();

		if(userMask.isChangeToInactive) {
			if(GlobalConstants.PROFILE_RBS_SET.contains(oldProfileName) ||
				GlobalConstants.PROFILE_AF_SET.contains(oldProfileName)) {
				if(eachLead.Refer_To_User__c == null) {
					eachLead.Status 		 		= GlobalConstants.CANCELLED;
					eachLead.Cancellation_Reason__c = 'ถูกยกเลิกโดยระบบเนื่องจากพนักงานที่ทำรายการ Refer ค้างไว้ลาออก';
				}
			}
		}
	}
}