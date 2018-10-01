global class UserStructureUpdateUser_Batch extends ApplicationLog_Service implements Database.Batchable<sObject>, Database.Stateful {
	
	private static final String CLASS_NAME = 'UserStructureUpdateUser_Batch';

	private Set<Id> hrisDiffIds;
    private Set<Id> hrisInActiveIds;
    private Map<String, User> userMapByNewRoleRC;
    private Map<String, User_MaskModel> userMaskMapByEmpId;
    //
	private Map<Id, User> updatedUser;
	private List<User> newUserList;
	
	private Map<String, Id> profileMapByName;
	private Map<String, String> jobCodeMapByName;

	private Map<String, User> userMapByEmpId;
	private Map<Id, User> oldUserMapById;
	private Map<String, UserRole> userRoleMapByDevName;

    private Map<String, User> currentLevelCrossCheckDemoteUserMapByNewRoleRC;

	private Map<String, Map<Id, User>> userMapByRoleDevName;
	private Set<Id> inActiveUserIds;
	private Set<Id> activeUserIds;
	private Set<String> existUsernameSet;
	private Map<String,CollaborationGroup> mapInsertCollaborationGroupMapByGroupName;
	private Map<String, List<CollaborationGroupMember>> mapListMemberMapByGroupName;
	private List<CollaborationGroupMember> listDeleteMember = new List<CollaborationGroupMember>();

	@TestVisible
    private Integer totalUnused;
    @TestVisible
    private Integer totalActiveUser;
    @TestVisible
    private Integer totalMaxLicense;

    private Map<String, Team_Structure__c> teamMapByRc;
    private Map<String, Id> userExtMapByEmpId;
	private Map<String, User_Extension__c> updateUserExtMap;
	private Map<String, Team_Structure__c> updateTeamMap;

    Boolean isRunSequence;
	String query;

	String batchRole;

	public UserStructureUpdateUser_Batch() {
		initialBatch();
	}

	public UserStructureUpdateUser_Batch(String batchRole) {
		this.batchRole = batchRole;
		initialBatch();
	}

	public UserStructureUpdateUser_Batch(String batchRole, Integer totalActiveUser, Integer totalMaxLicense) {
		this.totalActiveUser = totalActiveUser;
		this.totalMaxLicense = totalMaxLicense;
		this.batchRole = batchRole;
		initialBatch();
	}

	public UserStructureUpdateUser_Batch(Map<String, User_MaskModel> userMaskMap, Map<String, User> userMapByNewRoleRC, Set<Id> hrisDiffSet, Set<Id> hrisInActiveSet) {
		this.userMaskMapByEmpId = userMaskMap;
        this.userMapByNewRoleRC = userMapByNewRoleRC;
        this.hrisDiffIds = hrisDiffSet;
        this.hrisInActiveIds = hrisInActiveSet;
		initialBatch();
	}

	public UserStructureUpdateUser_Batch(String batchRole, Integer totalActiveUser, Integer totalMaxLicense, Map<String, User_MaskModel> userMaskMap, Map<String, User> userMapByNewRoleRC, Set<Id> hrisDiffSet, Set<Id> hrisInActiveSet,Map<String,CollaborationGroup> mapInsertCollaborationGroupMapByGroupName,Map<String, User> previousLevelCrossCheckDemoteUserMapByNewRoleRC) {
		this.userMaskMapByEmpId = userMaskMap;
        this.userMapByNewRoleRC = userMapByNewRoleRC;
        this.hrisDiffIds = hrisDiffSet;
        this.hrisInActiveIds = hrisInActiveSet;
        this.mapInsertCollaborationGroupMapByGroupName = mapInsertCollaborationGroupMapByGroupName;
        this.currentLevelCrossCheckDemoteUserMapByNewRoleRC = previousLevelCrossCheckDemoteUserMapByNewRoleRC;

		this.totalActiveUser = totalActiveUser;
		this.totalMaxLicense = totalMaxLicense;
		this.batchRole = batchRole;
		initialBatch();
	}

	private void initialBatch() {
		existUsernameSet = new Set<String>();
		updateTeamMap = new Map <String, Team_Structure__c>();
		updateUserExtMap = new Map<String, User_Extension__c>();
		inActiveUserIds = new Set<Id>();
		activeUserIds = new Set<Id>();

		userMapByRoleDevName = new Map<String, Map<Id, User>>();
		userMapByEmpId = new Map<String, User>();
		oldUserMapById = new Map<Id, User>();
		
		profileMapByName = new Map<String, Id>();
		jobCodeMapByName = new Map<String, String>();
		userRoleMapByDevName = new Map<String, UserRole>();

        mapListMemberMapByGroupName = new Map<String, List<CollaborationGroupMember>>();
        
		List<String> jobCodeIds = new List<String>();

		if (batchRole == null) {
			batchRole = GlobalConstants.SME_NH;
		}

		if(batchRole == GlobalConstants.SME_NH){
			currentLevelCrossCheckDemoteUserMapByNewRoleRC = new Map<String,User>();
		}
		for(Job_Code__c jobCode : [SELECT Profile_Name__c, Name FROM Job_Code__c]) {
			jobCodeMapByName.put(jobCode.Name, jobCode.Profile_Name__c);
			if(jobCode.Profile_Name__c == batchRole) {
				jobCodeIds.add(jobCode.Name);
			}
				
		}
		//Modified and Added By Nareerat W. INC000000234674 28-Apr-2016 Add field Network_Name, Area_Name.
		for(User eachUser : [SELECT Id, Name, IsActive, Acting_Flag__c, Employee_ID__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Job_Code__c, ManagerId, UserRole.DeveloperName, Profile.Name, Email, Username, FirstName, LastName, Segment__c, Status__c, Effective_Date__c, Team_Name__c, Area_Name__c, Network_Name__c  FROM User]) {
			if(eachUser.Username != null) {
				existUsernameSet.add(eachUser.Username);
			}
			if(eachUser.Employee_ID__c != null) {
				userMapByEmpId.put(formatEmployeeId(eachUser.Employee_ID__c), eachUser);
			}
			if(eachUser.Id != null) {
				oldUserMapById.put(eachUser.Id, eachUser);
			}
			if(eachUser.UserRole.DeveloperName != null) {
				updateUserMapByRoleDevName(eachUser, eachUser.UserRole.DeveloperName);
			}
			// INC000000466338 Include check acting flag for group chatter
			if(eachUser.Acting_Flag__c) {
				updateCurrentLevelCrossCheckDemoteUserMapByNewRoleRC(eachUser.Job_Code__c,eachUser.RC_Code__c,eachUser);
			}
		}

		for(Profile eachProfile : [SELECT Id, Name FROM Profile WHERE Name IN :jobCodeMapByName.values()]) {
			profileMapByName.put(eachProfile.Name, eachProfile.Id);
		}
		for(UserRole eachUserRole : [SELECT Id, DeveloperName, Name FROM UserRole]) {
			userRoleMapByDevName.put(eachUserRole.DeveloperName, eachUserRole);
		}
		if(totalMaxLicense == null) {
			totalMaxLicense = UsersStructureUpdateUsers.getLicenseMaxUser();	
		}
		if(totalActiveUser == null) {
			totalActiveUser = UsersStructureUpdateUsers.getActiveUser();	
		}
		if(Test.isRunningTest()) {
			totalMaxLicense = 2000;
			totalActiveUser = 0;
		}

		totalUnused = totalMaxLicense - totalActiveUser;

		this.query = 'SELECT Id, Name, Team_Name__c, Email__c, First_Name__c, Last_Name__c, Segment__c, RC_Code__c, Job_Code__c, Status__c, AH_RC_Code__c, NH_RC_Code__c, Effective_Date__c, Username__c FROM User_Structure__c WHERE Job_Code__c IN (\'' + String.join(jobCodeIds,'\',\'') + '\')';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<User_Structure__c> deltaUserStructure) {
		Set<String> rcCodes = new Set<String>();
        Set<String> empIds = new Set<String>();

		Map<Id, User_Structure__c> deltaUserStructureMap = new Map<Id, User_Structure__c>(deltaUserStructure);

		updatedUser = new Map<Id, User>();
		newUserList = new List<User>();
		Integer numberUserChange = 0;

		String employeeIdFormatted;
		List<User> inactiveUserList = new List<user>();
		if(mapInsertCollaborationGroupMapByGroupName == null){
			mapInsertCollaborationGroupMapByGroupName = SME_GroupChatterService.getAllCollaborationGroupMapByName();
		}

		// Sort Data to NH > AH > TM > RM
		deltaUserStructureMap = UsersStructureUpdateUsers.sort(deltaUserStructureMap, jobCodeMapByName);

		for(User_Structure__c eachDeltaUser : deltaUserStructureMap.values()) {
			employeeIdFormatted = formatEmployeeId(eachDeltaUser.Name);
			if(eachDeltaUser.RC_Code__c != null) rcCodes.add(eachDeltaUser.RC_Code__c);
			if(eachDeltaUser.Name!= null) empIds.add(employeeIdFormatted);
			
			if(userMapByEmpId.containsKey(employeeIdFormatted)) {
				User eachUser = userMapByEmpId.get(employeeIdFormatted);
				if(checkDataUpdate(eachUser, eachDeltaUser)) {
					// Do Case Inactive User
					if(eachDeltaUser.Effective_Date__c != null && eachDeltaUser.Effective_Date__c <= System.today()) {
						if(eachUser.IsActive && eachDeltaUser.Status__c != null && eachDeltaUser.Status__c == 'I') {
							eachUser.IsActive = false;
							eachUser.Status__c = eachDeltaUser.Status__c;
							eachUser.Effective_Date__c = eachDeltaUser.Effective_Date__c;
							inactiveUserList.add(eachUser);
							numberUserChange--;
							deltaUserStructureMap.remove(eachDeltaUser.Id);
						}
					}
				}
			}else{
				// Do Case Insert New User
				UserRole currentUserRole;
				if(!userMapByEmpId.containsKey(employeeIdFormatted)){
			        currentUserRole = getUserRoleFromCode(eachDeltaUser.RC_Code__c, eachDeltaUser.Job_Code__c);
					User newUser = createNewUser(eachDeltaUser, currentUserRole, numberUserChange);
					if(newUser != null) {
						if(newUser.IsActive){
							numberUserChange++;
						}
						newUserList.add(newUser);
						if(currentUserRole != null) updateUserMapByRoleDevName(newUser, currentUserRole.DeveloperName);
					}
					deltaUserStructureMap.remove(eachDeltaUser.Id);
				}
			}
		}
		if(!inactiveUserList.isEmpty()){
			TriggerHandler.bypass('UserTriggerHandler');
			updateNewCurrentOppApprovalToChildRecord(inactiveUserList);
			update inactiveUserList;
        }

		teamMapByRc = TeamStructure_Service.getTeamStructureMapByRCCodeWithRC(rcCodes);
		userExtMapByEmpId = UserExtension_Service.getUserExtensionMapByEmpId(empIds);

		SME_GroupChatterService.teamMapByRC = TeamStructure_Service.getTeamStructureMapByRCCode();
		if(!inactiveUserList.isEmpty()){
            deleteInactiveUserFromGroup(inactiveUserList);
        }

        // Insert new user
		if(!newUserList.isEmpty()){
			TriggerHandler.bypass('UserTriggerHandler');
            insert newUserList;

	        User_Extension__c userExt;
	        SME_GroupChatterService.allUserMap = new Map<Id,User>([SELECT Id, Name, Status__c, FirstName, LastName, Profile.Name, Employee_ID__c, RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId,Manager.RC_Code__c, Manager.Manager.RC_Code__c, Manager.Manager.Manager.RC_Code__c, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive,Segment__c,NH_RC_Code__c FROM User WHERE Id IN :newUserList]);
	        for(User eachUser : newUserList){
	        	if(eachUser.IsActive) {
		            activeUserIds.add(eachUser.Id);
		        }
	        	// Add new User for replace case
	        	updateCurrentLevelCrossCheckDemoteUserMapByNewRoleRC(eachUser.Job_Code__c,eachUser.RC_Code__c,eachUser);
	        	if(userMapByNewRoleRC!=null) {
					userMapByNewRoleRC.put(eachUser.Job_Code__c + '-' + eachUser.RC_Code__c, eachUser);
	        	}
				if(eachUser.Employee_ID__c != null) {
		            userExt = new User_Extension__c();
		            if(eachUser.IsActive){
		            	userExt.OwnerId = eachUser.Id;
		            }
		            userExt.User__c = eachUser.Id;
		            userExt.Name = (eachUser.FirstName != null) ? (eachUser.FirstName + ' ' + eachUser.LastName) : eachUser.LastName;
		            userExt.External_ID__c = formatEmployeeId(eachUser.Employee_ID__c);

		            if(teamMapByRc.containsKey(eachUser.RC_Code__c)) {
		                userExt.Team_Structure__c = teamMapByRc.get(eachUser.RC_Code__c).Id;
		                if(eachUser.IsActive) {
		                	Team_Structure__c newTeam = new Team_Structure__c(Id = teamMapByRc.get(eachUser.RC_Code__c).Id, OwnerId = eachUser.Id);
			                updateTeamMap.put(eachUser.RC_Code__c, newTeam);
			                
			                String profileName = jobCodeMapByName.get(eachUser.Job_Code__c);
			                if(profileName == GlobalConstants.SME_NH || profileName == GlobalConstants.SME_AH || profileName == GlobalConstants.SME_TM || profileName == GlobalConstants.SME_RM){
				                CollaborationGroup currentGroup = createGroupChatter(eachUser);
				                createNewGroupMember(eachUser,currentGroup);
				                CollaborationGroup allNhGroup = createGroupChatterAllNhGroup(eachUser);
				                createNewGroupMember(eachUser,allNhGroup);
				            }
		                }
		            }
		            updateUserExtMap.put(eachUser.Employee_ID__c, userExt);
	        	}
	        }
        }

        // Do Case Update Active User
		numberUserChange = updateUser(deltaUserStructureMap.values(), numberUserChange);
		
	    for(User eachUser : newUserList) {
	    	String currentTIER = getTIER(eachUser.Job_Code__c);
	    	if(currentTIER == GlobalConstants.SME_RM){
				if(getUserFromCode(eachUser.RC_Code__c) != null){
					eachUser.ManagerId = getUserFromCode(eachUser.RC_Code__c).Id;
				}else if(getUserFromCode(eachUser.AH_RC_Code__c) != null){
					eachUser.ManagerId = getUserFromCode(eachUser.AH_RC_Code__c).Id;
				}else if(getUserFromCode(eachUser.NH_RC_Code__c) != null){
					eachUser.ManagerId = getUserFromCode(eachUser.NH_RC_Code__c).Id;
				}
				
			}else if(currentTIER == GlobalConstants.SME_TM){
				if(getUserFromCode(eachUser.AH_RC_Code__c) != null){
					eachUser.ManagerId = getUserFromCode(eachUser.AH_RC_Code__c).Id;
				}else if(getUserFromCode(eachUser.NH_RC_Code__c) != null){
					eachUser.ManagerId = getUserFromCode(eachUser.NH_RC_Code__c).Id;
				}
			}else if(currentTIER == GlobalConstants.SME_AH){
				if(getUserFromCode(eachUser.NH_RC_Code__c) != null){
					eachUser.ManagerId = getUserFromCode(eachUser.NH_RC_Code__c).Id;
				}
			}
			//eachUser.ManagerId = getNewManagerId(eachUser, getTIER(eachUser.Job_Code__c));
			updatedUser.put(eachUser.Id, eachUser);
		}
		clearance(numberUserChange);
	}

	private void updateNewCurrentOppApprovalToChildRecord(List<User> listInactiveUser){
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
		//allChildUpdatedUser.addAll(listInactiveUser);
		if(!setInactiveAH.isEmpty()){
			//List<User> listChildUserOfAh = [SELECT Id,ProfileId,Profile.Name,Current_Opportunity_Approval__c,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId FROM User WHERE Current_Opportunity_Approval__c IN :setInactiveAH];
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
			//List<User> listChildUserOfNh = [SELECT Id,ProfileId,Profile.Name,Current_Opportunity_Approval__c,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId FROM User WHERE Current_Opportunity_Approval__c IN :setInactiveNH];
			for(User eachNhChildUser : [SELECT Id,ProfileId,Profile.Name,Current_Opportunity_Approval__c,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId FROM User WHERE Current_Opportunity_Approval__c IN :setInactiveNH]){
				eachNhChildUser.Current_Opportunity_Approval__c = null;
				allChildUpdatedUser.add(eachNhChildUser);
			}
		}
		if (allChildUpdatedUser.size() > 0){
			update allChildUpdatedUser;
		}
	}

	private void createNewGroupMember(User newUser, CollaborationGroup currentGroup){
		if(currentGroup != null){
			List<CollaborationGroupMember> listMember = mapListMemberMapByGroupName.get(currentGroup.Name);
			if(listMember == null){
				listMember = new List<CollaborationGroupMember>();
			}
			CollaborationGroupMember newMember = SME_GroupChatterService.createMemberGroup(newUser, currentGroup);
			listMember.add(newMember);
			mapListMemberMapByGroupName.put(currentGroup.Name, listMember);
		}
	}

	private Boolean deleteGroupMember(User deleteUser,String oldSegment,String currentTIER){
		Boolean addDeleteUserSuccess = false;
		CollaborationGroupMember deletedMember;
		CollaborationGroupMember deletedMemberFromAllAhGroup;
		if(currentTIER == GlobalConstants.SME_NH || currentTIER == GlobalConstants.SME_AH || currentTIER == GlobalConstants.SME_TM || currentTIER == GlobalConstants.SME_RM){
			Team_Structure__c teamStructure = SME_GroupChatterService.teamMapByRC.get(deleteUser.NH_RC_Code__c);
			if(teamStructure != null){
				String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(teamStructure.Name, teamStructure.Segment__c);
				CollaborationGroup currentGroup = mapInsertCollaborationGroupMapByGroupName.get(groupName);
				deletedMember = SME_GroupChatterService.deleteMemberGroup(deleteUser,currentGroup);
				if(oldSegment != null && oldSegment != deleteUser.Segment__c){
					deletedMemberFromAllAhGroup = SME_GroupChatterService.deleteMemberFromAllNhGroup(deleteUser,null,oldSegment);
				}
				if(deletedMember != null){
					listDeleteMember.add(deletedMember);
					addDeleteUserSuccess = true;
				}
				if(deletedMemberFromAllAhGroup != null){
					listDeleteMember.add(deletedMemberFromAllAhGroup);
				}
			}
		}
		return addDeleteUserSuccess;
	}

	private CollaborationGroup createGroupChatterAllNhGroup(User user){
		CollaborationGroup groupAllNh;
		if(user.Segment__c != null){
			groupAllNh = mapInsertCollaborationGroupMapByGroupName.get(user.Segment__c);
			if(groupAllNh == null){
	        	groupAllNh = SME_GroupChatterService.createGroupChatter(user.Segment__c);
	        	mapInsertCollaborationGroupMapByGroupName.put(groupAllNh.Name, groupAllNh);
	        	List<CollaborationGroupMember> listManager = SME_GroupChatterService.getListManager(groupAllNh);
	        	mapListMemberMapByGroupName.put(groupAllNh.Name, listManager);
	        }
	    }
        return groupAllNh;
	}

	private CollaborationGroup createGroupChatter(User user){
		CollaborationGroup currentGroup;
		String groupName = '';
		Team_Structure__c teamStructure = SME_GroupChatterService.teamMapByRc.get(user.NH_RC_Code__c);
		if(teamStructure != null && teamStructure.Type__c == 'Network' && !teamStructure.Name.contains('franchise')){
			groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(teamStructure.Name, teamStructure.Segment__c);
			if(groupName != null && !mapInsertCollaborationGroupMapByGroupName.containsKey(groupName)){
				currentGroup = SME_GroupChatterService.createGroupChatter(groupName);
				mapInsertCollaborationGroupMapByGroupName.put(groupName,currentGroup);
				List<CollaborationGroupMember> listManager = SME_GroupChatterService.getListManager(currentGroup);
				mapListMemberMapByGroupName.put(currentGroup.Name, listManager);
			}
		}
		return mapInsertCollaborationGroupMapByGroupName.get(groupName);
	}

	private void deleteInactiveUserFromGroup(List<User> inactiveUserList){
		for(User eachInactiveUser : inactiveUserList){
			deleteGroupMember(eachInactiveUser,eachInactiveUser.Segment__c,eachInactiveUser.Profile.Name);
		}
	}

	private Boolean checkDataUpdate(User user, User_Structure__c deltaUser) {
		String userString = user.FirstName + user.LastName + user.Username + user.Email + user.Job_Code__c + user.RC_Code__c + user.AH_RC_Code__c + user.NH_RC_Code__c + user.Segment__c + user.Team_Name__c + user.Status__c + user.Effective_Date__c+'';
		String deltaString = deltaUser.First_Name__c + deltaUser.Last_Name__c + deltaUser.Username__c + deltaUser.Email__c + deltaUser.Job_Code__c + deltaUser.RC_Code__c + deltaUser.AH_RC_Code__c + deltaUser.NH_RC_Code__c + deltaUser.Segment__c + deltaUser.Team_Name__c + deltaUser.Status__c + deltaUser.Effective_Date__c+'';
		if (userString != deltaString){
			return true;
		}
		return false;
	}

	private User createNewUser(User_Structure__c deltaUser, UserRole currentUserRole, Integer numberUserChange) {
		User newUser = new User();
		newUser.UserPermissionsMarketingUser = true;

        if(currentUserRole != null) {
            newUser.UserRoleId = currentUserRole.Id;
        }else{
        	addLog(CLASS_NAME, 'Cannot Create new User Employee Id : ' + deltaUser.Name + ' No RC Code : ' + deltaUser.RC_Code__c);
            return null;
        }
        if(jobCodeMapByName.containsKey(deltaUser.Job_Code__c) && profileMapByName.containsKey(jobCodeMapByName.get(deltaUser.Job_Code__c))) {
            newUser.ProfileId = profileMapByName.get(jobCodeMapByName.get(deltaUser.Job_Code__c));  
        }else{
            addLog(CLASS_NAME, 'Cannot Create new User Employee Id : ' + deltaUser.Name + ' No Profile From JobCode : ' + deltaUser.Job_Code__c);
            return null;
        }
		newUser.Employee_ID__c = formatEmployeeId(deltaUser.Name);
		if(!isNull(deltaUser.First_Name__c, 'First_Name__c', deltaUser.Name)) {
			newUser.FirstName = deltaUser.First_Name__c;
		}else{
			return null;
		}
		if(!isNull(deltaUser.Last_Name__c, 'Last_Name__c', deltaUser.Name)) {
			newUser.LastName = deltaUser.Last_Name__c;
		} else {
			return null;
		}
		if(!isNull(deltaUser.Username__c, 'Username__c', deltaUser.Name)) {
			newUser.Username = deltaUser.Username__c;
			if(existUsernameSet.contains(newUser.Username)) {
				addLog(CLASS_NAME, 'Cannot Create new User Employee Id : ' + deltaUser.Name + ' Duplicate Username : ' + newUser.Username);
				return null;
			}
		}else{
			return null;
		}
		if(!isNull(deltaUser.Email__c, 'Email__c', deltaUser.Name)) {
			newUser.Email = deltaUser.Email__c;
		}else{
			return null;
		}
		
		newUser.Job_Code__c = deltaUser.Job_Code__c;
		newUser.Alias = deltaUser.First_Name__c.substring(0,1) + deltaUser.Last_Name__c.substring(0, ((String)deltaUser.Last_Name__c).length() < 4 ? ((String)deltaUser.Last_Name__c).length() : 4);
		newUser.LanguageLocaleKey = 'th';
    	newUser.LocaleSidKey = 'th_TH';
    	newUser.EmailEncodingKey = 'UTF-8';
    	newUser.TimeZoneSidKey = 'Asia/Bangkok';
		newUser.Segment__c = deltaUser.Segment__c;
		newUser.Team_Name__c = deltaUser.Team_Name__c;

		String currentTIER = getTIER(deltaUser.Job_Code__c);
		UsersStructureUpdateUsers userStructureModel = new UsersStructureUpdateUsers(deltaUser, currentTIER);

		//TM Employee ID, TM Name (based on RC code)
		newUser.RC_Code__c = userStructureModel.rcCode;
		// Job_Code__c = ME4A  => RM
		if (newUser.RC_Code__c != null) {
			newUser.Team_Name__c = getUserRoleFromCode(newUser.RC_Code__c) != null ? getUserRoleFromCode(newUser.RC_Code__c).Name : null;
			if(currentTIER == GlobalConstants.SME_RM) {
				newUser.TM_Employee_ID__c = getUserFromCode(newUser.RC_Code__c) != null ? getUserFromCode(newUser.RC_Code__c).Employee_ID__c : null;
				newUser.TM_Name__c = getUserFromCode(newUser.RC_Code__c) != null ? getUserFromCode(newUser.RC_Code__c).Name : null;
			}else if(currentTIER == GlobalConstants.SME_TM) {
				newUser.TM_Employee_ID__c = newUser.Employee_ID__c;
				newUser.TM_Name__c = newUser.FirstName + ' ' + newUser.LastName;
			}
			
		}

		//AH Employee ID, AH Name (based on AH RC Code)
		newUser.AH_RC_Code__c = userStructureModel.ahRcCode;
		if (newUser.AH_RC_Code__c != null) {
			newUser.Area_Name__c = getUserRoleFromCode(newUser.AH_RC_Code__c) != null ? getUserRoleFromCode(newUser.AH_RC_Code__c).Name : null; 
			if(currentTIER == GlobalConstants.SME_AH) {
				newUser.AH_Employee_ID__c = newUser.Employee_ID__c;
				newUser.AH_Name__c = newUser.FirstName + ' ' + newUser.LastName;
			}else{
				newUser.AH_Employee_ID__c = getUserFromCode(newUser.AH_RC_Code__c) != null ? getUserFromCode(newUser.AH_RC_Code__c).Employee_ID__c : null;
				newUser.AH_Name__c = getUserFromCode(newUser.AH_RC_Code__c) != null ? getUserFromCode(newUser.AH_RC_Code__c).Name : null;	
			}
				
		}
		
		//NH Employee ID, NH Name (based on NH RC Code)
		newUser.NH_RC_Code__c = userStructureModel.nhRcCode;
		if (newUser.NH_RC_Code__c != null) {
			newUser.Network_Name__c = getUserRoleFromCode(newUser.NH_RC_Code__c) != null ? getUserRoleFromCode(newUser.NH_RC_Code__c).Name : null;
			if(currentTIER == GlobalConstants.SME_NH) {
				newUser.NH_Employee_ID__c = newUser.Employee_ID__c;
				newUser.NH_Name__c = newUser.FirstName + ' ' + newUser.LastName;
			}else{
				newUser.NH_Employee_ID__c = getUserFromCode(newUser.NH_RC_Code__c) != null ? getUserFromCode(newUser.NH_RC_Code__c).Employee_ID__c : null;
				newUser.NH_Name__c = getUserFromCode(newUser.NH_RC_Code__c) != null ? getUserFromCode(newUser.NH_RC_Code__c).Name : null;
			}
		}
		newUser.IsActive = false;
		newUser.Status__c = deltaUser.Status__c;
		newUser.Effective_Date__c = deltaUser.Effective_Date__c;
		if(newUser.Effective_Date__c <= System.today()) {
			if(newUser.Status__c == 'A') {
				if(totalActiveUser + numberUserChange + 1 > totalMaxLicense){
					addLog(CLASS_NAME, 'License already exceed : Cannot new User Employee ' + newUser.Employee_ID__c);
				}else{
					newUser.IsActive = true;
				}
			}
		}
		newUser.Current_Opportunity_Approval__c = getCurrentOppApproval(currentUserRole,currentTIER,newUser);
		return newUser;
	}

	private Integer updateUser(List<User_Structure__c> userStructureList, Integer numberUserChange) {
		SME_GroupChatterService.allOldUserMap = oldUserMapById;
		SME_GroupChatterService.mapCollaborationGroupMapByName = null;
		SME_GroupChatterService.mapAllGroupMembersByGroupIdAndMemberId = null;
		SME_GroupChatterService.teamMapByRC = TeamStructure_Service.getTeamStructureMapByRCCode();
		
		String oldSegment;
		Boolean isModifiedGroupMember = false;
		Boolean addDeleteUserSuccess= false;
		Boolean addUserSuccess= false;
		Boolean isUserBecomeActive = false;
		Boolean isUpdateCrossCheckMap = true;

		for (User_Structure__c eachDeltaUser : userStructureList) {
			oldSegment = null;
			isModifiedGroupMember = false;
			addDeleteUserSuccess = false;
			addUserSuccess = false;
			isUserBecomeActive = false;
			isUpdateCrossCheckMap = true;

			if (userMapByEmpId.containsKey(formatEmployeeId(eachDeltaUser.Name))) {
				User eachUser = userMapByEmpId.get(formatEmployeeId(eachDeltaUser.Name));
				// Check Role
				String currentTIER = getTIER(eachDeltaUser.Job_Code__c);
				if (currentTIER == null) {
					addLog(CLASS_NAME, 'Cannot Update User Employee Id : ' + eachDeltaUser.Name + ' Invalid Job Code : ' + eachDeltaUser.Job_Code__c);
					continue;
				}

				UsersStructureUpdateUsers userStructureModel = new UsersStructureUpdateUsers(eachDeltaUser, currentTIER);

				if(eachDeltaUser.Status__c == 'I' && !eachUser.IsActive){
					isUpdateCrossCheckMap = false;
				}
				
				// Check acting flag
				if(eachUser.Acting_Flag__c == true && eachDeltaUser.Job_Code__c != null && eachDeltaUser.RC_Code__c != null && 
					(eachUser.Job_Code__c != eachDeltaUser.Job_Code__c || eachUser.RC_Code__c != userStructureModel.rcCode ||
					 eachUser.AH_RC_Code__c != userStructureModel.ahRcCode || eachUser.NH_RC_Code__c != userStructureModel.nhRcCode)
					){
					if(isUpdateCrossCheckMap){
						updateCurrentLevelCrossCheckDemoteUserMapByNewRoleRC(eachUser.Job_Code__c,eachUser.RC_Code__c,eachUser); // INC000000466338 change key in Map for acting user
					}
					continue;
				}
				UserRole currentUserRole = getUserRoleFromCode(eachDeltaUser.RC_Code__c, eachDeltaUser.Job_Code__c);
 				if(currentUserRole == null) {
					addLog(CLASS_NAME, 'Cannot Update User Employee Id : ' + eachDeltaUser.Name + ' No RC Code : ' + eachUser.RC_Code__c);
					continue;
				}
				if(eachUser.Job_Code__c != eachDeltaUser.Job_Code__c) {
					eachUser.Job_Code__c = eachDeltaUser.Job_Code__c;

					if(profileMapByName.containsKey(jobCodeMapByName.get(eachDeltaUser.Job_Code__c))) {
						eachUser.ProfileId = profileMapByName.get(jobCodeMapByName.get(eachDeltaUser.Job_Code__c));
					}else{
						addLog(CLASS_NAME, 'Cannot Update User Employee Id : ' + eachDeltaUser.Name + ' No Profile From JobCode : ' + eachDeltaUser.Job_Code__c);
						continue;
					}
				}

				if(isUpdateCrossCheckMap){
					updateCurrentLevelCrossCheckDemoteUserMapByNewRoleRC(eachDeltaUser.Job_Code__c,userStructureModel.rcCode,eachUser);
				}
				if (eachUser.Acting_Flag__c == true && eachDeltaUser.Job_Code__c != null && eachDeltaUser.RC_Code__c != null && 
					eachUser.Job_Code__c == eachDeltaUser.Job_Code__c && 
					eachUser.RC_Code__c == userStructureModel.rcCode && 
					eachUser.AH_RC_Code__c == userStructureModel.ahRcCode && 
					eachUser.NH_RC_Code__c == userStructureModel.nhRcCode) {
					eachUser.Acting_Flag__c = false;
				}

				User_Extension__c userExt;
	            if(eachUser.RC_Code__c != userStructureModel.rcCode || eachUser.FirstName != eachDeltaUser.First_Name__c || eachUser.LastName != eachDeltaUser.Last_Name__c) {
	                userExt = new User_Extension__c(
	                    Id = userExtMapByEmpId.get(eachUser.Employee_ID__c)
	                );
	                if(teamMapByRc.containsKey(eachDeltaUser.RC_Code__c)) {
	                	userExt.Team_Structure__c = teamMapByRc.get(eachDeltaUser.RC_Code__c).Id;
	                }
	                userExt.Name = (eachDeltaUser.First_Name__c != null) ? (eachDeltaUser.First_Name__c + ' ' + eachDeltaUser.Last_Name__c) : eachDeltaUser.Last_Name__c;
	                userExt.External_ID__c = formatEmployeeId(eachUser.Employee_ID__c);
	                updateUserExtMap.put(eachUser.Employee_ID__c, userExt);
	            }
				if (eachDeltaUser.Email__c != null && eachUser.Email != eachDeltaUser.Email__c) {
					eachUser.Email = eachDeltaUser.Email__c;
				}
				if (eachDeltaUser.First_Name__c != null && eachUser.FirstName != eachDeltaUser.First_Name__c) {
					eachUser.FirstName = eachDeltaUser.First_Name__c;
				}
				if (eachDeltaUser.Last_Name__c != null && eachUser.LastName != eachDeltaUser.Last_Name__c) {
					eachUser.LastName = eachDeltaUser.Last_Name__c;
				}
				if (eachDeltaUser.Username__c != null && eachUser.Username != eachDeltaUser.Username__c) {
					eachUser.Username = eachDeltaUser.Username__c;
				}
				if (eachUser.Segment__c != eachDeltaUser.Segment__c) {
					oldSegment = eachUser.Segment__c;
					eachUser.Segment__c = eachDeltaUser.Segment__c;
				}
				if (eachUser.Team_Name__c != eachDeltaUser.Team_Name__c) {
					eachUser.Team_Name__c = eachDeltaUser.Team_Name__c;
				}

				eachUser.RC_Code__c = userStructureModel.rcCode;
				if (currentTIER == GlobalConstants.SME_RM) {
					eachUser.TM_Employee_ID__c = getUserFromCode(userStructureModel.rcCode) != null ? getUserFromCode(userStructureModel.rcCode).Employee_ID__c : null;
					eachUser.TM_Name__c = getUserFromCode(userStructureModel.rcCode) != null ? getUserFromCode(userStructureModel.rcCode).Name : null;
				} else if (currentTIER == GlobalConstants.SME_TM) {
					eachUser.TM_Employee_ID__c = eachUser.Employee_ID__c;
					eachUser.TM_Name__c = eachUser.FirstName + ' ' + eachUser.LastName;
				}

				if (eachUser.AH_RC_Code__c != userStructureModel.ahRcCode) {
					eachUser.AH_RC_Code__c = userStructureModel.ahRcCode;
					eachUser.Area_Name__c = getUserRoleFromCode(userStructureModel.ahRcCode) != null ? getUserRoleFromCode(userStructureModel.ahRcCode).Name : null;
				} else {
				//Added By Nareerat W. INC000000234674 28-Apr-2016.
				//Code for case BU change Role label and RoleName not change, should be update Area Name at User Detail.
					if(userStructureModel.ahRcCode != null){
						UserRole role = getUserRoleFromCode(userStructureModel.ahRcCode);
						if(role != null){
							if(eachUser.Area_Name__c != role.Name) eachUser.Area_Name__c = role.Name;
						}
					}
				}

				if(currentTIER == GlobalConstants.SME_AH) {
					eachUser.TM_Employee_ID__c = null;
					eachUser.TM_Name__c = null;
					eachUser.AH_Employee_ID__c = eachUser.Employee_ID__c;
					eachUser.AH_Name__c = eachUser.Name;
				}else if(currentTIER != GlobalConstants.SME_NH) {
					eachUser.AH_Employee_ID__c = getUserFromCode(userStructureModel.ahRcCode) != null ? getUserFromCode(userStructureModel.ahRcCode).Employee_ID__c : null;
					eachUser.AH_Name__c = getUserFromCode(userStructureModel.ahRcCode) != null ? getUserFromCode(userStructureModel.ahRcCode).Name : null;
				} 
				//End Added By Nareerat W. INC000000234674 28-Apr-2016.

				if(eachDeltaUser.Effective_Date__c <= System.today() && eachDeltaUser.Status__c == 'I' && eachUser.IsActive){
					isModifiedGroupMember = true;
					addDeleteUserSuccess = deleteGroupMember(eachUser,eachUser.Segment__c,currentTIER);
				}else if(eachDeltaUser.Effective_Date__c <= System.today() && eachDeltaUser.Status__c == 'A' && !eachUser.IsActive){
					isUserBecomeActive = true;
				}else if(eachDeltaUser.Effective_Date__c > System.today() && eachDeltaUser.Status__c == 'A' && !eachUser.IsActive){
					isModifiedGroupMember = true;
				}

				if (eachUser.NH_RC_Code__c != userStructureModel.nhRcCode) {
					if(!isModifiedGroupMember && !isUserBecomeActive){
						addDeleteUserSuccess = deleteGroupMember(eachUser,oldSegment,currentTIER);
					}
					eachUser.NH_RC_Code__c = userStructureModel.nhRcCode;	
					// For CR011
					//NH Employee ID, NH Name (based on NH RC Code)
					eachUser.Network_Name__c = getUserRoleFromCode(userStructureModel.nhRcCode) != null ? getUserRoleFromCode(userStructureModel.nhRcCode).Name : null;
					if (currentTIER == GlobalConstants.SME_NH) {
						eachUser.NH_Employee_ID__c = eachUser.Employee_ID__c;
						eachUser.NH_Name__c = eachUser.Name;
					} else {
						eachUser.NH_Employee_ID__c = getUserFromCode(userStructureModel.nhRcCode) != null ? getUserFromCode(userStructureModel.nhRcCode).Employee_ID__c : null;
						eachUser.NH_Name__c = getUserFromCode(userStructureModel.nhRcCode) != null ? getUserFromCode(userStructureModel.nhRcCode).Name : null;
					}

					if(!isModifiedGroupMember && !isUserBecomeActive){
						if(eachUser.Profile.Name == GlobalConstants.SME_NH || eachUser.Profile.Name == GlobalConstants.SME_AH || eachUser.Profile.Name == GlobalConstants.SME_TM || eachUser.Profile.Name == GlobalConstants.SME_RM){
			                CollaborationGroup currentGroup = createGroupChatter(eachUser);
			                if(currentGroup != null){
			                	createNewGroupMember(eachUser,currentGroup);
			                }
			                if(oldSegment != null && oldSegment != eachDeltaUser.Segment__c){
				                CollaborationGroup allNhGroup = createGroupChatterAllNhGroup(eachUser);
				                if(allNhGroup != null){
				                	createNewGroupMember(eachUser,allNhGroup);
				                }
				            }
			                addUserSuccess = true;
			            }
					}
					isModifiedGroupMember = true;
				} else {
				//Added By Nareerat W. INC000000234674 28-Apr-2016.
				//Code for case BU change Role label and RoleName not change, should be update Network Name at User Detail.                   
					if(userStructureModel.nhRcCode != null){
						UserRole role = getUserRoleFromCode(userStructureModel.nhRcCode);
						if(role != null){
							if(eachUser.Network_Name__c != role.Name) eachUser.Network_Name__c = role.Name;
						}
					}								
				}
				eachUser.NH_RC_Code__c = userStructureModel.nhRcCode;
				eachUser.Network_Name__c = getUserRoleFromCode(userStructureModel.nhRcCode) != null ? getUserRoleFromCode(userStructureModel.nhRcCode).Name : null;
				if (currentTIER == GlobalConstants.SME_NH) {
					eachUser.AH_Employee_ID__c = null;
					eachUser.AH_Name__c = null;
					eachUser.TM_Employee_ID__c = null;
					eachUser.TM_Name__c = null;
					eachUser.NH_Employee_ID__c = eachUser.Employee_ID__c;
					eachUser.NH_Name__c = eachUser.Name;
				} else {
					eachUser.NH_Employee_ID__c = getUserFromCode(userStructureModel.nhRcCode) != null ? getUserFromCode(userStructureModel.nhRcCode).Employee_ID__c : null;
					eachUser.NH_Name__c = getUserFromCode(userStructureModel.nhRcCode) != null ? getUserFromCode(userStructureModel.nhRcCode).Name : null;
				}
				//End Added By Nareerat W. INC000000234674 28-Apr-2016.
				
				if(eachDeltaUser.Effective_Date__c <= System.today() && eachDeltaUser.Status__c == 'A' && !eachUser.IsActive && isUserBecomeActive){
					if(eachUser.Profile.Name == GlobalConstants.SME_NH || eachUser.Profile.Name == GlobalConstants.SME_AH || eachUser.Profile.Name == GlobalConstants.SME_TM || eachUser.Profile.Name == GlobalConstants.SME_RM){
		                CollaborationGroup currentGroup = createGroupChatter(eachUser);
		                createNewGroupMember(eachUser,currentGroup);
		                CollaborationGroup allNhGroup = createGroupChatterAllNhGroup(eachUser);
		                createNewGroupMember(eachUser,allNhGroup);
		            }
				}

				eachUser.Status__c = eachDeltaUser.Status__c;
				eachUser.Effective_Date__c = eachDeltaUser.Effective_Date__c;
					
				if (eachDeltaUser.Effective_Date__c <= System.today()) {
					if (eachDeltaUser.Status__c == 'A' && !eachUser.IsActive) {
						if(totalActiveUser + numberUserChange + 1 > totalMaxLicense){
							addLog(CLASS_NAME, 'License already exceed : Cannot Activate ' + eachUser.Employee_ID__c);
						} else {
							eachUser.IsActive = true;
							updateCurrentLevelCrossCheckDemoteUserMapByNewRoleRC(eachDeltaUser.Job_Code__c,userStructureModel.rcCode,eachUser);
							numberUserChange++;
							activeUserIds.add(eachUser.Id);
						}
					} else if (eachDeltaUser.Status__c == 'I' && eachUser.IsActive) {
						eachUser.IsActive = false;
						numberUserChange--;
						inActiveUserIds.add(eachUser.Id);
					}
					if(currentUserRole != null) updateUserMapByRoleDevName(eachUser, currentUserRole.DeveloperName);
				}
				if(eachUser.IsActive) {
					if(teamMapByRc.containsKey(eachUser.RC_Code__c)) {
	                	Team_Structure__c newTeam = new Team_Structure__c(Id = teamMapByRc.get(eachUser.RC_Code__c).Id, OwnerId = eachUser.Id);
		                updateTeamMap.put(eachUser.RC_Code__c, newTeam);
	                }
	                if(updateUserExtMap.containsKey(eachUser.Employee_ID__c)) {
	                	userExt = updateUserExtMap.get(eachUser.Employee_ID__c);
	                	userExt.OwnerId = eachUser.Id;
	                	userExt.External_ID__c = formatEmployeeId(eachUser.Employee_ID__c);
	                	updateUserExtMap.put(eachUser.Employee_ID__c, userExt);
	                } else {
	                	userExt = new User_Extension__c(
	                    	Id = userExtMapByEmpId.get(eachUser.Employee_ID__c),
	                    	OwnerId = eachUser.Id,
	                    	External_ID__c = formatEmployeeId(eachUser.Employee_ID__c)
	                	);
	                	updateUserExtMap.put(eachUser.Employee_ID__c, userExt);
	                }
                }
				if (currentUserRole != null) {
					if (currentUserRole.Id != eachUser.UserRoleId) {
						eachUser.UserRoleId = currentUserRole.Id;
					}
				}
				 //Get New ManagerId
				if (eachUser.IsActive && currentTIER != GlobalConstants.SME_NH) {
					if(currentTIER == GlobalConstants.SME_RM){
						if(getUserFromCode(userStructureModel.rcCode) != null){
							eachUser.ManagerId = getUserFromCode(userStructureModel.rcCode).Id;
						}else if(getUserFromCode(userStructureModel.ahRcCode) != null){
							eachUser.ManagerId = getUserFromCode(userStructureModel.ahRcCode).Id;
						}else if(getUserFromCode(userStructureModel.nhRcCode) != null){
							eachUser.ManagerId = getUserFromCode(userStructureModel.nhRcCode).Id;
						}
					}else if(currentTIER == GlobalConstants.SME_TM){
						if(getUserFromCode(userStructureModel.ahRcCode) != null){
							eachUser.ManagerId = getUserFromCode(userStructureModel.ahRcCode).Id;
						}else if(getUserFromCode(userStructureModel.nhRcCode) != null){
							eachUser.ManagerId = getUserFromCode(userStructureModel.nhRcCode).Id;
						}
					}else if(currentTIER == GlobalConstants.SME_AH){
						if(getUserFromCode(userStructureModel.nhRcCode) != null){
							eachUser.ManagerId = getUserFromCode(userStructureModel.nhRcCode).Id;
						}
					}
					//eachUser.ManagerId = getNewManagerId(eachUser, currentTIER);
					eachUser.Current_Opportunity_Approval__c = getCurrentOppApproval(currentUserRole,currentTIER,eachUser);
				} 
				updatedUser.put(eachUser.Id, eachUser);
			}
		}
		return numberUserChange;
	}

	private Boolean isNull(String valueToCheck, String valueName, String employeeId) {
		if (valueToCheck == null) {
			addLog(CLASS_NAME, 'Cannot Create new User Employee Id : ' + employeeId + valueName + ' = null');
			return true;
		} else {
			return false;
		}
	}

	private Id getCurrentOppApproval(UserRole currentUserRole,String currentTIER,User user){
		Id newManagerId;
		if(currentUserRole != null && currentUserRole.Name != 'แฟรนไชส์' && (currentTIER == GlobalConstants.SME_RM || currentTIER == GlobalConstants.SME_TM)){
			if (user.AH_RC_Code__c != null && getUserFromCode(user.AH_RC_Code__c, user) != null) {
                newManagerId = getUserFromCode(user.AH_RC_Code__c, user).Id;
            } else if (user.NH_RC_Code__c != null && getUserFromCode(user.NH_RC_Code__c, user) != null) {
                newManagerId = getUserFromCode(user.NH_RC_Code__c, user).Id;
            }
		}
		return newManagerId;
	}

	private void updateUserMapByRoleDevName(User eachUser, String roleDevName) {
		if (userMapByRoleDevName.get(roleDevName) == null) {
			userMapByRoleDevName.put(roleDevName, new Map<Id, User>{eachUser.Id => eachUser});
		} else {
			userMapByRoleDevName.get(roleDevName).put(eachUser.Id, eachUser);
		}
	}

	private UserRole getUserRoleFromCode(String rcCode) {
		return getUserRoleFromCode(rcCode, null);
	}

	private UserRole getUserRoleFromCode(String rcCode, String jobCode) {
		String roleDevName = null;
		if (jobCodeMapByName.get(jobCode) == GlobalConstants.SME_RM) {
			roleDevName = 'RCRM' + rcCode;
		} else {
			roleDevName = 'RC' + rcCode;
		}
        if (roleDevName != null && userRoleMapByDevName.containsKey(roleDevName)) {
        	return userRoleMapByDevName.get(roleDevName);
        }
        return null;
    }

    private User getUserFromCode(String rcCode) {
		String roleDevName = 'RC' + rcCode;
        if (userMapByRoleDevName.containsKey(roleDevName)) {
        	for (User user : userMapByRoleDevName.get(roleDevName).values()) {
        		if(currentLevelCrossCheckDemoteUserMapByNewRoleRC.containsKey(roleDevName)){
        			User returnUser = currentLevelCrossCheckDemoteUserMapByNewRoleRC.get(roleDevName);
        			returnUser = userMapByEmpId.get(formatEmployeeId(returnUser.Employee_ID__c));
        			if (returnUser.IsActive) return returnUser;
        		}
        	}
        }
        return null;
    }

    // Case cannot return ownId
	private User getUserFromCode(String rcCode, User usr) {
		String roleDevName = 'RC' + rcCode;
        if (userMapByRoleDevName.containsKey(roleDevName)) {
        	for (User eachUser : userMapByRoleDevName.get(roleDevName).values()) {
        		if (eachUser.IsActive && usr.Id != eachUser.Id) {
        			return eachUser;
        		}
        	}
        }
        return null;
    }

    /*private Id getNewManagerId(User usr, String currentTIER) {
        Id newManagerId = null;
        if (currentTIER == GlobalConstants.SME_RM) {
            if(usr.RC_Code__c != null && getUserFromCode(usr.RC_Code__c, usr) != null) {
                newManagerId = getUserFromCode(usr.RC_Code__c, usr).Id;
            } else if (usr.AH_RC_Code__c != null && getUserFromCode(usr.AH_RC_Code__c, usr) != null) {
                newManagerId = getUserFromCode(usr.AH_RC_Code__c, usr).Id;
            } else if (usr.NH_RC_Code__c != null && getUserFromCode(usr.NH_RC_Code__c, usr) != null) {
                newManagerId = getUserFromCode(usr.NH_RC_Code__c, usr).Id;
            }
        } else if (currentTIER == GlobalConstants.SME_TM) {
            if (usr.AH_RC_Code__c != null && getUserFromCode(usr.AH_RC_Code__c, usr) != null) {
                newManagerId = getUserFromCode(usr.AH_RC_Code__c, usr).Id;
            } else if (usr.NH_RC_Code__c != null && getUserFromCode(usr.NH_RC_Code__c, usr) != null) {
                newManagerId = getUserFromCode(usr.NH_RC_Code__c, usr).Id;
            }
        } else if (currentTIER == GlobalConstants.SME_AH) {
            if (usr.NH_RC_Code__c != null && getUserFromCode(usr.NH_RC_Code__c, usr) != null) {
                newManagerId = getUserFromCode(usr.NH_RC_Code__c, usr).Id;
            }
        }
        if (newManagerId == null) {
			addLog(CLASS_NAME,'Cannot update new Manager of User EmpId : ' + usr.Employee_ID__c);
        }
        return newManagerId;
    }*/

    private void updateCurrentLevelCrossCheckDemoteUserMapByNewRoleRC(String jobCode,String rcCode,User user){
        //Added Fix INC000000488065, INC000000493019, INC000000504658
    	System.debug('updateCurrentLevelCrossCheckDemoteUserMapByNewRoleRC == '+rcCode +'::'+user);
    	if (jobCodeMapByName.containsKey(jobCode) && jobCodeMapByName.get(jobCode) != GlobalConstants.SME_RM) {
    		if(user.IsActive){
				String roleDevName = 'RC' + rcCode;
				currentLevelCrossCheckDemoteUserMapByNewRoleRC.put(roleDevName, user);
			}
		}
        //End Fix INC000000488065, INC000000493019, INC000000504658
    }

    private String getTIER(String jobCode) {
        // Check Role
        String currentTIER = null;
        if (jobCodeMapByName.containsKey(jobCode)) {
        	currentTIER = jobCodeMapByName.get(jobCode);
        }
        return currentTIER;
    }

    private String formatEmployeeId(String employeeId) {
    	 if(Test.isRunningTest()){
            return employeeId;
        }else{
            employeeId = '00000' + employeeId;
            return employeeId.substring(employeeId.length() - 6, employeeId.length());
        }
    }

 	private void clearance(Integer numberUserChange){
    	super.clearance();
		if(!updatedUser.isEmpty()){
			TriggerHandler.bypass('UserTriggerHandler');
            update (List<User>) updatedUser.values();
            totalActiveUser += numberUserChange; //apply temporary change
            totalUnused = (totalMaxLicense - totalActiveUser);
        }

        // Update FSC permission set
        if(activeUserIds.size() > 0) {
        	System_Settings__c systemSetting = System_Settings__c.getOrgDefaults();
        	List<PermissionSetAssignment> permissionAssignments = new List<PermissionSetAssignment>();
        	if(systemSetting.FSCPermissionSetId__c != null) {
        		String permissionSetId = systemSetting.FSCPermissionSetId__c;
	        	for(Id eachActiveUserId : activeUserIds) {
	        		permissionAssignments.add(new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = eachActiveUserId));
	        	}
	        	try {
		        	insert permissionAssignments;
	        	} catch(DmlException ex) {
				    for (Integer i = 0; i < ex.getNumDml(); i++) {
				        System.debug(ex.getDmlMessage(i));
				    }
				}
	        	//Database.insert(permissionAssignments, false);
        	}
        }
    }

	global void finish(Database.BatchableContext BC) {
		if(updateUserExtMap!=null && updateUserExtMap.size() > 0) {
		    upsert updateUserExtMap.values() External_ID__c;
		    updateUserExtMap.clear();
        }
        if(updateTeamMap!=null && updateTeamMap.size() > 0) {
		    update updateTeamMap.values();
		    updateTeamMap.clear();
        }

        //System.enqueueJob(new GroupChatter_Queue(mapInsertCollaborationGroupMapByGroupName,mapListMemberMapByGroupName,listDeleteMember));

		if(batchRole!=null) {
	    	if(batchRole == GlobalConstants.SME_NH) {
	    		Database.executeBatch(new UserStructureUpdateUser_Batch(GlobalConstants.SME_AH, totalActiveUser, totalMaxLicense, userMaskMapByEmpId, userMapByNewRoleRC, hrisDiffIds, hrisInActiveIds,mapInsertCollaborationGroupMapByGroupName,currentLevelCrossCheckDemoteUserMapByNewRoleRC));
	    	} else if (batchRole == GlobalConstants.SME_AH) {
	    		Database.executeBatch(new UserStructureUpdateUser_Batch(GlobalConstants.SME_TM, totalActiveUser, totalMaxLicense, userMaskMapByEmpId, userMapByNewRoleRC, hrisDiffIds, hrisInActiveIds,mapInsertCollaborationGroupMapByGroupName,currentLevelCrossCheckDemoteUserMapByNewRoleRC));
	    	} else if (batchRole == GlobalConstants.SME_TM) {
	    		Database.executeBatch(new UserStructureUpdateUser_Batch(GlobalConstants.SME_RM, totalActiveUser, totalMaxLicense, userMaskMapByEmpId, userMapByNewRoleRC, hrisDiffIds, hrisInActiveIds,mapInsertCollaborationGroupMapByGroupName,currentLevelCrossCheckDemoteUserMapByNewRoleRC));
	    	} else if(batchRole == GlobalConstants.SME_RM) {
	    		if(userMaskMapByEmpId != null && userMaskMapByEmpId.size() > 0) {
		            //Database.executeBatch(new SME_CalculateOwnershipAssignment_Batch(userMaskMapByEmpId, userMapByNewRoleRC, hrisDiffIds, hrisInActiveIds));
		        }
	    	}
        }
	}
}