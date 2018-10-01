@isTest
private class RequestOwnership_Test {
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
		
		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
		System.runAs(CBS_RM){
			insert I_CUSTOMER_PORT;
			// When
			User currentUser = RequestOwnershipController.getCurrentUserInfo();
			Test.startTest();
			String userSegment = RequestOwnershipService.validateUserPermission(I_CUSTOMER_PORT, currentUser);
			// Then
			System.assertEquals('CBS', userSegment);
			Test.stopTest();
		}
	}

	@isTest static void validateUserCBS_OwnByCBSAdminOnly() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'CBS');
		User CBS_RM = UserManagementMockupTest.createNewUser(CBS_RM_EMP, CBS_RM_FIRST_NAME, CBS_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(CBS_RM, UserManagementMockupTest.JOB_CODE_CBS_RM, 'RCRM', RC_CODE);
		
		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_CB);
		System.runAs(CBS_RM){
			insert I_CUSTOMER_PORT;
			// When
			User currentUser = RequestOwnershipController.getCurrentUserInfo();
			Test.startTest();
			try {
				String userSegment = RequestOwnershipService.validateUserPermission(I_CUSTOMER_PORT, currentUser);
			} catch(RequestOwnershipService.OwnershipException ex) {
				// Then
				System.assertEquals(Label.CBS_Can_Request_Customer_from_CBS_Admin, ex.getMessage());
			}
			Test.stopTest();
		}
	}
	
	@isTest static void validateUserSME() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'SME');
		User SME_RM = UserManagementMockupTest.createNewUser(SME_RM_EMP, SME_RM_FIRST_NAME, SME_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(SME_RM, UserManagementMockupTest.JOB_CODE_SME_RM_1, 'RCRM', RC_CODE);
		
		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
		System.runAs(SME_RM){
			insert I_CUSTOMER_PORT;
			// When
			User currentUser = RequestOwnershipController.getCurrentUserInfo();
			Test.startTest();
			String userSegment = RequestOwnershipService.validateUserPermission(I_CUSTOMER_PORT, currentUser);
			// Then
			System.assertEquals('SME', userSegment);
			Test.stopTest();
		}
	}

	@isTest static void validateUserSME_AlreadyPort() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'SME');
		User SME_RM = UserManagementMockupTest.createNewUser(SME_RM_EMP, SME_RM_FIRST_NAME, SME_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(SME_RM, UserManagementMockupTest.JOB_CODE_SME_RM_1, 'RCRM', RC_CODE);
		insert SME_RM;

		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
		I_CUSTOMER_PORT.OwnerId = SME_RM.Id;
		System.runAs(SME_RM){
			insert I_CUSTOMER_PORT;
			// When
			User currentUser = RequestOwnershipController.getCurrentUserInfo();
			Test.startTest();
			try {
				String userSegment = RequestOwnershipService.validateUserPermission(I_CUSTOMER_PORT, currentUser);
			} catch(RequestOwnershipService.OwnershipException ex) {
				// Then
				System.assertEquals('This customer already in your port.', ex.getMessage());
			}
			Test.stopTest();
		}
	}

	@isTest static void validateUserRMRBS() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'RBS');
		User RBS_RM = UserManagementMockupTest.createNewUser(RBS_RM_EMP, RBS_RM_FIRST_NAME, RBS_RM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_RM, UserManagementMockupTest.JOB_CODE_RBS_RM_BAR_1, 'RCRM', RC_CODE);
		
		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
		System.runAs(RBS_RM){
			insert I_CUSTOMER_PORT;
			// When
			User currentUser = RequestOwnershipController.getCurrentUserInfo();
			Test.startTest();
			String userSegment = RequestOwnershipService.validateUserPermission(I_CUSTOMER_PORT, currentUser);
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

		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
		System.runAs(AF_RM){
			insert I_CUSTOMER_PORT;
			Test.startTest();
			try {
				// When
				User currentUser = RequestOwnershipController.getCurrentUserInfo();
				String userSegment = RequestOwnershipService.validateUserPermission(I_CUSTOMER_PORT, currentUser);
			} catch(RequestOwnershipService.OwnershipException ex) {
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

		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_LM);
		System.runAs(AN_RM){
			insert I_CUSTOMER_PORT;
			Test.startTest();
			try {
				// When
				User currentUser = RequestOwnershipController.getCurrentUserInfo();
				String userSegment = RequestOwnershipService.validateUserPermission(I_CUSTOMER_PORT, currentUser);
			} catch(RequestOwnershipService.OwnershipException ex) {
				// Then
				System.assertEquals(Label.Request_Ownership_Error_User, ex.getMessage());
			}
			Test.stopTest();
		}
	}

	@isTest static void createRequestRBSCustomer() {
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'RBS');
		User RBS_BM = UserManagementMockupTest.createNewUser(RBS_BM_EMP, RBS_BM_FIRST_NAME, RBS_BM_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE);
		insert RBS_BM;

		UserManagementMockupTest.init(NH_RC_CODE_2, AH_RC_CODE_2, RC_CODE_2, 'RBS');
		User RBS_BM_2 = UserManagementMockupTest.createNewUser(RBS_BM_EMP_2, RBS_BM_FIRST_NAME_2, RBS_BM_LAST_NAME_2, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(RBS_BM_2, UserManagementMockupTest.JOB_CODE_RBS_BM, 'RC', RC_CODE_2);
		insert RBS_BM_2;

		Team_Structure__c requestorClosnessBranch = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE);
		requestorClosnessBranch.OwnerId = RBS_BM.Id;

		Team_Structure__c currentClosnessBranch = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE_2);
		currentClosnessBranch.OwnerId = RBS_BM_2.Id;
		
		System.runAs(new User(Id=UserInfo.getUserId())){
			update requestorClosnessBranch;
			update currentClosnessBranch;
		}

		Account I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_MI);
		I_CUSTOMER_PORT.RBS_Branch_Closeness__c = currentClosnessBranch.Id;
		I_CUSTOMER_PORT.RBS_Previous_Branch_Closeness__c = null;

		System.runAs(RBS_BM){
			insert I_CUSTOMER_PORT;
			User currentUser = ReleaseOwnershipService.getCurrentUserManager();
			// When
			Test.startTest();
			Account targetAccount = Account_Service.getAccountInformation(I_CUSTOMER_PORT.Id);
			RBSRequestOwnership rbsRelease = new RBSRequestOwnership();
			Customer_Ownership_Request__c newRequest = rbsRelease.createCustomerOwnershipRequest(targetAccount, currentUser);
			Test.stopTest();

			// Then
			Id recordTypeId = GlobalUtility.getRecordTypeId('Customer_Ownership_Request__c', GlobalConstants.OWNERSHIP_REQUEST_RBS_DEVNAME);
			//System.assertEquals(, newRequest.User_Admin__c);UserManager.getUserAdmin().RBS_User_ID__c;
        	System.assertEquals(GlobalConstants.BRANCH_CLOSENESS_REQUEST, newRequest.Request_Type__c);
            System.assertEquals(currentUser.Id, newRequest.OwnerID);
            System.assertEquals(currentUser.Id, newRequest.Requestor__c);
            System.assertEquals(recordTypeId, newRequest.RecordTypeId);
            System.assertEquals(RBS_BM_2.Id, newRequest.Approver__c);
            System.assertEquals(currentClosnessBranch.Id, newRequest.Approver_Branch__c);
		}
	}
}