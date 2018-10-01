public with sharing virtual class UserManager implements IEventService{
	private static UserManager mUserManager;
	private static User_Admin__c userAdmin;

	public static User_Admin__c getUserAdmin() {
        if(userAdmin == null) {
            userAdmin = User_Admin__c.getOrgDefaults();
        }
        return userAdmin;
    }

	public static UserManager getInstance() {
		if(mUserManager == null) {
			mUserManager = new UserManager();
		}
		return mUserManager;
	}

	public void updateEventTeamHierachy(List<Event> eventList) {
		Team_Structure__c eachTeam = (new TeamStructureSelector()).selectByRCCode(UserService.getCurrentUserInfo().RC_Code__c);
		if(eachTeam != null) {
			for(Event eachEvent : eventList) {
				if(GlobalUtility.getRecordTypeDevNameMapByIdFromSObject('Event').containsKey(eachEvent.RecordTypeId)
					&& GlobalConstants.CALL_PLAN_CALL_REPORT_NEWABLE_SET.contains(GlobalUtility.getRecordTypeDevNameMapByIdFromSObject('Event').get(eachEvent.RecordTypeId))) {
					eachEvent.Branch_Code__c 		= eachTeam.Branch_Code__c;
					eachEvent.Branch_Name__c 		= eachTeam.Branch_Name__c;
					eachEvent.Team_RC_Code__c 		= eachTeam.RC_Code__c;
					eachEvent.Team_Short_Name__c	= eachTeam.RC_Short_Name__c;
					eachEvent.AH_RC_Code__c 		= eachTeam.AH_RC_Code__c;
					eachEvent.AH_Short_Name__c		= eachTeam.AH_Short_Name__c;
					eachEvent.NH_RC_Code__c			= eachTeam.NH_RC_Code__c;
					eachEvent.NH_Short_Name__c		= eachTeam.NH_Short_Name__c;
				}
			}
		}
	}

	public void validateEditPermission(List<Event> eventList) {
		User_Management__c userManagement = User_Management__c.getInstance();
		Set<Id> ownerIds = new Set<Id>();
		for(Event eachEvent : eventList) {
			ownerIds.add(eachEvent.OwnerId);
		}
		Map<Id, User> ownerUserMapById = new Map<Id, User>([SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId FROM User WHERE Id IN :ownerIds]);
		for(Event eachEvent : eventList) {
			if(!userManagement.Allow_Change_to_Activities__c && !isAllowEditUserIds(eachEvent, ownerUserMapById)) {
				eachEvent.addError(Label.Call_No_Access_Right);
			}
		}
	}

	private Boolean isAllowEditUserIds(Event eachEvent, Map<Id, User> ownerUserMapById) {
		User ownerUser = ownerUserMapById.get(eachEvent.OwnerId);
		Set<Id> allowEditUserIds = new Set<Id>();
		allowEditUserIds.add(eachEvent.OwnerId);
		allowEditUserIds.add(ownerUser.ManagerId);
		allowEditUserIds.add(ownerUser.Manager.ManagerId);
		allowEditUserIds.add(ownerUser.Manager.Manager.ManagerId);
		if(allowEditUserIds.contains(UserInfo.getUserId())) {
			return true;
		}

		return false;
	}
}