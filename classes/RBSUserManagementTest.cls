@isTest
private class RBSUserManagementTest {

	@isTest static void Given_JobCodeNewRBSUserManagement_When_RunProfileNHGetQuery_Then_ReturnQueryWithJobCodeNH() {
		String resultJobCodeNH1 = UserManagementMockupTest.JOB_CODE_RBS_NH;
		UserManagementMockupTest.createJobCode();
		RBSUserManagement rbsClass = new RBSUserManagement();
		String queryResult = rbsClass.getQuery();
		System.assertEquals(true,queryResult.contains(resultJobCodeNH1));
	}
	
	@isTest static void Given_JobCodeNewRBSUserManagementRoleAH_When_RunProfileAHGetQuery_Then_ReturnQueryWithJobCodeNH() {
		String resultJobCodeAH1 = UserManagementMockupTest.JOB_CODE_RBS_AH;
		UserManagementMockupTest.createJobCode();
		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_AH);
		String queryResult = rbsClass.getQuery();
		System.assertEquals(true,queryResult.contains(resultJobCodeAH1));
	}

	@isTest static void Given_JobCodeNewRBSUserManagementRoleTM_When_RunProfileTMGetQuery_Then_ReturnQueryWithJobCodeTM() {
		String resultJobCodeTM1 = UserManagementMockupTest.JOB_CODE_RBS_BM;
		UserManagementMockupTest.createJobCode();
		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_TM);
		String queryResult = rbsClass.getQuery();
		System.assertEquals(true,queryResult.contains(resultJobCodeTM1));
	}

	@isTest static void Given_JobCodeNewRBSUserManagementRoleRM_When_RunProfileRMGetQuery_Then_ReturnQueryWithJobCodeRM() {
		String resultJobCodeRM1 = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1;
		String resultJobCodeRM2 = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_2;
		String resultJobCodeRM3 = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_3;
		UserManagementMockupTest.createJobCode();
		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_RM_BAR);
		String queryResult = rbsClass.getQuery();
		System.assertEquals(true,queryResult.contains(resultJobCodeRM1));
		System.assertEquals(true,queryResult.contains(resultJobCodeRM2));
		System.assertEquals(true,queryResult.contains(resultJobCodeRM3));
	}

	@isTest static void Given_JobCodeNewRBSUserManagementRoleRMAndEmployeeId_When_GetQuery_Then_ReturnQueryWithJobCodeRMAndEmployeeId() {
		String resultJobCodeRM1 = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1;
		String resultJobCodeRM2 = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_2;
		String resultJobCodeRM3 = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_3;
		String employeeId = Mockup_Test.userEmpIdRM;
		UserManagementMockupTest.createJobCode();
		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_RM_BAR,new List<String>{employeeId});
		String queryResult = rbsClass.getQuery();
		System.assertEquals(true,queryResult.contains(resultJobCodeRM1));
		System.assertEquals(true,queryResult.contains(resultJobCodeRM2));
		System.assertEquals(true,queryResult.contains(resultJobCodeRM3));
		System.assertEquals(true,queryResult.contains(employeeId));
	}

	@isTest static void Given_ExistingUserAndUserStructureSameEmployeeId_When_InactiveUser_Then_ReturnUserInactive() {
		String employeeId = Mockup_Test.userEmpIdRM;
		String resultStatus = 'I';
		Date retultEffectiveDate = Date.newInstance(2018, 8, 9);

		RBSUserManagement rbsClass = new RBSUserManagement();
		User_Structure__c userStructure = new User_Structure__c(
			Name = employeeId,
			Status__c = resultStatus,
			Effective_Date__c = retultEffectiveDate
		);
		User user = new User(
			Employee_Id__c = employeeId,
			IsActive = true,
			TempInactive__c = true,
			Status__c = 'A',
			Effective_Date__c = retultEffectiveDate.addDays(-1)
		);
		Map<String, User> mapExistingUserByEmpId = new Map<String, User>{employeeId=>user};
		User inactiveUser = rbsClass.inactiveUser(mapExistingUserByEmpId,userStructure);

		System.assertEquals(resultStatus,inactiveUser.Status__c);
		System.assertEquals(false,inactiveUser.IsActive);
		System.assertEquals(false,inactiveUser.TempInactive__c);
		System.assertEquals(retultEffectiveDate,inactiveUser.Effective_Date__c);
	}

	@isTest static void Given_UserTM_UserRMAndUserStructure_When_SetCurrentOppApproval_Then_SetTMAsCurrentOppApproval() {
		Date retultEffectiveDate = Date.newInstance(2018, 8, 9);
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userTM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdTM, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, true, null);
		userTM.RC_Code__c = Mockup_Test.RC_CODE;
		userTM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_BM).Id;
		TriggerHandler.bypass('UserTriggerHandler');
		insert userTM;

		User userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, userTM.Id);
		userRM.RC_Code__c = Mockup_Test.RC_CODE;
		userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;

		User_Structure__c userStructureTM = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdTM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'A', System.today());
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert userStructureTM;
		}

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_RM_BAR);
		rbsClass.setCurrentOppApproval(userRM);

		System.assertEquals(userTM.Id,userRM.Current_Opportunity_Approval__c);
	}

	@isTest static void Given_UserAH_UserRMAndUserStructure_When_SetCurrentOppApproval_Then_SetAHAsCurrentOppApproval() {
		Date retultEffectiveDate = Date.newInstance(2018, 8, 9);
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userAH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdAH, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, true, null);
		userAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_AH).Id;
		TriggerHandler.bypass('UserTriggerHandler');
		insert userAH;

		User_Structure__c userStructureAH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdAH, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, UserManagementMockupTest.JOB_CODE_RBS_AH, 'A', System.today());
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert userStructureAH;
		}

		User userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, userAH.Id);
		userRM.RC_Code__c = Mockup_Test.RC_CODE;
		userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_RM_BAR);
		rbsClass.setCurrentOppApproval(userRM);

		System.assertEquals(userAH.Id,userRM.Current_Opportunity_Approval__c);
	}

	@isTest static void Given_UserNH_UserRMAndUserStructure_When_SetCurrentOppApproval_Then_SetNHAsCurrentOppApproval() {
		Date retultEffectiveDate = Date.newInstance(2018, 8, 9);
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id;
		TriggerHandler.bypass('UserTriggerHandler');
		insert userNH;

		User_Structure__c userStructureNH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdNH, Mockup_Test.NH_RC_CODE, null, Mockup_Test.NH_RC_CODE, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, UserManagementMockupTest.JOB_CODE_RBS_NH, 'A', System.today());
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert userStructureNH;
		}

		User userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, userNH.Id);
		userRM.RC_Code__c = Mockup_Test.RC_CODE;
		userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_RM_BAR);
		rbsClass.setCurrentOppApproval(userRM);

		System.assertEquals(userNH.Id,userRM.Current_Opportunity_Approval__c);
	}

	@isTest static void Given_UserRM_TM_AH_NH_ButTMInactive_When_UpdateNewCurrentOppApprovalToChildRecord_Then_SetAHAsCurrentOppApproval() {
		TriggerHandler.bypass('UserTriggerHandler');
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id;
		insert userNH;

		User userAH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdAH, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, true, userNH.Id);
		userAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_AH).Id;
		insert userAH;

		User userTM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdTM, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, true, userAH.Id);
		userTM.RC_Code__c = Mockup_Test.RC_CODE;
		userTM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_BM).Id;
		userTM.Current_Opportunity_Approval__c = userAH.Id;
		insert userTM;

		User userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, userTM.Id);
		userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userRM.RC_Code__c = Mockup_Test.RC_CODE;
		userRM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1).Id;
		userRM.Current_Opportunity_Approval__c = userTM.Id;
		insert userRM;

		List<User> listInactiveUser = [SELECT Id,Profile.Name FROM User WHERE Id = :userTM.Id];
		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_TM);
		rbsClass.updateNewCurrentOppApprovalToChildRecord(listInactiveUser);

		User resultUserRM = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE Id = :userRM.Id];
		System.assertEquals(userAH.Id,resultUserRM.Current_Opportunity_Approval__c);
	}
	
	@isTest static void Given_UserRM_TM_AH_NH_ButAHInactive_When_UpdateNewCurrentOppApprovalToChildRecord_Then_SetNHAsCurrentOppApproval() {
		TriggerHandler.bypass('UserTriggerHandler');
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id;
		insert userNH;

		User userAH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdAH, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, true, userNH.Id);
		userAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_AH).Id;
		insert userAH;

		User userTM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdTM, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, true, userAH.Id);
		userTM.RC_Code__c = Mockup_Test.RC_CODE;
		userTM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_BM).Id;
		userTM.Current_Opportunity_Approval__c = userAH.Id;
		insert userTM;

		User userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, userTM.Id);
		userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userRM.RC_Code__c = Mockup_Test.RC_CODE;
		userRM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1).Id;
		userRM.Current_Opportunity_Approval__c = userAH.Id;
		insert userRM;

		List<User> listInactiveUser = [SELECT Id,Profile.Name FROM User WHERE Id = :userAH.Id];
		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_AH);
		rbsClass.updateNewCurrentOppApprovalToChildRecord(listInactiveUser);

		User resultUserRM = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE Id = :userRM.Id];
		System.assertEquals(userNH.Id,resultUserRM.Current_Opportunity_Approval__c);
		User resultUserTM = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE Id = :userTM.Id];
		System.assertEquals(userNH.Id,resultUserTM.Current_Opportunity_Approval__c);
	}

	@isTest static void Given_UserRM_TM_AH_NH_ButNHInactive_When_UpdateNewCurrentOppApprovalToChildRecord_Then_SetNullAsCurrentOppApproval() {
		TriggerHandler.bypass('UserTriggerHandler');
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id;
		insert userNH;

		User userAH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdAH, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, true, userNH.Id);
		userAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_AH).Id;
		insert userAH;

		User userTM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdTM, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, true, userAH.Id);
		userTM.RC_Code__c = Mockup_Test.RC_CODE;
		userTM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_BM).Id;
		userTM.Current_Opportunity_Approval__c = userNH.Id;
		insert userTM;

		User userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, userTM.Id);
		userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userRM.RC_Code__c = Mockup_Test.RC_CODE;
		userRM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1).Id;
		userRM.Current_Opportunity_Approval__c = userNH.Id;
		insert userRM;

		List<User> listInactiveUser = [SELECT Id,Profile.Name FROM User WHERE Id = :userNH.Id];
		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_NH);
		rbsClass.updateNewCurrentOppApprovalToChildRecord(listInactiveUser);

		User resultUserRM = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE Id = :userRM.Id];
		System.assertEquals(null,resultUserRM.Current_Opportunity_Approval__c);
		User resultUserTM = [SELECT Id,Current_Opportunity_Approval__c FROM User WHERE Id = :userTM.Id];
		System.assertEquals(null,resultUserTM.Current_Opportunity_Approval__c);
	}

	@isTest static void Given_UserAndUserStructureUpdateNewData_When_IsDataChange_Then_ReturnTrue() {
		RBSUserManagement rbsClass = new RBSUserManagement();
		Boolean result = false;
		User user = new User();
		User_Structure__c userStructure = new User_Structure__c();
		
		user.FirstName = 'FirstName';
		userStructure.First_Name__c = 'First_Name__c';
		result = rbsClass.isDataChange(user, userStructure);
		System.assertEquals(true,result);

		user = new User();
		user.LastName = 'LastName';
		userStructure = new User_Structure__c();
		userStructure.Last_Name__c = 'Last_Name__c';
		result = rbsClass.isDataChange(user, userStructure);
		System.assertEquals(true,result);

		user = new User();
		user.Username = 'Username';
		userStructure = new User_Structure__c();
		userStructure.Username__c = 'Username__c';
		result = rbsClass.isDataChange(user, userStructure);
		System.assertEquals(true,result);

		user = new User();
		user.Email = 'Email';
		userStructure = new User_Structure__c();
		userStructure.Email__c = 'Email__c';
		result = rbsClass.isDataChange(user, userStructure);
		System.assertEquals(true,result);

		user = new User();
		user.Job_Code__c = 'Job_Code__c';
		userStructure = new User_Structure__c();
		userStructure.Job_Code__c = 'New_Job_Code__c';
		result = rbsClass.isDataChange(user, userStructure);
		System.assertEquals(true,result);

		user = new User();
		user.RC_Code__c = 'RC_Code__c';
		userStructure = new User_Structure__c();
		userStructure.RC_Code__c = 'New_RC_Code__c';
		result = rbsClass.isDataChange(user, userStructure);
		System.assertEquals(true,result);

		user = new User();
		user.AH_RC_Code__c = 'AH_RC_Code__c';
		userStructure = new User_Structure__c();
		userStructure.AH_RC_Code__c = 'New_AH_RC_Code__c';
		result = rbsClass.isDataChange(user, userStructure);
		System.assertEquals(true,result);

		user = new User();
		user.NH_RC_Code__c = 'NH_RC_Code__c';
		userStructure = new User_Structure__c();
		userStructure.NH_RC_Code__c = 'New_NH_RC_Code__c';
		result = rbsClass.isDataChange(user, userStructure);
		System.assertEquals(true,result);

		user = new User();
		user.Segment__c = 'Segment__c';
		userStructure = new User_Structure__c();
		userStructure.Segment__c = 'New_Segment__c';
		result = rbsClass.isDataChange(user, userStructure);
		System.assertEquals(true,result);

		user = new User();
		user.Team_Name__c = 'Team_Name__c';
		userStructure = new User_Structure__c();
		userStructure.Team_Name__c = 'New_Team_Name__c';
		result = rbsClass.isDataChange(user, userStructure);
		System.assertEquals(true,result);

		user = new User();
		user.Status__c = 'Status__c';
		userStructure = new User_Structure__c();
		userStructure.Status__c = 'New_Status__c';
		result = rbsClass.isDataChange(user, userStructure);
		System.assertEquals(true,result);

		user = new User();
		user.MobilePhone = 'MobilePhone';
		userStructure = new User_Structure__c();
		userStructure.Mobile__c = 'New_MobilePhone';
		result = rbsClass.isDataChange(user, userStructure);
		System.assertEquals(true,result);

		user = new User();
		user.Effective_Date__c = Date.newInstance(2018, 01, 01);
		userStructure = new User_Structure__c();
		userStructure.Effective_Date__c = Date.newInstance(2018, 12, 12);
		result = rbsClass.isDataChange(user, userStructure);
		System.assertEquals(true,result);
	}

	@isTest static void Given_UserRMAndUserStructureUpdateNewData_When_RunProfileRMUpdateUser_Then_UpdateUserInfoActive() {
		TriggerHandler.bypass('UserTriggerHandler');
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id;
		insert userNH;

		User userAH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdAH, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, true, userNH.Id);
		userAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_AH).Id;
		insert userAH;

		User userTM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdTM, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, true, userAH.Id);
		userTM.RC_Code__c = Mockup_Test.RC_CODE;
		userTM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_BM).Id;
		insert userTM;

		User_Structure__c userStructureTM = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdTM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'A', System.today());
		User_Structure__c userStructureAH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdAH, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, UserManagementMockupTest.JOB_CODE_RBS_AH, 'A', System.today());
		User_Structure__c userStructureNH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdNH, Mockup_Test.NH_RC_CODE, null, Mockup_Test.NH_RC_CODE, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, UserManagementMockupTest.JOB_CODE_RBS_NH, 'A', System.today());
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert new List<User_Structure__c>{userStructureTM,userStructureAH,userStructureNH};
		}

		User userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, userTM.Id);
		userRM.TempInactive__c = true;
		userRM.IsActive = false;

		User_Structure__c userStructure = new User_Structure__c();
		userStructure.RC_Code__c = Mockup_Test.RC_CODE;
		userStructure.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userStructure.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructure.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1;
		userStructure.Email__c = 'Email__c';
		userStructure.First_Name__c = 'First_Name__c';
		userStructure.Last_Name__c = 'Last_Name__c';
		userStructure.Username__c = 'Username@kbank.com';
		userStructure.Segment__c = 'SE';
		userStructure.Effective_Date__c = System.today();
		userStructure.Status__c = 'A';
		userStructure.Mobile__c = 'Mobile__c';

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_RM_BAR);
		User resultUser = rbsClass.updateUser(userStructure,userRM);
		System.assertEquals(UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c, userStructure.Job_Code__c).Id,resultUser.UserRoleId);
		System.assertEquals(userStructure.Job_Code__c,resultUser.Job_Code__c);
		System.assertEquals(UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1).Id,resultUser.ProfileId);
		System.assertEquals(userStructure.Email__c,resultUser.Email);
		System.assertEquals(userStructure.First_Name__c,resultUser.FirstName);
		System.assertEquals(userStructure.Last_Name__c,resultUser.LastName);
		System.assertEquals(userStructure.Username__c,resultUser.Username);
		System.assertEquals(userStructure.Segment__c,resultUser.Segment__c);
		System.assertEquals(true,resultUser.IsActive);
		System.assertEquals(userStructure.Status__c,resultUser.Status__c);
		System.assertEquals(userStructure.Effective_Date__c,resultUser.Effective_Date__c);
		System.assertEquals(false,resultUser.TempInactive__c);
		System.assertEquals(userStructure.RC_Code__c,resultUser.RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdTM,resultUser.TM_Employee_ID__c);
		System.assertNotEquals(null,resultUser.TM_Name__c);
		System.assertNotEquals(null,resultUser.Team_Name__c);
		System.assertEquals(userStructure.AH_RC_Code__c,resultUser.AH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdAH,resultUser.AH_Employee_ID__c);
		System.assertNotEquals(null,resultUser.AH_Name__c);
		System.assertNotEquals(null,resultUser.Area_Name__c);
		System.assertEquals(userStructure.NH_RC_Code__c,resultUser.NH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdNH,resultUser.NH_Employee_ID__c);
		System.assertNotEquals(null,resultUser.NH_Name__c);
		System.assertNotEquals(null,resultUser.Network_Name__c);
		System.assertEquals(userTM.Id,resultUser.ManagerId);
		System.assertEquals('Username',resultUser.CommunityNickname);
		System.assertEquals(userStructure.Mobile__c,resultUser.MobilePhone);
	}

	@isTest static void Given_UserRMInactiveAndUserStructureUpdateNewData_When_RunProfileRMUpdateUser_Then_UserStillInactive() {
		TriggerHandler.bypass('UserTriggerHandler');
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id;
		insert userNH;

		User userAH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdAH, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, true, userNH.Id);
		userAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_AH).Id;
		insert userAH;

		User userTM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdTM, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, true, userAH.Id);
		userTM.RC_Code__c = Mockup_Test.RC_CODE;
		userTM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_BM).Id;
		insert userTM;

		User userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, userTM.Id);
		userRM.IsActive = false;

		User_Structure__c userStructure = new User_Structure__c();
		userStructure.RC_Code__c = Mockup_Test.RC_CODE;
		userStructure.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userStructure.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructure.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1;
		userStructure.Email__c = 'Email__c';
		userStructure.First_Name__c = 'First_Name__c';
		userStructure.Last_Name__c = 'Last_Name__c';
		userStructure.Username__c = 'Username__c';
		userStructure.Segment__c = 'SE';
		userStructure.Effective_Date__c = System.today();
		userStructure.Status__c = 'I';

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_RM_BAR);
		User resultUser = rbsClass.updateUser(userStructure,userRM);
		System.assertEquals(false,resultUser.IsActive);
	}

	@isTest static void Given_UserTMAndUserStructureUpdateNewData_When_RunProfileTMUpdateUser_Then_UpdateUserInfoActive() {
		TriggerHandler.bypass('UserTriggerHandler');
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id;
		insert userNH;

		User userAH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdAH, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, true, userNH.Id);
		userAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_AH).Id;
		insert userAH;

		User userTM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdTM, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, true, userAH.Id);
		userTM.TempInactive__c = true;
		userTM.IsActive = false;

		User_Structure__c userStructureTM = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdTM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'A', System.today());
		User_Structure__c userStructureAH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdAH, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, UserManagementMockupTest.JOB_CODE_RBS_AH, 'A', System.today());
		User_Structure__c userStructureNH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdNH, Mockup_Test.NH_RC_CODE, null, Mockup_Test.NH_RC_CODE, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, UserManagementMockupTest.JOB_CODE_RBS_NH, 'A', System.today());
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert new List<User_Structure__c>{userStructureTM,userStructureAH,userStructureNH};
		}

		User_Structure__c userStructure = new User_Structure__c();
		userStructure.RC_Code__c = Mockup_Test.RC_CODE;
		userStructure.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userStructure.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructure.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_BM;
		userStructure.Email__c = 'Email__c';
		userStructure.First_Name__c = 'First_Name__c';
		userStructure.Last_Name__c = 'Last_Name__c';
		userStructure.Username__c = 'Username@kbank.com';
		userStructure.Segment__c = 'SE';
		userStructure.Effective_Date__c = System.today();
		userStructure.Status__c = 'A';
		userStructure.Mobile__c = 'Mobile__c';

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_TM);
		User resultUser = rbsClass.updateUser(userStructure,userTM);
		System.assertEquals(UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c, userStructure.Job_Code__c).Id,resultUser.UserRoleId);
		System.assertEquals(userStructure.Job_Code__c,resultUser.Job_Code__c);
		System.assertEquals(UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_BM).Id,resultUser.ProfileId);
		System.assertEquals(userStructure.Email__c,resultUser.Email);
		System.assertEquals(userStructure.First_Name__c,resultUser.FirstName);
		System.assertEquals(userStructure.Last_Name__c,resultUser.LastName);
		System.assertEquals(userStructure.Username__c,resultUser.Username);
		System.assertEquals(userStructure.Segment__c,resultUser.Segment__c);
		System.assertEquals(true,resultUser.IsActive);
		System.assertEquals(userStructure.Status__c,resultUser.Status__c);
		System.assertEquals(userStructure.Effective_Date__c,resultUser.Effective_Date__c);
		System.assertEquals(false,resultUser.TempInactive__c);
		System.assertEquals(userStructure.RC_Code__c,resultUser.RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdTM,resultUser.TM_Employee_ID__c);
		System.assertEquals(userStructure.First_Name__c + ' ' + userStructure.Last_Name__c,resultUser.TM_Name__c);
		System.assertNotEquals(null,resultUser.Team_Name__c);
		System.assertEquals(userStructure.AH_RC_Code__c,resultUser.AH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdAH,resultUser.AH_Employee_ID__c);
		System.assertNotEquals(null,resultUser.AH_Name__c);
		System.assertNotEquals(null,resultUser.Area_Name__c);
		System.assertEquals(userStructure.NH_RC_Code__c,resultUser.NH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdNH,resultUser.NH_Employee_ID__c);
		System.assertNotEquals(null,resultUser.NH_Name__c);
		System.assertNotEquals(null,resultUser.Network_Name__c);
		System.assertEquals(userAH.Id,resultUser.ManagerId);
		System.assertEquals('Username',resultUser.CommunityNickname);
		System.assertEquals(userStructure.Mobile__c,resultUser.MobilePhone);
	}

	@isTest static void Given_UserAHAndUserStructureUpdateNewData_When_RunProfileAHUpdateUser_Then_UpdateUserInfoActiveAndFieldTeamInfoNull() {
		TriggerHandler.bypass('UserTriggerHandler');
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id;
		insert userNH;

		User userAH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdAH, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, true, userNH.Id);
		userAH.TempInactive__c = true;
		userAH.IsActive = false;

		User_Structure__c userStructureNH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdNH, Mockup_Test.NH_RC_CODE, null, Mockup_Test.NH_RC_CODE, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, UserManagementMockupTest.JOB_CODE_RBS_NH, 'A', System.today());
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert userStructureNH;
		}

		User_Structure__c userStructure = new User_Structure__c();
		userStructure.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userStructure.AH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructure.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructure.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_AH;
		userStructure.Email__c = 'Email__c';
		userStructure.First_Name__c = 'First_Name__c';
		userStructure.Last_Name__c = 'Last_Name__c';
		userStructure.Username__c = 'Username@kbank.com';
		userStructure.Segment__c = 'SE';
		userStructure.Effective_Date__c = System.today();
		userStructure.Status__c = 'A';
		userStructure.Mobile__c = 'Mobile__c';

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_AH);
		User resultUser = rbsClass.updateUser(userStructure,userAH);
		System.assertEquals(UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c, userStructure.Job_Code__c).Id,resultUser.UserRoleId);
		System.assertEquals(userStructure.Job_Code__c,resultUser.Job_Code__c);
		System.assertEquals(UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_AH).Id,resultUser.ProfileId);
		System.assertEquals(userStructure.Email__c,resultUser.Email);
		System.assertEquals(userStructure.First_Name__c,resultUser.FirstName);
		System.assertEquals(userStructure.Last_Name__c,resultUser.LastName);
		System.assertEquals(userStructure.Username__c,resultUser.Username);
		System.assertEquals(userStructure.Segment__c,resultUser.Segment__c);
		System.assertEquals(true,resultUser.IsActive);
		System.assertEquals(userStructure.Status__c,resultUser.Status__c);
		System.assertEquals(userStructure.Effective_Date__c,resultUser.Effective_Date__c);
		System.assertEquals(false,resultUser.TempInactive__c);
		System.assertEquals(userStructure.RC_Code__c,resultUser.RC_Code__c);
		System.assertEquals(null,resultUser.TM_Employee_ID__c);
		System.assertEquals(null,resultUser.TM_Name__c);
		System.assertEquals(null,resultUser.Team_Name__c);
		System.assertEquals(userStructure.RC_Code__c,resultUser.AH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdAH,resultUser.AH_Employee_ID__c);
		System.assertEquals(userStructure.First_Name__c + ' ' + userStructure.Last_Name__c,resultUser.AH_Name__c);
		System.assertNotEquals(null,resultUser.Area_Name__c);
		System.assertEquals(userStructure.NH_RC_Code__c,resultUser.NH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdNH,resultUser.NH_Employee_ID__c);
		System.assertNotEquals(null,resultUser.NH_Name__c);
		System.assertNotEquals(null,resultUser.Network_Name__c);
		System.assertEquals(userNH.Id,resultUser.ManagerId);
		System.assertEquals('Username',resultUser.CommunityNickname);
		System.assertEquals(userStructure.Mobile__c,resultUser.MobilePhone);
	}

	@isTest static void Given_UserNHAndUserStructureUpdateNewData_When_RunProfileNHUpdateUser_Then_UpdateUserInfoActiveAndFieldTeamNullAndFieldAreaNull() {
		TriggerHandler.bypass('UserTriggerHandler');
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.TempInactive__c = true;
		userNH.IsActive = false;

		User_Structure__c userStructure = new User_Structure__c();
		userStructure.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructure.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructure.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_NH;
		userStructure.Email__c = 'Email__c';
		userStructure.First_Name__c = 'First_Name__c';
		userStructure.Last_Name__c = 'Last_Name__c';
		userStructure.Username__c = 'Username@kbank.com';
		userStructure.Segment__c = 'SE';
		userStructure.Effective_Date__c = System.today();
		userStructure.Status__c = 'A';
		userStructure.Mobile__c = 'Mobile__c';

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_NH);
		User resultUser = rbsClass.updateUser(userStructure,userNH);
		System.assertEquals(UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c, userStructure.Job_Code__c).Id,resultUser.UserRoleId);
		System.assertEquals(userStructure.Job_Code__c,resultUser.Job_Code__c);
		System.assertEquals(UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id,resultUser.ProfileId);
		System.assertEquals(userStructure.Email__c,resultUser.Email);
		System.assertEquals(userStructure.First_Name__c,resultUser.FirstName);
		System.assertEquals(userStructure.Last_Name__c,resultUser.LastName);
		System.assertEquals(userStructure.Username__c,resultUser.Username);
		System.assertEquals(userStructure.Segment__c,resultUser.Segment__c);
		System.assertEquals(true,resultUser.IsActive);
		System.assertEquals(userStructure.Status__c,resultUser.Status__c);
		System.assertEquals(userStructure.Effective_Date__c,resultUser.Effective_Date__c);
		System.assertEquals(false,resultUser.TempInactive__c);
		System.assertEquals(userStructure.RC_Code__c,resultUser.RC_Code__c);
		System.assertEquals(null,resultUser.TM_Employee_ID__c);
		System.assertEquals(null,resultUser.TM_Name__c);
		System.assertEquals(null,resultUser.Team_Name__c);
		System.assertEquals(null,resultUser.AH_RC_Code__c);
		System.assertEquals(null,resultUser.AH_Employee_ID__c);
		System.assertEquals(null,resultUser.AH_Name__c);
		System.assertEquals(null,resultUser.Area_Name__c);
		System.assertEquals(userStructure.NH_RC_Code__c,resultUser.NH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdNH,resultUser.NH_Employee_ID__c);
		System.assertEquals(userStructure.First_Name__c + ' ' + userStructure.Last_Name__c,resultUser.NH_Name__c);
		System.assertNotEquals(null,resultUser.Network_Name__c);
		System.assertEquals(null,resultUser.ManagerId);
		System.assertEquals('Username',resultUser.CommunityNickname);
		System.assertEquals(userStructure.Mobile__c,resultUser.MobilePhone);
	}

	@isTest static void Given_UserStructureRM_When_RunProfileRMCreateNewUser_Then_ReturnNewUserRM() {
		TriggerHandler.bypass('UserTriggerHandler');
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id;
		insert userNH;

		User userAH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdAH, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, true, userNH.Id);
		userAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_AH).Id;
		insert userAH;

		User userTM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdTM, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, true, userAH.Id);
		userTM.RC_Code__c = Mockup_Test.RC_CODE;
		userTM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_BM).Id;
		insert userTM;

		User_Structure__c userStructureTM = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdTM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'A', System.today());
		User_Structure__c userStructureAH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdAH, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, UserManagementMockupTest.JOB_CODE_RBS_AH, 'A', System.today());
		User_Structure__c userStructureNH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdNH, Mockup_Test.NH_RC_CODE, null, Mockup_Test.NH_RC_CODE, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, UserManagementMockupTest.JOB_CODE_RBS_NH, 'A', System.today());
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert new List<User_Structure__c>{userStructureTM,userStructureAH,userStructureNH};
		}

		User_Structure__c userStructure = new User_Structure__c();
		userStructure.RC_Code__c = Mockup_Test.RC_CODE;
		userStructure.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userStructure.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructure.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1;
		userStructure.Email__c = 'Email__c';
		userStructure.First_Name__c = 'First_Name__c';
		userStructure.Last_Name__c = 'Last_Name__c';
		userStructure.Username__c = 'Username@kbank.com';
		userStructure.Segment__c = 'SE';
		userStructure.Effective_Date__c = System.today();
		userStructure.Status__c = 'A';
		userStructure.Name = Mockup_Test.userEmpIdRM;
		userStructure.Mobile__c = '1234567890';

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_RM_BAR);
		User resultUser = rbsClass.createNewUser(userStructure);
		System.assertEquals(UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c, userStructure.Job_Code__c).Id,resultUser.UserRoleId);
		System.assertEquals(userStructure.Job_Code__c,resultUser.Job_Code__c);
		System.assertEquals(UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1).Id,resultUser.ProfileId);
		System.assertEquals(userStructure.Email__c,resultUser.Email);
		System.assertEquals(true,resultUser.UserPermissionsMarketingUser);
		System.assertEquals(Mockup_Test.userEmpIdRM,resultUser.Employee_ID__c);
		System.assertEquals('Username',resultUser.Alias);
		System.assertEquals('th',resultUser.LanguageLocaleKey);
        System.assertEquals('th_TH',resultUser.LocaleSidKey);
        System.assertEquals('UTF-8',resultUser.EmailEncodingKey);
        System.assertEquals('Asia/Bangkok',resultUser.TimeZoneSidKey);
		System.assertEquals(userStructure.First_Name__c,resultUser.FirstName);
		System.assertEquals(userStructure.Last_Name__c,resultUser.LastName);
		System.assertEquals(userStructure.Username__c,resultUser.Username);
		System.assertEquals(userStructure.Segment__c,resultUser.Segment__c);
		System.assertEquals(true,resultUser.IsActive);
		System.assertEquals(userStructure.Status__c,resultUser.Status__c);
		System.assertEquals(userStructure.Effective_Date__c,resultUser.Effective_Date__c);
		System.assertEquals(false,resultUser.TempInactive__c);
		System.assertEquals(userStructure.RC_Code__c,resultUser.RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdTM,resultUser.TM_Employee_ID__c);
		System.assertNotEquals(null,resultUser.TM_Name__c);
		System.assertNotEquals(null,resultUser.Team_Name__c);
		System.assertEquals(userStructure.AH_RC_Code__c,resultUser.AH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdAH,resultUser.AH_Employee_ID__c);
		System.assertNotEquals(null,resultUser.AH_Name__c);
		System.assertNotEquals(null,resultUser.Area_Name__c);
		System.assertEquals(userStructure.NH_RC_Code__c,resultUser.NH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdNH,resultUser.NH_Employee_ID__c);
		System.assertNotEquals(null,resultUser.NH_Name__c);
		System.assertNotEquals(null,resultUser.Network_Name__c);
		System.assertEquals(userTM.Id,resultUser.ManagerId);
		System.assertEquals('Username',resultUser.CommunityNickname);
        System.assertEquals(userStructure.Mobile__c,resultUser.MobilePhone);
	}

	@isTest static void Given_UserStructureTM_When_RunProfileTMCreateNewUser_Then_ReturnNewUserTM() {
		TriggerHandler.bypass('UserTriggerHandler');
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id;
		insert userNH;

		User userAH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdAH, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, true, userNH.Id);
		userAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_AH).Id;
		insert userAH;

		User_Structure__c userStructureTM = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdTM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'A', System.today());
		User_Structure__c userStructureAH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdAH, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, UserManagementMockupTest.JOB_CODE_RBS_AH, 'A', System.today());
		User_Structure__c userStructureNH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdNH, Mockup_Test.NH_RC_CODE, null, Mockup_Test.NH_RC_CODE, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, UserManagementMockupTest.JOB_CODE_RBS_NH, 'A', System.today());
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert new List<User_Structure__c>{userStructureTM,userStructureAH,userStructureNH};
		}

		User_Structure__c userStructure = new User_Structure__c();
		userStructure.RC_Code__c = Mockup_Test.RC_CODE;
		userStructure.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userStructure.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructure.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_BM;
		userStructure.Email__c = 'Email__c';
		userStructure.First_Name__c = 'First_Name__c';
		userStructure.Last_Name__c = 'Last_Name__c';
		userStructure.Username__c = 'Username@kbank.com';
		userStructure.Segment__c = 'SE';
		userStructure.Effective_Date__c = System.today();
		userStructure.Status__c = 'A';
		userStructure.Name = Mockup_Test.userEmpIdTM;
		userStructure.Mobile__c = '1234567890';

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_TM);
		User resultUser = rbsClass.createNewUser(userStructure);
		System.assertEquals(UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c, userStructure.Job_Code__c).Id,resultUser.UserRoleId);
		System.assertEquals(userStructure.Job_Code__c,resultUser.Job_Code__c);
		System.assertEquals(UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_BM).Id,resultUser.ProfileId);
		System.assertEquals(userStructure.Email__c,resultUser.Email);
		System.assertEquals(true,resultUser.UserPermissionsMarketingUser);
		System.assertEquals(Mockup_Test.userEmpIdTM,resultUser.Employee_ID__c);
		System.assertEquals('Username',resultUser.Alias);
		System.assertEquals('th',resultUser.LanguageLocaleKey);
        System.assertEquals('th_TH',resultUser.LocaleSidKey);
        System.assertEquals('UTF-8',resultUser.EmailEncodingKey);
        System.assertEquals('Asia/Bangkok',resultUser.TimeZoneSidKey);
		System.assertEquals(userStructure.First_Name__c,resultUser.FirstName);
		System.assertEquals(userStructure.Last_Name__c,resultUser.LastName);
		System.assertEquals(userStructure.Username__c,resultUser.Username);
		System.assertEquals(userStructure.Segment__c,resultUser.Segment__c);
		System.assertEquals(true,resultUser.IsActive);
		System.assertEquals(userStructure.Status__c,resultUser.Status__c);
		System.assertEquals(userStructure.Effective_Date__c,resultUser.Effective_Date__c);
		System.assertEquals(false,resultUser.TempInactive__c);
		System.assertEquals(userStructure.RC_Code__c,resultUser.RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdTM,resultUser.TM_Employee_ID__c);
		System.assertEquals(userStructure.First_Name__c + ' ' + userStructure.Last_Name__c,resultUser.TM_Name__c);
		System.assertNotEquals(null,resultUser.Team_Name__c);
		System.assertEquals(userStructure.AH_RC_Code__c,resultUser.AH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdAH,resultUser.AH_Employee_ID__c);
		System.assertNotEquals(null,resultUser.AH_Name__c);
		System.assertNotEquals(null,resultUser.Area_Name__c);
		System.assertEquals(userStructure.NH_RC_Code__c,resultUser.NH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdNH,resultUser.NH_Employee_ID__c);
		System.assertNotEquals(null,resultUser.NH_Name__c);
		System.assertNotEquals(null,resultUser.Network_Name__c);
		System.assertEquals(userAH.Id,resultUser.ManagerId);
		System.assertEquals('Username',resultUser.CommunityNickname);
        System.assertEquals(userStructure.Mobile__c,resultUser.MobilePhone);
	}

	@isTest static void Given_UserStructureAH_When_RunProfileAHCreateNewUser_Then_ReturnNewUserAH() {
		TriggerHandler.bypass('UserTriggerHandler');
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id;
		insert userNH;

		User_Structure__c userStructureNH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdNH, Mockup_Test.NH_RC_CODE, null, Mockup_Test.NH_RC_CODE, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, UserManagementMockupTest.JOB_CODE_RBS_NH, 'A', System.today());
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert userStructureNH;
		}

		User_Structure__c userStructure = new User_Structure__c();
		userStructure.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userStructure.AH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructure.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructure.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_AH;
		userStructure.Email__c = 'Email__c';
		userStructure.First_Name__c = 'First_Name__c';
		userStructure.Last_Name__c = 'Last_Name__c';
		userStructure.Username__c = 'Username@kbank.com';
		userStructure.Segment__c = 'SE';
		userStructure.Effective_Date__c = System.today();
		userStructure.Status__c = 'A';
		userStructure.Name = Mockup_Test.userEmpIdAH;
		userStructure.Mobile__c = '1234567890';

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_AH);
		User resultUser = rbsClass.createNewUser(userStructure);
		System.assertEquals(UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c, userStructure.Job_Code__c).Id,resultUser.UserRoleId);
		System.assertEquals(userStructure.Job_Code__c,resultUser.Job_Code__c);
		System.assertEquals(UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_AH).Id,resultUser.ProfileId);
		System.assertEquals(userStructure.Email__c,resultUser.Email);
		System.assertEquals(true,resultUser.UserPermissionsMarketingUser);
		System.assertEquals(Mockup_Test.userEmpIdAH,resultUser.Employee_ID__c);
		System.assertEquals('Username',resultUser.Alias);
		System.assertEquals('th',resultUser.LanguageLocaleKey);
        System.assertEquals('th_TH',resultUser.LocaleSidKey);
        System.assertEquals('UTF-8',resultUser.EmailEncodingKey);
        System.assertEquals('Asia/Bangkok',resultUser.TimeZoneSidKey);
		System.assertEquals(userStructure.First_Name__c,resultUser.FirstName);
		System.assertEquals(userStructure.Last_Name__c,resultUser.LastName);
		System.assertEquals(userStructure.Username__c,resultUser.Username);
		System.assertEquals(userStructure.Segment__c,resultUser.Segment__c);
		System.assertEquals(true,resultUser.IsActive);
		System.assertEquals(userStructure.Status__c,resultUser.Status__c);
		System.assertEquals(userStructure.Effective_Date__c,resultUser.Effective_Date__c);
		System.assertEquals(false,resultUser.TempInactive__c);
		System.assertEquals(userStructure.RC_Code__c,resultUser.RC_Code__c);
		System.assertEquals(null,resultUser.TM_Employee_ID__c);
		System.assertEquals(null,resultUser.TM_Name__c);
		System.assertEquals(null,resultUser.Team_Name__c);
		System.assertEquals(userStructure.RC_Code__c,resultUser.AH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdAH,resultUser.AH_Employee_ID__c);
		System.assertEquals(userStructure.First_Name__c + ' ' + userStructure.Last_Name__c,resultUser.AH_Name__c);
		System.assertNotEquals(null,resultUser.Area_Name__c);
		System.assertEquals(userStructure.NH_RC_Code__c,resultUser.NH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdNH,resultUser.NH_Employee_ID__c);
		System.assertNotEquals(null,resultUser.NH_Name__c);
		System.assertNotEquals(null,resultUser.Network_Name__c);
		System.assertEquals(userNH.Id,resultUser.ManagerId);
		System.assertEquals('Username',resultUser.CommunityNickname);
        System.assertEquals(userStructure.Mobile__c,resultUser.MobilePhone);
	}

	@isTest static void Given_UserStructureNH_When_RunProfileNHCreateNewUser_Then_ReturnNewUserNH() {
		TriggerHandler.bypass('UserTriggerHandler');
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);

		User_Structure__c userStructure = new User_Structure__c();
		userStructure.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructure.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructure.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_NH;
		userStructure.Email__c = 'Email__c';
		userStructure.First_Name__c = 'First_Name__c';
		userStructure.Last_Name__c = 'Last_Name__c';
		userStructure.Username__c = 'Username@kbank.com';
		userStructure.Segment__c = 'SE';
		userStructure.Effective_Date__c = System.today();
		userStructure.Status__c = 'A';
		userStructure.Name = Mockup_Test.userEmpIdNH;
		userStructure.Mobile__c = '1234567890';

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_NH);
		User resultUser = rbsClass.createNewUser(userStructure);
		System.assertEquals(UserManagementService.getUserRoleFromRcCode(userStructure.RC_Code__c, userStructure.Job_Code__c).Id,resultUser.UserRoleId);
		System.assertEquals(userStructure.Job_Code__c,resultUser.Job_Code__c);
		System.assertEquals(UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id,resultUser.ProfileId);
		System.assertEquals(userStructure.Email__c,resultUser.Email);
		System.assertEquals(true,resultUser.UserPermissionsMarketingUser);
		System.assertEquals(Mockup_Test.userEmpIdNH,resultUser.Employee_ID__c);
		System.assertEquals('Username',resultUser.Alias);
		System.assertEquals('th',resultUser.LanguageLocaleKey);
        System.assertEquals('th_TH',resultUser.LocaleSidKey);
        System.assertEquals('UTF-8',resultUser.EmailEncodingKey);
        System.assertEquals('Asia/Bangkok',resultUser.TimeZoneSidKey);
		System.assertEquals(userStructure.First_Name__c,resultUser.FirstName);
		System.assertEquals(userStructure.Last_Name__c,resultUser.LastName);
		System.assertEquals(userStructure.Username__c,resultUser.Username);
		System.assertEquals(userStructure.Segment__c,resultUser.Segment__c);
		System.assertEquals(true,resultUser.IsActive);
		System.assertEquals(userStructure.Status__c,resultUser.Status__c);
		System.assertEquals(userStructure.Effective_Date__c,resultUser.Effective_Date__c);
		System.assertEquals(false,resultUser.TempInactive__c);
		System.assertEquals(userStructure.RC_Code__c,resultUser.RC_Code__c);
		System.assertEquals(null,resultUser.TM_Employee_ID__c);
		System.assertEquals(null,resultUser.TM_Name__c);
		System.assertEquals(null,resultUser.Team_Name__c);
		System.assertEquals(null,resultUser.AH_RC_Code__c);
		System.assertEquals(null,resultUser.AH_Employee_ID__c);
		System.assertEquals(null,resultUser.AH_Name__c);
		System.assertEquals(null,resultUser.Area_Name__c);
		System.assertEquals(userStructure.NH_RC_Code__c,resultUser.NH_RC_Code__c);
		System.assertEquals(Mockup_Test.userEmpIdNH,resultUser.NH_Employee_ID__c);
		System.assertEquals(userStructure.First_Name__c + ' ' + userStructure.Last_Name__c,resultUser.NH_Name__c);
		System.assertNotEquals(null,resultUser.Network_Name__c);
		System.assertEquals(null,resultUser.ManagerId);
		System.assertEquals('Username',resultUser.CommunityNickname);
        System.assertEquals(userStructure.Mobile__c,resultUser.MobilePhone);
	}

	@isTest static void Given_NewClass_When_RunProfileNHhasNextRole_Then_ReturnTrue() {
		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_NH);
		Boolean result = rbsClass.hasNextRole();
		System.assertEquals(true,result);
	}

	@isTest static void Given_NewClass_When_RunProfileAHhasNextRole_Then_ReturnTrue() {
		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_AH);
		Boolean result = rbsClass.hasNextRole();
		System.assertEquals(true,result);
	}

	@isTest static void Given_NewClass_When_RunProfileTMhasNextRole_Then_ReturnTrue() {
		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_TM);
		Boolean result = rbsClass.hasNextRole();
		System.assertEquals(true,result);
	}

	@isTest static void Given_NewClass_When_RunProfileNHhasNextRole_Then_ReturnFalse() {
		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_RM_BAR);
		Boolean result = rbsClass.hasNextRole();
		System.assertEquals(false,result);
	}

	@isTest static void Given_NewClass_When_UpdateUserStructureInfo_Then_ReturnUserStructureInfo() {
		RBSUserManagement rbsClass = new RBSUserManagement();
		User_Structure__c userStructure = new User_Structure__c();
		userStructure.Name = Mockup_Test.userEmpIdRM;

		User_Structure__c result = rbsClass.updateUserStructureInfo(null,userStructure);
		System.assertEquals(true,result.IsChangeUserInfo__c);
		System.assertEquals(false,result.Previous_IsActive__c);
	}

	@isTest static void Given_User_When_UpdateUserStructureInfo_Then_ReturnUserStructureInfoWithPrevious() {
		TriggerHandler.bypass('UserTriggerHandler');
		User_Structure__c userStructure = new User_Structure__c();
		userStructure.Name = Mockup_Test.userEmpIdRM;

		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		User userNH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdNH, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, true, null);
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_NH;
		userNH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_NH).Id;
		insert userNH;

		User userAH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdAH, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, true, userNH.Id);
		userAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_AH;
		userAH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_AH).Id;
		insert userAH;

		User userTM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdTM, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, true, userAH.Id);
		userTM.RC_Code__c = Mockup_Test.RC_CODE;
		userTM.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_BM;
		userTM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_BM).Id;
		userTM.Current_Opportunity_Approval__c = userNH.Id;
		insert userTM;

		User userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, userTM.Id);
		userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userRM.RC_Code__c = Mockup_Test.RC_CODE;
		userRM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1).Id;
		userRM.IsActive = true;
		userRM.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1;
		insert userRM;

		Map<String,User> mapResultUser = UserManagementService.getExistingUserMapByEmpId(new List<User_Structure__c>{userStructure});
		RBSUserManagement rbsClass = new RBSUserManagement();
		User_Structure__c result = rbsClass.updateUserStructureInfo(mapResultUser.get(Mockup_Test.userEmpIdRM),userStructure);
		System.assertEquals(true,result.IsChangeUserInfo__c);
		System.assertEquals(true,result.Previous_IsActive__c);
        System.assertEquals(Mockup_Test.RC_CODE,result.Previous_RC_Code__c);
        System.assertEquals(Mockup_Test.AH_RC_CODE,result.Previous_AH_RC_Code__c);
        System.assertEquals(Mockup_Test.NH_RC_CODE,result.Previous_NH_RC_Code__c);
        System.assertEquals(UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1,result.Previous_Job_Code__c);
	}

	@isTest static void Given_User_When_CreateUserExtension_Then_ReturnUserExtensionWithInfo() {
		TriggerHandler.bypass('UserTriggerHandler');
		User userRM;
		System.runAs(new User(Id =UserInfo.getUserId())){
			UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
			userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, null);
			userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
			userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
			userRM.RC_Code__c = Mockup_Test.RC_CODE;
			userRM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1).Id;
			userRM.IsActive = true;
			userRM.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1;
			insert userRM;
		}

		User_Structure__c userStructure = new User_Structure__c(Name = userRM.Employee_Id__c);

		User resultUserRM = UserManagementService.getExistingUserMapByEmpId(new List<User_Structure__c>{userStructure}).get(userRM.Employee_Id__c);
		RBSUserManagement rbsClass = new RBSUserManagement();
		User_Extension__c userExtension = rbsClass.createUserExtension(resultUserRM);
		insert userExtension;
		User_Extension__c resultUserEx = [SELECT External_ID__c,Name,OwnerId,User__c,Team_Structure__r.RC_Code__c FROM User_Extension__c WHERE Id = :userExtension.Id];
		System.assertEquals(resultUserRM.RC_Code__c,resultUserEx.Team_Structure__r.RC_Code__c);
		System.assertEquals(resultUserRM.Employee_Id__c,resultUserEx.External_ID__c);
		System.assertEquals(resultUserRM.Name,resultUserEx.Name);
		System.assertEquals(resultUserRM.Id,resultUserEx.OwnerId);
		System.assertEquals(resultUserRM.Id,resultUserEx.User__c);
		
	}

	@isTest static void Given_UserActiveAndUserStructureEffectiveInactive_When_DoesUserStructureInactive_Then_ReturnTrue() {
		User userRM = new User();
		userRM.IsActive = true;
		
		User_Structure__c userStructure = new User_Structure__c();
		userStructure.Name = userRM.Employee_Id__c;
		userStructure.Effective_Date__c = System.today();
		userStructure.Status__c = 'I';

		Boolean result = UserManagementService.doesUserStructureInactive(userRM,userStructure);
		System.assertEquals(true,result);
	}

	@isTest static void Given_UserInactiveAndUserStructureEffectiveInactive_When_DoesUserStructureInactive_Then_ReturnFalse() {
		User userRM = new User();
		userRM.IsActive = false;
		
		User_Structure__c userStructure = new User_Structure__c();
		userStructure.Name = userRM.Employee_Id__c;
		userStructure.Effective_Date__c = System.today();
		userStructure.Status__c = 'I';

		Boolean result = UserManagementService.doesUserStructureInactive(userRM,userStructure);
		System.assertEquals(false,result);
	}

	@isTest static void Given_UserActiveAndUserStructureInactiveNotEffective_When_DoesUserStructureInactive_Then_ReturnFalse() {
		User userRM = new User();
		userRM.IsActive = true;
		
		User_Structure__c userStructure = new User_Structure__c();
		userStructure.Name = userRM.Employee_Id__c;
		userStructure.Effective_Date__c = System.today()+1;
		userStructure.Status__c = 'I';

		Boolean result = UserManagementService.doesUserStructureInactive(userRM,userStructure);
		System.assertEquals(false,result);
	}

	@isTest static void Given_UserActiveAndUserStructureEffectiveActive_When_DoesUserStructureActive_Then_ReturnFalse() {
		User userRM = new User();
		userRM.IsActive = true;
		
		User_Structure__c userStructure = new User_Structure__c();
		userStructure.Name = userRM.Employee_Id__c;
		userStructure.Effective_Date__c = System.today()+1;
		userStructure.Status__c = 'I';

		Boolean result = UserManagementService.doesUserStructureActive(userRM,userStructure);
		System.assertEquals(false,result);
	}

	@isTest static void Given_UserInactiveAndUserStructureEffectiveActive_When_DoesUserStructureActive_Then_ReturnTrue() {
		User userRM = new User();
		userRM.IsActive = false;
		
		User_Structure__c userStructure = new User_Structure__c();
		userStructure.Name = userRM.Employee_Id__c;
		userStructure.Effective_Date__c = System.today();
		userStructure.Status__c = 'A';

		Boolean result = UserManagementService.doesUserStructureActive(userRM,userStructure);
		System.assertEquals(true,result);
	}

	@isTest static void Given_UserInactiveAndUserStructureActiveNotEffective_When_DoesUserStructureActive_Then_ReturnFalse() {
		User userRM = new User();
		userRM.IsActive = false;
		
		User_Structure__c userStructure = new User_Structure__c();
		userStructure.Name = userRM.Employee_Id__c;
		userStructure.Effective_Date__c = System.today()+1;
		userStructure.Status__c = 'A';

		Boolean result = UserManagementService.doesUserStructureActive(userRM,userStructure);
		System.assertEquals(false,result);
	}

	@isTest static void Given_UserStructureNoUserRole_When_ValidateUserStructure_Then_ReturnFalse() {
		String rcCodeNoRole = '321';
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		
		User_Structure__c userStructure = new User_Structure__c();
		userStructure.First_Name__c = 'First_Name__c';
		userStructure.Last_Name__c = 'Last_Name__c';
		userStructure.Email__c = 'Email__c';
		userStructure.RC_Code__c = rcCodeNoRole;

		Boolean result = UserManagementService.validateUserStructure(userStructure,GlobalConstants.RBS_RM_BAR);
		System.assertEquals(false,result);
	}

	@isTest static void Given_UserStructureNoJobCode_When_ValidateUserStructure_Then_ReturnFalse() {
		String jobCodeNotInSalesforce = 'TU1A';
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		
		User_Structure__c userStructure = new User_Structure__c();
		userStructure.First_Name__c = 'First_Name__c';
		userStructure.Last_Name__c = 'Last_Name__c';
		userStructure.Email__c = 'Email__c';
		userStructure.Job_Code__c = jobCodeNotInSalesforce;

		Boolean result = UserManagementService.validateUserStructure(userStructure,GlobalConstants.RBS_RM_BAR);
		System.assertEquals(false,result);
	}

	@isTest static void Given_UserStructureNoFirstName_When_ValidateUserStructure_Then_ReturnFalse() {
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		
		User_Structure__c userStructure = new User_Structure__c();
		userStructure.Last_Name__c = 'Last_Name__c';
		userStructure.Email__c = 'Email__c';
		userStructure.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1;

		Boolean result = UserManagementService.validateUserStructure(userStructure,GlobalConstants.RBS_RM_BAR);
		System.assertEquals(false,result);
	}

	@isTest static void Given_UserStructureNoLastName_When_ValidateUserStructure_Then_ReturnFalse() {
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		
		User_Structure__c userStructure = new User_Structure__c();
		userStructure.First_Name__c = 'First_Name__c';
		userStructure.Email__c = 'Email__c';
		userStructure.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1;

		Boolean result = UserManagementService.validateUserStructure(userStructure,GlobalConstants.RBS_RM_BAR);
		System.assertEquals(false,result);
	}

	@isTest static void Given_UserStructureNoEmail_When_ValidateUserStructure_Then_ReturnFalse() {
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		
		User_Structure__c userStructure = new User_Structure__c();
		userStructure.First_Name__c = 'First_Name__c';
		userStructure.Last_Name__c = 'Last_Name__c';
		userStructure.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1;

		Boolean result = UserManagementService.validateUserStructure(userStructure,GlobalConstants.RBS_RM_BAR);
		System.assertEquals(false,result);
	}

	@isTest static void Given_UserActingFlagFalse_When_DisableActingFlag_Then_ActingFlagEqualFalse() {
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		
		User userNH = new User();
		userNH.Acting_Flag__c = false;
		UserManagementService.disableActingFlag(new User_Structure__c(),userNH ,GlobalConstants.RBS_NH);
		System.assertEquals(false,userNH.Acting_Flag__c);

		User userAH = new User();
		userAH.Acting_Flag__c = false;
		UserManagementService.disableActingFlag(new User_Structure__c(),userAH ,GlobalConstants.RBS_AH);
		System.assertEquals(false,userAH.Acting_Flag__c);

		User userTM = new User();
		userTM.Acting_Flag__c = false;
		UserManagementService.disableActingFlag(new User_Structure__c(),userTM ,GlobalConstants.RBS_TM);
		System.assertEquals(false,userTM.Acting_Flag__c);

		User userRM = new User();
		userRM.Acting_Flag__c = false;
		UserManagementService.disableActingFlag(new User_Structure__c(),userRM ,GlobalConstants.RBS_RM_BAR);
		System.assertEquals(false,userRM.Acting_Flag__c);
	}

	@isTest static void Given_UserActingFlagTrueUserStructureHasSameDataWithUser_When_DisableActingFlag_Then_ActingFlagEqualFalse() {
		UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		
		User userNH = new User();
		userNH.Acting_Flag__c = true;
		userNH.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_NH;
		userNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userNH.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;

		User_Structure__c userStructureNH = new User_Structure__c();
		userStructureNH.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_NH;
		userStructureNH.RC_Code__c = Mockup_Test.NH_RC_CODE;
		userStructureNH.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;

		UserManagementService.disableActingFlag(userStructureNH,userNH ,GlobalConstants.RBS_NH);
		System.assertEquals(false,userNH.Acting_Flag__c);

		User userAH = new User();
		userAH.Acting_Flag__c = true;
		userAH.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_AH;
		userAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;

		User_Structure__c userStructureAH = new User_Structure__c();
		userStructureAH.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_AH;
		userStructureAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userStructureAH.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userStructureAH.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;

		UserManagementService.disableActingFlag(userStructureAH,userAH ,GlobalConstants.RBS_AH);
		System.assertEquals(false,userAH.Acting_Flag__c);

		User userTM = new User();
		userTM.Acting_Flag__c = true;
		userTM.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_NH;
		userTM.RC_Code__c = Mockup_Test.RC_CODE;
		userTM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userTM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;

		User_Structure__c userStructureTM = new User_Structure__c();
		userStructureTM.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_NH;
		userStructureTM.RC_Code__c = Mockup_Test.RC_CODE;
		userStructureTM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userStructureTM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;

		UserManagementService.disableActingFlag(userStructureTM,userTM ,GlobalConstants.RBS_TM);
		System.assertEquals(false,userTM.Acting_Flag__c);

		User userRM = new User();
		userRM.Acting_Flag__c = true;
		userRM.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_NH;
		userRM.RC_Code__c = Mockup_Test.RC_CODE;
		userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;

		User_Structure__c userStructureRM = new User_Structure__c();
		userStructureRM.Job_Code__c = UserManagementMockupTest.JOB_CODE_RBS_NH;
		userStructureRM.RC_Code__c = Mockup_Test.RC_CODE;
		userStructureRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userStructureRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;

		UserManagementService.disableActingFlag(userStructureRM,userRM ,GlobalConstants.RBS_RM_BAR);
		System.assertEquals(false,userRM.Acting_Flag__c);
	}

	@isTest static void Given_UserNull_When_SkipUpdateUser_Then_ReturnFalse() {
		Boolean result = UserManagementService.skipUpdateUser(null,GlobalConstants.RBS_RM_BAR);
		System.assertEquals(false,result);
	}

	@isTest static void Given_UserActingFlagTrue_When_SkipUpdateUser_Then_ReturnTrue() {
		User user = new User();
		user.Acting_Flag__c = true;

		Boolean result = UserManagementService.skipUpdateUser(user,GlobalConstants.RBS_RM_BAR);
		System.assertEquals(true,result);
	}

	@isTest static void Given_UserActingFlagFalse_When_SkipUpdateUser_Then_ReturnFalse() {
		User user = new User();
		user.Acting_Flag__c = false;

		Boolean result = UserManagementService.skipUpdateUser(user,GlobalConstants.RBS_RM_BAR);
		System.assertEquals(false,result);
	}

	@isTest static void Given_UserStructure_When_Calculate_Then_Create1User1UserExtension(){
		System.runAs(new User(Id =UserInfo.getUserId())){
			UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		}

		User_Structure__c userStructure = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdRM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1, 'A', System.today());

		Test.startTest();

		RBSUserManagement rbsClass = new RBSUserManagement();
		DML_Queueable dmlQueue = new DML_Queueable();
		System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.calculateUser(new List<User_Structure__c>{userStructure});
			rbsClass.executeUpdateInactiveUser();
			rbsClass.executeInsertActiveUser();
			rbsClass.executeUpdateActiveUser();
			rbsClass.prepareUpsertUserExtension(dmlQueue);
	        rbsClass.prepareUpdateUserStructure(dmlQueue);
	        rbsClass.executeInsertUserPermission();
	    }
	    System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.executeOtherObject(dmlQueue);
		}
		Test.stopTest();

		User resultUser = [SELECT Id FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdRM LIMIT 1];
		System.assertNotEquals(null,resultUser);
		List<User_Extension__c> listUserEx = [SELECT Id FROM User_Extension__c];
		System.assertEquals(1,listUserEx.size());		
	}

	@isTest static void Given_UserStructureFullTeam_When_Calculate_Then_CreateUserUserExtensionFullTeam(){
		System.runAs(new User(Id =UserInfo.getUserId())){
			UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		}

		User_Structure__c userStructureRM = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdRM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1, 'A', System.today());
		User_Structure__c userStructureTM = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdTM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'A', System.today());
		User_Structure__c userStructureAH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdAH, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, UserManagementMockupTest.JOB_CODE_RBS_AH, 'A', System.today());
		User_Structure__c userStructureNH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdNH, Mockup_Test.NH_RC_CODE, null, Mockup_Test.NH_RC_CODE, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, UserManagementMockupTest.JOB_CODE_RBS_NH, 'A', System.today());

		List<User_Structure__c> listUserStructureNH = new List<User_Structure__c>{userStructureNH};
		List<User_Structure__c> listUserStructureAH = new List<User_Structure__c>{userStructureAH};
		List<User_Structure__c> listUserStructureTM = new List<User_Structure__c>{userStructureTM};
		List<User_Structure__c> listUserStructureRM = new List<User_Structure__c>{userStructureRM};
		Test.startTest();

		//NH
		RBSUserManagement rbsClass = new RBSUserManagement();
		DML_Queueable dmlQueue = new DML_Queueable();
		System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.calculateUser(listUserStructureNH);
			rbsClass.executeUpdateInactiveUser();
			rbsClass.executeInsertActiveUser();
			rbsClass.executeUpdateActiveUser();
			rbsClass.prepareUpsertUserExtension(dmlQueue);
	        rbsClass.prepareUpdateUserStructure(dmlQueue);
	        rbsClass.executeInsertUserPermission();
	    }
	    System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.executeOtherObject(dmlQueue);
		}

		//AH
		insert listUserStructureNH;
		rbsClass = new RBSUserManagement(GlobalConstants.RBS_AH);
		dmlQueue = new DML_Queueable();
		System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.calculateUser(listUserStructureAH);
			rbsClass.executeUpdateInactiveUser();
			rbsClass.executeInsertActiveUser();
			rbsClass.executeUpdateActiveUser();
			rbsClass.prepareUpsertUserExtension(dmlQueue);
	        rbsClass.prepareUpdateUserStructure(dmlQueue);
	        rbsClass.executeInsertUserPermission();
	    }
	    System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.executeOtherObject(dmlQueue);
		}

		//TM
		insert listUserStructureAH;
		rbsClass = new RBSUserManagement(GlobalConstants.RBS_TM);
		dmlQueue = new DML_Queueable();
		System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.calculateUser(listUserStructureTM);
			rbsClass.executeUpdateInactiveUser();
			rbsClass.executeInsertActiveUser();
			rbsClass.executeUpdateActiveUser();
			rbsClass.prepareUpsertUserExtension(dmlQueue);
	        rbsClass.prepareUpdateUserStructure(dmlQueue);
	        rbsClass.executeInsertUserPermission();
	    }
	    System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.executeOtherObject(dmlQueue);
		}

		//RM
		insert listUserStructureTM;
		rbsClass = new RBSUserManagement(GlobalConstants.RBS_RM_BAR);
		dmlQueue = new DML_Queueable();
		System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.calculateUser(listUserStructureRM);
			rbsClass.executeUpdateInactiveUser();
			rbsClass.executeInsertActiveUser();
			rbsClass.executeUpdateActiveUser();
			rbsClass.prepareUpsertUserExtension(dmlQueue);
	        rbsClass.prepareUpdateUserStructure(dmlQueue);
	        rbsClass.executeInsertUserPermission();
	    }
	    System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.executeOtherObject(dmlQueue);
		}
		Test.stopTest();

		User resultUserRM = [SELECT Id,ManagerId,RC_Code__c,Profile.Name FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdRM LIMIT 1];
		User resultUserTM = [SELECT Id,ManagerId,RC_Code__c,Profile.Name FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdTM LIMIT 1];
		User resultUserAH = [SELECT Id,ManagerId,RC_Code__c,Profile.Name FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdAH LIMIT 1];
		User resultUserNH = [SELECT Id,ManagerId,RC_Code__c,Profile.Name FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdNH LIMIT 1];
		System.assertEquals(GlobalConstants.RBS_RM_BAR,resultUserRM.Profile.Name);
		System.assertEquals(resultUserTM.Id,resultUserRM.ManagerId);
		System.assertEquals(GlobalConstants.RBS_TM,resultUserTM.Profile.Name);
		System.assertEquals(resultUserAH.Id,resultUserTM.ManagerId);
		System.assertEquals(GlobalConstants.RBS_AH,resultUserAH.Profile.Name);
		System.assertEquals(resultUserNH.Id,resultUserAH.ManagerId);
		System.assertEquals(GlobalConstants.RBS_NH,resultUserNH.Profile.Name);
		List<User_Extension__c> listUserEx = [SELECT Id FROM User_Extension__c];
		System.assertEquals(4,listUserEx.size());
	}

	@isTest static void Given_OldTmInactiveNewTmActive_When_Calculate_Then_ChangeRmManager(){
		System.runAs(new User(Id =UserInfo.getUserId())){
			UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		}

		TriggerHandler.bypass('UserTriggerHandler');
		User userTM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdTM, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, true, null);
		userTM.RC_Code__c = Mockup_Test.RC_CODE;
		userTM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userTM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userTM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_BM).Id;
		insert userTM;

		User userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, userTM.Id);
		userRM.RC_Code__c = Mockup_Test.RC_CODE;
		userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userRM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1).Id;
		insert userRM;

		User_Structure__c userStructureRM1 = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdRM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameRM+'1', Mockup_Test.userLastNameRM+'1', UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1, 'A', System.today());
		User_Structure__c userStructureRM2 = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdRMDiff, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameRM+'2', Mockup_Test.userLastNameRM+'2', UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1, 'A', System.today());
		User_Structure__c userStructureTM1 = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdTM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameTM+'1', Mockup_Test.userLastNameTM+'1', UserManagementMockupTest.JOB_CODE_RBS_BM, 'I', System.today());
		User_Structure__c userStructureTM2 = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdTMDiff, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameTM+'2', Mockup_Test.userLastNameTM+'2', UserManagementMockupTest.JOB_CODE_RBS_BM, 'A', System.today());

		List<User_Structure__c> listUserStructureTM = new List<User_Structure__c>{userStructureTM1,userStructureTM2};
		List<User_Structure__c> listUserStructureRM = new List<User_Structure__c>{userStructureRM1,userStructureRM2};
		Test.startTest();

		//TM
		System.runAs(new User(Id =UserInfo.getUserId())){
			insert listUserStructureTM;
		}

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_TM);
		DML_Queueable dmlQueue = new DML_Queueable();
		System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.calculateUser(listUserStructureTM);
			rbsClass.executeUpdateInactiveUser();
			rbsClass.executeInsertActiveUser();
			rbsClass.executeUpdateActiveUser();
			rbsClass.prepareUpsertUserExtension(dmlQueue);
	        rbsClass.prepareUpdateUserStructure(dmlQueue);
	        rbsClass.executeInsertUserPermission();
	    }
	    System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.executeOtherObject(dmlQueue);
		}

		//RM
		rbsClass = new RBSUserManagement(GlobalConstants.RBS_RM_BAR);
		dmlQueue = new DML_Queueable();
		System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.calculateUser(listUserStructureRM);
			rbsClass.executeUpdateInactiveUser();
			rbsClass.executeInsertActiveUser();
			rbsClass.executeUpdateActiveUser();
			rbsClass.prepareUpsertUserExtension(dmlQueue);
	        rbsClass.prepareUpdateUserStructure(dmlQueue);
	        rbsClass.executeInsertUserPermission();
	    }
	    System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.executeOtherObject(dmlQueue);
		}
		Test.stopTest();

		User resultUserRM1 = [SELECT Id,ManagerId,RC_Code__c,Profile.Name FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdRM LIMIT 1];
		User resultUserRM2 = [SELECT Id,ManagerId,RC_Code__c,Profile.Name FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdRMDiff LIMIT 1];
		User resultUserTM1 = [SELECT Id,ManagerId,RC_Code__c,Profile.Name,IsActive FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdTM LIMIT 1];
		User resultUserTM2 = [SELECT Id,ManagerId,RC_Code__c,Profile.Name,IsActive FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdTMDiff LIMIT 1];
		
		System.assertEquals(false,resultUserTM1.IsActive);
		System.assertEquals(true,resultUserTM2.IsActive);
		System.assertEquals(resultUserTM2.Id,resultUserRM1.ManagerId);
		System.assertEquals(resultUserTM2.Id,resultUserRM2.ManagerId);
	}

	@isTest static void Given_PromoteRmToTmAndDemoteTmToRm_When_Calculate_Then_ChangeProfileAndManager(){
		System.runAs(new User(Id =UserInfo.getUserId())){
			UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		}

		TriggerHandler.bypass('UserTriggerHandler');
		User userTM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdTM, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, true, null);
		userTM.RC_Code__c = Mockup_Test.RC_CODE;
		userTM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userTM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userTM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_BM).Id;
		insert userTM;

		User userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, userTM.Id);
		userRM.RC_Code__c = Mockup_Test.RC_CODE;
		userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userRM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1).Id;
		insert userRM;

		User_Structure__c userStructureRMToTM = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdRM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'A', System.today());
		User_Structure__c userStructureTMToRM = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdTM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1, 'A', System.today());

		List<User_Structure__c> listUserStructureTM = new List<User_Structure__c>{userStructureRMToTM};
		List<User_Structure__c> listUserStructureRM = new List<User_Structure__c>{userStructureTMToRM};
		Test.startTest();

		//TM
		System.runAs(new User(Id =UserInfo.getUserId())){
			insert listUserStructureTM;
		}

		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_TM);
		DML_Queueable dmlQueue = new DML_Queueable();
		System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.calculateUser(listUserStructureTM);
			rbsClass.executeUpdateInactiveUser();
			rbsClass.executeInsertActiveUser();
			rbsClass.executeUpdateActiveUser();
			rbsClass.prepareUpsertUserExtension(dmlQueue);
	        rbsClass.prepareUpdateUserStructure(dmlQueue);
	        rbsClass.executeInsertUserPermission();
	    }
	    System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.executeOtherObject(dmlQueue);
		}

		//RM
		rbsClass = new RBSUserManagement(GlobalConstants.RBS_RM_BAR);
		dmlQueue = new DML_Queueable();
		System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.calculateUser(listUserStructureRM);
			rbsClass.executeUpdateInactiveUser();
			rbsClass.executeInsertActiveUser();
			rbsClass.executeUpdateActiveUser();
			rbsClass.prepareUpsertUserExtension(dmlQueue);
	        rbsClass.prepareUpdateUserStructure(dmlQueue);
	        rbsClass.executeInsertUserPermission();
	    }
	    System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.executeOtherObject(dmlQueue);
		}
		Test.stopTest();

		User resultUserTMDemoteToRM = [SELECT Id,ManagerId,RC_Code__c,Profile.Name FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdTM LIMIT 1];
		User resultUserRMPromoteToTM = [SELECT Id,ManagerId,RC_Code__c,Profile.Name FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdRM LIMIT 1];
		
		System.assertEquals(resultUserRMPromoteToTM.Id,resultUserTMDemoteToRM.ManagerId);
		System.assertEquals(GlobalConstants.RBS_RM_BAR,resultUserTMDemoteToRM.Profile.Name);
		System.assertEquals(GlobalConstants.RBS_TM,resultUserRMPromoteToTM.Profile.Name);
	}

	@isTest static void Given_AhAndDemoteTmToRm_When_Calculate_Then_ChangeManagerToAh(){
		System.runAs(new User(Id =UserInfo.getUserId())){
			UserManagementMockupTest.init(Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, GlobalConstants.SEGMENT_BN);
		}

		TriggerHandler.bypass('UserTriggerHandler');
		User userAH = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdAH, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, true, null);
		userAH.RC_Code__c = Mockup_Test.AH_RC_CODE;
		userAH.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_AH).Id;
		insert userAH;

		User userTM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdTM, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, true, userAH.Id);
		userTM.RC_Code__c = Mockup_Test.RC_CODE;
		userTM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userTM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userTM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_BM).Id;
		insert userTM;

		User userRM = UserManagementMockupTest.createNewUser(Mockup_Test.userEmpIdRM, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, true, userTM.Id);
		userRM.RC_Code__c = Mockup_Test.RC_CODE;
		userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		userRM.ProfileId = UserManagementMockupTest.getProfileByJobCode(UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1).Id;
		insert userRM;

		User_Structure__c userStructureRM = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdRM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameRM, Mockup_Test.userLastNameRM, UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1, 'A', System.today());
		User_Structure__c userStructureTMToRM = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdTM, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.RC_CODE, Mockup_Test.userFirstNameTM, Mockup_Test.userLastNameTM, UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1, 'A', System.today());
		User_Structure__c userStructureAH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdAH, Mockup_Test.NH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.AH_RC_CODE, Mockup_Test.userFirstNameAH, Mockup_Test.userLastNameAH, UserManagementMockupTest.JOB_CODE_RBS_AH, 'A', System.today());
		User_Structure__c userStructureNH = Mockup_Test.newUserStructure(Mockup_Test.userEmpIdNH, Mockup_Test.NH_RC_CODE, null, Mockup_Test.NH_RC_CODE, Mockup_Test.userFirstNameNH, Mockup_Test.userLastNameNH, UserManagementMockupTest.JOB_CODE_RBS_NH, 'A', System.today());

		List<User_Structure__c> listUserStructureRM = new List<User_Structure__c>{userStructureTMToRM,userStructureRM};
		Test.startTest();

		System.runAs(new User(Id = UserInfo.getUserId())){
			insert new List<User_Structure__c>{userStructureAH,userStructureNH};
		}

		//RM
		RBSUserManagement rbsClass = new RBSUserManagement(GlobalConstants.RBS_RM_BAR);
		DML_Queueable dmlQueue = new DML_Queueable();
		System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.calculateUser(listUserStructureRM);
			rbsClass.executeUpdateInactiveUser();
			rbsClass.executeInsertActiveUser();
			rbsClass.executeUpdateActiveUser();
			rbsClass.prepareUpsertUserExtension(dmlQueue);
	        rbsClass.prepareUpdateUserStructure(dmlQueue);
	        rbsClass.executeInsertUserPermission();
	    }
	    System.runAs(new User(Id =UserInfo.getUserId())){
			rbsClass.executeOtherObject(dmlQueue);
		}
		Test.stopTest();

		User resultUserTMDemoteToRM = [SELECT Id,ManagerId,RC_Code__c,Profile.Name FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdTM LIMIT 1];
		User resultUserRM = [SELECT Id,ManagerId,RC_Code__c,Profile.Name FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdRM LIMIT 1];

		System.assertEquals(userAH.Id,resultUserTMDemoteToRM.ManagerId);
		System.assertEquals(userAH.Id,resultUserRM.ManagerId);
	}
}