@isTest
private class AccountChangeOwnerTest {
	
	// @isTest static void test_checkPortPool_Port_Positive() {
	// 	AccountChangeOwner accountService = new AccountChangeOwner();
	// 	Account newAccount = new Account(Is_createby_Integration__c = true, Port_Pool__c = GlobalConstants.PORT, Name = 'Test1');
	// 	Account oldAccount = new Account(Port_Pool__c = GlobalConstants.POOL, Name = 'Test1');
	// 	System.assertEquals(GlobalConstants.PORT,(String)accountService.checkPortPool(newAccount,oldAccount));
	// 	System.assertEquals(oldAccount.Port_Pool__c, newAccount.Port_Pool_Flag_Previous_Owner__c);
	// 	System.assertEquals(false, newAccount.Trash_Pool_Flag__c);
	// }
	
	// @isTest static void test_checkPortPool_Pool_Positive() {
	// 	AccountChangeOwner accountService = new AccountChangeOwner();
	// 	Account newAccount = new Account(Is_createby_Integration__c = true, Port_Pool__c = GlobalConstants.POOL, Name = 'Test1');
	// 	Account oldAccount = new Account(Port_Pool__c = GlobalConstants.PORT, Name = 'Test1');
	// 	System.assertEquals(GlobalConstants.POOL,(String)accountService.checkPortPool(newAccount,oldAccount));
	// 	System.assertEquals(oldAccount.Port_Pool__c, newAccount.Port_Pool_Flag_Previous_Owner__c);
	// 	System.assertEquals(false, newAccount.Trash_Pool_Flag__c);
	// }

	// @isTest static void test_checkPortPool_Null_Negative() {
	// 	AccountChangeOwner accountService = new AccountChangeOwner();
	// 	Account newAccount = new Account(Is_createby_Integration__c = true, Port_Pool__c = GlobalConstants.POOL, Name = 'Test1');
	// 	Account oldAccount = null;
	// 	System.assertEquals(null,accountService.checkPortPool(newAccount,oldAccount));
	// }

	// @isTest static void test_checkPortPool_Poor_Negative() {
	// 	AccountChangeOwner accountService = new AccountChangeOwner();
	// 	Account newAccount = new Account(Is_createby_Integration__c = true, Port_Pool__c = 'Poor', Name = 'Test1');
	// 	Account oldAccount = new Account(Port_Pool__c = GlobalConstants.POOL, Name = 'Test1');
	// 	System.assertEquals(null,accountService.checkPortPool(newAccount,oldAccount));
	// }

