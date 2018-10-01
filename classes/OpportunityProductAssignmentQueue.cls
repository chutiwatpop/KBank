public without sharing class OpportunityProductAssignmentQueue extends OwnershipAssignmentManager implements Queueable {
	@TestVisible
	private static Boolean doChainJob = true;
	
	private Map<Id, User_MaskModel> userMaskMapByUserId;

	private User_Admin__c userAdmin;
	private Map<String, Team_Structure__c> teamMapByRc;
	private Map<Id, User> assignedUserMap;
	private Set<String> reAssignRCCodes;

	public OpportunityProductAssignmentQueue(Map<Id, User_MaskModel> userMaskMapByUserId) {
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
			List<OpportunityLineItem> opportunityProductList = getObjectList();
			if(!opportunityProductList.isEmpty()) {
				setOwnership(opportunityProductList);
				executeUpdate(opportunityProductList, false);
			}
			if(doChainJob && Globalutility.isApexClassConfigActive('BudgetAssignmentQueue')) {
				System.enqueueJob(new BudgetAssignmentQueue(userMaskMapByUserId));
			}
        } catch (Exception ex) {
        	generateLog(ex.getMessage());
        }
	}

	public void generateLog(String errorMsg) {
		generateLog(userMaskMapByUserId.values(), 'OpportunityProductAssignmentQueue', errorMsg);
	}

	public override List<SObject> getObjectList() {
		List<OpportunityLineItem> opportunityProductList = new List<OpportunityLineItem>();
		if(reAssignRCCodes == null) {
			opportunityProductList = [SELECT Id, OwnerExtension__c, OwnerExtension__r.User__c, Previous_RC_Code__c FROM OpportunityLineItem 
				WHERE OwnerExtension__r.User__c IN :userMaskMapByUserId.keySet()];
		} else {
			opportunityProductList = [SELECT Id, OwnerExtension__c, OwnerExtension__r.User__c, Previous_RC_Code__c FROM OpportunityLineItem 
				WHERE OwnerExtension__r.User__c IN :userMaskMapByUserId.keySet() OR Previous_RC_Code__c IN :reAssignRCCodes];
		}
		
		return opportunityProductList;
	}

	private void setOwnership(List<SObject> sObjectList){
		for(OpportunityLineItem eachOppProduct : (List<OpportunityLineItem>) sObjectList) {
			if(eachOppProduct.Previous_RC_Code__c != null && teamMapByRc.containsKey(eachOppProduct.Previous_RC_Code__c)) {
				if(setReAssignUser(eachOppProduct)) {
					continue;
				}
			}
			if(eachOppProduct.OwnerExtension__r.User__c != null && userMaskMapByUserId.containsKey(eachOppProduct.OwnerExtension__r.User__c)) {
				setAssignNewUser(eachOppProduct);
			}
		}
	}

	private Boolean setReAssignUser(OpportunityLineItem eachOppProduct) {
		Boolean isReAssignOwner = false;
		Team_Structure__c eachTeam = teamMapByRc.get(eachOppProduct.Previous_RC_Code__c);
		if(userMaskMapByUserId.containsKey(eachTeam.OwnerId)) {
			User_MaskModel userMask = userMaskMapByUserId.get(eachTeam.OwnerId);
			if(userMask.isChangeToActive || userMask.isChangeRCCode) {
				if(assignedUserMap.containsKey(userMask.userId) && !assignedUserMap.get(userMask.userId).User_Extension__r.isEmpty()) {
					eachOppProduct.OwnerExtension__c   = assignedUserMap.get(userMask.userId).User_Extension__r[0].Id;
					eachOppProduct.Previous_RC_Code__c = null;
					isReAssignOwner = true;
				}
			}
		}
		return isReAssignOwner;
	}

	private void setAssignNewUser(OpportunityLineItem eachOppProduct) {
		User_MaskModel userMask = userMaskMapByUserId.get(eachOppProduct.OwnerExtension__r.User__c);
		String oldProfileName = userMask.getProfileName();
		User assignedUser;

		if(userMask.isChangeToInactive || userMask.isChangeRCCode) {
			if(GlobalConstants.PROFILE_RBS_SET.contains(oldProfileName)) {
				if(oldProfileName == GlobalConstants.RBS_RM_ABM || oldProfileName == GlobalConstants.RBS_RM_BAR) {
					assignedUser = getAssignedUserWhenOneLevelUp(teamMapByRc, assignedUserMap, userMask.userObj);
				} else {
					assignedUser = getAdminFromUserMask(userMask, userAdmin, assignedUserMap);
				}
			}
		}

		if(assignedUser != null && !assignedUser.User_Extension__r.isEmpty()) {
			eachOppProduct.OwnerExtension__c   = assignedUser.User_Extension__r[0].Id;
			eachOppProduct.Previous_RC_Code__c = userMask.previousRCCode;
		}
	}
}