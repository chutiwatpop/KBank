@isTest
private class ReleaseOwnership_Test {
	public static final String SME_RM_PORT = 'SME_RM_PORT';

	public static final String RC_CODE    = '88881';
    public static final String AH_RC_CODE = '88882';
    public static final String NH_RC_CODE = '88883';

    public static final String CBS_RM_EMP 		 = '8000000001';
    public static final String CBS_RM_FIRST_NAME = 'CBSFirstName';
	public static final String CBS_RM_LAST_NAME  = 'CBSLastName';

	public static final String RBS_BM_EMP 		 = '7000000002';
    public static final String RBS_BM_FIRST_NAME = 'RBSFirstName1';
	public static final String RBS_BM_LAST_NAME  = 'RBSLastName1';

	public static final String RBS_BM_EMP_2 	   = '7000000012';
    public static final String RBS_BM_FIRST_NAME_2 = 'RBSFirstName2';
	public static final String RBS_BM_LAST_NAME_2  = 'RBSLastName2';

	public static final String RBS_RM_EMP 		 = '7000000001';
    public static final String RBS_RM_FIRST_NAME = 'RBSFirstName';
	public static final String RBS_RM_LAST_NAME  = 'RBSLastName';

	public static final String SME_NH_EMP 		 = '6000000004';
    public static final String SME_NH_FIRST_NAME = 'NHFirstName';
	public static final String SME_NH_LAST_NAME  = 'NHLastName';
	public static final String SME_AH_EMP 		 = '6000000003';
    public static final String SME_AH_FIRST_NAME = 'AHFirstName';
	public static final String SME_AH_LAST_NAME  = 'AHLastName';
	public static final String SME_TM_EMP 		 = '6000000002';
    public static final String SME_TM_FIRST_NAME = 'TMFirstName';
	public static final String SME_TM_LAST_NAME  = 'TMLastName';
	public static final String SME_RM_EMP 		 = '6000000001';
    public static final String SME_RM_FIRST_NAME = 'RMFirstName';
	public static final String SME_RM_LAST_NAME  = 'RMLastName';

	public static final String AF_RM_EMP 		 = '5000000001';
    public static final String AF_RM_FIRST_NAME  = 'AFFirstName';
	public static final String AF_RM_LAST_NAME   = 'AFLastName';

	public static final String AN_RM_EMP 		 = '4000000001';
    public static final String AN_RM_FIRST_NAME  = 'ANFirstName';
	public static final String AN_RM_LAST_NAME   = 'ANLastName';

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

