@isTest
private class AFChangeOwner_Test {
	/* Mock Up */
	public static final String RC_CODE    = '888881';
    public static final String AH_RC_CODE = '888882';
    public static final String NH_RC_CODE = '888883';
    public static final String RC_CODE_2    = '881404';
    public static final String AH_RC_CODE_2 = '881400';
    public static final String NH_RC_CODE_2 = '881201';

    public static final String AF_AH_EMP 		 = '7000000003';
    public static final String AF_AH_FIRST_NAME = 'AFFirstName3';
	public static final String AF_AH_LAST_NAME  = 'AFLastName3';

	public static final String AF_TM_EMP 		 = '7000000002';
    public static final String AF_TM_FIRST_NAME = 'AFFirstName1';
	public static final String AF_TM_LAST_NAME  = 'AFLastName1';

	public static final String AF_RM_EMP 		 = '7000000001';
    public static final String AF_RM_FIRST_NAME = 'AFFirstName';
	public static final String AF_RM_LAST_NAME  = 'AFLastName';

	public static final String AF_TM_EMP_2 	   = '7000000012';
    public static final String AF_TM_FIRST_NAME_2 = 'AFFirstName2';
	public static final String AF_TM_LAST_NAME_2  = 'AFLastName2';

	@testSetup static void setUpTest(){
		Mockup_Test.setUpCustomSetting();
	}
	
