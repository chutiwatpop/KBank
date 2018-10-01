public class User_Service {
    private static List<UserRole> userRoleList;
    private static Map<String, Job_Code__c> jobCodeMapByName;
    public static Map<Id,User> allUserMap;
    public static Map<Id,User> allUserMapWithId;
    public static Map<Id,User> allOldUserMap;
    public static Map<Id,Profile> allProfileMap;
    public static Map<Id,UserRole> allUserRoleMap;
    public static Map<String,User_Extension__c> userExtensionMapByUserId;
    public static Map<String,Team_Structure__c> teamMapByRC;
    public static Set<Id> filterUserIdSet;
    public static Set<Id> ahIdToUpdateInactiveAfterUpdate;
    public static Set<Id> nhIdToUpdateInactiveAfterUpdate;
    public static Boolean overrideUpdateCurrentOpportunityApproval;
    public static Map<String,User> mapGetAHandNHIdByRCCode;

    public static Map<Id, User> salesUserNotInTriggerMap;
    public static Map<Id, User> salesUserInTriggerMap;
    public static Set<Id> inActiveUserManager;
    public static Map<Id,User> overrideCurrentOppUserMap;
    
    public static void getAHandNHIdByRCCode(){
        mapGetAHandNHIdByRCCode = new Map<String,User>();
        List<User> listOfAHandNHWithRCCode = new List<User>();
        listOfAHandNHWithRCCode = [SELECT Id, RC_Code__c, IsActive FROM User WHERE Profile.Name IN (:GlobalConstants.SME_AH,:GlobalConstants.SME_NH)];
        for(User eachUser : listOfAHandNHWithRCCode){
            mapGetAHandNHIdByRCCode.put(eachUser.RC_Code__c, eachUser);
        }
    }

    public static Map<String, User_Extension__c> getUserExtensionMapByUser() {
        List<User_Extension__c> userExtList = new List<User_Extension__c>();
        userExtList = [SELECT Id, User__c, OwnerId FROM User_Extension__c];
        Map<String, User_Extension__c>  userExtMapByUser = new Map<String, User_Extension__c> ();
        
        for(User_Extension__c eachUserExt : userExtList) {
            userExtMapByUser.put(eachUserExt.User__c, eachUserExt);
        }
        return userExtMapByUser;
    }

    public static Map<String, Team_Structure__c> getAllTeamStructureMapByRC() {
        List<Team_Structure__c> teamStructureList = new List<Team_Structure__c>();
        teamStructureList = [SELECT Id, External_ID__c,RC_Code__C, OwnerId, Segment__c, Name, Type__c,NH_RC_Code__c FROM Team_Structure__c];
        Map<String, Team_Structure__c> allTeamMapByRc = new Map<String, Team_Structure__c>();

        for(Team_Structure__c eachTeam : teamStructureList) {
            allTeamMapByRc.put(eachTeam.RC_Code__C, eachTeam);
        }
        return allTeamMapByRc;
    }

    public static Map<String, Team_Structure__c> getAllTeamStructureMapByRCCBS() {
        List<Team_Structure__c> teamStructureList = new List<Team_Structure__c>();
        teamStructureList = [SELECT Id, External_ID__c,RC_Code__C, OwnerId, Segment__c, Name, Type__c,NH_RC_Code__c FROM Team_Structure__c WHERE Segment__c IN (:GlobalConstants.SEGMENT_CB,:GlobalConstants.SEGMENT_MB)];
        Map<String, Team_Structure__c> allTeamMapByRc = new Map<String, Team_Structure__c>();

        for(Team_Structure__c eachTeam : teamStructureList) {
            allTeamMapByRc.put(eachTeam.RC_Code__C, eachTeam);
        }
        return allTeamMapByRc;
    }

    public static Map<Id,Profile> getAllProfile(){
        if(User_Service.allProfileMap == null){
            allProfileMap = new Map<Id,Profile>([SELECT Id, Name FROM Profile]);
        }
        return User_Service.allProfileMap;
    }

    public static Map<Id,UserRole> getAllUserRole(){
        if(User_Service.allUserRoleMap == null){
            allUserRoleMap = new Map<Id,UserRole>([SELECT Id, Name, DeveloperName FROM UserRole]);
        }
        return User_Service.allUserRoleMap;
    }

    public static Map<Id,User> getAllUserMap(){
        if(User_Service.allUserMap == null || Test.isRunningTest()){
            allUserMap = new Map<Id,User>([SELECT Id,ProfileId,Name,Segment__c,IsActive,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c,Profile.Name,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.IsActive,Manager.Manager.IsActive,Manager.Manager.Manager.IsActive,Manager.Profile.Name,Manager.Manager.Profile.Name,Manager.Manager.Email,Manager.Manager.Manager.Email,Manager.Manager.Manager.Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c,SME_User__c,CBS_User__c,RBS_User__c FROM User]);
        }
        return User_Service.allUserMap;
    }

    public static Map<Id,User> getAllUserMapWithId(Set<Id> userIdSet){
        if(User_Service.allUserMapWithId == null || (User_Service.filterUserIdSet !=null && User_Service.filterUserIdSet != userIdSet) ){
            allUserMapWithId = new Map<Id,User>([SELECT Id,Phone,UserRole.Name,Employee_ID__c,AH_RC_CODE__c,NH_RC_CODE__c,UserRole.DeveloperName,Manager.UserRole.Name,Manager.UserRole.DeveloperName,Manager.Manager.UserRole.Name,Manager.Manager.UserRole.DeveloperName,IsActive,ProfileId,Profile.Name, ManagerId,Manager.Name,Manager.IsActive,Manager.ProfileId,Manager.Profile.Name,Manager.ManagerId,Manager.Manager.Name,Manager.Manager.IsActive,Manager.Manager.ProfileId,Manager.Manager.Profile.Name,RC_Code__c,Manager.Employee_ID__c,Manager.Manager.Employee_ID__c,Segment__c,Manager.Manager.ManagerId,Manager.Manager.Manager.IsActive,Manager.Manager.Manager.Profile.Name,Manager.Manager.Manager.Name FROM User WHERE Id IN:userIdSet]);
            User_Service.filterUserIdSet = userIdSet;
        }
        return User_Service.allUserMapWithId;
    }

    public static Map<Id,User> getAllRMandTMUserMap(){
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id, Profile.Name, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, IsActive, Current_Opportunity_Approval__c FROM User WHERE Profile.Name IN (:GlobalConstants.SME_RM,:GlobalConstants.SME_TM)]);
        if(userMap != null){
            return userMap;    
        }else{
            return new Map<Id,User>();
        }
    }

    public static List<User> getAllRMandTMUserList(){
        List<User> userList = [SELECT Id, Profile.Name, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, IsActive, Current_Opportunity_Approval__c FROM User WHERE Profile.Name IN (:GlobalConstants.SME_RM,:GlobalConstants.SME_TM)];
        
        if(userList != null){
            return userList;    
        }else{
            return new List<User>();
        }
    }

    public static List<User> getAllRMandTMUserListWithInactiveCurrentOpportunityApprover(Set<Id> inactiveUserIds,Set<Id> userRMandTMNotToRecursiveUpdate){
        List<User> userList = [SELECT Id, Profile.Name, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, IsActive, Current_Opportunity_Approval__c FROM User WHERE Profile.Name IN (:GlobalConstants.SME_RM,:GlobalConstants.SME_TM) AND Current_Opportunity_Approval__c IN: inactiveUserIds AND Id NOT IN: userRMandTMNotToRecursiveUpdate];
        
        if(userList != null){
            return userList;    
        }else{
            return new List<User>();
        }
    }

    public static List<User> getAllRMandTMUserListWithActiveAgainCurrentOpportunityApprover(Set<Id> activeUserIds,Set<Id> userRMandTMNotToRecursiveUpdate){
        List<User> userList = [SELECT Id, Profile.Name, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, IsActive, Current_Opportunity_Approval__c FROM User WHERE Profile.Name IN (:GlobalConstants.SME_RM,:GlobalConstants.SME_TM) AND Id NOT IN: userRMandTMNotToRecursiveUpdate];
        
        if(userList != null){
            return userList;    
        }else{
            return new List<User>();
        }
    }

    public static Map<Id,User> isIntegrationUser(SME_Admin__c sa){
        if(sa!=null){
            List<User> integrationUserList = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId() AND Profile.Name = :GlobalConstants.INTEGRATION_USER];
            if(integrationUserList!=null && integrationUserList.size() > 0){
                return new Map<Id,User>(integrationUserList);
            }
        }
        return null;
    }

    public static User getUserInfoWithId(Id userId){
        User queryUser = [SELECT RC_Code__c, Profile.Name, Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId, Manager.IsActive, 
                        Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Manager.Manager.Manager.Manager.IsActive, Manager.Profile.Name, 
                        Manager.Manager.Profile.Name, Manager.Manager.Manager.Profile.Name, Manager.Manager.Manager.Manager.Profile.Name,
                        UserRole.Name, UserRole.DeveloperName, Employee_ID__c, AH_RC_CODE__c, NH_RC_CODE__c, Segment__c 
                        FROM User WHERE Id = :userId];
        return queryUser;
    }

    public static User getUserInfoWithName(String userName){
        User queryUser = [SELECT Name, RC_Code__c, Profile.Name, Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId, Manager.IsActive, 
                        Manager.Manager.IsActive, Manager.Manager.Manager.IsActive, Manager.Manager.Manager.Manager.IsActive, Manager.Profile.Name, 
                        Manager.Manager.Profile.Name, Manager.Manager.Manager.Profile.Name, Manager.Manager.Manager.Manager.Profile.Name,
                        UserRole.Name, UserRole.DeveloperName, Employee_ID__c, AH_RC_CODE__c, NH_RC_CODE__c, Segment__c 
                        FROM User WHERE Name = :userName];
        return queryUser;
    }
    
    public static Map<String,String> queryUserRole(){
        Map<String,String> userRoleMapping = new Map<String,String>();
        Map<Id,String> userRoleCodeMapping = new Map<Id,String>();
        if(User_Service.userRoleList == null){
            userRoleList =[SELECT DeveloperName,Id,ParentRoleId FROM UserRole];
        }
        for(UserRole eachUserRole : User_Service.userRoleList){
            userRoleCodeMapping.put(eachUserRole.Id,eachUserRole.DeveloperName);
        }
        for(UserRole eachUserRole : User_Service.userRoleList){
            userRoleMapping.put(eachUserRole.DeveloperName, userRoleCodeMapping.get(eachUserRole.ParentRoleId));
        }
        return userRoleMapping;
    }

    public static Map<Id,User> getUserMapWithId(List<Id> userIdSet){
        Map<Id,User> userMapWithId = new Map<Id,User>();
        List<User> userLists = [SELECT Id, Phone, UserRole.Name, CBS_User__c, SME_User__c, RBS_User__c, Employee_ID__c, AH_RC_CODE__c, NH_RC_CODE__c, UserRole.DeveloperName, Manager.UserRole.Name, Manager.UserRole.DeveloperName, Manager.Manager.UserRole.Name, Manager.Manager.UserRole.DeveloperName, Manager.Manager.Manager.UserRole.DeveloperName, IsActive, ProfileId, Profile.Name, ManagerId, Manager.Name, Manager.IsActive, Manager.ProfileId, Manager.Profile.Name, Manager.ManagerId, Manager.Manager.Name, Manager.Manager.IsActive, Manager.Manager.ProfileId, Manager.Manager.Profile.Name, Manager.Manager.ManagerId, Manager.Manager.Manager.Name, Manager.Manager.Manager.IsActive, Manager.Manager.Manager.ProfileId, Manager.Manager.Manager.Profile.Name, RC_Code__c, Manager.Employee_ID__c, Manager.Manager.Employee_ID__c, Manager.Manager.Manager.Employee_ID__c, Segment__c FROM User WHERE Id IN:userIdSet];
        for(User eachUser : userLists){
            userMapWithId.put(eachUser.Id, eachUser);
        }
        return userMapWithId;
    }

    public static Map<String, Job_Code__c> getJobCodeMapByName(){
        if(jobCodeMapByName != null) return jobCodeMapByName;
        
        jobCodeMapByName = new Map<String, Job_Code__c>();
        for(Job_Code__c jobCode : [SELECT Profile_Name__c, Name FROM Job_Code__c]) {
            jobCodeMapByName.put(jobCode.Name, jobCode);
        }
        return jobCodeMapByName;
    }
}