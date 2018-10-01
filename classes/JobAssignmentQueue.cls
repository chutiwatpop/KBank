public without sharing class JobAssignmentQueue extends OwnershipAssignmentManager implements Queueable {
	@TestVisible
	private static Boolean doChainJob = true;

	private Map<Id, User_MaskModel> userMaskMapByUserId;

	private User_Admin__c userAdmin;
	private Map<String, Team_Structure__c> teamMapByRc;
	private Map<Id, User> assignedUserMap;
	private Set<String> reAssignRCCodes;
	private Set<Id> oneTeamInActiveUserIds;

	public JobAssignmentQueue(Map<Id, User_MaskModel> userMaskMapByUserId) {
		System.debug('Debug -- JobAssignmentQueue ::');
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
			List<Opportunity> updatedOpportunity = getObjectList();
			if(!updatedOpportunity.isEmpty()) {
				setOwnership(updatedOpportunity);
				executeUpdate(updatedOpportunity, false);
			}
	        if(doChainJob && GlobalUtility.isApexClassConfigActive('LeadAssignmentQueue')) {
	        	System.enqueueJob(new LeadAssignmentQueue(userMaskMapByUserId));
	        }
		} catch(Exception ex) {
			generateLog(ex.getMessage());
		}
        // Re-assign one team Job Owner
        //assignOneTeamShareBackToOwner(updatedOpportunity);
	}

	public void generateLog(String errorMsg) {
		generateLog(userMaskMapByUserId.values(), 'JobAssignmentQueue', errorMsg);
	}

	public override List<SObject> getObjectList() {
		List<Opportunity> opportunityList = new List<Opportunity>();
		if(reAssignRCCodes == null) {
			opportunityList = [SELECT Id, OwnerId, StageName, Previous_RC_Code__c FROM Opportunity 
				WHERE OwnerId IN :userMaskMapByUserId.keySet()];
		} else {
			opportunityList = [SELECT Id, OwnerId, StageName, Previous_RC_Code__c FROM Opportunity 
				WHERE OwnerId IN :userMaskMapByUserId.keySet() OR Previous_RC_Code__c IN :reAssignRCCodes];
		}
		
		return opportunityList;
	}

	@TestVisible
	private void setOwnership(List<SObject> sObjectList){
		for(Opportunity eachOpp : (List<Opportunity>) sObjectList) {
			if(eachOpp.Previous_RC_Code__c != null && teamMapByRc.containsKey(eachOpp.Previous_RC_Code__c)) {
				if(setReAssignUser(eachOpp)) {
					continue;
				}
			}
			if(eachOpp.OwnerId != null && userMaskMapByUserId.containsKey(eachOpp.OwnerId)) {
				setAssignNewUser(eachOpp);
			}
		}
	}

	private Boolean setReAssignUser(Opportunity eachOpp) {
		Boolean isReAssignOwner = false;
		Team_Structure__c eachTeam = teamMapByRc.get(eachOpp.Previous_RC_Code__c);
		if(userMaskMapByUserId.containsKey(eachTeam.OwnerId)) {
			User_MaskModel userMask = userMaskMapByUserId.get(eachTeam.OwnerId);
			if(userMask.isChangeToActive || userMask.isChangeRCCode) {
				eachOpp.OwnerId 			= userMask.userId;
				eachOpp.Previous_RC_Code__c = null;
				if(assignedUserMap.containsKey(userMask.userId) && !assignedUserMap.get(userMask.userId).User_Extension__r.isEmpty()) {
					eachOpp.Current_Owner_Extension__c   = assignedUserMap.get(userMask.userId).User_Extension__r[0].Id;
				}
				isReAssignOwner = true;
			}
		}
		return isReAssignOwner;
	}

	private void setAssignNewUser(Opportunity eachOpp) {
		User_MaskModel userMask = userMaskMapByUserId.get(eachOpp.OwnerId);
		String oldProfileName = userMask.getProfileName();
		User assignedUser;
		if(userMask.isChangeToInactive || userMask.isChangeRCCode) {
			// RBS Re-Assign Job Owner
			if(GlobalConstants.PROFILE_RBS_SET.contains(oldProfileName)) {
				if(oldProfileName == GlobalConstants.RBS_RM_ABM || oldProfileName == GlobalConstants.RBS_RM_BAR) {
					assignedUser = getAssignedUserWhenOneLevelUp(teamMapByRc, assignedUserMap, userMask.userObj);
				}
				if(assignedUser == null) {
					assignedUser = getAdminFromUserMask(userMask, userAdmin, assignedUserMap);
				}
			} else {
				/* One Team Re-Assign Job Owner
				if(userMask.isChangeToInactive) {
					oneTeamInActiveUserIds.add(eachOpp.OwnerId);
				}*/
			}
		}

		if(assignedUser != null) {
			eachOpp.OwnerId 			= assignedUser.Id;
			eachOpp.Previous_RC_Code__c = userMask.previousRCCode;
			if(assignedUserMap.containsKey(assignedUser.Id) && !assignedUserMap.get(assignedUser.Id).User_Extension__r.isEmpty()) {
				eachOpp.Current_Owner_Extension__c   = assignedUserMap.get(assignedUser.Id).User_Extension__r[0].Id;
			}
		}
	}

	/*public static void assignOneTeamShareBackToOwner(List<Opportunity> opportunityList){
        // CR099 for temporary use for oneteam 
        // Create by charnun.t on 25 Feb 2018
        Map<Id,Id> accountIdMapUserId = new Map<Id,Id>();
        Map<Id, AccountTeamMember> accountIdMapAccountTeam = new Map<Id, AccountTeamMember>();
        
        List<AccountTeamMember> mapAccountTeamMember = [SELECT Id, AccountId, Account.OwnerId, Account.Owner.AH_RC_Code__c, Account.Owner.NH_RC_Code__c, Account.Owner.RC_Code__c, Account.Owner.Employee_ID__c, UserId, CreatedById, LastModifiedById FROM AccountTeamMember WHERE UserId IN:oneTeamInActiveUserIds];
        if(!mapAccountTeamMember.isEmpty()){
            for(AccountTeamMember eachAccountTeamMember : mapAccountTeamMember.values()){
                if(eachAccountTeamMember.UserId != eachAccountTeamMember.Account.OwnerId){
                    accountIdMapUserId.put(eachAccountTeamMember.AccountId, eachAccountTeamMember.Account.OwnerId);
                    accountIdMapAccountTeam.put(eachAccountTeamMember.AccountId, eachAccountTeamMember);
                }
            }
        }

        List<Opportunity> updateOpportunityReassign = new List<Opportunity>();
        List<String> closedStage = GlobalConstants.OPP_STAGE_CLOSE_JOB;
        // Reassign Opportunity owner to main account owner
        for(Opportunity eachOpp : opportunityList) {
        	if(!GlobalConstants.OPP_STAGE_CLOSE_JOB.contains(eachOpp.StageName)) {
        		eachOpportunityReassign.Port_Pool__c 	= GlobalConstants.PORT;
                eachOpportunityReassign.Ownership__c 	= GlobalConstants.OWNERSHIP_PERMANENT;
        		eachOpportunityReassign.OwnerId 		= // Account OwnerId
                eachOpportunityReassign.Current_Owner_Extension__c = // Account Owner User Extension
                eachOpportunityReassign.Current_Team_Name__c = // Account Owner RC Code
                eachOpportunityReassign.Current_AH_Name__c   = // Account Owner AH RC Code
                eachOpportunityReassign.Current_NH_Name__c 	 = // Account Owner NH RC Code
        		updateOpportunityReassign.add(eachOpportunityReassign);
        	}
        }
        Database.update(updateOpportunityReassign);
    }*/
}