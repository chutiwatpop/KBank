@isTest
private class EventAssignment_Test {
	public static final String RC_CODE    = '888881';
    public static final String AH_RC_CODE = '888882';
    public static final String NH_RC_CODE = '888883';
    public static final String RC_CODE_2    = '881404';
    public static final String AH_RC_CODE_2 = '881400';
    public static final String NH_RC_CODE_2 = '881201';

	public static final String RBS_BM_EMP 		 = '7000000002';
    public static final String RBS_BM_FIRST_NAME = 'RBSFirstName1';
	public static final String RBS_BM_LAST_NAME  = 'RBSLastName1';

	public static final String RBS_RM_EMP 		 = '7000000001';
    public static final String RBS_RM_FIRST_NAME = 'RBSFirstName';
	public static final String RBS_RM_LAST_NAME  = 'RBSLastName';

	public static final String RBS_BM_EMP_2 	   = '7000000012';
    public static final String RBS_BM_FIRST_NAME_2 = 'RBSFirstName2';
	public static final String RBS_BM_LAST_NAME_2  = 'RBSLastName2';

	@testSetup static void setUpTest(){
		Mockup_Test.setUpCustomSetting();
	}
	
	private static Map<String, User> setUpUser() {
		UserTriggerHandler.isByPass = true;
		Map<String, User> userMapByEmpId = new Map<String, User>();
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'RBS');
		User RBS_BM = UserManagementMockupTest.createNewUser(RBS_BM_EMP, RBS_BM_FIRST_NAME, RBS_BM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE);
		RBS_BM.Pending_for_Ownership_Calculation__c = true;
		insert RBS_BM;

		User RBS_RM = UserManagementMockupTest.createNewUser(RBS_RM_EMP, RBS_RM_FIRST_NAME, RBS_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_RM, UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1, 'RCRM', RC_CODE);
		RBS_RM.Pending_for_Ownership_Calculation__c = true;
		insert RBS_RM;

		UserManagementMockupTest.init(NH_RC_CODE_2, AH_RC_CODE_2, RC_CODE_2, 'RBS');
		User RBS_BM_2 = UserManagementMockupTest.createNewUser(RBS_BM_EMP_2, RBS_BM_FIRST_NAME_2, RBS_BM_LAST_NAME_2, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM_2, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE_2);
		RBS_BM_2.Pending_for_Ownership_Calculation__c = false;
		insert RBS_BM_2;

