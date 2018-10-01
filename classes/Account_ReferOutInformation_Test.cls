@isTest
private class Account_ReferOutInformation_Test {
	public static String accountName = 'referOutCreatedAccountName';
	public static String contactName = 'referOutCreatedContactName';
	public static String lastName = 'referOutCreatedLastName';
	public static String accountNameReq = 'accountNameReq';
	public static String relatedAccountCBSName = 'rmCBCreateAccount1';
	@testSetup static void setupUser(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountName,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
        	Account account = Mockup_Test.newAccountWithSegment(relatedAccountCBSName,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),GlobalConstants.PRIMARY_SEGMENT_CODE_CB);
        	account.CIS__c = '111111';
        	insert account;
        }
    }

	@isTest static void testInitNewData() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
		Boolean expectedInitailDisabledFlag = true;
		String expectedInitailProvince = ' - ';
		String expectedInitailTeam = ' - ';
		Customer_Ownership_Request__c cusOwnershipReq = new Customer_Ownership_Request__c();
		//insert cusOwnershipReq;
		ApexPages.currentPage().getParameters().put('cisID', targetAccount.Id);
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReq));
        System.assertEquals(expectedInitailDisabledFlag,accountReferOutController.disabledFlag);
        System.assertEquals(expectedInitailProvince,accountReferOutController.selectedProvince);
        System.assertEquals(expectedInitailTeam,accountReferOutController.selectedTeam);
	}

	@isTest static void testInitEditData() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
        Boolean expectedInitailDisabledFlag = true;
		String expectedInitailProvince = ' - ';
		String expectedInitailTeam = ' - ';
		String expectedId;

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Customer_Ownership_Request__c cusOwnershipReq = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id);
			insert cusOwnershipReq;
	        expectedId = cusOwnershipReq.id;
	        ApexPages.currentPage().getParameters().put('cisID', cusOwnershipReq.Id);
	        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReq));

	        System.assertEquals(expectedInitailDisabledFlag,accountReferOutController.disabledFlag);
	        System.assertEquals(expectedInitailProvince,accountReferOutController.selectedProvince);
	        System.assertEquals(expectedInitailTeam,accountReferOutController.selectedTeam);
	        System.assertEquals(targetAccount.id,accountReferOutController.mysObject.CIS_ID__c);
	    }
	}
	
	@isTest static void testCheckReasonConditionReasonOtherTeam() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
        Boolean expectedDisabledFlag = false;

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Customer_Ownership_Request__c cusOwnershipReq = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = GlobalConstants.REASON_OTHER_TEAM,Refer_Out_Segment__c = 'ME',Refer_Out_Team__c = 'testTeam');
			insert cusOwnershipReq;
	        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReq));
			accountReferOutController.checkReasonCondition();
	        System.assertEquals(expectedDisabledFlag,accountReferOutController.disabledFlag);
	    }
	}

	@isTest static void testCheckReasonConditionReasonNotOtherTeamOrWrongArea() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
        Boolean expectedDisabledFlag = true;

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Customer_Ownership_Request__c cusOwnershipReq = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'test',Refer_Out_Segment__c = 'ME',Refer_Out_Team__c = 'testTeam');
			insert cusOwnershipReq;
	        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReq));
			accountReferOutController.checkReasonCondition();
	        System.assertEquals(expectedDisabledFlag,accountReferOutController.disabledFlag);
	    }
	}
	
	@isTest static void testCheckSegmentConditionSelectedReferOutSegment() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
        Boolean expectedDisabledFlag = false;

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'testReason',Refer_Out_Segment__c = 'ME',Refer_Out_Team__c = 'testTeam');
	        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
	        accountReferOutController.checkSegmentCondition();
	        System.assertEquals(expectedDisabledFlag,accountReferOutController.disabledFlag);
	    }
	}

	@isTest static void testCheckSegmentConditionNotSelectedReferOutSegment() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
        Boolean expectedDisabledFlag = true;
		String expectedProvince = ' - ';
		String expectedTeam = ' - ';

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'testReason',Refer_Out_Segment__c = '-',Refer_Out_Team__c = 'testTeam');
	        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
	        accountReferOutController.checkSegmentCondition();
	        System.assertEquals(expectedDisabledFlag,accountReferOutController.disabledFlag);
	        System.assertEquals(expectedProvince,accountReferOutController.selectedProvince);
	        System.assertEquals(expectedTeam,accountReferOutController.selectedTeam);
	    }
	}
	
	@isTest static void testGetSelectedProvince() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
        String expectedSelectedProvince = 'testReferProvince';

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'testReason',Refer_Out_Segment__c = 'testSegment',Refer_Out_Team__c = 'testTeam', Refer_Out_Province__c = expectedSelectedProvince);
	        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
	        accountReferOutController.selectedProvince = null; 
	        System.assertEquals(expectedSelectedProvince,accountReferOutController.getSelectedProvince());
	    }
	}

	@isTest static void testGetSelectedProvinceNone() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
        String expectedSelectedProvince = ' - ';

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'testReason',Refer_Out_Segment__c = 'testSegment',Refer_Out_Team__c = 'testTeam');
	        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
	        
	        System.assertEquals(expectedSelectedProvince,accountReferOutController.getSelectedProvince());
	    }
	}

	@isTest static void testGetProvinceListNotFound() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'testReason',Refer_Out_Segment__c = 'testSegment',Refer_Out_Team__c = 'testTeam');
	        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
	        accountReferOutController.getProvinceList();
	        System.assertEquals(1,accountReferOutController.provinceList.size());
	        System.assertEquals(0,accountReferOutController.teamList.size());
	    }
	}

	@isTest static void testGetProvinceList() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
		Id ON_GOING_RECORD_TYPE_ID = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Team_Province_Master_Data__c', 'On_Going');
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = GlobalConstants.REASON_WRONG_AREA,Refer_Out_Segment__c = 'ME',Refer_Out_Team__c = 'testTeam');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
        List<Team_Structure__c> listTeamStructure = [SELECT Id FROM Team_Structure__c];
        List<Team_Province_Master_Data__c> listTeamProvinceMasterData = new  List<Team_Province_Master_Data__c>();
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 1',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'ME',Team_Structure__c = listTeamStructure[0].Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 2',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'ME',Team_Structure__c = listTeamStructure[1].Id));
		insert listTeamProvinceMasterData;

        accountReferOutController.getProvinceList();
        System.assertNotEquals(1,accountReferOutController.provinceList.size());
        System.assertNotEquals(0,accountReferOutController.teamList.size());
	}
	
	@isTest static void testSelectProvinceThenSelectTeamME() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
		Id ON_GOING_RECORD_TYPE_ID = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Team_Province_Master_Data__c', 'On_Going');
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = GlobalConstants.REASON_WRONG_AREA,Refer_Out_Segment__c = 'ME',Refer_Out_Team__c = 'testTeam');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
        List<Team_Structure__c> listTeamStructure = [SELECT Id FROM Team_Structure__c];

		Team_Structure__c ts1 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = System.Label.Filter_ME_Team + ' team 1',
			External_ID__c = '1'
		);
		insert ts1;

		Team_Structure__c ts2 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = System.Label.Filter_ME_Team + ' team 2',
			External_ID__c = '2'
		);
		insert ts2;

        List<Team_Province_Master_Data__c> listTeamProvinceMasterData = new  List<Team_Province_Master_Data__c>();
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 1',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'ME',Team_Structure__c = listTeamStructure[0].Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 2',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'ME',Team_Structure__c = listTeamStructure[1].Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 3',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'ME',Team_Structure__c = ts1.Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 4',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'ME',Team_Structure__c = ts2.Id));
		insert listTeamProvinceMasterData;

        accountReferOutController.selectProvince();
        System.assertEquals(3,accountReferOutController.teamList.size());
	}

	@isTest static void testSelectProvinceThenSelectTeamSE() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
		Id ON_GOING_RECORD_TYPE_ID = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Team_Province_Master_Data__c', 'On_Going');
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = GlobalConstants.REASON_WRONG_AREA,Refer_Out_Segment__c = 'SE',Refer_Out_Team__c = 'testTeam');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
        List<Team_Structure__c> listTeamStructure = [SELECT Id FROM Team_Structure__c];

		Team_Structure__c ts1 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = System.Label.Filter_SE_Team + ' team 1',
			External_ID__c = '1'
		);
		insert ts1;

		Team_Structure__c ts2 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = System.Label.Filter_SE_Team + ' team 2',
			External_ID__c = '2'
		);
		insert ts2;

        List<Team_Province_Master_Data__c> listTeamProvinceMasterData = new  List<Team_Province_Master_Data__c>();
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 1',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'SE',Team_Structure__c = listTeamStructure[0].Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 2',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'SE',Team_Structure__c = listTeamStructure[1].Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 3',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'SE',Team_Structure__c = ts1.Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 4',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'SE',Team_Structure__c = ts2.Id));
		insert listTeamProvinceMasterData;

        accountReferOutController.selectProvince();
        System.assertEquals(3,accountReferOutController.teamList.size());
	}

	@isTest static void testIfBlockTeamThenNotSave() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
		Id ON_GOING_RECORD_TYPE_ID = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Team_Province_Master_Data__c', 'On_Going');
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = GlobalConstants.REASON_WRONG_AREA,Refer_Out_Segment__c = 'SE',Refer_Out_Team__c = System.Label.Filter_SE_Team + ' team 1');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
        
        Team_Structure__c ts1 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = System.Label.Filter_SE_Team + ' team 1',
			External_ID__c = '99999'
		);
		insert ts1;

        PageReference result = accountReferOutController.save();
        System.assertEquals(null,result);
	}

	@isTest static void testSave() {
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
		Id ON_GOING_RECORD_TYPE_ID = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Team_Province_Master_Data__c', 'On_Going');
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'test other reason',Refer_Out_Segment__c = 'SE',Refer_Out_Team__c = System.Label.Filter_SE_Team + ' team 1');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
       
        Team_Structure__c ts1 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = System.Label.Filter_SE_Team + ' team 1',
			External_ID__c = '1'
		);
		insert ts1;

		Team_Structure__c ts2 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = 'Blocked team',
			External_ID__c = '99999'
		);
		insert ts2;

		Test.startTest();
			System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
        		accountReferOutController.save();
        	}
        Test.stopTest();
        List<Customer_Ownership_Request__c> result = [SELECT Id FROM Customer_Ownership_Request__c];
        System.assertEquals(1,result.size());
	}

	@isTest static void testCoverageConstantString(){
		//Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Account targetAccount = Mockup_Test.getFirstAccountFromName(accountName, 'Id');
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = GlobalConstants.CLOSED_BUSINESS );
		Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));

		System.assertEquals(false,accountReferOutController.isSF1); 
	}

	@isTest static void testCompanyRelatedThenSelectTeam(){
		Test.startTest();
			Team_Structure__c smeTeam = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c = :Mockup_Test.RC_CODE LIMIT 1];
			//Account accountSME = [SELECT Id,CIS__c FROM Account WHERE Name = :accountName LIMIT 1];
			Account accountSME = Mockup_Test.getFirstAccountFromName(accountName, 'Id,CIS__c');
			accountSME.CIS__c = '222222';
			accountSME.Current_Team_Name__c = smeTeam.Id;
			System.runAs(new User(Id=UserInfo.getUserId())){
				update accountSME;
			}
			Team_Structure__c cbTeam = [SELECT Id FROM Team_Structure__c WHERE RC_Code__c = :Mockup_Test.TL_CB_RC_CODE LIMIT 1];
			//Account accountCBS = [SELECT Id,CIS__c From Account WHERE Name = :relatedAccountCBSName LIMIT 1];
			Account accountCBS = Mockup_Test.getFirstAccountFromName(relatedAccountCBSName, 'Id,CIS__c');
			accountCBS.Current_Team_Name__c = cbTeam.Id;
        	System.runAs(new User(Id=UserInfo.getUserId())){
				update accountCBS;
			}
			List<User> userListToUpdate = new List<User>();
			User userSMERM = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
			userSMERM.Segment__c = GlobalConstants.SEGMENT_SE;
			userListToUpdate.add(userSMERM);

			User userCBSRM = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0];
			TriggerHandler.bypass('UserTriggerHandler');
				update userListToUpdate;
			TriggerHandler.clearbypass('UserTriggerHandler');

			//System.debug('Debug - :: userSMERM '+userSMERM);
			//System.debug('Debug - :: userCBSRM '+userCBSRM);
			System.runAs(userSMERM){
				Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = accountSME.id,
																											Refer_Out_Reason__c = GlobalConstants.REASON_COMPANY_RELATED,
																											Company_Related_Text__c = accountCBS.CIS__c
																											);
				Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
				accountReferOutController.getTeamList();
			}

			System.runAs(userCBSRM){
				Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = accountCBS.id,
																											Refer_Out_Reason__c = GlobalConstants.REASON_COMPANY_RELATED,
																											Company_Related_Text__c = accountSME.CIS__c
																											);
				Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
				accountReferOutController.getTeamList();
				System.assertEquals(2,accountReferOutController.teamList.size());
			}
		Test.stopTest();
	}

	@isTest static void testREASON_NOT_SME(){
		String businessCodeString = 'accountBusinessCode';
		String subIndustryGroup = 'subGroup';
		Test.startTest();

		Team_Structure__c teamStructure = [SELECT id,RC_Code__c From Team_Structure__c WHERE RC_Code__c = :Mockup_Test.TL_CB_RC_CODE LIMIT 1];
		Business_Code__c businessCode = new Business_Code__c(Name = businessCodeString,External_ID__c = businessCodeString,Sub_Industry_Group__c =subIndustryGroup);
			insert businessCode;
		Team_Mapping_Refer_Out_Condition_3__c teamMapping3 = new Team_Mapping_Refer_Out_Condition_3__c (Sub_Industry_Group__c=subIndustryGroup,RC_Code__c =teamStructure.RC_Code__c,Min_Sale_Size__c = 200, Max_Sale_Size__c = 400,Name='teamMapping');
			insert teamMapping3;
		Team_Province_Master_Data__c teampMappingMasterData = new Team_Province_Master_Data__c(Team_Structure__c=teamStructure.id,Province_Name__c='นครนายก',Segment__c=GlobalConstants.SEGMENT_CB);
			insert teampMappingMasterData;

		//Account accountSME = [SELECT Id,CIS__c FROM Account WHERE Name = :accountName LIMIT 1];
		Account accountSME = Mockup_Test.getFirstAccountFromName(accountName, 'Id,CIS__c');
			accountSME.CIS__c = '222222';
			accountSME.Customer_s_Business_Code__c = businessCodeString;
			accountSME.Sales_Size__c = 250;
			System.runAs(new User(Id=UserInfo.getUserId())){
				update accountSME;
			}

		List<User> userListToUpdate = new List<User>();
		User userSMERM = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		userSMERM.Segment__c = GlobalConstants.SEGMENT_SE;
		userListToUpdate.add(userSMERM);
		TriggerHandler.bypass('UserTriggerHandler');
		System.runAs(new User(Id=UserInfo.getUserId())){
			update userListToUpdate;
		}
		TriggerHandler.clearbypass('UserTriggerHandler');
		System.runAs(userSMERM){
			Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = accountSME.id,
																										Refer_Out_Reason__c = GlobalConstants.REASON_NOT_SME,
																										Refer_Out_Province__c = 'นครนายก',
																										Refer_Out_Segment__c = GlobalConstants.SEGMENT_CB
																										);
			Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
			
			accountReferOutController.getTeamList();
			System.debug('Debug - accountReferOutController.teamList ::'+accountReferOutController.teamList);
			System.assertEquals(2,accountReferOutController.teamList.size());
		}


		System.runAs(userSMERM){
			Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = accountSME.id,
																											Refer_Out_Reason__c = GlobalConstants.REASON_NOT_SME,
																											Refer_Out_Province__c = 'UnknownProvince',
																											Refer_Out_Segment__c = GlobalConstants.SEGMENT_CB
																										);
			Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
			accountReferOutController.getTeamList();
			System.assertEquals(1,accountReferOutController.teamList.size());
		}
		Test.stopTest();
	}

}