	private static Map<String, User> setUpUser() {
		UserTriggerHandler.isByPass = true;
		Map<String, User> userMapByEmpId = new Map<String, User>();
		// Given
		UserManagementMockupTest.init(NH_RC_CODE, AH_RC_CODE, RC_CODE, 'AF');
		User AF_AH = UserManagementMockupTest.createNewUser(AF_AH_EMP, AF_AH_FIRST_NAME, AF_AH_LAST_NAME, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(AF_AH, UserManagementMockupTest.JOB_CODE_AF_AH, 'RC', RC_CODE);
		AF_AH.Pending_for_Ownership_Calculation__c = true;
		insert AF_AH;

		User AF_TM = UserManagementMockupTest.createNewUser(AF_TM_EMP, AF_TM_FIRST_NAME, AF_TM_LAST_NAME, true, AF_AH.Id);
		UserManagementMockupTest.setUserAdditionalInfo(AF_TM, UserManagementMockupTest.JOB_CODE_AF_TM, 'RC', RC_CODE);
		AF_TM.Pending_for_Ownership_Calculation__c = true;
		insert AF_TM;

		User AF_RM = UserManagementMockupTest.createNewUser(AF_RM_EMP, AF_RM_FIRST_NAME, AF_RM_LAST_NAME, true, AF_TM.Id);
		UserManagementMockupTest.setUserAdditionalInfo(AF_RM, UserManagementMockupTest.JOB_CODE_AF_RM_1, 'RCRM', RC_CODE);
		AF_RM.Pending_for_Ownership_Calculation__c = true;
		insert AF_RM;

		UserManagementMockupTest.init(NH_RC_CODE_2, AH_RC_CODE_2, RC_CODE_2, 'AF');
		User AF_TM_2 = UserManagementMockupTest.createNewUser(AF_TM_EMP_2, AF_TM_FIRST_NAME_2, AF_TM_LAST_NAME_2, true, null);
		UserManagementMockupTest.setUserAdditionalInfo(AF_TM_2, UserManagementMockupTest.JOB_CODE_AF_TM, 'RC', RC_CODE_2);
		AF_TM_2.Pending_for_Ownership_Calculation__c = false;
		insert AF_TM_2;

		Team_Structure__c branchTeam1 = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE);
		branchTeam1.OwnerId = AF_TM.Id;

		Team_Structure__c branchTeam2 = UserManagementMockupTest.mapTeamByRCCode.get(RC_CODE_2);
		branchTeam2.OwnerId = AF_TM_2.Id;
		
		System.runAs(new User(Id=UserInfo.getUserId())){
			update branchTeam1;
			update branchTeam2;

			List<User_Extension__c> userExtensionList = new List<User_Extension__c>();
			User_Extension__c AF_RM_EXT = UserService.createUserExtension(AF_RM, UserManagementMockupTest.mapTeamByRCCode);
			User_Extension__c AF_TM_EXT = UserService.createUserExtension(AF_TM, UserManagementMockupTest.mapTeamByRCCode);
			User_Extension__c AF_TM_2_EXT = UserService.createUserExtension(AF_TM_2, UserManagementMockupTest.mapTeamByRCCode);
			userExtensionList.add(AF_RM_EXT);
			userExtensionList.add(AF_TM_EXT);
			userExtensionList.add(AF_TM_2_EXT);

			upsert userExtensionList External_ID__c;
		}

		userMapByEmpId.put(AF_AH_EMP, AF_AH);
		userMapByEmpId.put(AF_TM_EMP, AF_TM);
		userMapByEmpId.put(AF_RM_EMP, AF_RM);
		userMapByEmpId.put(AF_TM_EMP_2, AF_TM_2);
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

	private static Application_History__c createApplication(Opportunity targetOpp) {
		return new Application_History__c(
            AppNum_NonCMAS__c 		= '',
            OppName__c 				= targetOpp.Id,
            RMCreditModel__c 		= GlobalConstants.ESTIMATE_CREDIT_MODEL_FL,
            RMSubmitRound__c 		= 'ส่งครั้งแรก',
            RMSubmitChannel__c 		= GlobalConstants.NON_CMAS,
            TentativeSubmitDate__c 	= System.today(),
            RMActualRequestedAmt__c = 100000
        );
	}

	private static OpportunityLineItem createOpportunityProduct(Opportunity targetOpp, Application_History__c application) {
		createProductAndPriceBook();
		PricebookEntry pricebookEntry = [SELECT Id, Name FROM PricebookEntry LIMIT 1];
		return new OpportunityLineItem(
            OpportunityId 		= targetOpp.Id,
            PricebookEntryId 	= pricebookEntry.Id,
            Application__c 		= application.Id,
            Remark__c 			= 'before'
        );
	}

	private static void createProductAndPriceBook() {
        List<Product2> productList = new List<Product2>();
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        productList.add(new Product2(Name = 'Deposit', Product_Code__c = 'P001', IsActive = true, Product_Segment__c = 'RBS'));
        productList.add(new Product2(Name = 'Account Link', Product_Code__c = 'P002', IsActive = true, Product_Segment__c = 'RBS'));
        productList.add(new Product2(Name = 'Inter Account Funds Transfer', Product_Code__c = 'P003', IsActive = true, Product_Segment__c = 'RBS'));
        insert productList;
        
        for(Product2 eachProduct : productList) {
            pricebookEntryList.add(new PricebookEntry(
                Product2Id = eachProduct.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 1,
                IsActive = true
            ));
        }
        insert pricebookEntryList;
    }

	@isTest static void changeOwner_AF_RM_to_AF_TM() {
		//********* GIVEN *********//
		Map<String, User> userMapByEmpId = setUpUser();
		User AF_RM = userMapByEmpId.get(AF_RM_EMP);
		User AF_TM = userMapByEmpId.get(AF_TM_EMP);
		Opportunity targetOpp;
		Account I_CUSTOMER_PORT;
		System.runAs(AF_RM) {
			// New Account
			I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_PC);
			insert I_CUSTOMER_PORT;
			// New Job
			targetOpp = Mockup_Test.newOpportunity(I_CUSTOMER_PORT.Id, 'JobName', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
	        insert targetOpp;
	        // New Event
	        insert createEvent(targetOpp);
	    }
	    //********* WHEN *********//
	    System.runAs(AF_TM) {
	    	I_CUSTOMER_PORT.OwnerId = UserInfo.getUserId();
	    	update I_CUSTOMER_PORT;
	    }
	}

	@isTest static void releaseTemporaryOwner_AF_RM() {
		//********* GIVEN *********//
		Map<String, User> userMapByEmpId = setUpUser();
		User AF_RM = userMapByEmpId.get(AF_RM_EMP);
		User AF_TM = userMapByEmpId.get(AF_TM_EMP);
		User_Extension__c AF_RM_EXT = [SELECT Id FROM User_Extension__c WHERE User__c = :AF_RM.Id];
		Opportunity targetOpp;
		Account I_CUSTOMER_PORT;
		System.runAs(AF_RM) {
			// New Account
			I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_PC);
			I_CUSTOMER_PORT.AF_Temporary_Customer__c = AF_RM_EXT.Id;
			insert I_CUSTOMER_PORT;
			// New Job
			targetOpp = Mockup_Test.newOpportunity(I_CUSTOMER_PORT.Id, 'JobName', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
	        insert targetOpp;
	    }
	    System.runAs(AF_RM) {
	    	// New Application
	        Application_History__c application = createApplication(targetOpp);
	        TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
	        insert application;
	        TriggerHandler.clearbypass('ApplicationHistoryTriggerHandler');
	        // New Opportunity Product
	        insert createOpportunityProduct(targetOpp, application);
	    }
	    System.runAs(AF_RM) {
	    	// New Event
	        insert createEvent(targetOpp);
	    }
	    
	    //********* WHEN *********//
	    System.runAs(AF_RM) {
	    	I_CUSTOMER_PORT.AF_Temporary_Customer__c = null;
	    	update I_CUSTOMER_PORT;
	    }
	}

	@isTest static void changeOwner_AF_TM_to_Other_AF_TM() {
		//********* GIVEN *********//
		Map<String, User> userMapByEmpId = setUpUser();
		User AF_TM_2 = userMapByEmpId.get(AF_TM_EMP_2);
		User AF_TM = userMapByEmpId.get(AF_TM_EMP);
		User AF_AH = userMapByEmpId.get(AF_AH_EMP);
		User_Extension__c AF_TM_EXT = [SELECT Id FROM User_Extension__c WHERE User__c = :AF_TM.Id];
		Opportunity targetOpp;
		Account I_CUSTOMER_PORT;
		System.runAs(AF_TM) {
			// New Account
			I_CUSTOMER_PORT = createCustomer('NAME', 'Port', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME, GlobalConstants.PRIMARY_SEGMENT_CODE_PC);
			I_CUSTOMER_PORT.AF_Temporary_Customer__c = AF_TM_EXT.Id;
			insert I_CUSTOMER_PORT;
			// New Job
			targetOpp = Mockup_Test.newOpportunity(I_CUSTOMER_PORT.Id, 'JobName', GlobalConstants.ON_PROCESS, GlobalConstants.NON_CMAS);
	        insert targetOpp;
	    }
	    System.runAs(AF_TM) {
	    	// New Application
	        Application_History__c application = createApplication(targetOpp);
	        TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
	        insert application;
	        TriggerHandler.clearbypass('ApplicationHistoryTriggerHandler');
	        // New Opportunity Product
	        insert createOpportunityProduct(targetOpp, application);
	    }
	    System.runAs(AF_TM) {
	    	// New Event
	        insert createEvent(targetOpp);
	    }
	    
	    Test.startTest();
	    //********* WHEN AF AH Bulk Assignment change Account Owner *********//
	    System.runAs(AF_AH) {
	    	Account_Service.isBulk = true;
	    	I_CUSTOMER_PORT.OwnerId = AF_TM_2.Id;
	    	// Use service class to bypass sharing rule
	    	OwnershipAssignmentManagerTest assignmentManager = new OwnershipAssignmentManagerTest();
	    	assignmentManager.executeUpdate(new List<Account>{I_CUSTOMER_PORT}, false);
	    }
	    Test.stopTest();
	}
}