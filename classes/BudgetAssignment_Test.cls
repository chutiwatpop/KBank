@isTest
private class BudgetAssignment_Test {
	static final Id TRANSFER_BUDGET				= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.TRANSFER_BUDGET_DEVNAME);
	static final Id TRANSFER_BUDGET_READ_ONLY	= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.TRANSFER_BUDGET_READ_ONLY_DEVNAME);
	static final Id REQUEST_BUDGET				= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.REQUEST_BUDGET_DEVNAME);
	static final Id REQUEST_BUDGET_READ_ONLY	= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.REQUEST_BUDGET_READ_ONLY_DEVNAME);
	
	static final String UserFirstNameNH = 'FirstnameNH';
	static final String UserLastNameNH = 'LastnameNH';
	static final String UserFirstNameZM = 'FirstnameZM';
	static final String UserLastNameZM = 'LastnameZM';
	static final String UserFirstNameBM = 'FirstnameBM';
	static final String UserLastNameBM = 'LastnameBM';

	static final String NH_RC_CODE = '10000';
	static final String ZM_RC_CODE = '10100';
	static final String BM_RC_CODE = '10101';

	static final String userEmpIdNH = '1000000001';
	static final String userEmpIdZM = '1000000002';
	static final String userEmpIdBM = '1000000003';

	@TestSetup
	static void setupTest(){
		System.runAs(new User(Id=UserInfo.getUserId())) {
			Profile nhProfile = Mockup_Test.getMapProfileByName(GlobalConstants.RBS_NH);
			Profile zmProfile = Mockup_Test.getMapprofileByName(GlobalConstants.RBS_AH);
			Profile bmProfile = Mockup_Test.getMapprofileByName(GlobalConstants.RBS_TM);

			UserRole nhRole = Mockup_Test.newRole(NH_RC_CODE, 'RC' + NH_RC_CODE, null);
			insert nhRole;
			UserRole zmRole = Mockup_Test.newRole(ZM_RC_CODE, 'RC' + ZM_RC_CODE, nhRole.Id);
			insert zmRole;
			UserRole bmRole = Mockup_Test.newRole(BM_RC_CODE, 'RC' + BM_RC_CODE, zmRole.Id);
			insert bmRole;

			User nhUser = Mockup_Test.newUser(
				UserFirstNameNH,
				UserLastNameNH,
				true,
				UserFirstNameNH + '@mail.com',
				UserFirstNameNH + '@mail.com',
				UserFirstNameNH.substring(0, 4),
				nhProfile.Id,
				nhRole.Id,
				null,
				userEmpIdNH
			);
			nhUser.RC_Code__c = NH_RC_Code;
			nhUser.NH_RC_CODE__c = NH_RC_CODE;
			insert nhUser;

			User zmUser = Mockup_Test.newUser(
				UserFirstNameZM,
				UserLastNameZM,
				true,
				UserFirstNameZM + '@mail.com',
				UserFirstNameZM + '@mail.com',
				UserFirstNameZM.substring(0, 4),
				zmProfile.Id,
				zmRole.Id,
				nhUser.Id,
				userEmpIdZM
			);
			zmUser.RC_Code__c = ZM_RC_CODE;
			zmUser.NH_RC_CODE__c = NH_RC_CODE;
			zmUser.AH_RC_Code__c = ZM_RC_CODE;
			insert zmUser;

			User bmUser = Mockup_Test.newUser(
				UserFirstNameBM,
				UserLastNameBM,
				true,
				UserFirstNameBM + '@mail.com',
				UserFirstNameBM + '@mail.com',
				UserFirstNameBM.substring(0, 4),
				bmProfile.Id,
				bmRole.Id,
				zmUser.Id,
				userEmpIdBM
			);
			bmUser.RC_Code__c = BM_RC_CODE;
			bmUser.NH_RC_CODE__c = NH_RC_CODE;
			bmUser.AH_RC_Code__c = ZM_RC_CODE;
			insert bmUser;

			Team_Structure__c ts_rbs_nh = new Team_Structure__c(
				External_ID__c = NH_RC_CODE,
				RC_Code__c = NH_RC_CODE,
				AH_RC_Code__c = null,
				NH_RC_CODE__c = null,
				Name = 'ภาค',
				OwnerId = nhUser.Id
			);
			insert ts_rbs_nh;

			Team_Structure__c ts_rbs_zm = new Team_Structure__c(
				External_ID__c = ZM_RC_CODE,
				RC_Code__c = ZM_RC_CODE,
				AH_RC_Code__c = null,
				NH_RC_CODE__c = NH_RC_CODE,
				Name = 'เขต',
				OwnerId = zmUser.Id
			);
			insert ts_rbs_zm;

			Team_Structure__c ts_rbs_bm = new Team_Structure__c(
				External_ID__c = BM_RC_CODE,
				RC_Code__c = BM_RC_CODE,
				AH_RC_Code__c = ZM_RC_CODE,
				NH_RC_CODE__c = NH_RC_CODE,
				Name = 'สาขาที่1',
				OwnerId = bmUser.Id
			);
			insert ts_rbs_bm;
		}
	}

	private static Budget__c createMainBudget(Id recordTypeId, Id OwnerId, String Stage) {
		Budget__c mainBudget = new Budget__c(
			recordTypeId = recordTypeId,
			OwnerId = OwnerId,
			Stage__c = Stage
		);
		insert mainBudget;
		return mainBudget;
	}

	private static Budget__c mockItemBudget(Id recordTypeId, Id ParentId, Id OwnerId) {
		Budget__c itemBudget = new Budget__c(
			recordTypeId = recordTypeId,
			Budget_ParentId__c = ParentId,
			OwnerId = OwnerId
		);
		insert itemBudget;
		return itemBudget;
	}

	private static Map<Id,User_MaskModel> mockUserMaskModel(List<User> userList) {
		Map<Id, User_MaskModel> userMaskMapByUserId = new Map<Id, User_MaskModel>();
		for(User eachUser : userList) {
			User_MaskModel userMask = new User_MaskModel();
	        userMask.userId = eachUser.Id;
	        userMask.setNewUser(eachUser);
	        userMask.setOldUser(eachUser);
	        userMaskMapByUserId.put(eachUser.Id, userMask);
		}
		return userMaskMapByUserId;
	}

	private static void updateUserMask(Map<Id, User_MaskModel> userMaskMapByUserId, User updatedUser) {
		User_MaskModel userMask = userMaskMapByUserId.get(updatedUser.Id);
		userMask.setNewUser(updatedUser);
	}

	private static Map<String, Team_Structure__c> getTeamStructureMapByName(){
		Map<String, Team_Structure__c> teamStructureMapByName = new Map<String, Team_Structure__c>();
		for(Team_Structure__c teamStructure : [SELECT Id, Name, OwnerId FROM Team_Structure__c]) {
			teamStructureMapByName.put(teamStructure.Name, teamStructure);
		} 
		return teamStructureMapByName; 
	}
	
	@isTest 
	static void transfer_Budget_Owner_InActive() {
		//********* GIVEN *********//
		Map<String,Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		User RBS_BM = [SELECT Id, FirstName, LastName, Segment__c, ProfileId, RC_Code__c, AH_RC_Code__c, NH_RC_CODE__c, Job_Code__c, IsActive FROM User WHERE Firstname = :UserFirstNameBM LIMIT 1][0];
		Id profileId = userInfo.getProfileId();
		String profileName = GlobalUtility.getProfileMap().get(userInfo.getProfileId()).Name;
		User_Management__c userManagement = new User_Management__c(Allow_Change_Budget_Owner__c = true);
		insert userManagement;

		System.runAs(RBS_BM) {
			createMainBudget(TRANSFER_BUDGET, RBS_BM.Id, GlobalConstants.BUDGET_OPEN);
			createMainBudget(TRANSFER_BUDGET, RBS_BM.Id, GlobalConstants.BUDGET_WAITING_FOR_APPROVE);
			createMainBudget(TRANSFER_BUDGET, RBS_BM.Id, GlobalConstants.BUDGET_APPROVED);
			createMainBudget(TRANSFER_BUDGET, RBS_BM.Id, GlobalConstants.BUDGET_COLLECT_DOCUMENT);
			System.debug(User_Management__c.getInstance(userInfo.getUserId()).Allow_Change_Budget_Owner__c);
		}
		//********* WHEN *********//
		User RBS_BM_UPDATED = RBS_BM.clone(true, true, false, false); // deep clone
	    RBS_BM_UPDATED.isActive = false;
		List<User> userList = new List<User> {RBS_BM};
		Map<Id, User_MaskModel> userMaskMapByUserId = mockUserMaskModel(userList);
		updateUserMask(userMaskMapByUserId, RBS_BM_UPDATED);

		Test.startTest();
		System.debug(profileName);
		System.debug(User_Management__c.getInstance(userInfo.getUserId()).Allow_Change_Budget_Owner__c);
        System.assertNotEquals(0, [SELECT Count() FROM Team_Structure__c]);
		EventAssignmentQueue.doChainJob = false;
		System.enqueueJob(new BudgetAssignmentQueue(userMaskMapByUserId));
		Test.stopTest();

		//********* THEN *********//
		for (Budget__c updatedBudget : [SELECT Id, recordTypeId, Stage__c FROM Budget__c WHERE OwnerId = :RBS_BM.Id]) {
			System.assertEquals(TRANSFER_BUDGET_READ_ONLY, updatedBudget.recordTypeId);
			System.assertEquals(GlobalConstants.BUDGET_CANCELLED, updatedBudget.Stage__c);
		}
	}
	
	@isTest 
	static void request_Budget_Owner_InActive() {
		// Implement test code
		//********* GIVEN *********//
		Map<String,Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		User RBS_BM = [SELECT Id, FirstName, LastName, Segment__c, ProfileId, RC_Code__c, AH_RC_Code__c, NH_RC_CODE__c, Job_Code__c, IsActive FROM User WHERE Firstname = :UserFirstNameBM LIMIT 1][0];
		Id profileId = userInfo.getProfileId();
		String profileName = GlobalUtility.getProfileMap().get(userInfo.getProfileId()).Name;
		User_Management__c userManagement = new User_Management__c(Allow_Change_Budget_Owner__c = true);
		insert userManagement;

		System.runAs(RBS_BM) {
			createMainBudget(REQUEST_BUDGET, RBS_BM.Id, GlobalConstants.BUDGET_OPEN);
			createMainBudget(REQUEST_BUDGET, RBS_BM.Id, GlobalConstants.BUDGET_WAITING_FOR_APPROVE);
			createMainBudget(REQUEST_BUDGET, RBS_BM.Id, GlobalConstants.BUDGET_APPROVED);
			createMainBudget(REQUEST_BUDGET, RBS_BM.Id, GlobalConstants.BUDGET_COLLECT_DOCUMENT);
			System.debug(User_Management__c.getInstance(userInfo.getUserId()).Allow_Change_Budget_Owner__c);
		}
		//********* WHEN *********//
		User RBS_BM_UPDATED = RBS_BM.clone(true, true, false, false); // deep clone
	    RBS_BM_UPDATED.isActive = false;
		List<User> userList = new List<User> {RBS_BM};
		Map<Id, User_MaskModel> userMaskMapByUserId = mockUserMaskModel(userList);
		updateUserMask(userMaskMapByUserId, RBS_BM_UPDATED);

		Test.startTest();
		System.debug(profileName);
		System.debug(User_Management__c.getInstance(userInfo.getUserId()).Allow_Change_Budget_Owner__c);
        System.assertNotEquals(0, [SELECT Count() FROM Team_Structure__c]);
		EventAssignmentQueue.doChainJob = false;
		System.enqueueJob(new BudgetAssignmentQueue(userMaskMapByUserId));
		Test.stopTest();

		//********* THEN *********//
		for (Budget__c updatedBudget : [SELECT Id, recordTypeId, Stage__c FROM Budget__c WHERE OwnerId = :RBS_BM.Id]) {
			System.assertEquals(REQUEST_BUDGET_READ_ONLY, updatedBudget.recordTypeId);
			System.assertEquals(GlobalConstants.BUDGET_CANCELLED, updatedBudget.Stage__c);
		}
	}
	
}