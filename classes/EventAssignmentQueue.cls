public without sharing class EventAssignmentQueue extends OwnershipAssignmentManager implements Queueable {
	@TestVisible
	private static Boolean doChainJob = true;

	private Map<Id, User_MaskModel> userMaskMapByUserId;

	private User_Admin__c userAdmin;
	private Map<String, Team_Structure__c> teamMapByRc;
	private Map<Id, User> assignedUserMap;
	private Set<String> reAssignRCCodes;

	public EventAssignmentQueue(Map<Id, User_MaskModel> userMaskMapByUserId) {
		System.debug('Debug -- EventAssignmentQueue ::');
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
        	List<Event> eventList = getObjectList();
			if(!eventList.isEmpty()) {
				setOwnership(eventList);
				System.debug('Debug -- eventList ::'+eventList);
				executeUpdate(eventList, false);
			}
	        if(doChainJob && GlobalUtility.isApexClassConfigActive('OpportunityProductAssignmentQueue')) {
	        	System.enqueueJob(new OpportunityProductAssignmentQueue(userMaskMapByUserId));
	        }
        } catch (Exception ex) {
        	generateLog(ex.getMessage());
        }
	}

	public void generateLog(String errorMsg) {
		generateLog(userMaskMapByUserId.values(), 'EventAssignmentQueue', errorMsg);
	}

	public override List<SObject> getObjectList() {
		List<Event> eventList = new List<Event>();
		if(reAssignRCCodes == null) {
			eventList = [SELECT Id, OwnerId, Previous_RC_Code__c FROM Event 
			WHERE OwnerId IN :userMaskMapByUserId.keySet() AND IsRecurrence = false];		
		} else {
			eventList = [SELECT Id, OwnerId, Previous_RC_Code__c FROM Event 
			WHERE (OwnerId IN :userMaskMapByUserId.keySet() OR Previous_RC_Code__c IN :reAssignRCCodes) AND IsRecurrence = false];		
		}
		return eventList;
	}

	private void setOwnership(List<SObject> sObjectList){
		for(Event eachEvent : (List<Event>) sObjectList) {
			if(eachEvent.Previous_RC_Code__c != null && teamMapByRc.containsKey(eachEvent.Previous_RC_Code__c)) {
				if(setReAssignUser(eachEvent)) {
					continue;
				}
			}
			if(eachEvent.OwnerId != null && userMaskMapByUserId.containsKey(eachEvent.OwnerId)) {
				setAssignNewUser(eachEvent);
			}
		}
	}

	private Boolean setReAssignUser(Event eachEvent) {
		Boolean isReAssignOwner = false;
		Team_Structure__c eachTeam = teamMapByRc.get(eachEvent.Previous_RC_Code__c);
		if(userMaskMapByUserId.containsKey(eachTeam.OwnerId)) {
			User_MaskModel userMask = userMaskMapByUserId.get(eachTeam.OwnerId);
			if(userMask.isChangeToActive || userMask.isChangeRCCode) {
				eachEvent.OwnerId 			  = userMask.userId;
				eachEvent.Previous_RC_Code__c = null;
				if(assignedUserMap.containsKey(userMask.userId) && !assignedUserMap.get(userMask.userId).User_Extension__r.isEmpty()) {
					eachEvent.Created_By_User_Extension__c = assignedUserMap.get(userMask.userId).User_Extension__r[0].Id;
				}
				isReAssignOwner = true;
			}
		}
		return isReAssignOwner;
	}

	private void setAssignNewUser(Event eachEvent) {
		User_MaskModel userMask = userMaskMapByUserId.get(eachEvent.OwnerId);
		String oldProfileName = userMask.getProfileName();
		User assignedUser;

		if(userMask.isChangeToInactive || userMask.isChangeRCCode) {
			if(GlobalConstants.PROFILE_RBS_SET.contains(oldProfileName)) {
				if(oldProfileName == GlobalConstants.RBS_RM_ABM || oldProfileName == GlobalConstants.RBS_RM_BAR) {
					assignedUser = getAssignedUserWhenOneLevelUp(teamMapByRc, assignedUserMap, userMask.userObj);
				}
				if(assignedUser == null) {
					assignedUser = getAdminFromUserMask(userMask, userAdmin, assignedUserMap);
				}
			}
		}

		if(assignedUser != null) {
			eachEvent.OwnerId 			  = assignedUser.Id;
			eachEvent.Previous_RC_Code__c = userMask.previousRCCode;
			if(assignedUserMap.containsKey(assignedUser.Id) && !assignedUserMap.get(assignedUser.Id).User_Extension__r.isEmpty()) {
				eachEvent.Created_By_User_Extension__c = assignedUserMap.get(assignedUser.Id).User_Extension__r[0].Id;
			}
		}
	}
}