@isTest
private class FlagInactiveUserTest {
	private static String whereCondition = 'IsActive = True ';

	@isTest static void Given_UserActiveAndUserStructureSameEmployeeId_When_RunBatch_Then_TempInactiveFalse() {
		Boolean result = false;
		String empId = '1';
		Profile rbsRmProfile = UserManagementMockupTest.getMapProfileByName(GlobalConstants.RBS_RM_ABM);
		User user = UserManagementMockupTest.createNewUser(empId, 'first', 'last', true, null);
		user.ProfileId = rbsRmProfile.Id;
		insert user;

		User_Structure__c userStructure = new User_Structure__c();
		userStructure.Name = empId;
		insert userStructure;

		Test.startTest();
			whereCondition = whereCondition +' AND Id IN (\'' + user.Id +'\') ';
			Database.executeBatch(new FlagInactiveUser_Batch(whereCondition,false));
		Test.stopTest();

		User result_user = [SELECT Id,TempInactive__c FROM User WHERE Employee_Id__c = :empId];
		System.assertEquals(result,result_user.TempInactive__c);
	}

	@isTest static void Given_UserActiveAndUserStructureDiffEmployeeId_When_RunBatch_Then_TempInactiveTrue() {
		Boolean result = true;
		String empId = '1';

		Profile rbsRmProfile = UserManagementMockupTest.getMapProfileByName(GlobalConstants.RBS_RM_ABM);
		User user = UserManagementMockupTest.createNewUser(empId, 'first', 'last', true, null);
		user.TempInactive__c = false;
		user.Employee_Id__c = empId;
		user.ProfileId = rbsRmProfile.Id;
		insert user;

		User_Structure__c userStructure = new User_Structure__c();
		userStructure.Name = '2';
		insert userStructure;

		Test.startTest();
			whereCondition = whereCondition +' AND Id IN (\'' + user.Id +'\') ';
			Database.executeBatch(new FlagInactiveUser_Batch(whereCondition,false));
		Test.stopTest();

		User result_user = [SELECT Id,TempInactive__c FROM User WHERE Employee_Id__c = :empId];

		System.assertEquals(result,result_user.TempInactive__c);
	}

	@isTest static void Given_UserActiveAndNoUserStructure_When_RunBatch_Then_TempInactiveTrue() {
		Boolean result = true;
		String empId = '1';

		Profile rbsRmProfile = UserManagementMockupTest.getMapProfileByName(GlobalConstants.RBS_RM_ABM);
		User user = UserManagementMockupTest.createNewUser(empId, 'first', 'last', true, null);
		user.TempInactive__c = false;
		user.Employee_Id__c = empId;
		user.ProfileId = rbsRmProfile.Id;
		insert user;

		Test.startTest();
			whereCondition = whereCondition +' AND Id IN (\'' + user.Id +'\') ';
			Database.executeBatch(new FlagInactiveUser_Batch(whereCondition,false));
		Test.stopTest();

		User result_user = [SELECT Id,TempInactive__c FROM User WHERE Employee_Id__c = :empId];

		System.assertEquals(result,result_user.TempInactive__c);
	}
	
	@isTest static void Given_UserInactiveAndUserStructureSameEmployeeId_When_RunBatch_Then_DoNothing() {
		Boolean result_1 = true;
		String empId_1 = '1';
		String empId_2 = '2';

		Profile rbsRmProfile = UserManagementMockupTest.getMapProfileByName(GlobalConstants.RBS_RM_ABM);
		User user_1 = UserManagementMockupTest.createNewUser(empId_1, 'first1', 'last1', false, null);
		user_1.TempInactive__c = result_1;
		user_1.Employee_Id__c = empId_1;
		user_1.ProfileId = rbsRmProfile.Id;

		User_Structure__c userStructure_1 = new User_Structure__c();
		userStructure_1.Name = empId_1;

		Boolean result_2 = false;
		User user_2 = UserManagementMockupTest.createNewUser(empId_2, 'first2', 'last2', false, null);
		user_2.TempInactive__c = result_2;
		user_2.Employee_Id__c = empId_2;
		user_2.ProfileId = rbsRmProfile.Id;

		User_Structure__c userStructure_2 = new User_Structure__c();
		userStructure_2.Name = empId_2;

		TriggerHandler.bypass('UserTriggerHandler');
		List<User> listUser = new List<User>{user_1,user_2};
		List<User_Structure__c> listUserStructure = new List<User_Structure__c>{userStructure_1,userStructure_2};
		insert listUser;
		insert listUserStructure;

		Test.startTest();
			whereCondition = whereCondition +' AND Id IN (\'' + user_1.Id +'\',\'' + user_2.Id +'\') ';
			Database.executeBatch(new FlagInactiveUser_Batch(whereCondition,false));
		Test.stopTest();

		User result_user_1 = [SELECT Id,TempInactive__c FROM User WHERE Employee_Id__c = :empId_1];
		User result_user_2 = [SELECT Id,TempInactive__c FROM User WHERE Employee_Id__c = :empId_2];

		System.assertEquals(result_1,result_user_1.TempInactive__c);
		System.assertEquals(result_2,result_user_2.TempInactive__c);
	}
	
