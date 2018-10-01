@isTest 
public with sharing class Budget_Test {
	static final Id TRANSFER_BUDGET				= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.TRANSFER_BUDGET_DEVNAME);
	static final Id TRANSFER_BUDGET_READ_ONLY	= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.TRANSFER_BUDGET_READ_ONLY_DEVNAME);
	static final Id TRANSFER_BUDGET_APPROVE		= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.TRANSFER_BUDGET_APPROVE_DEVNAME);
	static final Id REQUEST_BUDGET				= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.REQUEST_BUDGET_DEVNAME);
	static final Id REQUEST_BUDGET_READ_ONLY	= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.REQUEST_BUDGET_READ_ONLY_DEVNAME);
	static final Id REQUEST_BUDGET_APPROVE		= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.REQUEST_BUDGET_APPROVE_DEVNAME);
	
	static final Id DECREASE_BUDGET_ITEM 		= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.DECREASE_BUDGET_ITEM_DEVNAME);
	static final Id INCREASE_BUDGET_ITEM 		= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.INCREASE_BUDGET_ITEM_DEVNAME);
	static final Id REQUEST_BUDGET_ITEM 		= GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.REQUEST_BUDGET_ITEM_DEVNAME);

	static final String UserFirstNameBudgetAdmin = 'FirstnameBudgetAdmin';
	static final String UserLastNameBudgetAdmin = 'LastnameBudgetAdmin';
	static final String UserFirstNameNH1 = 'FirstnameNH1';
	static final String UserLastNameNH1 = 'LastnameNH1';
	static final String UserFirstNameZM1 = 'FirstnameZM11';
	static final String UserLastNameZM1 = 'LastnameZM11';
	static final String UserFirstNameBM1 = 'FirstnameBM111';
	static final String UserLastNameBM1 = 'LastnameBM111';
	static final String UserFirstNameBM2 = 'FirstnameBM112';
	static final String UserLastNameBM2 = 'LastnameBM112';
	static final String UserFirstNameZM2 = 'FirstnameZM12';
	static final String UserLastNameZM2 = 'LastnameZM12';

	static final String NH1_RC_CODE = '10000';
	static final String ZM1_RC_CODE = '10100';
	static final String ZM2_RC_CODE = '10200';
	static final String BM1_RC_CODE = '10101';
	static final String BM2_RC_CODE = '10102';

	static final String userEmpIdBudgetAdmin = '1000000001';
	static final String userEmpIdNH1 = '1000000002';
	static final String userEmpIdZM1 = '1000000003';
	static final String userEmpIdZM2 = '1000000004';
	static final String userEmpIdBM1 = '1000000005';
	static final String userEmpIdBM2 = '1000000006';
	
	@TestSetup
	static void setupData(){
		System.runAs(new User(Id=UserInfo.getUserId())) {
			Profile budgetAdminProfile = Mockup_Test.getMapProfileByName(GlobalConstants.RBS_BUDGET_ADMIN);
			Profile rbsAdminProfile = Mockup_Test.getMapProfileByName(GlobalConstants.RBS_ADMIN);
			Profile nhProfile = Mockup_Test.getMapProfileByName(GlobalConstants.RBS_NH);
			Profile zmProfile = Mockup_Test.getMapprofileByName(GlobalConstants.RBS_AH);
			Profile bmProfile = Mockup_Test.getMapprofileByName(GlobalConstants.RBS_TM);

			UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'RBS_Admin'];
			UserRole nh1Role = Mockup_Test.newRole(NH1_RC_CODE, 'RC' + NH1_RC_CODE, adminRole.Id);
			insert nh1Role;
			UserRole zm1Role = Mockup_Test.newRole(ZM1_RC_CODE, 'RC' + ZM1_RC_CODE, nh1Role.Id);
			insert zm1Role;
			UserRole zm2Role = Mockup_Test.newRole(ZM2_RC_CODE, 'RC' + ZM2_RC_CODE, nh1Role.Id);
			insert zm2Role;
			UserRole bm1Role = Mockup_Test.newRole(BM1_RC_CODE, 'RC' + BM1_RC_CODE, zm1Role.Id);
			insert bm1Role;
			UserRole bm2Role = Mockup_Test.newRole(BM2_RC_CODE, 'RC' + BM2_RC_CODE, zm1Role.Id);
			insert bm2Role;

			User BudgetAdminUser = Mockup_Test.newUser(
				UserFirstNameBudgetAdmin,
				UserLastNameBudgetAdmin,
				true,
				UserFirstNameBudgetAdmin + '@mail.com',
				UserFirstNameBudgetAdmin + '@mail.com',
				UserFirstNameBudgetAdmin.substring(0, 4),
				budgetAdminProfile.Id,
				adminRole.Id,
				null,
				userEmpIdBudgetAdmin
			);
			insert BudgetAdminUser;

			User nh1User = Mockup_Test.newUser(
				UserFirstNameNH1,
				UserLastNameNH1,
				true,
				UserFirstNameNH1 + '@mail.com',
				UserFirstNameNH1 + '@mail.com',
				UserFirstNameNH1.substring(0, 4),
				nhProfile.Id,
				nh1Role.Id,
				null,
				userEmpIdNH1
			);
			nh1User.RC_Code__c = NH1_RC_Code;
			nh1User.NH_RC_CODE__c = NH1_RC_CODE;
			insert nh1User;
			
			User zm1User = Mockup_Test.newUser(
				UserFirstNameZM1,
				UserLastNameZM1,
				true,
				UserFirstNameZM1 + '@mail.com',
				UserFirstNameZM1 + '@mail.com',
				UserFirstNameZM1.substring(0, 4),
				zmProfile.Id,
				zm1Role.Id,
				nh1User.Id,
				userEmpIdZM1
			);
			zm1User.RC_Code__c = ZM1_RC_CODE;
			zm1User.NH_RC_Code__c = NH1_RC_CODE;
			zm1User.AH_RC_Code__c = ZM1_RC_CODE;
			insert zm1User;

			User zm2User = Mockup_Test.newUser(
				UserFirstNameZM2,
				UserLastNameZM2,
				true,
				UserFirstNameZM2 + '@mail.com',
				UserFirstNameZM2 + '@mail.com',
				UserFirstNameZM2.substring(0, 4),
				zmProfile.Id,
				zm2Role.Id,
				nh1User.Id,
				userEmpIdZM2
			);
			zm2User.RC_Code__c = ZM2_RC_CODE;
			zm2User.NH_RC_Code__c = NH1_RC_CODE;
			zm2User.AH_RC_Code__c = ZM2_RC_CODE;
			insert zm2User;

			User bm1User = Mockup_Test.newUser(
				UserFirstNameBM1,
				UserLastNameBM1,
				true,
				UserFirstNameBM1 + '@mail.com',
				UserFirstNameBM1 + '@mail.com',
				UserFirstNameBM1.substring(0, 4),
				bmProfile.Id,
				bm1Role.Id,
				zm1User.Id,
				userEmpIdBM1
			);
			bm1User.RC_Code__c = BM1_RC_CODE;
			bm1User.NH_RC_Code__c = NH1_RC_CODE;
			bm1User.AH_RC_Code__c = ZM1_RC_CODE;
			insert bm1User;

			User bm2User = Mockup_Test.newUser(
				UserFirstNameBM2,
				UserLastNameBM2,
				true,
				UserFirstNameBM2 + '@mail.com',
				UserFirstNameBM2 + '@mail.com',
				UserFirstNameBM2.substring(0, 4),
				bmProfile.Id,
				bm2Role.Id,
				zm1User.Id,
				userEmpIdBM2
			);
			bm2User.RC_Code__c = BM2_RC_CODE;
			bm2User.NH_RC_Code__c = NH1_RC_CODE;
			bm2User.AH_RC_Code__c = ZM2_RC_CODE;
			insert bm2User;

			Team_Structure__c ts_rbs_nh1 = new Team_Structure__c(
				External_ID__c = NH1_RC_CODE,
				RC_Code__c = NH1_RC_CODE,
				AH_RC_Code__c = null,
				NH_RC_Code__c = null,
				Name = 'ภาคที่1',
				OwnerId = nh1User.Id
			);
			insert ts_rbs_nh1;
			
			Team_Structure__c ts_rbs_zm1 = new Team_Structure__c(
				External_ID__c = ZM1_RC_CODE,
				RC_Code__c = ZM1_RC_CODE,
				AH_RC_Code__c = null,
				NH_RC_Code__c = NH1_RC_CODE,
				Name = 'เขตที่1',
				OwnerId = zm1User.Id
			);
			insert ts_rbs_zm1;

			Team_Structure__c ts_rbs_zm2 = new Team_Structure__c(
				External_ID__c = ZM2_RC_CODE,
				RC_Code__c = ZM2_RC_CODE,
				AH_RC_Code__c = null,
				NH_RC_Code__c = NH1_RC_CODE,
				Name = 'เขตที่2',
				OwnerId = zm2User.Id
			);
			insert ts_rbs_zm2;
			
			Team_Structure__c ts_rbs_bm1 = new Team_Structure__c(
				External_ID__c = BM1_RC_CODE,
				RC_Code__c = BM1_RC_CODE,
				AH_RC_Code__c = ZM1_RC_CODE,
				NH_RC_Code__c = NH1_RC_CODE,
				Name = 'สาขาที่1',
				OwnerId = bm1User.Id
			);
			insert ts_rbs_bm1;

			Team_Structure__c ts_rbs_bm2 = new Team_Structure__c(
				External_ID__c = BM2_RC_CODE,
				RC_Code__c = BM2_RC_CODE,
				AH_RC_Code__c = ZM1_RC_CODE,
				NH_RC_Code__c = NH1_RC_CODE,
				Name = 'สาขาที่2',
				OwnerId = bm2User.Id
			);
			insert ts_rbs_bm2;
		}
	}

	private static Map<String, Team_Structure__c> getTeamStructureMapByName(){
		Map<String, Team_Structure__c> teamStructureMapByName = new Map<String, Team_Structure__c>();
		for(Team_Structure__c teamStructure : [SELECT Id, Name, OwnerId FROM Team_Structure__c]) {
			teamStructureMapByName.put(teamStructure.Name, teamStructure);
		} 
		return teamStructureMapByName; 
	}

	private static Budget__c mockMainBudget (Id recordTypeId, String Stage) {
		Budget__c mainBudget = new Budget__c(
			recordTypeId = recordTypeId,
			OwnerId = userInfo.getUserId(),
			Stage__c = Stage
		);
		return mainBudget;
	}

	private static Budget__c mockItemBudget (Id parentId, Id recordTypeId, Id Team_Name, String Account_Type, String Account_Subtype, Integer Amount) {
		Budget__c itemBudget;
		if(recordTypeId == DECREASE_BUDGET_ITEM) {
			itemBudget = new Budget__c(
				Budget_ParentId__c = parentId,
				recordTypeId = recordTypeId,
				Team_Name__c = Team_Name,
				OwnerId = userInfo.getUserId(),
				Account_Decrease_Type__c = Account_Type,
				Account_Decrease_Subtype__c = Account_Subtype,
				Total_Decrease__c = Amount
			);
		} else if (recordTypeId == INCREASE_BUDGET_ITEM) {
			itemBudget = new Budget__c(
				Budget_ParentId__c = parentId,
				recordTypeId = recordTypeId,
				Team_Name__c = Team_Name,
				OwnerId = userInfo.getUserId(),
				Account_Increase_Type__c = Account_Type,
				Account_Increase_Subtype__c = Account_Subtype,
				Increase_Amount__c = Amount
			);
		} else if (recordTypeId == REQUEST_BUDGET_ITEM) {
			itemBudget = new Budget__c(
				Budget_ParentId__c = parentId,
				recordTypeId = recordTypeId,
				Team_Name__c = Team_Name,
				OwnerId = userInfo.getUserId(),
				Account_Type__c = Account_Type,
				Account_Subtype__c = Account_Subtype,
				Increase_Amount__c = Amount
			);
		}
		return itemBudget;
	}

	@isTest
	static void test_stampInsertedMainBudget_InsertMainBudget() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		List<Budget__c> insertList = new List<Budget__c>();
		Budget__c mainBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = mockMainBudget(TRANSFER_BUDGET, GlobalConstants.BUDGET_OPEN);
			insertList.add(mainBudget);
			BudgetService.stampInsertedMainBudget(insertList);
		}
		for(Budget__c inserted : insertList) {
			System.assertEquals(teamStructureMapByName.get('สาขาที่1').Id, inserted.Owner_Team_Name__c);
		}
	}

	@isTest
	static void test_createNewItemBudget_insertDecItemBudget() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		Map<Id, Budget__c> newMapById = new Map<Id, Budget__c>();
		Budget__c mainBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				recordTypeId = TRANSFER_BUDGET
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c insertMainBudget = new Budget__c(
				Id = mainBudget.Id,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Decrease_Subtype__c = '6051001 Domestic travelling expense and allowance',
				Total_Decrease__c = 1000,
				Reason__c = 'test',
				recordTypeId = TRANSFER_BUDGET
			);
			newMapById.put(mainBudget.Id, insertMainBudget);
			BudgetService.createNewItemBudget(newMapById, oldMapById);
		}
		List<Budget__c> newItemList = [
			SELECT Id, Budget_ParentId__c, Team_Name__c, Account_Decrease_Type__c, Account_Decrease_Subtype__c, Total_Decrease__c, Reason__c, recordTypeId
			FROM Budget__c
			WHERE Budget_ParentId__c = :mainBudget.Id
		];
		//results
		System.assertEquals(1, newItemList.size());
		mainBudget = newMapById.values()[0];
		Budget__c itemBudget = newItemList[0];
		System.assertEquals(mainBudget.Team_Name__c, itemBudget.Team_Name__c);
		System.assertEquals(mainBudget.Account_Decrease_Type__c, itemBudget.Account_Decrease_Type__c);
		System.assertEquals(mainBudget.Account_Decrease_Subtype__c, itemBudget.Account_Decrease_Subtype__c);
		System.assertEquals(mainBudget.Total_Decrease__c, itemBudget.Total_Decrease__c);
		System.assertEquals(mainBudget.Reason__c, itemBudget.Reason__c);
		System.assertEquals(DECREASE_BUDGET_ITEM, itemBudget.recordTypeId);
	}

	@isTest
	static void test_createNewItemBudget_insertIncItemBudget() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		Map<Id, Budget__c> newMapById = new Map<Id, Budget__c>();
		Budget__c mainBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				recordTypeId = TRANSFER_BUDGET
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c insertMainBudget = new Budget__c(
				Id = mainBudget.Id,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Increase_Type__c = '10150 Entertainment Expenses',
				Account_Increase_Subtype__c = '6014906 Food and beverages',
				Increase_Amount__c = 1000,
				Reason__c = 'test',
				recordTypeId = TRANSFER_BUDGET
			);
			newMapById.put(mainBudget.Id, insertMainBudget);
			BudgetService.createNewItemBudget(newMapById, oldMapById);
		}
		List<Budget__c> newItemList = [
			SELECT Id, Budget_ParentId__c, Team_Name__c, Account_Decrease_Type__c, Account_Increase_Type__c, Account_Increase_Subtype__c, Increase_Amount__c, Reason__c, recordTypeId
			FROM Budget__c
			WHERE Budget_ParentId__c = :mainBudget.Id
		];
		//results
		System.assertEquals(1, newItemList.size());
		mainBudget = newMapById.values()[0];
		Budget__c itemBudget = newItemList[0];
		System.assertEquals(mainBudget.Team_Name__c, itemBudget.Team_Name__c);
		System.assertEquals(mainBudget.Account_Decrease_Type__c, itemBudget.Account_Decrease_Type__c);
		System.assertEquals(mainBudget.Account_Increase_Type__c, itemBudget.Account_Increase_Type__c);
		System.assertEquals(mainBudget.Account_Increase_Subtype__c, itemBudget.Account_Increase_Subtype__c);
		System.assertEquals(mainBudget.Increase_Amount__c, itemBudget.Increase_Amount__c);
		System.assertEquals(mainBudget.Reason__c, itemBudget.Reason__c);
		System.assertEquals(INCREASE_BUDGET_ITEM, itemBudget.recordTypeId);
	}

	@isTest
	static void test_createNewItemBudget_insertReqItemBudget() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		Map<Id, Budget__c> newMapById = new Map<Id, Budget__c>();
		Budget__c mainBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				Account_Type__c = '10020 Salaries and Wages',
				recordTypeId = REQUEST_BUDGET
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c insertMainBudget = new Budget__c(
				Id = mainBudget.Id,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Type__c = '10020 Salaries and Wages',
				Account_Subtype__c = '6011005 Overtime',
				Increase_Amount__c = 1000,
				Reason__c = 'test',
				recordTypeId = REQUEST_BUDGET
			);
			newMapById.put(mainBudget.Id, insertMainBudget);
			BudgetService.createNewItemBudget(newMapById, oldMapById);
		}
		List<Budget__c> newItemList = [
			SELECT Id, Budget_ParentId__c, Team_Name__c, Account_Type__c, Account_Subtype__c, Increase_Amount__c, Reason__c, recordTypeId
			FROM Budget__c
			WHERE Budget_ParentId__c = :mainBudget.Id
		];
		//results
		System.assertEquals(1, newItemList.size());
		mainBudget = newMapById.values()[0];
		Budget__c itemBudget = newItemList[0];
		System.assertEquals(mainBudget.Team_Name__c, itemBudget.Team_Name__c);
		System.assertEquals(mainBudget.Account_Type__c, itemBudget.Account_Type__c);
		System.assertEquals(mainBudget.Account_Subtype__c, itemBudget.Account_Subtype__c);
		System.assertEquals(mainBudget.Increase_Amount__c, itemBudget.Increase_Amount__c);
		System.assertEquals(mainBudget.Reason__c, itemBudget.Reason__c);
		System.assertEquals(REQUEST_BUDGET_ITEM, itemBudget.recordTypeId);
	}

	@isTest
	static void test_clearAndStampMainBudgetFieldAfterCreateItemBudget_decItemBudget() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				recordTypeId = TRANSFER_BUDGET,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Reason__c = 'test'
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c insertDecMainBudget = new Budget__c(
				Id = mainBudget.Id,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Decrease_Subtype__c = '6051001 Domestic travelling expense and allowance',
				Total_Decrease__c = 1000,
				Reason__c = 'test',
				recordTypeId = TRANSFER_BUDGET
			);
			newList.add(insertDecMainBudget);
			BudgetService.clearAndStampMainBudgetFieldAfterCreateItemBudget(newList, oldMapById);
		}
		System.debug(mainBudget.Id);
		List<Budget__c> newMainList = [
			SELECT Id, Account_Decrease_Subtype__c, Team_Name__c, Reason__c, Is_code_update__c, Is_Increase__c, Decrease_Branch__c
			FROM Budget__c
			WHERE Id = :mainBudget.Id
		];
		//results
		System.assertEquals(1, newMainList.size());
		mainBudget = newMainList[0];
		System.assertEquals(null, mainBudget.Account_Decrease_Subtype__c);
		System.assertEquals(null, mainBudget.Team_Name__c);
		System.assertEquals(null, mainBudget.Reason__c);
		System.assertEquals(true, mainBudget.Is_code_update__c);
		System.assertEquals(true, mainBudget.Is_Increase__c);
		System.assertEquals('สาขาที่1', mainBudget.Decrease_Branch__c);
	}

	@isTest
	static void test_clearAndStampMainBudgetFieldAfterCreateItemBudget_incItemBudget() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				recordTypeId = TRANSFER_BUDGET,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Increase_Type__c = '10150 Entertainment Expenses',
				Increase_Amount__c = 200,
				Reason__c = 'Hi'
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c insertIncMainBudget = new Budget__c(
				Id = mainBudget.Id,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Increase_Type__c = '10150 Entertainment Expenses',
				Account_Increase_Subtype__c = '6014906 Food and beverages',
				Increase_Amount__c = 1000,
				Total_Increase__c = 200,
				Reason__c = 'test',
				recordTypeId = TRANSFER_BUDGET
			);
			newList.add(insertIncMainBudget);
			BudgetService.clearAndStampMainBudgetFieldAfterCreateItemBudget(newList, oldMapById);
		}
		System.debug(mainBudget.Id);
		List<Budget__c> newMainList = [
			SELECT Id, Team_Name__c, Account_Increase_Type__c, Account_Increase_Subtype__c, Increase_Amount__c, Reason__c, Total_Increase__c, Increase_Branch__c
			FROM Budget__c
			WHERE Id = :mainBudget.Id
		];
		//results
		System.assertEquals(1, newMainList.size());
		mainBudget = newMainList[0];
		System.assertEquals(null, mainBudget.Team_Name__c);
		System.assertEquals(null, mainBudget.Account_Increase_Type__c);
		System.assertEquals(null, mainBudget.Account_Increase_Subtype__c);
		System.assertEquals(0, mainBudget.Increase_Amount__c);
		System.assertEquals(null, mainBudget.Reason__c);
		System.assertEquals(1200, mainBudget.Total_Increase__c);
		System.assertEquals('สาขาที่1', mainBudget.Increase_Branch__c);
	}

	@isTest
	static void test_clearAndStampMainBudgetFieldAfterCreateItemBudget_reqItemBudget() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				recordTypeId = REQUEST_BUDGET,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Type__c = '10020 Salaries and Wages',
				Increase_Amount__c = 200,
				Reason__c = 'Hi'
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c insertIncMainBudget = new Budget__c(
				Id = mainBudget.Id,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Type__c = '10020 Salaries and Wages',
				Account_Subtype__c = '6011005 Overtime',
				Increase_Amount__c = 1000,
				Total_Increase__c = 200,
				Reason__c = 'test',
				recordTypeId = REQUEST_BUDGET
			);
			newList.add(insertIncMainBudget);
			BudgetService.clearAndStampMainBudgetFieldAfterCreateItemBudget(newList, oldMapById);
		}
		System.debug(mainBudget.Id);
		List<Budget__c> newMainList = [
			SELECT Id, Team_Name__c, Account_Subtype__c, Increase_Amount__c, Reason__c, Total_Increase__c, Increase_Branch__c
			FROM Budget__c
			WHERE Id = :mainBudget.Id
		];
		//results
		System.assertEquals(1, newMainList.size());
		mainBudget = newMainList[0];
		System.assertEquals(null, mainBudget.Team_Name__c);
		System.assertEquals(null, mainBudget.Account_Subtype__c);
		System.assertEquals(0, mainBudget.Increase_Amount__c);
		System.assertEquals(null, mainBudget.Reason__c);
		System.assertEquals(1200, mainBudget.Total_Increase__c);
		System.assertEquals('สาขาที่1', mainBudget.Increase_Branch__c);
	}

	@isTest
	static void test_getMainBudgetAdditionalInfoMapById() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		List<Budget__c> mainList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c itemBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				Stage__c = GlobalConstants.BUDGET_OPEN,
				Total_Increase__c = 200,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				recordTypeId = TRANSFER_BUDGET
			);
			insert mainBudget;
			mainList.add(mainBudget);
		}
		Map<Id, Budget__c> mainAdditionalInfoMapById = BudgetService.getMainBudgetAdditionalInfoMapById(new Map<Id, Budget__c>(mainList).keySet());
		System.assertEquals(1, mainAdditionalInfoMapById.size());
		mainBudget = mainAdditionalInfoMapById.get(mainBudget.Id);
		System.assertEquals(GlobalConstants.BUDGET_OPEN, mainBudget.Stage__c);
		System.assertEquals(200, mainBudget.Total_Increase__c);
		System.assertEquals('สาขาที่1', mainBudget.Team_Name__r.Name);
	}

	@isTest
	static void test_addingIncreaseBranchName_firstInput() {
		String ans = '';
		String input = '1';
		ans = BudgetService.addingIncreaseBranchName(ans, input);
		System.assertEquals('1', ans);
	}

	@isTest
	static void test_addingIncreaseBranchName_secondInputSameWithFirst() {
		String ans = '1';
		String input = '2';
		ans = BudgetService.addingIncreaseBranchName(ans, input);
		System.assertEquals('1, 2', ans);
	}

	@isTest
	static void test_addingIncreaseBranchName_secondInputDifferentWithFirst() {
		String ans = '1';
		String input = '1';
		ans = BudgetService.addingIncreaseBranchName(ans, input);
		System.assertEquals('1', ans);
	}

	@isTest
	static void test_addingIncreaseBranchName_thirdInput() {
		String ans = '1, 2';
		String input = '3';
		ans = BudgetService.addingIncreaseBranchName(ans, input);
		System.assertEquals('1, 2, 3', ans);
	}

	@isTest
	static void test_updateItemBudgetInfo_updateDecItem_positiveUpdate() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updateItem;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				recordTypeId = TRANSFER_BUDGET,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Total_Decrease__c = 1000
			);
			insert mainBudget;

			Budget__c itemBudget = new Budget__c(
				Budget_ParentId__c 	= mainBudget.Id,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Decrease_Subtype__c = '6051001 Domestic travelling expense and allowance',
				Total_Decrease__c = 1000,
				Reason__c = 'test',
				recordTypeId = DECREASE_BUDGET_ITEM
			);
			insert itemBudget;
			oldMapById.put(itemBudget.Id, itemBudget);

			updateItem = new Budget__c(
				Id			= itemBudget.Id,
				Budget_ParentId__c 	= mainBudget.Id,
				Account_Decrease_Type__c = '10160 Public Relation Expenses',
				Account_Decrease_Subtype__c = '6709015 Special Occasion Expense',
				Total_Decrease__c = 800,
				recordTypeId = DECREASE_BUDGET_ITEM
			);
			newList.add(updateItem);

			BudgetService.updateItemBudgetInfo(newList, oldMapById);
		}
		mainBudget = [SELECT Id, Total_Decrease__c, Account_Decrease_Type__c FROM Budget__c WHERE Id = :mainBudget.Id LIMIT 1];
		//Result...
		System.assertEquals(800, mainBudget.Total_Decrease__c);
		System.assertEquals('10160 Public Relation Expenses', mainBudget.Account_Decrease_Type__c);
	}

	@isTest
	static void test_updateItemBudgetInfo_updateDecItem_negativeUpdate() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updateItem;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				recordTypeId = TRANSFER_BUDGET,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Total_Decrease__c = 1000
			);
			insert mainBudget;

			Budget__c itemBudget = new Budget__c(
				Budget_ParentId__c 	= mainBudget.Id,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Decrease_Subtype__c = '6051001 Domestic travelling expense and allowance',
				Total_Decrease__c = 1000,
				Reason__c = 'test',
				recordTypeId = DECREASE_BUDGET_ITEM
			);
			insert itemBudget;
			oldMapById.put(itemBudget.Id, itemBudget);

			updateItem = new Budget__c(
				Id			= itemBudget.Id,
				Budget_ParentId__c 	= mainBudget.Id,
				Account_Decrease_Type__c = '10160 Public Relation Expenses',
				Account_Decrease_Subtype__c = '6709015 Special Occasion Expense',
				recordTypeId = DECREASE_BUDGET_ITEM
			);
			newList.add(updateItem);

			itemBudget = new Budget__c(
				Budget_ParentId__c 	= mainBudget.Id,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Increase_Type__c = '10150 Entertainment Expenses',
				Account_Increase_Subtype__c = '6075001 Entertainment',
				Increase_Amount__c = 1000,
				Reason__c = 'test',
				recordTypeId = INCREASE_BUDGET_ITEM
			);
			insert itemBudget;

			try {
				BudgetService.updateItemBudgetInfo(newList, oldMapById);
			} catch (Exception e) {
				System.assert(e.getMessage().contains(Label.Budget_Not_Allow_To_Edit_Decrease_Budget));
			}
				
		}
	}

	@isTest
	static void test_updateItemBudgetInfo_updateIncItem() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updateItem;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameZM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				recordTypeId = TRANSFER_BUDGET,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Total_Increase__c = 2000
			);
			insert mainBudget;

			Budget__c itemBudget = new Budget__c(
				Budget_ParentId__c = mainBudget.Id,
				Is_Select_Increase__c = true,
				Is_Increase__c = true,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Increase_Type__c = '10150 Entertainment Expenses',
				Account_Increase_Subtype__c = '6014906 Food and beverages',
				Increase_Amount__c = 1000,
				Reason__c = 'test',
				recordTypeId = INCREASE_BUDGET_ITEM
			);
			insert itemBudget;
			oldMapById.put(itemBudget.Id, itemBudget);

			updateItem = new Budget__c(
				Id			= itemBudget.Id,
				Is_Select_Increase__c = true,
				Is_Increase__c = true,
				Team_Name__c = teamStructureMapByName.get('สาขาที่2').Id,
				Budget_ParentId__c 	= mainBudget.Id,
				Increase_Amount__c = 800,
				recordTypeId = INCREASE_BUDGET_ITEM
			);
			newList.add(updateItem);

			BudgetService.updateItemBudgetInfo(newList, oldMapById);
		}
		mainBudget = [SELECT Id, Total_Increase__c, Increase_Branch__c FROM Budget__c WHERE Id = :mainBudget.Id LIMIT 1];
		//Result...
		System.assertEquals(1800, mainBudget.Total_Increase__c);
		System.assertEquals('สาขาที่2', mainBudget.Increase_Branch__c);
	}

	@isTest
	static void test_updateItemBudgetInfo_updateReqItem() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updateItem;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameZM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				recordTypeId = REQUEST_BUDGET,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Total_Increase__c = 2000
			);
			insert mainBudget;

			Budget__c itemBudget = new Budget__c(
				Budget_ParentId__c = mainBudget.Id,
				Is_Select_Increase__c = true,
				Is_Increase__c = true,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Increase_Type__c = '10150 Entertainment Expenses',
				Account_Increase_Subtype__c = '6014906 Food and beverages',
				Increase_Amount__c = 1000,
				Reason__c = 'test',
				recordTypeId = REQUEST_BUDGET_ITEM
			);
			insert itemBudget;
			oldMapById.put(itemBudget.Id, itemBudget);

			updateItem = new Budget__c(
				Id			= itemBudget.Id,
				Is_Select_Increase__c = true,
				Is_Increase__c = true,
				Team_Name__c = teamStructureMapByName.get('สาขาที่2').Id,
				Budget_ParentId__c 	= mainBudget.Id,
				Increase_Amount__c = 800,
				recordTypeId = REQUEST_BUDGET_ITEM
			);
			newList.add(updateItem);

			BudgetService.updateItemBudgetInfo(newList, oldMapById);
		}
		mainBudget = [SELECT Id, Total_Increase__c, Increase_Branch__c FROM Budget__c WHERE Id = :mainBudget.Id LIMIT 1];
		//Result...
		System.assertEquals(1800, mainBudget.Total_Increase__c);
		System.assertEquals('สาขาที่2', mainBudget.Increase_Branch__c);
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_openToWaiting_TransferBudget() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updateItem;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = TRANSFER_BUDGET,
				Stage__c = GlobalConstants.BUDGET_OPEN
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c updatedBudget = mainBudget.clone(true, false, true, true);
			updatedBudget.Stage__c = GlobalConstants.BUDGET_WAITING_FOR_APPROVE;
			newList.add(updatedBudget);
			BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
		}

		Budget__c result = newList[0];
		//result
		System.assertEquals(TRANSFER_BUDGET_APPROVE, result.recordTypeId);
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_openToWaiting_notHaveManager() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updateItem;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBudgetAdmin LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = TRANSFER_BUDGET,
				Stage__c = GlobalConstants.BUDGET_OPEN
			);
			TriggerHandler.bypass('BudgetTriggerHandler');
			insert mainBudget;
			TriggerHandler.clearBypass('BudgetTriggerHandler');
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c updatedBudget = mainBudget.clone(true, false, true, true);
			updatedBudget.Stage__c = GlobalConstants.BUDGET_WAITING_FOR_APPROVE;
			newList.add(updatedBudget);
			test.startTest();
			try {
				BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
			}catch (Exception e) {
				System.assertEquals(Label.Not_allow_to_submit_for_approve, e.getMessage());
			}
			test.stopTest();
		}
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_openToWaiting_incNotSameAsDec() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updateItem;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = TRANSFER_BUDGET,
				Stage__c = GlobalConstants.BUDGET_OPEN
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c updatedBudget = mainBudget.clone(true, false, true, true);
			updatedBudget.Stage__c = GlobalConstants.BUDGET_WAITING_FOR_APPROVE;
			updatedBudget.Total_Increase__c = 1000;
			updatedBudget.Total_Increase__c = 800;
			newList.add(updatedBudget);
			test.startTest();
			try {
				BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
			}catch (Exception e) {
				System.assertEquals(Label.Not_Allow_To_Submit_Transfer_Budget, e.getMessage());
			}
			test.stopTest();
		}
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_openToWaiting_NHinsertBudget() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c itemBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameNH1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = TRANSFER_BUDGET,
				Stage__c = GlobalConstants.BUDGET_OPEN
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c updatedBudget = mainBudget.clone(true, false, true, true);
			updatedBudget.Stage__c = GlobalConstants.BUDGET_WAITING_FOR_APPROVE;
			updatedBudget.Total_Increase__c = 1000;
			updatedBudget.Total_Decrease__c = 1000;
			newList.add(updatedBudget);
			itemBudget = new Budget__c(
				Budget_ParentId__c = mainBudget.Id,
				Is_Select_Increase__c = true,
				Is_Increase__c = true,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Increase_Type__c = '10150 Entertainment Expenses',
				Account_Increase_Subtype__c = '6014906 Food and beverages',
				Increase_Amount__c = 500,
				Reason__c = 'test',
				recordTypeId = INCREASE_BUDGET_ITEM
			);
			insert itemBudget;
			itemBudget.Id = null;
			itemBudget.Team_Name__c = teamStructureMapByName.get('สาขาที่2').Id;
			insert itemBudget;
			test.startTest();
			BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
			test.stopTest();
		}
		//Result
		Budget__c result = newList[0];
		System.assertEquals(TRANSFER_BUDGET_READ_ONLY, result.recordTypeId);
		System.assertEquals(GlobalConstants.BUDGET_APPROVED, result.Stage__c);
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_openToWaiting_requestBudget() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updateItem;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = REQUEST_BUDGET,
				Stage__c = GlobalConstants.BUDGET_OPEN
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c updatedBudget = mainBudget.clone(true, false, true, true);
			updatedBudget.Stage__c = GlobalConstants.BUDGET_WAITING_FOR_APPROVE;
			newList.add(updatedBudget);
			BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
		}

		Budget__c result = newList[0];
		//result
		System.assertEquals(REQUEST_BUDGET_APPROVE, result.recordTypeId);
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_waitingToOpen() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updateItem;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = TRANSFER_BUDGET_READ_ONLY,
				Stage__c = GlobalConstants.BUDGET_WAITING_FOR_APPROVE
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c updatedBudget = mainBudget.clone(true, false, true, true);
			updatedBudget.Stage__c = GlobalConstants.BUDGET_OPEN;
			newList.add(updatedBudget);
			BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
		}

		Budget__c result = newList[0];
		//result
		System.assertEquals(TRANSFER_BUDGET, result.recordTypeId);
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_waitingToApprove() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c itemBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameZM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = TRANSFER_BUDGET_APPROVE,
				Stage__c = GlobalConstants.BUDGET_OPEN,
				Total_Increase__c = 1000,
				Total_Decrease__c = 1000
			);
			insert mainBudget;
			itemBudget = new Budget__c(
				Budget_ParentId__c = mainBudget.Id,
				Is_Select_Increase__c = true,
				Is_Increase__c = true,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Increase_Type__c = '10150 Entertainment Expenses',
				Account_Increase_Subtype__c = '6014906 Food and beverages',
				Increase_Amount__c = 500,
				Reason__c = 'test',
				recordTypeId = INCREASE_BUDGET_ITEM
			);
			insert itemBudget;
			itemBudget.Id = null;
			itemBudget.Team_Name__c = teamStructureMapByName.get('สาขาที่2').Id;
			insert itemBudget;
			mainBudget.Stage__c = GlobalConstants.BUDGET_WAITING_FOR_APPROVE;
			update mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c updatedBudget = mainBudget.clone(true, false, true, true);
			updatedBudget.Stage__c = GlobalConstants.BUDGET_APPROVED;
			newList.add(updatedBudget);
			test.startTest();
			BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
			test.stopTest();
		}

		Budget__c result = newList[0];
		//result
		System.assertEquals(TRANSFER_BUDGET_READ_ONLY, result.recordTypeId);
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_waitingToReject() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updateItem;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = TRANSFER_BUDGET_APPROVE,
				Stage__c = GlobalConstants.BUDGET_WAITING_FOR_APPROVE
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c updatedBudget = mainBudget.clone(true, false, true, true);
			updatedBudget.Stage__c = GlobalConstants.BUDGET_REJECTED;
			newList.add(updatedBudget);
			BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
		}

		Budget__c result = newList[0];
		//result
		System.assertEquals(TRANSFER_BUDGET_READ_ONLY, result.recordTypeId);
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_collectToApprove() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updateItem;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = TRANSFER_BUDGET_READ_ONLY,
				Stage__c = GlobalConstants.BUDGET_COLLECT_DOCUMENT
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			Budget__c updatedBudget = mainBudget.clone(true, false, true, true);
			updatedBudget.Stage__c = GlobalConstants.BUDGET_APPROVED;
			newList.add(updatedBudget);
			BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
		}
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_acceptBudget() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updatedBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = TRANSFER_BUDGET,
				Stage__c = GlobalConstants.BUDGET_APPROVED
			);
			insert mainBudget;
			mainBudget.recordTypeId = TRANSFER_BUDGET_READ_ONLY;
			oldMapById.put(mainBudget.Id, mainBudget);
			updatedBudget = mainBudget.clone(true, false, true, true);
		}
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBudgetAdmin LIMIT 1][0]) {
			updatedBudget.Approve_Results__c = GlobalConstants.BUDGET_APPROVE_PROCESSED;
			newList.add(updatedBudget);
			BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
		}
		Budget__c result = newList[0];
		//result
		System.assertEquals(null, result.Approve_Results__c);
		System.assertEquals(GlobalConstants.BUDGET_COMPLETE, result.Stage__c);
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_refuseBudget() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updatedBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = TRANSFER_BUDGET,
				Stage__c = GlobalConstants.BUDGET_APPROVED
			);
			insert mainBudget;
			mainBudget.recordTypeId = TRANSFER_BUDGET_READ_ONLY;
			oldMapById.put(mainBudget.Id, mainBudget);
			updatedBudget = mainBudget.clone(true, false, true, true);
		}
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBudgetAdmin LIMIT 1][0]) {
			updatedBudget.Approve_Results__c = GlobalConstants.BUDGET_APPROVE_REFUSE;
			newList.add(updatedBudget);
			BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
		}
		Budget__c result = newList[0];
		//result
		System.assertEquals(null, result.Approve_Results__c);
		System.assertEquals(GlobalConstants.BUDGET_CONTACT_BUDGET_ADMIN, result.Stage__c);
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_requireDocument() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updatedBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = TRANSFER_BUDGET,
				Stage__c = GlobalConstants.BUDGET_APPROVED
			);
			insert mainBudget;
			mainBudget.recordTypeId = TRANSFER_BUDGET_READ_ONLY;
			oldMapById.put(mainBudget.Id, mainBudget);
			updatedBudget = mainBudget.clone(true, false, true, true);
		}
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBudgetAdmin LIMIT 1][0]) {
			updatedBudget.Approve_Results__c = GlobalConstants.BUDGET_APPROVE_REQUIRE_DOCUMENT;
			newList.add(updatedBudget);
			BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
		}
		Budget__c result = newList[0];
		//result
		System.assertEquals(null, result.Approve_Results__c);
		System.assertEquals(GlobalConstants.BUDGET_COLLECT_DOCUMENT, result.Stage__c);
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_vetoWaitingToApprove() {
		Id VETO_IQM = GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.VETO_IQM_DEVNAME);

		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updatedBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = VETO_IQM,
				Stage__c = GlobalConstants.BUDGET_WAITING_FOR_APPROVE
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			updatedBudget = mainBudget.clone(true, false, true, true);
		}
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBudgetAdmin LIMIT 1][0]) {
			updatedBudget.Stage__c = GlobalConstants.BUDGET_APPROVED;
			newList.add(updatedBudget);
			BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
		}
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_vetoWaitingToReject() {
		Id VETO_IQM = GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.VETO_IQM_DEVNAME);

		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updatedBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = VETO_IQM,
				Stage__c = GlobalConstants.BUDGET_WAITING_FOR_APPROVE
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			updatedBudget = mainBudget.clone(true, false, true, true);
		}
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBudgetAdmin LIMIT 1][0]) {
			updatedBudget.Stage__c = GlobalConstants.BUDGET_REJECTED;
			newList.add(updatedBudget);
			BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
		}
	}

	@isTest
	static void test_checkBudgetSubmissionAndStampRecordType_vetoWaitingToIncorrect() {
		Id VETO_IQM = GlobalUtility.getRecordTypeId('Budget__c', GlobalConstants.VETO_IQM_DEVNAME);

		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		Map<Id, Budget__c> oldMapById = new Map<Id, Budget__c>();
		List<Budget__c> newList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c updatedBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBM1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				recordTypeId = VETO_IQM,
				Stage__c = GlobalConstants.BUDGET_WAITING_FOR_APPROVE
			);
			insert mainBudget;
			oldMapById.put(mainBudget.Id, mainBudget);
			updatedBudget = mainBudget.clone(true, false, true, true);
		}
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameBudgetAdmin LIMIT 1][0]) {
			updatedBudget.Stage__c = GlobalConstants.BUDGET_INCORRECT;
			newList.add(updatedBudget);
			BudgetService.checkBudgetSubmissionAndStampRecordType(newList, oldMapById);
		}
	}

	@isTest
	static void test_deleteBudget() {
		Map<String, Team_Structure__c> teamStructureMapByName = getTeamStructureMapByName();
		List<Budget__c> deletedList = new List<Budget__c>();
		Budget__c mainBudget;
		Budget__c extraBudget;
		Budget__c itemBudget;
		System.runAs([SELECT Id FROM User WHERE FirstName = :UserFirstNameNH1 LIMIT 1][0]) {
			mainBudget = new Budget__c(
				OwnerId = userInfo.getUserId(),
				Stage__c = GlobalConstants.BUDGET_OPEN,
				Total_Increase__c = 1500,
				recordTypeId = TRANSFER_BUDGET
			);
			insert mainBudget;
			itemBudget = new Budget__c(
				Budget_ParentId__c = mainBudget.Id,
				Is_Select_Increase__c = true,
				Is_Increase__c = true,
				Team_Name__c = teamStructureMapByName.get('สาขาที่1').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Increase_Type__c = '10150 Entertainment Expenses',
				Account_Increase_Subtype__c = '6014906 Food and beverages',
				Increase_Amount__c = 500,
				Reason__c = 'test',
				OwnerId = userInfo.getUserId(),
				recordTypeId = INCREASE_BUDGET_ITEM
			);
			insert itemBudget;
			extraBudget = itemBudget;
			itemBudget = new Budget__c(
				Budget_ParentId__c = mainBudget.Id,
				Is_Select_Increase__c = true,
				Is_Increase__c = true,
				Team_Name__c = teamStructureMapByName.get('สาขาที่2').Id,
				Account_Decrease_Type__c = '10130 Transportation and Communication Expense',
				Account_Increase_Type__c = '10150 Entertainment Expenses',
				Account_Increase_Subtype__c = '6014906 Food and beverages',
				Increase_Amount__c = 1000,
				Reason__c = 'test',
				OwnerId = userInfo.getUserId(),
				recordTypeId = INCREASE_BUDGET_ITEM
			);
			insert itemBudget;
			deletedList.add(itemBudget);
			BudgetService.deleteBudget(deletedList);
		}
		//result
		Budget__c result = [SELECT Id, Total_Increase__c, Increase_Branch__c FROM Budget__c WHERE Id = :mainBudget.Id LIMIT 1][0];
		System.debug(result == null);
		System.assertEquals(500, result.Total_Increase__c);
		System.assertEquals('สาขาที่1', result.Increase_Branch__c);

		delete extraBudget;
	}
}