		Team_Structure__c branchTeam1 = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE);
		branchTeam1.OwnerId = RBS_BM.Id;

		Team_Structure__c branchTeam2 = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE_2);
		branchTeam2.OwnerId = RBS_BM_2.Id;
		
		System.runAs(new User(Id=UserInfo.getUserId())){
			update branchTeam1;
			update branchTeam2;

			List<User_Extension__c> userExtensionList = new List<User_Extension__c>();
			User_Extension__c RBS_RM_EXT = UserService.createUserExtension(RBS_RM, UserManagementMockupTest.mapTeamByRCCode);
			User_Extension__c RBS_BM_EXT = UserService.createUserExtension(RBS_BM, UserManagementMockupTest.mapTeamByRCCode);
			User_Extension__c RBS_BM_2_EXT = UserService.createUserExtension(RBS_BM_2, UserManagementMockupTest.mapTeamByRCCode);
			userExtensionList.add(RBS_RM_EXT);
			userExtensionList.add(RBS_BM_EXT);
			userExtensionList.add(RBS_BM_2_EXT);

			upsert userExtensionList External_ID__c;
		}

		userMapByEmpId.put(RBS_BM_EMP, RBS_BM);
		userMapByEmpId.put(RBS_RM_EMP, RBS_RM);
		userMapByEmpId.put(RBS_BM_EMP_2, RBS_BM_2);
		return userMapByEmpId;
	}		

	private static Account createCustomer(String name, String portPool, String recordTypeDevName, String customerSegment) {
		Id recordTypeId = GlobalUtility.getRecordTypeId('Account', recordTypeDevName);
		Account newAccount = new Account(
            Port_Pool__c = portPool,
            RecordTypeId = recordTypeId,
            Primary_Segment_Code__c 	= customerSegment,
            Customer_Segment_Code__c 	= customerSegment,
            Is_createby_Integration__c 	= true
        );
        if(recordTypeDevName == GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME || 
        	recordTypeDevName == GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME) {
            newAccount.LastName = name;
        } else if(recordTypeDevName == GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME || 
        	recordTypeDevName == GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME) {
            newAccount.Name = name;
        }

        return newAccount;
	}

	private static Event createEvent(Opportunity targetOpp) {
		return new Event(
			WhatId 			= targetOpp.Id,
			OwnerId 		= UserInfo.getUserId(),
			Status__c 		= GlobalConstants.PLAN,
			StartDateTime 	= System.now(),
			EndDateTime 	= System.now().addDays(7),
			RecordTypeId 	= GlobalUtility.getRecordTypeId('Event', GlobalConstants.RBS_CALL_PLAN_DEVNAME)
		);
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

	@isTest static void RBS_RM_InActive() {
		//********* GIVEN *********//
		Map<String, User> userMapByEmpId = setUpUser();
		User RBS_RM = userMapByEmpId.get(RBS_RM_EMP);
		User RBS_BM = userMapByEmpId.get(RBS_BM_EMP);
		
		Opportunity targetOpp;
		System.runAs(RBS_RM) {
			// New Account
			Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
			insert I_CUSTOMER_PORT;
			// New Job
			targetOpp = Mockup_Test.newOpportunity(I_CUSTOMER_PORT.Id, 'JobName', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
	        insert targetOpp;
	        // New Event
	        insert createEvent(targetOpp);
	    }
	    //********* WHEN *********//
	    User RBS_RM_UPDATED = RBS_RM.clone(true, true, false, false); // deep clone
	    RBS_RM_UPDATED.isActive = false;
		Map<Id, User_MaskModel> userMaskMapByUserId = mockUserMaskModel(userMapByEmpId.values());
		updateUserMask(userMaskMapByUserId, RBS_RM_UPDATED);

        Test.startTest();
        System.assertNotEquals(0, [SELECT Count() FROM Team_Structure__c]);
		EventAssignmentQueue.doChainJob = false;
		System.enqueueJob(new EventAssignmentQueue(userMaskMapByUserId));
		Test.stopTest();

		//********* THEN *********//
		User_Extension__c RBS_BM_EXT = [SELECT Id FROM User_Extension__c WHERE User__c = :RBS_BM.Id];
		Event updatedEvent = [SELECT Id, OwnerId, Created_By_User_Extension__c FROM Event WHERE WhatId = :targetOpp.Id];
        System.assertEquals(RBS_BM.Id, updatedEvent.OwnerId);
        System.assertEquals(RBS_BM_EXT.Id, updatedEvent.Created_By_User_Extension__c);
	}

	@isTest static void reAssignto_RBS_BM() {
		//********* GIVEN *********//
		Map<String, User> userMapByEmpId = setUpUser();
		User RBS_RM = userMapByEmpId.get(RBS_RM_EMP);
		User RBS_BM = userMapByEmpId.get(RBS_BM_EMP);
		RBS_BM.IsActive = false;
		update RBS_BM;

		Opportunity targetOpp;
		System.runAs(RBS_RM) {
			// New Account
			Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
			insert I_CUSTOMER_PORT;
			// New Job
			targetOpp = Mockup_Test.newOpportunity(I_CUSTOMER_PORT.Id, 'JobName', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
	        insert targetOpp;
	        // New Event
	        Event targetEvent = createEvent(targetOpp);
	        targetEvent.Previous_RC_Code__c = RC_CODE;
	        insert targetEvent;
	    }
	    Event afterCreated = [SELECT Id, OwnerId, Created_By_User_Extension__c FROM Event WHERE WhatId = :targetOpp.Id];
        System.assertEquals(RBS_RM.Id, afterCreated.OwnerId);

	    //********* WHEN *********//
	    User RBS_BM_UPDATED = RBS_BM.clone(true, true, false, false); // deep clone
	    RBS_BM_UPDATED.isActive = true;
		Map<Id, User_MaskModel> userMaskMapByUserId = mockUserMaskModel(userMapByEmpId.values());
		updateUserMask(userMaskMapByUserId, RBS_BM_UPDATED);

        Test.startTest();
        System.assertNotEquals(0, [SELECT Count() FROM Team_Structure__c]);
		EventAssignmentQueue.doChainJob = false;
		System.enqueueJob(new EventAssignmentQueue(userMaskMapByUserId));
		Test.stopTest();

		//********* THEN *********//
		User_Extension__c RBS_BM_EXT = [SELECT Id FROM User_Extension__c WHERE User__c = :RBS_BM.Id];
		Event updatedEvent = [SELECT Id, OwnerId, Created_By_User_Extension__c FROM Event WHERE WhatId = :targetOpp.Id];
        System.assertEquals(RBS_BM.Id, updatedEvent.OwnerId);
        System.assertEquals(RBS_BM_EXT.Id, updatedEvent.Created_By_User_Extension__c);
	}
}