	@isTest static void Given_UserInactiveAndUserStructureDiffEmployeeId_When_RunBatch_Then_DoNothing() {
		Boolean result_1 = true;
		String empId_1 = '1';
		String empId_2 = '2';

		Profile rbsRmProfile = UserManagementMockupTest.getMapProfileByName(GlobalConstants.RBS_RM_ABM);
		User user_1 = UserManagementMockupTest.createNewUser(empId_1, 'first1', 'last1', false, null);
		user_1.TempInactive__c = result_1;
		user_1.Employee_Id__c = empId_1;
		user_1.ProfileId = rbsRmProfile.Id;

		User_Structure__c userStructure_1 = new User_Structure__c();
		userStructure_1.Name = '9';

		Boolean result_2 = false;
		User user_2 = UserManagementMockupTest.createNewUser(empId_2, 'first2', 'last2', false, null);
		user_2.TempInactive__c = result_2;
		user_2.Employee_Id__c = empId_2;
		user_2.ProfileId = rbsRmProfile.Id;

		User_Structure__c userStructure_2 = new User_Structure__c();
		userStructure_2.Name = '8';

		TriggerHandler.bypass('UserTriggerHandler');
		List<User> listUser = new List<User>{user_1,user_2};
		List<User_Structure__c> listUserStructure = new List<User_Structure__c>{userStructure_1,userStructure_2};
		insert listUser;
		insert listUserStructure;

		Test.startTest();
			whereCondition = whereCondition +' AND Id IN (\'' + user_1.Id +'\',\'' + user_2.Id +'\') ';
			Database.executeBatch(new FlagInactiveUser_Batch(whereCondition,false));
		Test.stopTest();

		User result_user_1 = [SELECT Id,TempInactive__c FROM User WHERE Employee_Id__c = :empId_1];
		User result_user_2 = [SELECT Id,TempInactive__c FROM User WHERE Employee_Id__c = :empId_2];

		System.assertEquals(result_1,result_user_1.TempInactive__c);
		System.assertEquals(result_2,result_user_2.TempInactive__c);
	}

	@isTest static void Given_UserInactiveAndNoUserStructure_When_RunBatch_Then_DoNothing() {
		Boolean result_1 = true;
		String empId_1 = '1';
		String empId_2 = '2';

		Profile rbsRmProfile = UserManagementMockupTest.getMapProfileByName(GlobalConstants.RBS_RM_ABM);
		User user_1 = UserManagementMockupTest.createNewUser(empId_1, 'first1', 'last', false, null);
		user_1.TempInactive__c = result_1;
		user_1.Employee_Id__c = empId_1;
		user_1.ProfileId = rbsRmProfile.Id;

		Boolean result_2 = false;
		User user_2 = UserManagementMockupTest.createNewUser(empId_2, 'first2', 'last2', false, null);
		user_2.TempInactive__c = result_2;
		user_2.Employee_Id__c = empId_2;
		user_2.ProfileId = rbsRmProfile.Id;

		TriggerHandler.bypass('UserTriggerHandler');
		List<User> listUser = new List<User>{user_1,user_2};
		insert listUser;

		Test.startTest();
			whereCondition = whereCondition +' AND Id IN (\'' + user_1.Id +'\',\'' + user_2.Id +'\') ';
			Database.executeBatch(new FlagInactiveUser_Batch(whereCondition,false));
		Test.stopTest();

		User result_user_1 = [SELECT Id,TempInactive__c FROM User WHERE Employee_Id__c = :empId_1];
		User result_user_2 = [SELECT Id,TempInactive__c FROM User WHERE Employee_Id__c = :empId_2];

		System.assertEquals(result_1,result_user_1.TempInactive__c);
		System.assertEquals(result_2,result_user_2.TempInactive__c);
	}

}