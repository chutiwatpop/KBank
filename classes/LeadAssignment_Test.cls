@isTest
private class LeadAssignment_Test {
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

	private static Map<String, User> setUpUser() {
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

	private static Lead createLead(Account targetCustomer) {
		Lead newLead = new Lead();
        newLead.LastName = 'LeadName';
        newLead.RecordTypeID = GlobalUtility.getRecordTypeId('Lead', GlobalConstants.LEAD_RECORDTYPE_LEAD_REFERRAL);
        return newLead;
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
		
		Account I_CUSTOMER_PORT;
		System.runAs(RBS_RM) {
			// New Account
			I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
			insert I_CUSTOMER_PORT;
			// New Lead
			Lead newLead = createLead(I_CUSTOMER_PORT);
			insert newLead;
	        newLead.Customer__c = I_CUSTOMER_PORT.Id;
	        update newLead;
	    }
	    //********* WHEN *********//
	    User RBS_RM_UPDATED = RBS_RM.clone(true, true, false, false); // deep clone
	    RBS_RM_UPDATED.isActive = false;
		Map<Id, User_MaskModel> userMaskMapByUserId = mockUserMaskModel(userMapByEmpId.values());
		updateUserMask(userMaskMapByUserId, RBS_RM_UPDATED);

        Test.startTest();
        System.assertNotEquals(0, [SELECT Count() FROM Team_Structure__c]);
		LeadAssignmentQueue.doChainJob = false;
		System.enqueueJob(new LeadAssignmentQueue(userMaskMapByUserId));
		Test.stopTest();

		//********* THEN *********//

		Lead updatedLead = [SELECT Id, Refer_To_User__c FROM Lead WHERE Customer__c = :I_CUSTOMER_PORT.Id];
        System.assertEquals(RBS_BM.Id, updatedLead.Refer_To_User__c);
	}

	@isTest static void reAssignto_RBS_BM() {
		//********* GIVEN *********//
		Map<String, User> userMapByEmpId = setUpUser();
		User RBS_RM = userMapByEmpId.get(RBS_RM_EMP);
		User RBS_BM = userMapByEmpId.get(RBS_BM_EMP);
		RBS_BM.IsActive = false;
		update RBS_BM;

		Account I_CUSTOMER_PORT;
		System.runAs(RBS_RM) {
			// New Account
			I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
			insert I_CUSTOMER_PORT;
			// New Lead
			Lead newLead = createLead(I_CUSTOMER_PORT);
			newLead.Previous_RC_Code__c = RC_CODE;
			insert newLead;
	        newLead.Customer__c = I_CUSTOMER_PORT.Id;
	        update newLead;
	    }
	    Lead afterCreated = [SELECT Id, Refer_To_User__c FROM Lead WHERE Customer__c = :I_CUSTOMER_PORT.Id];
        System.assertEquals(RBS_RM.Id, afterCreated.Refer_To_User__c);

	    //********* WHEN *********//
	    User RBS_BM_UPDATED = RBS_BM.clone(true, true, false, false); // deep clone
	    RBS_BM_UPDATED.isActive = true;
		Map<Id, User_MaskModel> userMaskMapByUserId = mockUserMaskModel(userMapByEmpId.values());
		updateUserMask(userMaskMapByUserId, RBS_BM_UPDATED);

        Test.startTest();
        System.assertNotEquals(0, [SELECT Count() FROM Team_Structure__c]);
		LeadAssignmentQueue.doChainJob = false;
		System.enqueueJob(new LeadAssignmentQueue(userMaskMapByUserId));
		Test.stopTest();

		//********* THEN *********//
		Lead updatedLead = [SELECT Id, Refer_To_User__c FROM Lead WHERE Customer__c = :I_CUSTOMER_PORT.Id];
        System.assertEquals(RBS_BM.Id, updatedLead.Refer_To_User__c);
	}
}