	@isTest static void validateUserCBS() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'CBS');
		User CBS_RM = UserManagementMockupTest.createNewUser(CBS_RM_EMP, CBS_RM_FIRST_NAME, CBS_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(CBS_RM, UserManagementMockupTest.JOB_CODE_CBS_RM, 'RCRM', RC_CODE);
		System.runAs(CBS_RM){
			// When
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			Test.startTest();
			String userSegment = ReleaseOwnershipService.validateUserPermission(currentUser);
			// Then
			System.assertEquals('CBS', userSegment);
			Test.stopTest();
		}
	}
	
	@isTest static void validateUserSME() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'SME');
		User SME_RM = UserManagementMockupTest.createNewUser(SME_RM_EMP, SME_RM_FIRST_NAME, SME_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(SME_RM, UserManagementMockupTest.JOB_CODE_SME_RM_1, 'RCRM', RC_CODE);
		System.runAs(SME_RM){
			// When
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			Test.startTest();
			String userSegment = ReleaseOwnershipService.validateUserPermission(currentUser);
			// Then
			System.assertEquals('SME', userSegment);
			Test.stopTest();
		}
	}

	@isTest static void validateUserRMRBS() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'RBS');
		User RBS_RM = UserManagementMockupTest.createNewUser(RBS_RM_EMP, RBS_RM_FIRST_NAME, RBS_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_RM, UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1, 'RCRM', RC_CODE);
		System.runAs(RBS_RM){
			// When
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			Test.startTest();
			try {
				String userSegment = ReleaseOwnershipService.validateUserPermission(currentUser);
			} catch(OwnershipException ex) {
				// Then
				System.assertEquals(Label.RBS_CantReleaseIfNotBM, ex.getMessage());
			}
			Test.stopTest();
		}
	}

	@isTest static void validateUserBMRBS() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'RBS');
		User RBS_BM = UserManagementMockupTest.createNewUser(RBS_BM_EMP, RBS_BM_FIRST_NAME, RBS_BM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE);
		System.runAs(RBS_BM){
			// When
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			Test.startTest();
			String userSegment = ReleaseOwnershipService.validateUserPermission(currentUser);
			Test.stopTest();
			// Then
			System.assertEquals('RBS', userSegment);
		}
	}
	
	
	@isTest static void validateUserAF() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'AF');
		User AF_RM = UserManagementMockupTest.createNewUser(AF_RM_EMP, AF_RM_FIRST_NAME, AF_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(AF_RM, UserManagementMockupTest.JOB_CODE_AF_RM_1, 'RCRM', RC_CODE);
		System.runAs(AF_RM){
			Test.startTest();
			try {
				// When
				User currentUser = ReleaseOwnershipService.getCurrentUserManager();
				String userSegment = ReleaseOwnershipService.validateUserPermission(currentUser);
			} catch(OwnershipException ex) {
				// Then
				System.assertEquals(Label.AF_CantReleaseRequestOwnership, ex.getMessage());
			}
			Test.stopTest();
		}
	}

	@isTest static void validateUserOther() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'AN');
		User AN_RM = UserManagementMockupTest.createNewUser(AN_RM_EMP, AN_RM_FIRST_NAME, AN_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(AN_RM, UserManagementMockupTest.JOB_CODE_AN_RM, 'RCRM', RC_CODE);
		System.runAs(AN_RM){
			Test.startTest();
			try {
				// When
				User currentUser = ReleaseOwnershipService.getCurrentUserManager();
				String userSegment = ReleaseOwnershipService.validateUserPermission(currentUser);
			} catch(OwnershipException ex) {
				// Then
				System.assertEquals(Label.Release_Ownership_Error_User, ex.getMessage());
			}
			Test.stopTest();
		}
	}
	
	@isTest static void validateSMECustomer_NotRMTM() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'SME');
		User SME_AH = UserManagementMockupTest.createNewUser(SME_AH_EMP, SME_AH_FIRST_NAME, SME_AH_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(SME_AH, UserManagementMockupTest.JOB_CODE_SME_AH_1, 'RC', RC_CODE);
		insert SME_AH;

		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
		I_CUSTOMER_PORT.OwnerId = SME_AH.Id;
		System.runAs(SME_AH){
			insert I_CUSTOMER_PORT;
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			// When
			Test.startTest();
			try {
				SMEReleaseOwnership smeRelease = new SMEReleaseOwnership();
				smeRelease.validateCustomer(I_CUSTOMER_PORT, currentUser);
			} catch(OwnershipException ex) {
				// Then
				System.assertEquals(ExceptionMessage.CUSTOMER_MUST_BE_IN_YOUR_PORT_OWNERSHIP, ex.getMessage());
			}
			Test.stopTest();
		}
	}

	@isTest static void validateSMECustomer_NotOwner() {
		// Given
		// SME User
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'SME');
		User SME_RM = UserManagementMockupTest.createNewUser(SME_RM_EMP, SME_RM_FIRST_NAME, SME_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(SME_RM, UserManagementMockupTest.JOB_CODE_SME_RM_1, 'RCRM', RC_CODE);
		
		// RBS User
		String RC_CODE_2    = '81404';
    	String AH_RC_CODE_2 = '81400';
    	String NH_RC_CODE_2 = '81201';
		UserManagementMockupTest.init(NH_RC_CODE_2, AH_RC_CODE_2, RC_CODE_2, 'RBS');
		User RBS_BM_2 = UserManagementMockupTest.createNewUser(RBS_BM_EMP_2, RBS_BM_FIRST_NAME_2, RBS_BM_LAST_NAME_2, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM_2, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE_2);
		insert RBS_BM_2;

		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_MI);
		System.runAs(RBS_BM_2){
			I_CUSTOMER_PORT.OwnerId = RBS_BM_2.Id;
			insert I_CUSTOMER_PORT;
		}

		System.runAs(SME_RM){
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			// When
			Test.startTest();
			try {
				SMEReleaseOwnership smeRelease = new SMEReleaseOwnership();
				smeRelease.validateCustomer(I_CUSTOMER_PORT, currentUser);
			} catch(OwnershipException ex) {
				// Then
				System.assertEquals(ExceptionMessage.CUSTOMER_MUST_BE_IN_YOUR_PORT_OWNERSHIP, ex.getMessage());
			}
			Test.stopTest();
		}
	}

	@isTest static void validateCBSCustomer_NotOwner() {
		// Given
		// CBS User
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'CBS');
		User CBS_RM = UserManagementMockupTest.createNewUser(CBS_RM_EMP, CBS_RM_FIRST_NAME, CBS_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(CBS_RM, UserManagementMockupTest.JOB_CODE_CBS_RM, 'RCRM', RC_CODE);
		
		// RBS User
		String RC_CODE_2    = '81404';
    	String AH_RC_CODE_2 = '81400';
    	String NH_RC_CODE_2 = '81201';
		UserManagementMockupTest.init(NH_RC_CODE_2, AH_RC_CODE_2, RC_CODE_2, 'RBS');
		User RBS_BM_2 = UserManagementMockupTest.createNewUser(RBS_BM_EMP_2, RBS_BM_FIRST_NAME_2, RBS_BM_LAST_NAME_2, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM_2, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE_2);
		insert RBS_BM_2;

		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_MI);
		System.runAs(RBS_BM_2){
			insert I_CUSTOMER_PORT;
		}

		System.runAs(CBS_RM){
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			// When
			Test.startTest();
			try {
				CBSReleaseOwnership cbsRelease = new CBSReleaseOwnership();
				cbsRelease.validateCustomer(I_CUSTOMER_PORT, currentUser);
			} catch(OwnershipException ex) {
				// Then
				System.assertEquals(ExceptionMessage.CUSTOMER_MUST_BE_IN_YOUR_PORT_OWNERSHIP, ex.getMessage());
			}
			Test.stopTest();
		}
	}

	@isTest static void validateRBSCustomer_NoPrevious() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'RBS');
		User RBS_RM = UserManagementMockupTest.createNewUser(RBS_RM_EMP, RBS_RM_FIRST_NAME, RBS_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_RM, UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1, 'RCRM', RC_CODE);
		insert RBS_RM;

		Team_Structure__c currentClosnessBranch = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE);
		currentClosnessBranch.OwnerId = RBS_RM.Id;
		System.runAs(new User(Id=UserInfo.getUserId())){
			update currentClosnessBranch;
		}

		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_MI);
		I_CUSTOMER_PORT.RBS_Branch_Closeness__c = currentClosnessBranch.Id;
		System.runAs(RBS_RM){
			insert I_CUSTOMER_PORT;
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			// When
			Test.startTest();
			try {
				Account targetAccount = Account_Service.getAccountInformation(I_CUSTOMER_PORT.Id);
				RBSReleaseOwnership rbsRelease = new RBSReleaseOwnership();
				rbsRelease.validateCustomer(targetAccount, currentUser);
			} catch(OwnershipException ex) {
				// Then
				System.assertEquals(Label.RBS_ClosenessBranchCantBeReleasetoEmpty, ex.getMessage());
			}
			Test.stopTest();
		}
	}

	@isTest static void validateRBSCustomer_NotCloseness() {
		String RC_CODE_2    = '81404';
    	String AH_RC_CODE_2 = '81400';
    	String NH_RC_CODE_2 = '81201';

		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'RBS');
		User RBS_BM = UserManagementMockupTest.createNewUser(RBS_BM_EMP, RBS_BM_FIRST_NAME, RBS_BM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE);
		insert RBS_BM;

		UserManagementMockupTest.init(NH_RC_CODE_2, AH_RC_CODE_2, RC_CODE_2, 'RBS');
		User RBS_BM_2 = UserManagementMockupTest.createNewUser(RBS_BM_EMP_2, RBS_BM_FIRST_NAME_2, RBS_BM_LAST_NAME_2, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM_2, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE_2);
		insert RBS_BM_2;

		Team_Structure__c currentClosnessBranch = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE);
		currentClosnessBranch.OwnerId = RBS_BM.Id;

		Team_Structure__c previousClosnessBranch = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE_2);
		previousClosnessBranch.OwnerId = RBS_BM_2.Id;
		
		System.runAs(new User(Id=UserInfo.getUserId())){
			update previousClosnessBranch;
			update currentClosnessBranch;
		}

		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_MI);
		I_CUSTOMER_PORT.RBS_Branch_Closeness__c = currentClosnessBranch.Id;
		I_CUSTOMER_PORT.RBS_Previous_Branch_Closeness__c = previousClosnessBranch.Id;

		System.runAs(RBS_BM_2){
			insert I_CUSTOMER_PORT;
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			// When
			Test.startTest();
			try {
				RBSReleaseOwnership rbsRelease = new RBSReleaseOwnership();
				rbsRelease.validateCustomer(I_CUSTOMER_PORT, currentUser);
			} catch(OwnershipException ex) {
				// Then
				System.assertEquals(Label.RBS_CantReleaseOthersClosenessBranch, ex.getMessage());
			}
			Test.stopTest();
		}
	}

	@isTest static void createRequestRBSCustomer() {
		String RC_CODE_2    = '81404';
    	String AH_RC_CODE_2 = '81400';
    	String NH_RC_CODE_2 = '81201';

		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'RBS');
		User RBS_BM = UserManagementMockupTest.createNewUser(RBS_BM_EMP, RBS_BM_FIRST_NAME, RBS_BM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE);
		insert RBS_BM;

		UserManagementMockupTest.init(NH_RC_CODE_2, AH_RC_CODE_2, RC_CODE_2, 'RBS');
		User RBS_BM_2 = UserManagementMockupTest.createNewUser(RBS_BM_EMP_2, RBS_BM_FIRST_NAME_2, RBS_BM_LAST_NAME_2, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM_2, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE_2);
		insert RBS_BM_2;

		Team_Structure__c currentClosnessBranch = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE);
		currentClosnessBranch.OwnerId = RBS_BM.Id;

		Team_Structure__c previousClosnessBranch = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE_2);
		previousClosnessBranch.OwnerId = RBS_BM_2.Id;
		
		System.runAs(new User(Id=UserInfo.getUserId())){
			update previousClosnessBranch;
			update currentClosnessBranch;
		}

		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_MI);
		I_CUSTOMER_PORT.RBS_Branch_Closeness__c = currentClosnessBranch.Id;
		I_CUSTOMER_PORT.RBS_Previous_Branch_Closeness__c = previousClosnessBranch.Id;

		System.runAs(RBS_BM){
			insert I_CUSTOMER_PORT;
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			// When
			Test.startTest();
			Account targetAccount = Account_Service.getAccountInformation(I_CUSTOMER_PORT.Id);
			RBSReleaseOwnership rbsRelease = new RBSReleaseOwnership();
			Customer_Ownership_Request__c newRequest = rbsRelease.createCustomerOwnershipRequest(targetAccount, currentUser);
			Test.stopTest();

			// Then
			Id recordTypeId = GlobalUtility.getRecordTypeId('Customer_Ownership_Request__c', GlobalConstants.OWNERSHIP_RELEASE_RBS_DEVNAME);
			//System.assertEquals(, newRequest.User_Admin__c);UserManager.getUserAdmin().RBS_User_ID__c;
        	System.assertEquals(GlobalConstants.BRANCH_CLOSENESS_RELEASE, newRequest.Request_Type__c);
            System.assertEquals(currentUser.Id, newRequest.OwnerID);
            System.assertEquals(currentUser.Id, newRequest.Requestor__c);
            System.assertEquals(recordTypeId, newRequest.RecordTypeId);
            System.assertEquals(RBS_BM_2.Id, newRequest.Approver__c);
            System.assertEquals(previousClosnessBranch.Id, newRequest.Approver_Branch__c);
		}
	}

	@isTest static void setSMEApproverManager_TMPool() {
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'SME');
		
		User SME_NH = UserManagementMockupTest.createNewUser(SME_NH_EMP, SME_NH_FIRST_NAME, SME_NH_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(SME_NH, UserManagementMockupTest.JOB_CODE_SME_NH_1, 'RC', RC_CODE);
		insert SME_NH;

		User SME_AH = UserManagementMockupTest.createNewUser(SME_AH_EMP, SME_AH_FIRST_NAME, SME_AH_LAST_NAME, true, SME_NH.Id);
		UserManagementMockupTest.setUserAdditionalInfo(SME_AH, UserManagementMockupTest.JOB_CODE_SME_AH_1, 'RC', RC_CODE);
		insert SME_AH;

		User SME_TM = UserManagementMockupTest.createNewUser(SME_TM_EMP, SME_TM_FIRST_NAME, SME_TM_LAST_NAME, true, SME_AH.Id);
		UserManagementMockupTest.setUserAdditionalInfo(SME_TM, UserManagementMockupTest.JOB_CODE_SME_TM_1, 'RC', RC_CODE);
		insert SME_TM;

		User SME_RM = UserManagementMockupTest.createNewUser(SME_RM_EMP, SME_RM_FIRST_NAME, SME_RM_LAST_NAME, true, SME_TM.Id);
		UserManagementMockupTest.setUserAdditionalInfo(SME_RM, UserManagementMockupTest.JOB_CODE_SME_RM_1, 'RCRM', RC_CODE);
		insert SME_RM;

		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_MI);
		System.runAs(SME_RM){
			insert I_CUSTOMER_PORT;
			Customer_Ownership_Request__c newRequest = new Customer_Ownership_Request__c(
				CIS_ID__c 			= I_CUSTOMER_PORT.Id,
				Request_Type__c 	= GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.REASON_TM_POOL,
				OwnerId 			= SME_RM.Id
				//Approval_Status__c = 
				//Reason__c
				//Company_Related_Text__c
			);
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			ReleaseOwnershipService.setRequestorApprover(newRequest, I_CUSTOMER_PORT, currentUser);
			System.assertEquals(SME_RM.Id, newRequest.OwnerId);
			System.assertEquals(SME_TM.Id, newRequest.Requestor_TM__c);
			System.assertEquals(SME_AH.Id, newRequest.Requestor_AH__c);
			System.assertEquals(SME_NH.Id, newRequest.Requestor_NH__c);
			System.assertEquals(SME_TM.Id, newRequest.Current_Owner__c);
		}
	}

	@isTest static void setSMEApproverManager_NotSME() {
		String RC_CODE_2    = '81404';
    	String AH_RC_CODE_2 = '81400';
    	String NH_RC_CODE_2 = '81201';
    	UserManagementMockupTest.init(NH_RC_CODE_2, AH_RC_CODE_2, RC_CODE_2, 'RBS');
		User SME_TM_2 = UserManagementMockupTest.createNewUser('8000000099', SME_TM_FIRST_NAME + '2', SME_TM_LAST_NAME + '2', true, null);
		UserManagementMockupTest.setUserAdditionalInfo(SME_TM_2, UserManagementMockupTest.JOB_CODE_SME_TM_2, 'RC', RC_CODE_2);
		insert SME_TM_2;
		Team_Structure__c referredTeam = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE_2);
		referredTeam.OwnerId = SME_TM_2.Id;
		System.runAs(new User(Id=UserInfo.getUserId())){
			update referredTeam;
		}

		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'SME');
		
		User SME_NH = UserManagementMockupTest.createNewUser(SME_NH_EMP, SME_NH_FIRST_NAME, SME_NH_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(SME_NH, UserManagementMockupTest.JOB_CODE_SME_NH_1, 'RC', RC_CODE);
		insert SME_NH;

		User SME_AH = UserManagementMockupTest.createNewUser(SME_AH_EMP, SME_AH_FIRST_NAME, SME_AH_LAST_NAME, true, SME_NH.Id);
		UserManagementMockupTest.setUserAdditionalInfo(SME_AH, UserManagementMockupTest.JOB_CODE_SME_AH_1, 'RC', RC_CODE);
		insert SME_AH;

		User SME_TM = UserManagementMockupTest.createNewUser(SME_TM_EMP, SME_TM_FIRST_NAME, SME_TM_LAST_NAME, true, SME_AH.Id);
		UserManagementMockupTest.setUserAdditionalInfo(SME_TM, UserManagementMockupTest.JOB_CODE_SME_TM_1, 'RC', RC_CODE);
		insert SME_TM;

		User SME_RM = UserManagementMockupTest.createNewUser(SME_RM_EMP, SME_RM_FIRST_NAME, SME_RM_LAST_NAME, true, SME_TM.Id);
		UserManagementMockupTest.setUserAdditionalInfo(SME_RM, UserManagementMockupTest.JOB_CODE_SME_RM_1, 'RCRM', RC_CODE);
		insert SME_RM;

		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_MI);
		System.runAs(SME_RM){
			insert I_CUSTOMER_PORT;
			Customer_Ownership_Request__c newRequest = new Customer_Ownership_Request__c(
				CIS_ID__c 			= I_CUSTOMER_PORT.Id,
				Request_Type__c 	= GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.REASON_NOT_SME,
				Refer_Out_Team__c	= referredTeam.Name,
				OwnerId 			= SME_RM.Id
				//Approval_Status__c = 
				//Reason__c
				//Company_Related_Text__c
			);
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			ReleaseOwnershipService.setRequestorApprover(newRequest, I_CUSTOMER_PORT, currentUser);
			System.assertEquals(SME_RM.Id, newRequest.OwnerId);
			System.assertEquals(SME_TM.Id, newRequest.Requestor_TM__c);
			System.assertEquals(SME_AH.Id, newRequest.Requestor_AH__c);
			System.assertEquals(SME_NH.Id, newRequest.Requestor_NH__c);

			System.assertEquals(SME_TM_2.Id, newRequest.Current_Owner__c);
			System.assertEquals(SME_TM_2.Id, newRequest.Current_Owner_TM__c);
			System.assertEquals(null, newRequest.Current_Owner_AH__c);
			System.assertEquals(null, newRequest.Current_Owner_NH__c);
		}
	}

	@isTest static void approveRequestRBSCustomer() {
		String RC_CODE_2    = '81404';
    	String AH_RC_CODE_2 = '81400';
    	String NH_RC_CODE_2 = '81201';

		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'RBS');
		User RBS_BM = UserManagementMockupTest.createNewUser(RBS_BM_EMP, RBS_BM_FIRST_NAME, RBS_BM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE);
		insert RBS_BM;

		UserManagementMockupTest.init(NH_RC_CODE_2, AH_RC_CODE_2, RC_CODE_2, 'RBS');
		User RBS_BM_2 = UserManagementMockupTest.createNewUser(RBS_BM_EMP_2, RBS_BM_FIRST_NAME_2, RBS_BM_LAST_NAME_2, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM_2, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE_2);
		insert RBS_BM_2;

		Team_Structure__c currentClosnessBranch = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE);
		currentClosnessBranch.OwnerId = RBS_BM.Id;

		Team_Structure__c previousClosnessBranch = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE_2);
		previousClosnessBranch.OwnerId = RBS_BM_2.Id;
		
		System.runAs(new User(Id=UserInfo.getUserId())){
			update previousClosnessBranch;
			update currentClosnessBranch;
		}

		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_MI);
		I_CUSTOMER_PORT.RBS_Branch_Closeness__c = currentClosnessBranch.Id;
		I_CUSTOMER_PORT.RBS_Previous_Branch_Closeness__c = previousClosnessBranch.Id;

		System.runAs(RBS_BM){
			insert I_CUSTOMER_PORT;
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			// When
			Test.startTest();
			Account targetAccount = Account_Service.getAccountInformation(I_CUSTOMER_PORT.Id);
			RBSReleaseOwnership rbsRelease = new RBSReleaseOwnership();
			Customer_Ownership_Request__c newRequest = rbsRelease.createCustomerOwnershipRequest(targetAccount, currentUser);
			insert newRequest;
			Test.stopTest();

			Id recordTypeId = GlobalUtility.getRecordTypeId('Customer_Ownership_Request__c', GlobalConstants.OWNERSHIP_RELEASE_RBS_READONLY_DEVNAME);
			newRequest.RecordTypeId = recordTypeId;
			newRequest.Approval_Status__c = GlobalConstants.APPROVED;
			update newRequest;
			// Then
			Account updatedAccount = Account_Service.getAccountInformation(I_CUSTOMER_PORT.Id);
			System.assertEquals(previousClosnessBranch.Id, updatedAccount.RBS_Branch_Closeness__c);
			System.assertEquals(currentClosnessBranch.Id, updatedAccount.RBS_Previous_Branch_Closeness__c);
		}
	}
}