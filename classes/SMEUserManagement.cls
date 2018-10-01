public class SMEUserManagement implements IUserManagement{
	private Map<String, String> mapHierarchy = new Map<String, String>{GlobalConstants.SME_NH=>GlobalConstants.SME_AH,GlobalConstants.SME_AH=>GlobalConstants.SME_TM,GlobalConstants.SME_TM=>GlobalConstants.SME_RM};
    private Map<String, User> mapUserManagerByRcCode = new Map<String, User>();
    private List<String> listEmpoyeeId;
    private Map<String,User> mapExecuteInactiveUserByEmployeeId = new Map<String,User>();
    private Map<String,User> mapExecuteInsertUserByEmployeeId = new Map<String,User>();
    private Map<String,User> mapExecuteUpdateUserByEmployeeId = new Map<String,User>();
    private Map<String,User_Structure__c> mapExecuteUserStructureByEmployeeId = new Map<String,User_Structure__c>();
    private final Set<String> managerProfile = new Set<String>{GlobalConstants.SME_NH,GlobalConstants.SME_AH,GlobalConstants.SME_TM};
    private final Set<String> setRmProfile = new Set<String>{GlobalConstants.SME_RM};
    private final Set<String> setTmProfile = new Set<String>{GlobalConstants.SME_TM};
    private final Set<String> setAhProfile = new Set<String>{GlobalConstants.SME_AH};
    private final Set<String> setNhProfile = new Set<String>{GlobalConstants.SME_NH};
    private String currentProfile = GlobalConstants.SME_NH;
    public Boolean isManualExecute = false;

	public SMEUserManagement() {
        mapUserManagerByRcCode = UserManagementService.getAllocatedPromoteDemoteUserManager(managerProfile);
	}

	public SMEUserManagement(String inputRole) {
		currentProfile = inputRole;
        mapUserManagerByRcCode = UserManagementService.getAllocatedPromoteDemoteUserManager(managerProfile);
	}
    
    public SMEUserManagement(String inputRole,List<String> listEmpId){
        currentProfile = inputRole;
        mapUserManagerByRcCode = UserManagementService.getAllocatedPromoteDemoteUserManager(managerProfile);
        isManualExecute = true;
        listEmpoyeeId = listEmpId;
    }

	public String getQuery(){
        Map<String, Job_Code__c> jobCodeMapByName = UserManagementService.getJobCodeMapByName();
		List<String> listJobCode = new List<String>();
        for(String jobCodeName : jobCodeMapByName.keySet()){
            if(currentProfile == jobCodeMapByName.get(jobCodeName).Profile_Name__c){
               listJobCode.add(jobCodeName);
            }
        }
        String query = 'SELECT Id, Name, Team_Name__c, Email__c, First_Name__c, Last_Name__c, Segment__c, RC_Code__c, Job_Code__c, Status__c, AH_RC_Code__c, NH_RC_Code__c, Effective_Date__c, Username__c FROM User_Structure__c WHERE Job_Code__c IN (\'' + String.join(listJobCode,'\',\'') + '\') ';
        if(listEmpoyeeId != null && listEmpoyeeId.size() > 0){
            query = query + ' AND Name IN (\'' + String.join(listEmpoyeeId,'\',\'') + '\') ';
        }
		return query;
	}

    public void calculateUser(List<User_Structure__c> listUserStructure){
        Map<String, User> mapExistingUserByEmpId = UserManagementService.getExistingUserMapByEmpId(listUserStructure);

        for(User_Structure__c eachUserStructure : listUserStructure){
            User existingUser = mapExistingUserByEmpId.get(UserManagementService.formatEmployeeId(eachUserStructure.Name));
            if(isDataChange(existingUser,eachUserStructure) || existingUser == null){
                User_Structure__c updateUserStructure = updateUserStructureInfo(existingUser,eachUserStructure);
                mapExecuteUserStructureByEmployeeId.put(updateUserStructure.Name, updateUserStructure);
            }
            if(isDataChange(existingUser,eachUserStructure) && UserManagementService.doesUserStructureInactive(existingUser,eachUserStructure)){
                User inactiveUser = inactiveUser(mapExistingUserByEmpId,eachUserStructure);
                mapExecuteInactiveUserByEmployeeId.put(inactiveUser.Employee_ID__c, inactiveUser);
                continue;
            }
            if(UserManagementService.isUserNewButInactive(existingUser, eachUserStructure)){
                eachUserStructure.Error_Message__c = 'User is new but inactive';
                mapExecuteUserStructureByEmployeeId.put(eachUserStructure.Name, eachUserStructure);
                continue;
            }
            if(!UserManagementService.validateUserStructure(eachUserStructure,currentProfile)) {
                eachUserStructure.Error_Message__c = 'ValidateUserStructure fail';
                mapExecuteUserStructureByEmployeeId.put(eachUserStructure.Name, eachUserStructure);
                continue;
            }
            UserManagementService.disableActingFlag(eachUserStructure,existingUser,currentProfile);
            if(UserManagementService.skipUpdateUser(existingUser,currentProfile)) {
                eachUserStructure.Error_Message__c = 'Skip update user';
                mapExecuteUserStructureByEmployeeId.put(eachUserStructure.Name, eachUserStructure);
                continue;
            }

            if(existingUser != null){
                User updateUser = updateUser(eachUserStructure,existingUser);
                mapExecuteUpdateUserByEmployeeId.put(updateUser.Employee_ID__c, updateUser);
            }else{
                User newUser = createNewUser(eachUserStructure);
                mapExecuteInsertUserByEmployeeId.put(newUser.Employee_ID__c, newUser);
            }
        }
    }

	public User inactiveUser(Map<String, User> mapExistingUserByEmpId,User_Structure__c userStructure){
		User currentUser = mapExistingUserByEmpId.get(UserManagementService.formatEmployeeId(userStructure.Name));
        currentUser.IsActive = false;
        currentUser.TempInactive__c = false;
        currentUser.Status__c = userStructure.Status__c;
        currentUser.Effective_Date__c = userStructure.Effective_Date__c;
        return currentUser;
	}

    private void setTeamInformation(User newUser,User_Structure__c userStructure){
        newUser.RC_Code__c = userStructure.RC_Code__c;
        if(UserManagementService.getUserRoleFromRcCode(newUser.RC_Code__c) != null) newUser.Team_Name__c = UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c).Name;

        UserManagementService.setTmUserInfomation(currentProfile,setRmProfile,setTmProfile,newUser,mapUserManagerByRcCode);
    }

    private void setAHTeamInformation(User newUser,User_Structure__c userStructure){
        newUser.AH_RC_Code__c = UserManagementService.getUserStructureAhRcCode(userStructure,currentProfile);

        if(UserManagementService.getUserRoleFromRcCode(newUser.AH_RC_Code__c) != null) newUser.Area_Name__c = UserManagementService.getUserRoleFromRcCode(newUser.AH_RC_Code__c).Name;
        
        UserManagementService.setAhUserInfomation(currentProfile,setAhProfile,newUser,mapUserManagerByRcCode);
    }

    private void setNHTeamInformation(User newUser,User_Structure__c userStructure){
        newUser.NH_RC_Code__c = UserManagementService.getUserStructureNhRcCode(userStructure,currentProfile);
        if(UserManagementService.getUserRoleFromRcCode(newUser.NH_RC_Code__c) != null) newUser.Network_Name__c = UserManagementService.getUserRoleFromRcCode(newUser.NH_RC_Code__c).Name;

        UserManagementService.setNhUserInfomation(currentProfile,setNhProfile,newUser,mapUserManagerByRcCode);
    }

    public void setCurrentOppApproval(User newUser,User_Structure__c userStructure){
        UserRole userRole = UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c, userStructure.Job_Code__c);
        if(userRole != null && userRole.Name != GlobalConstants.SME_FRANCHISE && (currentProfile == GlobalConstants.SME_RM || currentProfile == GlobalConstants.SME_TM)){
            if (newUser.AH_RC_Code__c != null && mapUserManagerByRcCode.containsKey(newUser.AH_RC_Code__c)) {
                newUser.Current_Opportunity_Approval__c = mapUserManagerByRcCode.get(newUser.AH_RC_Code__c).Id;
            } else if (newUser.NH_RC_Code__c != null && mapUserManagerByRcCode.containsKey(newUser.NH_RC_Code__c)) {
                newUser.Current_Opportunity_Approval__c = mapUserManagerByRcCode.get(newUser.NH_RC_Code__c).Id;
            }
        }
    }

    public void updateNewCurrentOppApprovalToChildRecord(List<User> listInactiveUser){
        Set<Id> setInactiveNH = new Set<Id>();
        Set<Id> setInactiveAH = new Set<Id>();
        List<User> allChildUpdatedUser = new List<User>();
        for(User eachInactiveUser : listInactiveUser){
            if(eachInactiveUser.Profile.Name == GlobalConstants.SME_NH){
                setInactiveNH.add(eachInactiveUser.Id);
            }else if(eachInactiveUser.Profile.Name == GlobalConstants.SME_AH){
                setInactiveAH.add(eachInactiveUser.Id);
            }
        }
        if(!setInactiveAH.isEmpty()){
            for(User eachAhChildUser : [SELECT Id,ProfileId,Profile.Name,Current_Opportunity_Approval__c,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId FROM User WHERE Current_Opportunity_Approval__c IN :setInactiveAH]){
                if(eachAhChildUser.Profile.Name == GlobalConstants.SME_RM){
                    eachAhChildUser.Current_Opportunity_Approval__c = eachAhChildUser.Manager.Manager.ManagerId;
                }else if(eachAhChildUser.Profile.Name == GlobalConstants.SME_TM){
                    eachAhChildUser.Current_Opportunity_Approval__c = eachAhChildUser.Manager.ManagerId;
                }
                allChildUpdatedUser.add(eachAhChildUser);
            }
        }
        if(!setInactiveNH.isEmpty()){
            for(User eachNhChildUser : [SELECT Id,ProfileId,Profile.Name,Current_Opportunity_Approval__c,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId FROM User WHERE Current_Opportunity_Approval__c IN :setInactiveNH]){
                eachNhChildUser.Current_Opportunity_Approval__c = null;
                allChildUpdatedUser.add(eachNhChildUser);
            }
        }
        if (allChildUpdatedUser.size() > 0){
            Database.update(allChildUpdatedUser,false);
        }
    }
    
    public Boolean isDataChange(User currentUser, User_Structure__c deltaUser){
        if(currentUser != null){
            String userString = currentUser.FirstName + currentUser.LastName + currentUser.Username + currentUser.Email + currentUser.Job_Code__c + currentUser.RC_Code__c + currentUser.AH_RC_Code__c + currentUser.NH_RC_Code__c + currentUser.Segment__c + currentUser.Team_Name__c + currentUser.Status__c + currentUser.Effective_Date__c+'';
            String deltaString = deltaUser.First_Name__c + deltaUser.Last_Name__c + deltaUser.Username__c + deltaUser.Email__c + deltaUser.Job_Code__c + deltaUser.RC_Code__c + deltaUser.AH_RC_Code__c + deltaUser.NH_RC_Code__c + deltaUser.Segment__c + deltaUser.Team_Name__c + deltaUser.Status__c + deltaUser.Effective_Date__c+'';
            if (userString != deltaString){
                return true;
            }
        }
        return false;
    }

    public User updateUser(User_Structure__c userStructure,User existingUser){
        Id userRoleId = UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c, userStructure.Job_Code__c).Id;
        if(userRoleId != existingUser.UserRoleId){
            existingUser.UserRoleId = userRoleId;
        }
        
        if(existingUser.Job_Code__c != userStructure.Job_Code__c) {
            existingUser.Job_Code__c = userStructure.Job_Code__c;
            existingUser.ProfileId = UserManagementService.getProfileIdFromJobCode(userStructure.Job_Code__c);
        }
        if (userStructure.Email__c != null && existingUser.Email != userStructure.Email__c) {
            existingUser.Email = userStructure.Email__c;
        }
        if (userStructure.First_Name__c != null && existingUser.FirstName != userStructure.First_Name__c) {
            existingUser.FirstName = userStructure.First_Name__c;
        }
        if (userStructure.Last_Name__c != null && existingUser.LastName != userStructure.Last_Name__c) {
            existingUser.LastName = userStructure.Last_Name__c;
        }
        if (userStructure.Username__c != null && existingUser.Username != userStructure.Username__c) {
            existingUser.Username = userStructure.Username__c;
        }
        if (existingUser.Segment__c != userStructure.Segment__c) {
            existingUser.Segment__c = userStructure.Segment__c;
        }
        if(isDataChange(existingUser,userStructure) && UserManagementService.doesUserStructureActive(existingUser, userStructure)){
            existingUser.IsActive = true;
        }
        if(existingUser.Status__c != userStructure.Status__c){
            existingUser.Status__c = userStructure.Status__c;
        }
        if(existingUser.Effective_Date__c != userStructure.Effective_Date__c){
            existingUser.Effective_Date__c = userStructure.Effective_Date__c;
        }
        existingUser.TempInactive__c = false;

        setTeamInformation(existingUser,userStructure);
        setAHTeamInformation(existingUser,userStructure);
        setNHTeamInformation(existingUser,userStructure);
        setCurrentOppApproval(existingUser,userStructure);
        assignManager(existingUser);

        return existingUser;
    }

	public User createNewUser(User_Structure__c userStructure){
		User newUser = UserManagementService.createUserFromUserStructure(userStructure);
        newUser.Alias = userStructure.First_Name__c.substring(0,1) + userStructure.Last_Name__c.substring(0, ((String)userStructure.Last_Name__c).length() < 4 ? ((String)userStructure.Last_Name__c).length() : 4);
        setTeamInformation(newUser,userStructure);
        setAHTeamInformation(newUser,userStructure);
        setNHTeamInformation(newUser,userStructure);
        setCurrentOppApproval(newUser,userStructure);
        assignManager(newUser);

        return newUser;
	}

    public Boolean executeUpdateInactiveUser(){
        if(mapExecuteInactiveUserByEmployeeId.values().isEmpty()) return false;

        TriggerHandler.bypass('UserTriggerHandler');
        updateNewCurrentOppApprovalToChildRecord(mapExecuteInactiveUserByEmployeeId.values());
        List<User> litsUpdateUser = mapExecuteInactiveUserByEmployeeId.values();
        List<Database.SaveResult> results = Database.update(litsUpdateUser, false);
        UserManagementService.manageUserStructure(results,litsUpdateUser,mapExecuteUserStructureByEmployeeId);
        return true;
    }

    public Boolean executeUpdateActiveUser(){
        if(mapExecuteUpdateUserByEmployeeId.values().isEmpty()) return false;
        
        TriggerHandler.bypass('UserTriggerHandler');
        List<User> litsUpdateUser = mapExecuteUpdateUserByEmployeeId.values();
        List<Database.SaveResult> results = Database.update(litsUpdateUser, false);
        UserManagementService.manageUserStructure(results,litsUpdateUser,mapExecuteUserStructureByEmployeeId);
        return true;
    }

    public Boolean executeInsertActiveUser(){
        if(mapExecuteInsertUserByEmployeeId.values().isEmpty()) return false;
        
        TriggerHandler.bypass('UserTriggerHandler');
        List<User> litsInsertUser = mapExecuteInsertUserByEmployeeId.values();
        List<Database.SaveResult> results = Database.insert(litsInsertUser, false);
        UserManagementService.manageUserStructure(results,litsInsertUser,mapExecuteUserStructureByEmployeeId);
        return true;
    }

    public void executeOtherObject(DML_Queueable dmlQueue){
        System.enqueueJob(dmlQueue);
    }

    public Boolean prepareUpsertUserExtension(DML_Queueable dmlQueue){
        List<User_Extension__c> listExecuteUserExtension = new List<User_Extension__c>();
        if(!mapExecuteInsertUserByEmployeeId.values().isEmpty()){
            for(User eachUser : mapExecuteInsertUserByEmployeeId.values()){
                User_Extension__c userEx = createUserExtension(eachUser);
                listExecuteUserExtension.add(userEx);
            }
        }

        if(!mapExecuteUpdateUserByEmployeeId.values().isEmpty()){
            for(User eachUser : mapExecuteUpdateUserByEmployeeId.values()){
                User_Extension__c userEx = createUserExtension(eachUser);
                listExecuteUserExtension.add(userEx);
            }
        }

        if(!mapExecuteInactiveUserByEmployeeId.values().isEmpty()){
            for(User eachUser : mapExecuteInactiveUserByEmployeeId.values()){
                User_Extension__c userEx = new User_Extension__c();
                userEx.External_ID__c = UserManagementService.formatEmployeeId(eachUser.Employee_ID__c);
                userEx.OwnerId = UserManagementService.getManagerId(currentProfile,eachUser,mapUserManagerByRcCode,setRmProfile,setTmProfile,setAhProfile);
                listExecuteUserExtension.add(userEx);
            }
        }

        if(listExecuteUserExtension.isEmpty()) return false;

        dmlQueue.setDmlList(listExecuteUserExtension, User_Extension__c.Fields.External_ID__c, DML_Queueable.ENUM_OPERATION.UPSERT_OPERATION);
        return true;
    }

    public Boolean prepareUpdateUserStructure(DML_Queueable dmlQueue){
        if(mapExecuteUserStructureByEmployeeId.values().isEmpty()) return false;

        dmlQueue.setDmlList(mapExecuteUserStructureByEmployeeId.values(), DML_Queueable.ENUM_OPERATION.UPDATE_OPERATION);
        return true;
    }

    public Boolean executeInsertUserPermission(){
        List<PermissionSetAssignment> permissionAssignments = new List<PermissionSetAssignment>();
        permissionAssignments.addAll(UserManagementService.createUserPermission(mapExecuteInsertUserByEmployeeId.values()));

        if(permissionAssignments.isEmpty()) return false;
        
        Database.insert(permissionAssignments,false);

        return true;
    }

    public User_Extension__c createUserExtension(User newUser){
        return UserManagementService.createUserExtension(newUser);
    }

    private void assignManager(User currentUser){
        currentUser.ManagerId = UserManagementService.getManagerId(currentProfile,currentUser,mapUserManagerByRcCode,setRmProfile,setTmProfile,setAhProfile);
    }

    public User_Structure__c updateUserStructureInfo(User existingUser,User_Structure__c userStructure){
        return UserManagementService.updateUserStructureInfo(existingUser,userStructure);
    }

    public Boolean hasNextRole(){
        if(mapHierarchy.containsKey(currentProfile)){
            return true;
        }
        return false;
    }

    public void calculateNextRole(){
        if(hasNextRole() && !isManualExecute){
            String nextRole = mapHierarchy.get(currentProfile);
            IUserManagement nextUserRoleClass = new SMEUserManagement(nextRole);
            Database.executeBatch(new UserStructure_Batch(nextUserRoleClass));
        }
    }
}