	@isTest static void test_getProspectRecordTypeId_Positive() {
		AccountChangeOwner accountService = new AccountChangeOwner();
		Map<Id,String> prospectRecordTypeId = accountService.getProspectRecordTypeId();
		System.assertEquals(2,prospectRecordTypeId.size());
		System.assertEquals(GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME, prospectRecordTypeId.get(GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME)));
		System.assertEquals(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME, prospectRecordTypeId.get(GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME)));
	}

	@isTest static void test_isProspectAccount_Positive() {
		AccountChangeOwner accountService = new AccountChangeOwner();
		Map<Id,String> prospectRecordTypeId = accountService.getProspectRecordTypeId();
		Account newAccount = new Account(Is_createby_Integration__c = true, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), Name = 'Test1');
		System.assertEquals(True,accountService.isProspectAccount(newAccount,prospectRecordTypeId));
	}


	@isTest static void test_changeOwnEvent_Positive() {
		User currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
		AccountChangeOwner accountService = new AccountChangeOwner();
		Account newAccount = new Account(Is_createby_Integration__c = true, Port_Pool__c = GlobalConstants.PORT, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), LastName = 'Test1');
		insert newAccount;
		List<Id> accountIdLists = new List<Id>();
		List<Id> ownerIdLists = new List<Id>();
		accountIdLists.add(newAccount.Id);
		ownerIdLists.add(currentUser.Id);

		Opportunity opp = Mockup_Test.newOpportunity(newAccount.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
	    insert opp;

		Event newEvent = new Event(
			WhatId = opp.Id,
			OwnerId = currentUser.Id,
			StartDateTime = System.now(),
			EndDateTime = System.now().addDays(7),
			Status__c = GlobalConstants.PLAN,
			RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_PLAN_DEVNAME)
		);
		insert newEvent;

		accountService.changeOwnEvent(accountIdLists,ownerIdLists);

	}

	@isTest static void test_closeOwnEvent_Positive() {
		User currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
		AccountChangeOwner accountService = new AccountChangeOwner();
		Account newAccount = new Account(Is_createby_Integration__c = true, Port_Pool__c = GlobalConstants.PORT, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), LastName = 'Test1');
		insert newAccount;
		List<Id> accountIdLists = new List<Id>();
		List<Id> ownerIdLists = new List<Id>();
		accountIdLists.add(newAccount.Id);
		ownerIdLists.add(currentUser.Id);

		Opportunity opp = Mockup_Test.newOpportunity(newAccount.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
	    insert opp;

		Event newEvent = new Event(
			WhatId = opp.Id,
			OwnerId = currentUser.Id,
			StartDateTime = System.now(),
			EndDateTime = System.now().addDays(7),
			Status__c = GlobalConstants.PLAN,
			RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_PLAN_DEVNAME)
		);
		insert newEvent;
		List<Event> eventLists = [SELECT Id, AccountId, OwnerId, Job__c, Status__c, RecordTypeId, Actual_Visit_Date__c, Plan_Date__c FROM Event WHERE AccountId IN :accountIdLists AND OwnerId IN: ownerIdLists AND Status__c !=:GlobalConstants.CANCELLED AND Status__c !=:GlobalConstants.CLOSED];
		accountService.updateOwnEvent(eventLists, true);

	}

	@isTest static void test_changeOwnJob_Positive() {
		User currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
		AccountChangeOwner accountService = new AccountChangeOwner();
		Account newAccount = new Account(Is_createby_Integration__c = true, Port_Pool__c = GlobalConstants.PORT, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), LastName = 'Test1');
		insert newAccount;
		List<Id> accountIdLists = new List<Id>();
		List<Id> ownerIdLists = new List<Id>();
		accountIdLists.add(newAccount.Id);
		ownerIdLists.add(currentUser.Id);

		Opportunity opp = Mockup_Test.newOpportunity(newAccount.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
	    insert opp;

		accountService.changeOwnJob(accountIdLists,ownerIdLists);

	}

	@isTest static void test_closeOwnJob_Positive() {
		User currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
		AccountChangeOwner accountService = new AccountChangeOwner();
		Account newAccount = new Account(Is_createby_Integration__c = true, Port_Pool__c = GlobalConstants.PORT, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), LastName = 'Test1');
		insert newAccount;
		List<Id> accountIdLists = new List<Id>();
		List<Id> ownerIdLists = new List<Id>();
		accountIdLists.add(newAccount.Id);
		ownerIdLists.add(currentUser.Id);

		Opportunity opp = Mockup_Test.newOpportunity(newAccount.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
	    insert opp;

		accountService.closeOwnJob(accountIdLists,ownerIdLists);

	}

	@isTest static void test_changeOwnJobProduct_Positive() {
		User currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
		AccountChangeOwner accountService = new AccountChangeOwner();
		Account newAccount = new Account(Is_createby_Integration__c = true, Port_Pool__c = GlobalConstants.PORT, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), LastName = 'Test1');
		insert newAccount;
		List<Id> opportunityIdLists = new List<Id>();
		List<Id> opportunityOwnerIdLists = new List<Id>();
		opportunityOwnerIdLists.add(currentUser.Id);

		Opportunity opp = Mockup_Test.newOpportunity(newAccount.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
	    insert opp;
		opportunityIdLists.add(opp.Id);

		accountService.changeOwnJobProduct(opportunityOwnerIdLists,opportunityIdLists);
	}

	@isTest static void test_closeOwnJobProduct_Positive() {
		User currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
		AccountChangeOwner accountService = new AccountChangeOwner();
		Account newAccount = new Account(Is_createby_Integration__c = true, Port_Pool__c = GlobalConstants.PORT, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), LastName = 'Test1');
		insert newAccount;
		List<Id> opportunityIdLists = new List<Id>();
		List<Id> opportunityOwnerIdLists = new List<Id>();
		opportunityOwnerIdLists.add(currentUser.Id);

		Opportunity opp = Mockup_Test.newOpportunity(newAccount.Id, 'OppName', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
	    insert opp;
		opportunityIdLists.add(opp.Id);

		accountService.closeOwnJobProduct(opportunityOwnerIdLists,opportunityIdLists);
	}

	// @isTest static void test_changeOwnContact_Positive() {
	// 	AccountChangeOwner accountService = new AccountChangeOwner();
	// 	Account newAccount = new Account(Is_createby_Integration__c = true, Port_Pool__c = GlobalConstants.PORT, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), LastName = 'Test1');
	// 	insert newAccount;
	// 	List<Id> accountIdLists = new List<Id>();
	// 	accountIdLists.add(newAccount.Id);
	// 	accountService.changeOwnContact(accountIdLists);

	// }

	
	@isTest static void test_checkCurrentAssignUserFromPermanentOwnerExt_Positive() {
		User currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
		currentUser.RBS_User__c = false;
		AccountChangeOwner accountService = new AccountChangeOwner();
		Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId = new Map<Id,User_Extension__c>();
		Map<Id,User> userMappingList = new Map<Id,User>();
		Map<String,Id> teamMapByRc = new Map<String,Id>();
		teamMapByRc.put('1234', currentUser.Id);
		userMappingList.put(currentUser.Id, currentUser);
		Account newAccount = new Account(Is_createby_Integration__c = true, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), Name = 'Test1', OwnerId=currentUser.Id, Sales_Size__c = 1111);
		Account oldAccount = new Account(Port_Pool__c = GlobalConstants.POOL, Name = 'Test1', Primary_Segment_Code__c='SE', Current_Owner_Extension__c=currentUser.Id, Current_AH_Name__c=currentUser.Id, Current_NH_Name__c=currentUser.Id, Current_Team_Name__c=currentUser.Id, OwnerId=currentUser.Id);
        User_Extension__c newUserExtension = new User_Extension__c(User__c = currentUser.Id, Name = 'Test0001', External_ID__c = '1234', User__r = currentUser);
		insert newUserExtension;

		possibleUserExtensionMapWithUserId.put(currentUser.Id, newUserExtension);

		User assignUser = accountService.checkCurrentAssignUserFromPermanentOwnerExt(newAccount, userMappingList, possibleUserExtensionMapWithUserId);
	}

	@isTest static void test_isRBSToRBSSegment_Positive() {
		User currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
		currentUser.RBS_User__c = false;
		AccountChangeOwner accountService = new AccountChangeOwner();
		Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId = new Map<Id,User_Extension__c>();
		Map<String,Id> teamMapByRc = new Map<String,Id>();
		teamMapByRc.put('1234', currentUser.Id);
		Account newAccount = new Account(Is_createby_Integration__c = true, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), Name = 'Test1', OwnerId=currentUser.Id, Sales_Size__c = 1111);
		Account oldAccount = new Account(Port_Pool__c = GlobalConstants.POOL, Name = 'Test1', Primary_Segment_Code__c='SE', Current_Owner_Extension__c=currentUser.Id, Current_AH_Name__c=currentUser.Id, Current_NH_Name__c=currentUser.Id, Current_Team_Name__c=currentUser.Id, OwnerId=currentUser.Id);
		User oldUser = new User(RBS_User__c = False, FirstName = 'Test2', IsActive = true, Segment__c = GlobalConstants.SEGMENT_SE);
		User_Extension__c newUserExtension = new User_Extension__c(User__c = currentUser.Id, Name = 'Test0001', External_ID__c = '1234', User__r = currentUser);
		insert newUserExtension;

		possibleUserExtensionMapWithUserId.put(currentUser.Id, newUserExtension);
		System.assertEquals(True,accountService.isRBSToRBSSegment(newAccount,oldUser,currentUser,oldAccount,teamMapByRc,possibleUserExtensionMapWithUserId));
	}

	@isTest static void test_isRBSToSMESegment_Positive() {
		User currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
		currentUser.RBS_User__c = false;
		AccountChangeOwner accountService = new AccountChangeOwner();
		Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId = new Map<Id,User_Extension__c>();
		Map<String,Id> teamMapByRc = new Map<String,Id>();
		teamMapByRc.put('1234', currentUser.Id);
		Account newAccount = new Account(Is_createby_Integration__c = true, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), Name = 'Test1', OwnerId=currentUser.Id, Sales_Size__c = 1111);
		Account oldAccount = new Account(Port_Pool__c = GlobalConstants.POOL, Name = 'Test1', Primary_Segment_Code__c='SE', Current_Owner_Extension__c=currentUser.Id, Current_AH_Name__c=currentUser.Id, Current_NH_Name__c=currentUser.Id, Current_Team_Name__c=currentUser.Id, OwnerId=currentUser.Id);
		User oldUser = new User(RBS_User__c = False, FirstName = 'Test2', IsActive = true, Segment__c = GlobalConstants.SEGMENT_SE);
		User_Extension__c newUserExtension = new User_Extension__c(User__c = currentUser.Id, Name = 'Test0001', External_ID__c = '1234', User__r = currentUser);
		insert newUserExtension;

		possibleUserExtensionMapWithUserId.put(currentUser.Id, newUserExtension);
		System.assertEquals(True,accountService.isRBSToSMESegment(newAccount,oldUser,currentUser,oldAccount,teamMapByRc,possibleUserExtensionMapWithUserId));
	}

	@isTest static void test_isSMEToSMESegment_Positive() {
		User currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
		currentUser.RBS_User__c = false;
		AccountChangeOwner accountService = new AccountChangeOwner();
		Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId = new Map<Id,User_Extension__c>();
		Map<String,Id> teamMapByRc = new Map<String,Id>();
		teamMapByRc.put('1234', currentUser.Id);
		Account newAccount = new Account(Is_createby_Integration__c = true, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), Name = 'Test1', OwnerId=currentUser.Id, Sales_Size__c = 1111);
		Account oldAccount = new Account(Port_Pool__c = GlobalConstants.POOL, Name = 'Test1', Primary_Segment_Code__c='SE', Current_Owner_Extension__c=currentUser.Id, Current_AH_Name__c=currentUser.Id, Current_NH_Name__c=currentUser.Id, Current_Team_Name__c=currentUser.Id, OwnerId=currentUser.Id);
		User oldUser = new User(RBS_User__c = False, FirstName = 'Test2', IsActive = true, Segment__c = GlobalConstants.SEGMENT_SE);
		User_Extension__c newUserExtension = new User_Extension__c(User__c = currentUser.Id, Name = 'Test0001', External_ID__c = '1234', User__r = currentUser);
		insert newUserExtension;

		possibleUserExtensionMapWithUserId.put(currentUser.Id, newUserExtension);
		System.assertEquals(True,accountService.isSMEToSMESegment(newAccount,oldUser,currentUser,oldAccount,teamMapByRc,possibleUserExtensionMapWithUserId));
	}
	
	@isTest static void test_updateOwnerFieldsSet_Positive() {
		User currentUser = User_Service.getUserInfoWithId(UserInfo.getUserId());
		currentUser.RBS_User__c = false;
		AccountChangeOwner accountService = new AccountChangeOwner();
		Map<Id,User_Extension__c> possibleUserExtensionMapWithUserId = new Map<Id,User_Extension__c>();
		Map<String,Id> teamMapByRc = new Map<String,Id>();
		teamMapByRc.put('1234', currentUser.Id);
		Account newAccount = new Account(Is_createby_Integration__c = true, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), Name = 'Test1', OwnerId=currentUser.Id, Sales_Size__c = 1111);
		Account oldAccount = new Account(Port_Pool__c = GlobalConstants.POOL, Name = 'Test1', Primary_Segment_Code__c='SE', Current_Owner_Extension__c=currentUser.Id, Current_AH_Name__c=currentUser.Id, Current_NH_Name__c=currentUser.Id, Current_Team_Name__c=currentUser.Id, OwnerId=currentUser.Id);
        User_Extension__c newUserExtension = new User_Extension__c(User__c = currentUser.Id, Name = 'Test0001', External_ID__c = '1234', User__r = currentUser);
		insert newUserExtension;

		possibleUserExtensionMapWithUserId.put(currentUser.Id, newUserExtension);
		accountService.updateOwnerFieldsSet(newAccount, oldAccount, teamMapByRc, possibleUserExtensionMapWithUserId);

		// System.assertEquals(null, newAccount.Permanent_Owner__c);
		// System.assertEquals(null, newAccount.Permanent_Owner_Extension__c);
		// System.assertEquals(null, newAccount.Permanent_AH_Name__c);
		// System.assertEquals(null, newAccount.Permanent_NH_Name__c);
		// System.assertEquals(null, newAccount.Permanent_Team_Name__c);
	}


	@isTest static void test_clearPermanentOwnerFieldsSet_Positive() {
		AccountChangeOwner accountService = new AccountChangeOwner();
		Account newAccount = new Account(Is_createby_Integration__c = true, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), Name = 'Test1');
		accountService.clearPermanentOwnerFieldsSet(newAccount);
		System.assertEquals(null, newAccount.Permanent_Owner__c);
		System.assertEquals(null, newAccount.Permanent_Owner_Extension__c);
		System.assertEquals(null, newAccount.Permanent_AH_Name__c);
		System.assertEquals(null, newAccount.Permanent_NH_Name__c);
		System.assertEquals(null, newAccount.Permanent_Team_Name__c);
	}

	// @isTest static void test_calculatePrimarySegment_RBSUser_Positive() {
	// 	AccountChangeOwner accountService = new AccountChangeOwner();
	// 	User newUser = new User(RBS_User__c = True, FirstName = 'Test1', IsActive = true);
	// 	Account newAccount = new Account(Is_createby_Integration__c = true, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), Name = 'Test1');
	// 	System.assertEquals(GlobalConstants.PRIMARY_SEGMENT_CODE_LM, accountService.calculatePrimarySegment(newUser, newAccount,''));
	// }

	// @isTest static void test_calculatePrimarySegment_SE_Positive() {
	// 	AccountChangeOwner accountService = new AccountChangeOwner();
	// 	User newUser = new User(RBS_User__c = False, FirstName = 'Test1', IsActive = true, Segment__c = GlobalConstants.SEGMENT_SE);
	// 	Account newAccount = new Account(Is_createby_Integration__c = true, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), Name = 'Test1');
	// 	System.assertEquals(GlobalConstants.PRIMARY_SEGMENT_CODE_SM, accountService.calculatePrimarySegment(newUser, newAccount,''));
	// }

	// @isTest static void test_calculatePrimarySegment_UM_Positive() {
	// 	AccountChangeOwner accountService = new AccountChangeOwner();
	// 	User newUser = new User(RBS_User__c = False, FirstName = 'Test1', IsActive = true, Segment__c = GlobalConstants.SEGMENT_ME);
	// 	Account newAccount = new Account(Is_createby_Integration__c = true, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), Name = 'Test1');
	// 	System.assertEquals(GlobalConstants.PRIMARY_SEGMENT_CODE_UM, accountService.calculatePrimarySegment(newUser, newAccount,'200000000'));
	// }

	// @isTest static void test_calculatePrimarySegment_LM_Positive() {
	// 	AccountChangeOwner accountService = new AccountChangeOwner();
	// 	User newUser = new User(RBS_User__c = False, FirstName = 'Test1', IsActive = true, Segment__c = GlobalConstants.SEGMENT_ME);
	// 	Account newAccount = new Account(Is_createby_Integration__c = true, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), Name = 'Test1');
	// 	System.assertEquals(GlobalConstants.PRIMARY_SEGMENT_CODE_LM, accountService.calculatePrimarySegment(newUser, newAccount,'100000'));
	// }

	// @isTest static void test_calculatePrimarySegment_CB_Positive() {
	// 	AccountChangeOwner accountService = new AccountChangeOwner();
	// 	User newUser = new User(RBS_User__c = False, FirstName = 'Test1', IsActive = true, Segment__c = GlobalConstants.SEGMENT_CB);
	// 	Account newAccount = new Account(Is_createby_Integration__c = true, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), Name = 'Test1');
	// 	System.assertEquals(GlobalConstants.PRIMARY_SEGMENT_CODE_CB, accountService.calculatePrimarySegment(newUser, newAccount,''));
	// }

	// @isTest static void test_calculatePrimarySegment_MB_Positive() {
	// 	AccountChangeOwner accountService = new AccountChangeOwner();
	// 	User newUser = new User(RBS_User__c = False, FirstName = 'Test1', IsActive = true, Segment__c = GlobalConstants.SEGMENT_MB);
	// 	Account newAccount = new Account(Is_createby_Integration__c = true, RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Account', GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME), Name = 'Test1');
	// 	System.assertEquals(GlobalConstants.PRIMARY_SEGMENT_CODE_MB, accountService.calculatePrimarySegment(newUser, newAccount,''));
	// }

	@isTest
	public static void test_updateIndividualContact_positive() {
		AccountChangeOwner accountService = new AccountChangeOwner();
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
		System.runAs(new User(Id=UserInfo.getUserId())) {
            mt.setUpTestDifferentArea();
            
	        List<User> AdditionalUser = new List<User>();

			String rmSMERoleDevname = 'RCRM' + Mockup_Test.RC_CODE;
			UserRole rmSMERole = [SELECT Id FROM UserRole WHERE DeveloperName = :rmSMERoleDevname LIMIT 1];
			User rmSMEUser = [SELECT Id, ProfileId, UserRoleId, ManagerId, Job_Code__c, AH_RC_Code__c, NH_RC_Code__c, RC_Code__c, Status__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
			User rmSMEUser2 = Mockup_Test.newUser(
				Mockup_Test.userFirstNameRM2,
				Mockup_Test.userLastNameRM2,
				true,
				Mockup_Test.userFirstNameRM2+'@mail.com',
				Mockup_Test.userFirstNameRM2+'@mail.com',
				Mockup_Test.userFirstNameRM2.substring(0, 4),
				rmSMEUser.ProfileId,
				rmSMEUser.UserRoleId,
				rmSMEUser.ManagerId,
				Mockup_Test.userEmpIdRM2
			);
			rmSMEUser2.Job_Code__c = rmSMEUser.Job_Code__c;
			rmSMEUser2.AH_RC_Code__c = rmSMEUser.AH_RC_Code__c;
			rmSMEUser2.NH_RC_Code__c = rmSMEUser.NH_RC_Code__c;
			rmSMEUser2.RC_Code__c = rmSMEUser.RC_Code__c;
			rmSMEUser2.Status__c = rmSMEUser.Status__c;
			insert rmSMEUser2;
		}

		User rmSMEUser = [SELECT Id FROM User WHERE Firstname = :Mockup_Test.userFirstNameRM LIMIT 1];
		User rmSMEUser2 = [SELECT Id FROM User WHERE Firstname = :Mockup_Test.userFirstNameRM2 LIMIT 1];
		
		Account personalAccountA = new Account();
		List<Contact> indiContactList = new List<Contact>();
		Contact individualContactA = new Contact();
		Contact individualContactB = new Contact();
		System.runAs(rmSMEUser){
			personalAccountA.FirstName = 'AccountA';
			personalAccountA.LastName = 'Personal';
			personalAccountA.Temporary_Customer__c = true;
			personalAccountA.recordTypeId = GlobalUtility.getRecordTypeAccountidbyName('Individual Customer');
			insert personalAccountA;

			individualContactA.FirstName = 'ContactA';
			individualContactA.LastName = 'Individual';
			individualContactA.Phone_Numbers__c = '0801111111';
			individualContactA.CIS__c = personalAccountA.Id;
			individualContactA.recordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Contact', 'Individual_Contact');
			indiContactList.add(individualContactA);
            
			individualContactB.FirstName = 'ContactB';
			individualContactB.LastName = 'Individual';
			individualContactB.Phone_Numbers__c = '0801111111';
			individualContactB.CIS__c = personalAccountA.Id;
			individualContactB.recordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Contact', 'Individual_Contact');
			indiContactList.add(individualContactB);
			insert indiContactList;
		}

		personalAccountA.OwnerId = rmSMEUser2.Id;
		Map<Id, Account> mapPersonalAccountWithId = new Map<Id,Account>();
		mapPersonalAccountWithId.put(personalAccountA.Id, personalAccountA);
		accountService.updateIndividualContactOwner(mapPersonalAccountWithId);

		List<Contact> updatedIndividualContact = [SELECT Id, OwnerId FROM Contact WHERE Id IN :indicontactList];
		boolean isContactChange = true;
		for(Contact eachContact : updatedIndividualContact){
			if(eachContact.OwnerId != rmSMEUser2.Id) isContactChange = false;
		}

		System.assertEquals(true, isContactChange);
	}
}