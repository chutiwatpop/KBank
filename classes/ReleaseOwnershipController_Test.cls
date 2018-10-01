@isTest
private class ReleaseOwnershipController_Test {
	public static final String SME_RM_PORT = 'SME_RM_PORT';

	public static final String RC_CODE    = '888881';
    public static final String AH_RC_CODE = '888882';
    public static final String NH_RC_CODE = '888883';
    public static final String RC_CODE_2    = '881404';
    public static final String AH_RC_CODE_2 = '881400';
    public static final String NH_RC_CODE_2 = '881201';

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
		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_MI);
		System.runAs(CBS_RM){
			insert I_CUSTOMER_PORT;
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			// When
			Test.startTest();
			ReleaseOwnershipController.Response res = ReleaseOwnershipController.validateReleaseOwnership(I_CUSTOMER_PORT.Id);
			Test.stopTest();
			// Then
			System.assertEquals('CBS', res.msg);
		}
	}
	
	@isTest static void validateUserSME() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'SME');
		User SME_RM = UserManagementMockupTest.createNewUser(SME_RM_EMP, SME_RM_FIRST_NAME, SME_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(SME_RM, UserManagementMockupTest.JOB_CODE_SME_RM_1, 'RCRM', RC_CODE);
		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_MI);
		System.runAs(SME_RM){
			insert I_CUSTOMER_PORT;
			// When
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			Test.startTest();
			ReleaseOwnershipController.Response res = ReleaseOwnershipController.validateReleaseOwnership(I_CUSTOMER_PORT.Id);
			Test.stopTest();
			// Then
			System.assertEquals('SME', res.msg);
		}
	}

	@isTest static void validateUserBMRBS() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'RBS');
		User RBS_BM = UserManagementMockupTest.createNewUser(RBS_BM_EMP, RBS_BM_FIRST_NAME, RBS_BM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE);
		insert RBS_BM;

		UserManagementMockupTest.init(NH_RC_CODE_2, AH_RC_CODE_2, RC_CODE_2, 'RBS');
		User RBS_BM_2 = UserManagementMockupTest.createNewUser(RBS_BM_EMP_2, RBS_BM_FIRST_NAME_2, RBS_BM_LAST_NAME_2, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM_2, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE_2);
		insert RBS_BM_2;

		Team_Structure__c currentClosnessBranch = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c = :RC_CODE];
		currentClosnessBranch.OwnerId = RBS_BM.Id;

		Team_Structure__c previousClosnessBranch = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c = :RC_CODE_2];
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
			// When
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			Test.startTest();
			ReleaseOwnershipController.Response res = ReleaseOwnershipController.validateReleaseOwnership(I_CUSTOMER_PORT.Id);
			Test.stopTest();
			// Then
			System.assertEquals('RBS', res.msg);
		}
	}

	@isTest static void createCustomerOwnershipRequest() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'RBS');
		User RBS_BM = UserManagementMockupTest.createNewUser(RBS_BM_EMP, RBS_BM_FIRST_NAME, RBS_BM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE);
		insert RBS_BM;

		UserManagementMockupTest.init(NH_RC_CODE_2, AH_RC_CODE_2, RC_CODE_2, 'RBS');
		User RBS_BM_2 = UserManagementMockupTest.createNewUser(RBS_BM_EMP_2, RBS_BM_FIRST_NAME_2, RBS_BM_LAST_NAME_2, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM_2, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE_2);
		insert RBS_BM_2;

		Team_Structure__c currentClosnessBranch = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c = :RC_CODE];
		currentClosnessBranch.OwnerId = RBS_BM.Id;

		Team_Structure__c previousClosnessBranch = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c = :RC_CODE_2];
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
			// When
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			Test.startTest();
			ReleaseOwnershipController.Response res = ReleaseOwnershipController.createCustomerOwnershipRequest(I_CUSTOMER_PORT.Id);
			Test.stopTest();
			// Then
			
			System.assertEquals(true, res.success);
			System.assertNotEquals(null, res.customerRequest);
		}
	}
	
}