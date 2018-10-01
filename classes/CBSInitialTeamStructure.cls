public without sharing class CBSInitialTeamStructure implements IInitialTeamStructure {
    public static final List<String> segmentList = new List<String>{GlobalConstants.SEGMENT_CB, GlobalConstants.SEGMENT_MB};
    private final Set<String> managerProfile = new Set<String>{GlobalConstants.CBS_TL, GlobalConstants.CBS_TM};
    private final Set<String> profileSet = GlobalConstants.PROFILE_CBS_SET;
    private String RCCode = '';
    Map<String, List<User>> listUsersMapByRCCode;
    Map<String, User> ownerUserMapByRCCode;
    Map<Id, User> userMapById;
    List<Team_Structure__c> listTeamStructure;
    List<Team_Structure__c> updateTeamList;

    public CBSInitialTeamStructure() {
        List<User> listUser = TeamStructure_Service.getUserListFromProfile(profileSet);
        //List<User> listUser = [SELECT Id, RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Province__c, Profile.Name FROM User WHERE Profile.Name IN :profileSet ORDER BY Isactive DESC, LastModifiedDate DESC];
        updateTeamList = new List<Team_Structure__c>();
        listUsersMapByRCCode = TeamStructure_Service.getListUserMapByRCCode(listUser);
        ownerUserMapByRCCode = TeamStructure_Service.getOwnerUserMapByRCCode(listUser, managerProfile);
    }

    public CBSInitialTeamStructure(String RCCode) {
        this.RCCode = RCCode;
        List<User> listUser = TeamStructure_Service.getUserListFromProfile(profileSet, RCCode);
        //List<User> listUser = [SELECT Id, RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Province__c, Profile.Name FROM User WHERE Profile.Name IN :profileSet AND RC_Code__c = :RCCode ORDER BY Isactive DESC, LastModifiedDate DESC];
        updateTeamList = new List<Team_Structure__c>();
        listUsersMapByRCCode = TeamStructure_Service.getListUserMapByRCCode(listUser);
        ownerUserMapByRCCode = TeamStructure_Service.getOwnerUserMapByRCCode(listUser, managerProfile);
    }

    public String getQuery(){
        String query = 'SELECT Id, RC_Code__c, AH_Name__c, AH_Name__r.OwnerId, NH_Name__c, NH_Name__r.OwnerId, Province__c FROM Team_Structure__c';
        query += ' WHERE Acting_Flag__c = false AND Segment__c IN (\'' + String.join(segmentList ,'\',\'') + '\')';
        if(!String.isBlank(RCCode)) {
            query += ' AND RC_Code__c = \'' + RCCode + '\'';
        }
		return query;
	}

    public void calculateInitialTeamStructure(List<Team_Structure__c> listTeamStructure) {
        calculateTeamOwner(listTeamStructure);
        calculateRelatedObject();
    }

    public void calculateTeamOwner(List<Team_Structure__c> listTeamStructure) {
        this.listTeamStructure = listTeamStructure;
        userMapById = TeamStructure_Service.getUserMapById(ownerUserMapByRCCode.values(), listTeamStructure);
        setTeamOwner();
        excuteUpdateTeam();
    }

    public void calculateRelatedObject() {
        DML_Queueable dmlQueue = new DML_Queueable();
        setUserProvince(dmlQueue);
        executeOtherObject(dmlQueue);
    }

    public Boolean excuteUpdateTeam() {
        if(updateTeamList.isEmpty()) return false;

        TriggerHandler.bypass('TeamStructureTriggerHandler');
        update updateTeamList;
        TriggerHandler.clearBypass('TeamStructureTriggerHandler');

        return true;
    }

    public void executeOtherObject(DML_Queueable dmlQueue) {
        System.enqueueJob(dmlQueue);
    }

    public Boolean setTeamOwner() {
        if(listTeamStructure == null || listTeamStructure.isEmpty()) return false;
        User_Admin__c userAdmin = User_Admin__c.getOrgDefaults();
        updateTeamList = TeamStructure_Service.updateInitialTeamOwner(listTeamStructure, ownerUserMapByRCCode, userMapById, userAdmin.CBS_User_ID__c, managerProfile);
        return true;
    }

    public Boolean setUserProvince(DML_Queueable dmlQueue) {
        if(listTeamStructure == null || listTeamStructure.isEmpty()) return false;
        List<User> updateUserList = new List<User>();
        for(Team_Structure__c eachTeam : listTeamStructure) {
            if(listUsersMapByRCCode.containsKey(eachTeam.RC_Code__c)) {
                for(User updateUser : listUsersMapByRCCode.get(eachTeam.RC_Code__c)) {
                    updateUser.Province__c = eachTeam.Province__c;
                    updateUserList.add(updateUser);
                }
            }
        }
        dmlQueue.setDmlList(updateUserList, DML_Queueable.ENUM_OPERATION.UPDATE_OPERATION,'UserTriggerHandler');
        return true;
    }
}