public without sharing class UserManagementService {
    private static Map<String, UserRole> userRoleMapByDevName;
    private static Map<String, Job_Code__c> jobCodeMapByName;
	
    private static Boolean validateUserStructure(User_Structure__c userStructure,UserRole userRole,Id profileId){
        if(userRole == null || profileId == null || userStructure.First_Name__c == null || userStructure.Last_Name__c == null || userStructure.Email__c == null){
            return false;
        }
        return true;
    }

    private static Boolean validateUserStructure(User_Structure__c userStructure,Id profileId){
        if(profileId == null || userStructure.First_Name__c == null || userStructure.Last_Name__c == null || userStructure.Email__c == null){
            return false;
        }
        return true;
    }

    public static String formatEmployeeId(String employeeId) {
    	 if(Test.isRunningTest()){
            return employeeId;
        }else{
            employeeId = '00000' + employeeId;
            return employeeId.substring(employeeId.length() - 6, employeeId.length());
        }
    }

    public static String getUserStructureAhRcCode(User_Structure__c userStructure,String currentProfile){
        String userStructureAhRcCode;
        if (currentProfile == GlobalConstants.SME_RM || currentProfile == GlobalConstants.RBS_RM_ABM || currentProfile == GlobalConstants.RBS_RM_BAR || currentProfile == GlobalConstants.AF_RM) {
            userStructureAhRcCode = userStructure.AH_RC_Code__c;
        } else if (currentProfile == GlobalConstants.SME_TM || currentProfile == GlobalConstants.RBS_TM || currentProfile == GlobalConstants.AF_TM) {
            userStructureAhRcCode = userStructure.AH_RC_Code__c;
        } else if (currentProfile == GlobalConstants.SME_AH || currentProfile == GlobalConstants.RBS_AH || currentProfile == GlobalConstants.AF_AH) {
            userStructureAhRcCode = userStructure.RC_Code__c;
        } else if (currentProfile == GlobalConstants.SME_NH || currentProfile == GlobalConstants.RBS_NH || currentProfile == GlobalConstants.AF_NH) {
            userStructureAhRcCode = null;
        }
        return userStructureAhRcCode;
    }

    public static String getUserStructureNhRcCode(User_Structure__c userStructure,String currentProfile){
        String userStructureNhRcCode;
        if (currentProfile == GlobalConstants.SME_RM || currentProfile == GlobalConstants.RBS_RM_ABM || currentProfile == GlobalConstants.RBS_RM_BAR || currentProfile == GlobalConstants.AF_RM) {
            userStructureNhRcCode = userStructure.NH_RC_Code__c;
        } else if (currentProfile == GlobalConstants.SME_TM || currentProfile == GlobalConstants.RBS_TM || currentProfile == GlobalConstants.AF_TM) {
            userStructureNhRcCode = userStructure.NH_RC_Code__c;
        } else if (currentProfile == GlobalConstants.SME_AH || currentProfile == GlobalConstants.RBS_AH || currentProfile == GlobalConstants.AF_AH) {
            userStructureNhRcCode = userStructure.NH_RC_Code__c;
        } else if (currentProfile == GlobalConstants.SME_NH || currentProfile == GlobalConstants.RBS_NH || currentProfile == GlobalConstants.AF_NH) {
            userStructureNhRcCode = userStructure.RC_Code__c;
        }
        return userStructureNhRcCode;
    }

    public static Map<String, UserRole> getUserRoleMapByDevName(){
        if(userRoleMapByDevName != null) return userRoleMapByDevName;

        userRoleMapByDevName = new Map<String, UserRole>();
        for(UserRole eachUserRole : [SELECT Id, DeveloperName, Name FROM UserRole]) {
            userRoleMapByDevName.put(eachUserRole.DeveloperName, eachUserRole);
        }
        return userRoleMapByDevName;
    }

    public static Map<String, User> getExistingUserMapByEmpId(List<User_Structure__c> listUserStructure){
        Set<String> setEmpId = new Set<String>();
        for(User_Structure__c eachUserStructure : listUserStructure){
            setEmpId.add(eachUserStructure.Name);
        }

        Map<String, User> mapExistingUserByEmpId = new Map<String, User>();
        List<User> listExistingUser = [SELECT Id, Name, EmployeeNickname__c, MobilePhone, IsActive, Acting_Flag__c, Employee_ID__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Job_Code__c, ManagerId, Manager.RC_Code__c, Manager.Manager.RC_Code__c, Manager.Manager.Manager.RC_Code__c, Manager.Job_Code__c, Manager.Manager.Job_Code__c, Manager.Manager.Manager.Job_Code__c, UserRole.DeveloperName, Profile.Name, Email, Username, FirstName, LastName, Segment__c, Status__c, Effective_Date__c, Team_Name__c, Area_Name__c, Network_Name__c FROM User WHERE Employee_ID__c IN :setEmpId];
        for(User eachUser : listExistingUser) {
            mapExistingUserByEmpId.put(UserManagementService.formatEmployeeId(eachUser.Employee_ID__c), eachUser);
        }
        return mapExistingUserByEmpId;
    }

    public static Map<String, User> getUserManagerByRcCode(Set<String> managerProfile){
        Map<String, User> tempMapUserManagerByRcCode = new Map<String, User>();
        List<User> listUserManager = [SELECT Id, Name, EmployeeNickname__c, MobilePhone, IsActive, Acting_Flag__c, Employee_ID__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Job_Code__c, ManagerId, UserRole.DeveloperName, Profile.Name, Email, Username, FirstName, LastName, Segment__c, Status__c, Effective_Date__c, Team_Name__c, Area_Name__c, Network_Name__c FROM User WHERE Profile.Name IN :managerProfile AND IsActive = true ORDER BY LastModifiedDate DESC];
        for(User eachUser : listUserManager) {
            if(!tempMapUserManagerByRcCode.containsKey(eachUser.RC_Code__c)) tempMapUserManagerByRcCode.put(eachUser.RC_Code__c, eachUser);
        }
        return tempMapUserManagerByRcCode;
    }

    public static Map<String, User> getAllocatedPromoteDemoteUserManager(Set<String> managerProfile){
        Map<String, User> mapAllocatedUserManagerByRcCode = new Map<String, User>();
        Map<String, User> mapCurrentUserManagerByRcCode = new Map<String, User>();
        Map<String, User_Structure__c> mapUserStructureManagerByEmpId = new Map<String, User_Structure__c>();
        
        Map<String, Job_Code__c> jobCodeMapByName = UserManagementService.getJobCodeMapByName();
        List<String> listJobCodeManager = new List<String>();
        for(Job_Code__c eachJobCode : jobCodeMapByName.values()){
            if(managerProfile.contains(eachJobCode.Profile_Name__c)){
                listJobCodeManager.add(eachJobCode.Name);
            }
        }
        mapCurrentUserManagerByRcCode = UserManagementService.getUserManagerByRcCode(managerProfile);

        List<User_Structure__c> listUserStructureManager = [SELECT Id,Name,RC_Code__c FROM User_Structure__c WHERE Job_Code__c IN :listJobCodeManager];
        for(User_Structure__c eachUserStructureManager : listUserStructureManager){
            mapUserStructureManagerByEmpId.put(eachUserStructureManager.Name, eachUserStructureManager);
        }

        for(String rcCode : mapCurrentUserManagerByRcCode.keySet()){
            User manager = mapCurrentUserManagerByRcCode.get(rcCode);
            if(mapUserStructureManagerByEmpId.containsKey(manager.Employee_ID__c)){
                User_Structure__c userStructureManagger = mapUserStructureManagerByEmpId.get(manager.Employee_ID__c);
                mapAllocatedUserManagerByRcCode.put(userStructureManagger.RC_Code__c, manager);
            }
        }

        return mapAllocatedUserManagerByRcCode;
    }

    public static Map<String, Job_Code__c> getJobCodeMapByName(){
        if(jobCodeMapByName != null) return jobCodeMapByName;
        
        jobCodeMapByName = new Map<String, Job_Code__c>();
        for(Job_Code__c jobCode : [SELECT Profile_Name__c, Name FROM Job_Code__c]) {
            jobCodeMapByName.put(jobCode.Name, jobCode);
        }
        return jobCodeMapByName;
    }

    public static UserRole getUserRoleFromRcCode(String rcCode){
        return getUserRoleFromRcCode(rcCode,null);
    }

    public static UserRole getUserRoleFromRcCode(String rcCode, String jobCode){
        Map<String, UserRole> tempUserRoleMapByDevName = UserManagementService.getUserRoleMapByDevName();
        Map<String, Job_Code__c> tempJobCodeMapByName = UserManagementService.getJobCodeMapByName();
        String roleDevName = null;
        if (jobCode != null && tempJobCodeMapByName.containsKey(jobCode)
            && (tempJobCodeMapByName.get(jobCode).Profile_Name__c == GlobalConstants.SME_RM
                || tempJobCodeMapByName.get(jobCode).Profile_Name__c == GlobalConstants.RBS_RM_ABM
                || tempJobCodeMapByName.get(jobCode).Profile_Name__c == GlobalConstants.RBS_RM_BAR)) {
            roleDevName = 'RCRM' + rcCode;
        } else {
            roleDevName = 'RC' + rcCode;
        }
        if (roleDevName != null && tempUserRoleMapByDevName.containsKey(roleDevName)) {
            return tempUserRoleMapByDevName.get(roleDevName);
        }
        return null;
    }

    public static Boolean validateUserStructure(User_Structure__c userStructure,String currentProfile){
        Map<String, Job_Code__c> tempJobCodeMapByName = UserManagementService.getJobCodeMapByName();
        Map<String, Profile> profileMapByName = GlobalUtility.getProfileMapNameKey();

        UserRole userRole = UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c, userStructure.Job_Code__c);
        Job_Code__c jobCode = tempJobCodeMapByName.get(userStructure.Job_Code__c);
        Id profileId = null;
        if(jobCode!=null) profileId = profileMapByName.get(jobCode.Profile_Name__c).Id;
        if(GlobalConstants.PROFILE_AF_SET.contains(currentProfile)){
            return UserManagementService.validateUserStructure(userStructure,profileId);
        }else{
            return UserManagementService.validateUserStructure(userStructure,userRole,profileId);
        }
    }

    public static void disableActingFlag(User_Structure__c userStructure, User currentUser ,String currentProfile){
        String userStructureRcCode = userStructure.RC_Code__c;
        String userStructureAhRcCode = UserManagementService.getUserStructureAhRcCode(userStructure,currentProfile);
        String userStructureNhRcCode = UserManagementService.getUserStructureNhRcCode(userStructure,currentProfile);

        if (currentUser != null && currentUser.Acting_Flag__c == true && userStructure.Job_Code__c != null && userStructure.RC_Code__c != null 
            && currentUser.Job_Code__c == userStructure.Job_Code__c 
            && currentUser.RC_Code__c == userStructureRcCode 
            && currentUser.AH_RC_Code__c == userStructureAhRcCode 
            && currentUser.NH_RC_Code__c == userStructureNhRcCode) {
            currentUser.Acting_Flag__c = false;
        }
    }

    public static Boolean doesUserStructureInactive(User currentUser,User_Structure__c userStructure){
        if(userStructure.Effective_Date__c != null && userStructure.Effective_Date__c <= System.today()) {
            if(currentUser != null && currentUser.IsActive && userStructure.Status__c != null && userStructure.Status__c == 'I') {
                return true;
            }
        }
        return false;
    }

    public static Boolean doesUserStructureActive(User currentUser,User_Structure__c userStructure){
        if(userStructure.Effective_Date__c != null && userStructure.Effective_Date__c <= System.today()) {
            if(currentUser != null && !currentUser.IsActive && userStructure.Status__c != null && userStructure.Status__c == 'A') {
                return true;
            }
        }
        return false;
    }

    public static Id getProfileIdFromJobCode(String jobCode) {
        Map<String, Profile> profileMapByName = GlobalUtility.getProfileMapNameKey();
        Map<String, Job_Code__c> tempJobCodeMapByName = UserManagementService.getJobCodeMapByName();
        if(jobCodeMapByName.containsKey(jobCode) && profileMapByName.containsKey(jobCodeMapByName.get(jobCode).Profile_Name__c)){
            return profileMapByName.get(jobCodeMapByName.get(jobCode).Profile_Name__c).Id;
        }
        return null;
    }

    public static Boolean skipUpdateUser(User currentUser,String currentProfile){
        if(currentUser == null) return false;
        if(currentUser.Acting_Flag__c)return true;
        return false;
    }

    public static List<PermissionSetAssignment> createUserPermission(List<User> listActiveUser){
        List<PermissionSetAssignment> permissionAssignments = new List<PermissionSetAssignment>();
        System_Settings__c systemSetting = System_Settings__c.getOrgDefaults();
        String permissionSetId = systemSetting.FSCPermissionSetId__c;

        if(!listActiveUser.isEmpty() && systemSetting.FSCPermissionSetId__c != null){
            for(User eachUser : listActiveUser){
                permissionAssignments.add(new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = eachUser.Id));
            }
        }

        return permissionAssignments;
    }

    public static User createUserFromUserStructure(User_Structure__c userStructure){
        User newUser = new User();
        newUser.UserPermissionsMarketingUser = true;
        if(UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c, userStructure.Job_Code__c) != null){
            newUser.UserRoleId = UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c, userStructure.Job_Code__c).Id;
        }
        newUser.ProfileId = UserManagementService.getProfileIdFromJobCode(userStructure.Job_Code__c);
        newUser.Employee_ID__c = UserManagementService.formatEmployeeId(userStructure.Name);
        newUser.FirstName = userStructure.First_Name__c;
        newUser.LastName = userStructure.Last_Name__c;
        newUser.Username = userStructure.Username__c;
        newUser.Email = userStructure.Email__c;
        newUser.Job_Code__c = userStructure.Job_Code__c;
        newUser.LanguageLocaleKey = 'th';
        newUser.LocaleSidKey = 'th_TH';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.TimeZoneSidKey = 'Asia/Bangkok';
        newUser.Segment__c = userStructure.Segment__c;
        newUser.IsActive = true;
        newUser.Status__c = userStructure.Status__c;
        newUser.Effective_Date__c = userStructure.Effective_Date__c;
        return newUser;
    }

    public static void setTmUserInfomation(String currentProfile,Set<String> setRmProfile,Set<String> setTmProfile,User newUser,Map<String, User> mapUserManagerByRcCode){
        if(setRmProfile.contains(currentProfile) && mapUserManagerByRcCode.containsKey(newUser.RC_Code__c)) {
            newUser.TM_Employee_ID__c = mapUserManagerByRcCode.get(newUser.RC_Code__c).Employee_ID__c;
            newUser.TM_Name__c = mapUserManagerByRcCode.get(newUser.RC_Code__c).Name;
        }else if(setTmProfile.contains(currentProfile)) {
            newUser.TM_Employee_ID__c = newUser.Employee_ID__c;
            newUser.TM_Name__c = newUser.FirstName + ' ' + newUser.LastName;
        }
    }

    public static void setAhUserInfomation(String currentProfile,Set<String> setAhProfile,User newUser,Map<String, User> mapUserManagerByRcCode){
        if(setAhProfile.contains(currentProfile)) {
            newUser.TM_Employee_ID__c = null;
            newUser.TM_Name__c = null;
            newUser.Team_Name__c = null;
            newUser.AH_Employee_ID__c = newUser.Employee_ID__c;
            newUser.AH_Name__c = newUser.FirstName + ' ' + newUser.LastName;
        }else if(mapUserManagerByRcCode.containsKey(newUser.AH_RC_Code__c)){
            newUser.AH_Employee_ID__c = mapUserManagerByRcCode.get(newUser.AH_RC_Code__c).Employee_ID__c;
            newUser.AH_Name__c = mapUserManagerByRcCode.get(newUser.AH_RC_Code__c).Name;
        }
    }

    public static void setNhUserInfomation(String currentProfile,Set<String> setNhProfile,User newUser,Map<String, User> mapUserManagerByRcCode){
        if(setNhProfile.contains(currentProfile)) {
            newUser.TM_Employee_ID__c = null;
            newUser.TM_Name__c = null;
            newUser.Team_Name__c = null;
            newUser.AH_Employee_ID__c = null;
            newUser.AH_Name__c = null;
            newUser.Area_Name__c = null;
            newUser.NH_Employee_ID__c = newUser.Employee_ID__c;
            newUser.NH_Name__c = newUser.FirstName + ' ' + newUser.LastName;
        }else if(mapUserManagerByRcCode.containsKey(newUser.NH_RC_Code__c)){
            newUser.NH_Employee_ID__c = mapUserManagerByRcCode.get(newUser.NH_RC_Code__c).Employee_ID__c;
            newUser.NH_Name__c = mapUserManagerByRcCode.get(newUser.NH_RC_Code__c).Name;
        }
    }

    public static User_Structure__c updateUserStructureInfo(User existingUser,User_Structure__c userStructure){
        userStructure.IsChangeUserInfo__c = true;
        if(existingUser != null){
            userStructure.Previous_IsActive__c = existingUser.IsActive;
            userStructure.Previous_RC_Code__c = existingUser.RC_Code__c;
            userStructure.Previous_AH_RC_Code__c = existingUser.AH_RC_Code__c;
            userStructure.Previous_NH_RC_Code__c = existingUser.NH_RC_Code__c;
            userStructure.Previous_Job_Code__c = existingUser.Job_Code__c;
        }else{
            userStructure.Previous_IsActive__c = false;
        }

        return userStructure;
    }

    public static Id getManagerId(String currentProfile,User currentUser,Map<String, User> mapUserManagerByRcCode,Set<String> setRmProfile,Set<String> setTmProfile,Set<String> setAhProfile){
        Id managerId;
        if(setRmProfile.contains(currentProfile)){
            if(mapUserManagerByRcCode.containsKey(currentUser.RC_Code__c)){
                managerId = mapUserManagerByRcCode.get(currentUser.RC_Code__c).Id;
            }else if(mapUserManagerByRcCode.containsKey(currentUser.AH_RC_Code__c)){
                managerId = mapUserManagerByRcCode.get(currentUser.AH_RC_Code__c).Id;
            }else if(mapUserManagerByRcCode.containsKey(currentUser.NH_RC_Code__c)){
                managerId = mapUserManagerByRcCode.get(currentUser.NH_RC_Code__c).Id;
            }
        }else if(setTmProfile.contains(currentProfile)){
            if(mapUserManagerByRcCode.containsKey(currentUser.AH_RC_Code__c)){
                managerId = mapUserManagerByRcCode.get(currentUser.AH_RC_Code__c).Id;
            }else if(mapUserManagerByRcCode.containsKey(currentUser.NH_RC_Code__c)){
                managerId = mapUserManagerByRcCode.get(currentUser.NH_RC_Code__c).Id;
            }
        }else if(setAhProfile.contains(currentProfile)){
            if(mapUserManagerByRcCode.containsKey(currentUser.NH_RC_Code__c)){
                managerId = mapUserManagerByRcCode.get(currentUser.NH_RC_Code__c).Id;
            }
        }

        return managerId;
    }

    public static User_Extension__c createUserExtension(User newUser){
        User_Extension__c userExt = new User_Extension__c();
        Sobject tempSObject = userExt;
        tempSObject.put('External_ID__c',UserManagementService.formatEmployeeId(newUser.Employee_ID__c));
        tempSObject.put('Name',newUser.Name);
        tempSObject.put('OwnerId',newUser.Id);
        tempSObject.put('User__c',newUser.Id);
        
        Team_Structure__c teamStructure = new Team_Structure__c(External_ID__c = newUser.RC_Code__c);
        tempSObject.putSObject('Team_Structure__r', teamStructure);
        return (User_Extension__c)tempSObject;
    }

    public static void manageUserStructure(List<Database.SaveResult> results,List<User> litsUser,Map<String,User_Structure__c> mapExecuteUserStructureByEmployeeId){
        Integer index = 0;
        for(Database.SaveResult eachResult : results){
            if(!eachResult.isSuccess()){
                User user = litsUser[index];
                User_Structure__c userStructure = mapExecuteUserStructureByEmployeeId.get(user.Employee_ID__c);
                String errorMessage = '';
                for(Database.Error err : eachResult.getErrors()) {
                    errorMessage = errorMessage + 'Error Msg :'+ String.valueOf(err.getMessage()) +  '\n' ;
                }
                System.debug('executeUpdateInactiveUser errorMessage = '+errorMessage);
                User_Structure__c errUserStructure = new User_Structure__c(Id = userStructure.Id, Error_Message__c = errorMessage);
                mapExecuteUserStructureByEmployeeId.put(user.Employee_ID__c,errUserStructure);
            }
            index++;
        }
    }

    public static Boolean isUserNewButInactive(User user,User_Structure__c userStructure){
        if(user == null && userStructure.Status__c == 'I') return true;
        return false;
    }
}