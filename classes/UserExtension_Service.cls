public class UserExtension_Service {
	private String userExtId;
	private String userObjId;
	private String userObjName;
	private String userObjEmployeeId;
	private String userObjTeam;
    private static User_Extension__c currentUserExtension;
	
    public static Map<Id,User> userMapAll;
	public static Map<String,Id> allTeamMapByRc;
    public static Map<String,Id> allUserExtMapByUser;
    public static Map<Id,User_Extension__c> allUserExtensionMap;
	public static Map<Id,Team_Structure__c> allTeamStructureMap;
	public static List<SObject> updateGlobalList;

	public UserExtension_Service(User_Extension__c userExt) {
		this.userObjId = userExt.User__c;
        this.userObjName = userExt.Name;
        this.userObjEmployeeId = userExt.External_ID__c;
        this.userObjTeam = userExt.Team_Structure__c;
        this.userExtId = userExt.Id;
	}

	public UserExtension_Service(User userObj) {
		this.userObjId = userObj.Id;
        this.userObjName = userObj.Name;
        this.userObjEmployeeId = userObj.Employee_ID__c;
	}

    /**
    Service Get UserExtenison
    **/
    public static Map<Id,User_Extension__c> getAllUserExtension(){
        if(UserExtension_Service.allUserExtensionMap == null){
            allUserExtensionMap = new Map<Id, User_Extension__c>([SELECT Id,User__c,External_ID__c FROM User_Extension__c]);
        }
        return UserExtension_Service.allUserExtensionMap;
    }

	public static Map<Id, User> getAllUserMapByUserExt() {
		Map<Id,User_Extension__c> userExtensionMap = getAllUserExtension();
        Map<Id,User> userMap = User_Service.getAllUserMap();
		Map<Id,User> resultMap = new Map<Id, User>();
		for(User_Extension__c eachUserExt : userExtensionMap.values()) {
			if(eachUserExt.User__c != null && userMap.containsKey(eachUserExt.User__c))
            	resultMap.put(eachUserExt.Id, userMap.get(eachUserExt.User__c));
        }
        return resultMap;
	}

    public static Map<String, Id> getUserExtensionMapByEmpId(Set<String> empIds) {
        Map<String, Id> userExtMapByEmpId = new Map<String, Id>();
        List<User_Extension__c> userExtList = [SELECT Id, External_ID__c FROM User_Extension__c WHERE External_Id__c IN :empIds];
        for(User_Extension__c eachUserExt : userExtList) {
            userExtMapByEmpId.put(eachUserExt.External_ID__c, eachUserExt.Id);
        }
        return userExtMapByEmpId;
    }

	public static Map<String, Id> getUserExtensionMapByUser() {
        Map<String,Id> userExtMapByEmpId = new Map<String,Id> ();
        Map<Id,User_Extension__c> userExtensionMap = getAllUserExtension();
		for(User_Extension__c eachUserExt : userExtensionMap.values()) {
            userExtMapByEmpId.put(eachUserExt.User__c, eachUserExt.Id);
        }
        return userExtMapByEmpId;
	}

    /**
    Future Get UserExtenison
    **/
	@future
	public static void insertUserExtension(String userExtStringList) {
		List<User_Extension__c> userExtList = (List<User_Extension__c>) JSON.deserialize(userExtStringList, List<User_Extension__c>.class);
		insert userExtList;
	}

	@future
	public static void updateUserExtension(String userExtStringList) {
		List<User_Extension__c> userExtList = (List<User_Extension__c>) JSON.deserialize(userExtStringList, List<User_Extension__c>.class);
		update userExtList;
	}

	public static void teamChange(Map<Id, User_Extension__c> userExtMap) {
        List<Event> updateCallRepList = new List<Event>();
        List<Opportunity> updateOppList = new List<SObject>();
        UserExtension_Service.userMapAll = User_Service.getAllUserMap();
        
		// Call Report
		List<Event> callReportUpdateList = [SELECT Id, Created_By_User_Extension__c, Status__c FROM Event WHERE Created_By_User_Extension__c IN :userExtMap.keySet()];
        if(UserExtension_Service.allTeamStructureMap == null) {
        	UserExtension_Service.allTeamStructureMap = TeamStructure_Service.getTeamStructureMap();
        }
        if(!callReportUpdateList.isEmpty()){
            for(Event eachCallReport : callReportUpdateList){
                if(userExtMap.containsKey(eachCallReport.Created_By_User_Extension__c) && eachCallReport.Status__c == GlobalConstants.PLAN) {
                    //eachCallReport.Current_Team_Name__c = userExtMap.get(eachCallReport.Current_Owner_Extension__c).Team_Structure__c;
                    //eachCallReport.Current_AH_Name__c = UserExtension_Service.allTeamStructureMap.get(eachCallReport.Current_Team_Name__c).AH_Name__c;
                    //eachCallReport.Current_NH_Name__c = UserExtension_Service.allTeamStructureMap.get(eachCallReport.Current_Team_Name__c).NH_Name__c;
                    String newTeamId = userExtMap.get(eachCallReport.Created_By_User_Extension__c).Team_Structure__c;
                    if(UserExtension_Service.allTeamStructureMap.containsKey(newTeamId)) {
                        Team_Structure__c eachTeam           = UserExtension_Service.allTeamStructureMap.get(newTeamId);
                        eachCallReport.Branch_Code__c        = eachTeam.Branch_Code__c;
                        eachCallReport.Branch_Name__c        = eachTeam.Branch_Name__c;
                        eachCallReport.Team_RC_Code__c       = eachTeam.RC_Code__c;
                        eachCallReport.Team_Short_Name__c    = eachTeam.RC_Short_Name__c;
                        eachCallReport.AH_RC_Code__c         = eachTeam.AH_RC_Code__c;
                        eachCallReport.AH_Short_Name__c      = eachTeam.AH_Short_Name__c;
                        eachCallReport.NH_RC_Code__c         = eachTeam.NH_RC_Code__c;
                        eachCallReport.NH_Short_Name__c      = eachTeam.NH_Short_Name__c;
                        updateCallRepList.add(eachCallReport);
                    }
                }
            }
        }

        // Opportunity
        List<Opportunity> opportunityUpdateList = new List<Opportunity>();
        opportunityUpdateList = [SELECT Id, Current_Owner_Extension__c, OwnerId, StageName, IsClosed FROM Opportunity WHERE Current_Owner_Extension__c IN :userExtMap.keySet()];    
        if(UserExtension_Service.allTeamStructureMap == null) {
        	UserExtension_Service.allTeamStructureMap = TeamStructure_Service.getTeamStructureMap();
        } 
        if(opportunityUpdateList!=null && opportunityUpdateList.size() > 0){
            for(Opportunity eachOpportunity : opportunityUpdateList){
                Opportunity oldRecord = (Opportunity)Trigger.oldMap.get(eachOpportunity.Id);
                if(userExtMap.containsKey(eachOpportunity.Current_Owner_Extension__c) && !eachOpportunity.IsClosed && (eachOpportunity.StageName!=GlobalConstants.ALL_LOAN_SETUP && eachOpportunity.StageName != GlobalConstants.AUTO_CLOSED && eachOpportunity.StageName != GlobalConstants.CLOSE_LOST)){
                    Id userIdRelatedToOpportunity = eachOpportunity.OwnerId;
                    User userRelatedToOpportunity = userMapAll.get(userIdRelatedToOpportunity);
                    eachOpportunity.Current_Team_Name__c = userExtMap.get(eachOpportunity.Current_Owner_Extension__c).Team_Structure__c;
                    eachOpportunity.Current_AH_Name__c = UserExtension_Service.allTeamStructureMap.get(eachOpportunity.Current_Team_Name__c).AH_Name__c;
                    eachOpportunity.Current_NH_Name__c = UserExtension_Service.allTeamStructureMap.get(eachOpportunity.Current_Team_Name__c).NH_Name__c;
                    updateOppList.add(eachOpportunity);
                }
            }
        }

        //if(updateCallRepList.size() > 0) DB_Service.updateCallReportWithBypass(updateCallRepList);
        TriggerHandler.bypass('EventTriggerHandler');
        Database.update(updateCallRepList, false);
        TriggerHandler.clearBypass('EventTriggerHandler');
        if(updateOppList.size() > 0) DB_Service.updateOpportunityWithBypass(updateOppList);
	}


    // Charnun.T - New Method to support SOLID
    public static Map<Id, User_Extension__c> getUserExtensionFromUserId(List<Id> userIdList){
        return  new Map<Id, User_Extension__c>([SELECT Id,Segment__c, User__c, User__r.Profile.Name, User__r.RBS_User__c, User__r.Segment__c , User__r.IsActive , Employee_ID__c, Team_Structure__c, Team_Structure__r.NH_Name__c, Team_Structure__r.AH_Name__c FROM User_Extension__c WHERE User__c IN: userIdList]);
    }

    public static Map<Id, User_Extension__c> getUserExtensionFromUserExtensionId(List<Id> userExtensionIdList){
        return  new Map<Id, User_Extension__c>([SELECT Id,Segment__c, User__c, User__r.Profile.Name, User__r.RBS_User__c, User__r.Segment__c , User__r.IsActive , Employee_ID__c, Team_Structure__c, Team_Structure__r.NH_Name__c, Team_Structure__r.AH_Name__c FROM User_Extension__c WHERE Id IN: userExtensionIdList]);
    }

    public static Map<String, Id> getUserExtensionIdMapByUserId(List<Id> userIdList){
        Map<String,Id> userExtMapByEmpId = new Map<String,Id> ();
        Map<Id,User_Extension__c> userExtensionMap = getUserExtensionFromUserId(userIdList);
		for(User_Extension__c eachUserExt : userExtensionMap.values()) {
            userExtMapByEmpId.put(eachUserExt.User__c, eachUserExt.Id);
        }
        return userExtMapByEmpId;
	}

    public static Map<Id,User_Extension__c> getUserExtensionMapByUserId(List<Id> userIdList){
        Map<Id,User_Extension__c> userExtMapByEmpId = new Map<Id,User_Extension__c> ();
        Map<Id,User_Extension__c> userExtensionMap = getUserExtensionFromUserId(userIdList);
		for(User_Extension__c eachUserExt : userExtensionMap.values()) {
            userExtMapByEmpId.put(eachUserExt.User__c, eachUserExt);
        }
        return userExtMapByEmpId;
	}

    public static Map<Id,User_Extension__c> getUserExtensionMapById(List<Id> userExtensionIdList){
        Map<Id,User_Extension__c> userExtMapByEmpId = new Map<Id,User_Extension__c> ();
        Map<Id,User_Extension__c> userExtensionMap = getUserExtensionFromUserExtensionId(userExtensionIdList);
        for(User_Extension__c eachUserExt : userExtensionMap.values()) {
            userExtMapByEmpId.put(eachUserExt.Id, eachUserExt);
        }
        return userExtMapByEmpId;
    }

    public static User_Extension__c getUserExtensionFromCurrentUserInfo() {
        if(currentUserExtension == null) {
            List<User_Extension__c> userExtensionList = [SELECT Id, Team_Structure__c, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c, User__r.Profile.Name FROM User_Extension__c WHERE User__c = :UserInfo.getUserId()];
            if(userExtensionList.isEmpty()) {
                currentUserExtension = null;
            } else {
                currentUserExtension = userExtensionList[0];
            }
        }
        return currentUserExtension;
    }
}