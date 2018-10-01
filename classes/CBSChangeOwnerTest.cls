@isTest
private class CBSChangeOwnerTest {
	private static String userEmpIdCBSChangeOwnerTest1 = '9900000020';
	private static String userEmpIdCBSChangeOwnerTest2 = '9900000021';
	private static String userFirstNameCBSChangeOwnerTest1 = 'FirstNameCBSChangeOwner1';
	private static String userLastNameCBSChangeOwnerTest1 = 'LastNameCBSChangeOwner1';
	private static String userFirstNameCBSChangeOwnerTest2 = 'FirstNameCBSChangeOwner2';
	private static String userLastNameCBSChangeOwnerTest2 = 'LastNameCBSChangeOwner2';

	@isTest static void Given_UserCBSSegmentCBAndAccount_When_ChangeAccountOwner_Then_ChangePrimarySegmentCodeToCB() {
		UserTriggerHandler.isByPass = true;
		User cbsTM = UserManagementMockupTest.createNewUser(userEmpIdCBSChangeOwnerTest2, userFirstNameCBSChangeOwnerTest2, userLastNameCBSChangeOwnerTest2, true, null);
		cbsTM.ProfileId = UserManagementMockupTest.getMapProfileByName(GlobalConstants.CBS_TM).Id;
		cbsTM.Segment__c = GlobalConstants.SEGMENT_CB;
		insert cbsTM;

		User cbsRM = UserManagementMockupTest.createNewUser(userEmpIdCBSChangeOwnerTest1, userFirstNameCBSChangeOwnerTest1, userLastNameCBSChangeOwnerTest1, true, cbsTM.Id);
		cbsRM.ProfileId = UserManagementMockupTest.getMapProfileByName(GlobalConstants.CBS_RM).Id;
		insert cbsRM;
		
		List<User_Extension__c> userExtensionList = new List<User_Extension__c>();
		User_Extension__c cbsRMEX = UserService.createUserExtension(cbsRM, new Map<String, Team_Structure__c>());
		User_Extension__c cbsTMEX = UserService.createUserExtension(cbsTM, new Map<String, Team_Structure__c>());
		userExtensionList.add(cbsRMEX);
		userExtensionList.add(cbsTMEX);
		insert userExtensionList;

		Account newAccount = new Account(
			Name = 'newAccount',
	        Port_Pool__c = GlobalConstants.PORT,
	        RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account',GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME),
	        Customer_Segment_Code__c 	= GlobalConstants.SEGMENT_CB,
	        Is_createby_Integration__c 	= true
	    );
		System.runAs(cbsRM){
        	insert newAccount;
        }

		System.runAs(cbsRM){
        	newAccount.OwnerId = cbsTM.Id;
        	update newAccount;
        }

        Account resultAccount = [SELECT Id,Name,Primary_Segment_Code__c FROM Account WHERE Id = :newAccount.Id];
        System.assertEquals(GlobalConstants.SEGMENT_CB,resultAccount.Primary_Segment_Code__c);
	}

	@isTest static void Given_UserCBSSegmentMBAndAccount_When_ChangeAccountOwner_Then_ChangePrimarySegmentCodeToMB() {
		UserTriggerHandler.isByPass = true;
		User cbsTM = UserManagementMockupTest.createNewUser(userEmpIdCBSChangeOwnerTest2, userFirstNameCBSChangeOwnerTest2, userLastNameCBSChangeOwnerTest2, true, null);
		cbsTM.ProfileId = UserManagementMockupTest.getMapProfileByName(GlobalConstants.CBS_TM).Id;
		cbsTM.Segment__c = GlobalConstants.SEGMENT_MB;
		insert cbsTM;

		User cbsRM = UserManagementMockupTest.createNewUser(userEmpIdCBSChangeOwnerTest1, userFirstNameCBSChangeOwnerTest1, userLastNameCBSChangeOwnerTest1, true, cbsTM.Id);
		cbsRM.ProfileId = UserManagementMockupTest.getMapProfileByName(GlobalConstants.CBS_RM).Id;
		insert cbsRM;
		
		List<User_Extension__c> userExtensionList = new List<User_Extension__c>();
		User_Extension__c cbsRMEX = UserService.createUserExtension(cbsRM, new Map<String, Team_Structure__c>());
		User_Extension__c cbsTMEX = UserService.createUserExtension(cbsTM, new Map<String, Team_Structure__c>());
		userExtensionList.add(cbsRMEX);
		userExtensionList.add(cbsTMEX);
		insert userExtensionList;

		Account newAccount = new Account(
			Name = 'newAccount',
	        Port_Pool__c = GlobalConstants.PORT,
	        RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account',GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME),
	        Customer_Segment_Code__c 	= GlobalConstants.SEGMENT_MB,
	        Is_createby_Integration__c 	= true
	    );
		System.runAs(cbsRM){
        	insert newAccount;
        }

		System.runAs(cbsRM){
        	newAccount.OwnerId = cbsTM.Id;
        	update newAccount;
        }

        Account resultAccount = [SELECT Id,Name,Primary_Segment_Code__c FROM Account WHERE Id = :newAccount.Id];
        System.assertEquals(GlobalConstants.SEGMENT_MB,resultAccount.Primary_Segment_Code__c);
	}
}