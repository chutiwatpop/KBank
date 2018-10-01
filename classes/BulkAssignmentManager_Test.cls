@isTest
private class BulkAssignmentManager_Test
{
	public static String USER_SMERM_EMPID = '9999999990';
	public static String USER_SMETM_EMPID = '99999999991' ;
	public static String USER_SMERM_TEMP_EMPID = '9999999992';
	public static String TEAM_TM_RC = '2222';
	public static String ACCOUNTOWNER_RM = 'ACCOUNTOWNER_RM';
	public static String ACCOUNTOWNER_RM_CIS = '000000001';

	public static String USER_AFRM_EMPID = '99999999980';
	public static String USER_AFTM_EMPID = '99999999981';
	public static String USER_DUAL_AFRM_EMPID = '99999999982';
	public static String AF_TEAM_TM_RC = '2223';
	public static String ACCOUNTOWNER_AFRM = 'ACCOUNTOWNER_AFRM';
	public static String ACCOUNTOWNER_AFRM_CIS = '000000002';

	public static String USER_CBSRM_EMPID = '99999999970';
	public static String USER_CBSTM_EMPID = '99999999971';
	public static String CBS_TEAM_TM_RC = '2224';
	public static String ACCOUNTOWNER_CBSRM_CIS = '000000003';
	@TestSetup
	public static void setupInfo(){
		Mockup_test mt = new Mockup_Test().setUpTestAdmin(); 
		Test.startTest();
			setUpUserandTeam();
    	Test.stopTest();
    	setUpAccounts();
    	
    }

    private static void setUpUserandTeam(){
		Id managerId = null;

		List<User> users = new List<User>();
		List<Team_Structure__c> teams = new List<Team_Structure__c>();
		/// TM
    	Profile profile = Mockup_Test.getMapProfileByName(GlobalConstants.SME_TM);
    	User userSMETm = Mockup_Test.newUser(USER_SMETM_EMPID,USER_SMETM_EMPID, USER_SMETM_EMPID,true, profile.id, null, managerId);
    	userSMETm.RC_Code__c = TEAM_TM_RC;
    	users.add(userSMETm);

    	profile = Mockup_Test.getMapProfileByName(GlobalConstants.CBS_TM);
    	User userCBSTm = Mockup_Test.newUser(USER_CBSTM_EMPID,USER_CBSTM_EMPID, USER_CBSTM_EMPID,true, profile.id, null, managerId);
    	userCBSTm.RC_Code__c = CBS_TEAM_TM_RC;
    	users.add(userCBSTm);

    	profile = Mockup_Test.getMapProfileByName(GlobalConstants.AF_TM);
    	User userAFTm = Mockup_Test.newUser(USER_AFTM_EMPID,USER_AFTM_EMPID, USER_AFTM_EMPID,true, profile.id, null, managerId);
   		userAFTm.RC_Code__c = AF_TEAM_TM_RC;
   		users.add(userAFTm);
   		// END TM
   		// RM
   		profile = Mockup_Test.getMapProfileByName(GlobalConstants.SME_RM);
    	managerId = userSMETm.id;
		User userSMERm = Mockup_Test.newUser(USER_SMERM_EMPID,USER_SMERM_EMPID, USER_SMERM_EMPID,true, profile.id, null, managerId);
    	userSMERm.RC_Code__c = TEAM_TM_RC;
    	users.add(userSMERm);

    	managerId = userSMETm.id;
		User userSMERmTemp = Mockup_Test.newUser(USER_SMERM_TEMP_EMPID,USER_SMERM_TEMP_EMPID, USER_SMERM_TEMP_EMPID,true, profile.id, null, managerId);
    	userSMERmTemp.RC_Code__c = TEAM_TM_RC;
    	users.add(userSMERmTemp);

    	profile = Mockup_Test.getMapProfileByName(GlobalConstants.CBS_RM);
    	managerId = userCBSTm.id;
		User userCBSRm = Mockup_Test.newUser(USER_CBSRM_EMPID,USER_CBSRM_EMPID, USER_CBSRM_EMPID,true, profile.id, null, managerId);
    	userCBSRm.RC_Code__c = CBS_TEAM_TM_RC;
    	users.add(userCBSRm);

    	managerId = userAFTm.id;
    	profile = Mockup_Test.getMapProfileByName(GlobalConstants.AF_RM);
   		User userAFRm = Mockup_Test.newUser(USER_AFRM_EMPID,USER_AFRM_EMPID, USER_AFRM_EMPID,true, profile.id, null, managerId);
   		userAFRm.RC_Code__c = AF_TEAM_TM_RC;
   		users.add(userAFRm);

   		User userAFRmDual = Mockup_Test.newUser(USER_DUAL_AFRM_EMPID,USER_DUAL_AFRM_EMPID, USER_DUAL_AFRM_EMPID,true, profile.id, null, managerId);
   		userAFRmDual.RC_Code__c = AF_TEAM_TM_RC;
   		users.add(userAFRmDual);
   		// END RM

   		insert users;

   		Team_Structure__c newTeamSMETM = Mockup_Test.newTeamStructure(TEAM_TM_RC,userSMETm.id);
   		Team_Structure__c newTeamCBSTM = Mockup_Test.newTeamStructure(CBS_TEAM_TM_RC,userCBSTm.id);
   		Team_Structure__c newTeamAFTM = Mockup_Test.newTeamStructure(AF_TEAM_TM_RC,userAFTm.id);
    	teams.add(newTeamSMETM);
    	teams.add(newTeamCBSTM);
    	teams.add(newTeamAFTM);
    	insert teams;
    }

    private static void setUpAccounts(){
    	User userSMERM = [SELECT Id From User WHERE Employee_id__c = :USER_SMERM_EMPID Limit 1];
    	User userSMERMTemp = [SELECT Id,(SELECT id From User_Extension__r Limit 1) From User WHERE Employee_id__c = :USER_SMERM_TEMP_EMPID Limit 1];
    	User userCBSRM = [SELECT Id From User WHERE Employee_id__c = :USER_CBSRM_EMPID Limit 1];
    	User userAFRM = [SELECT Id From User WHERE Employee_id__c = :USER_AFRM_EMPID Limit 1];
    	User userAFRMDual = [SELECT Id,(SELECT id From User_Extension__r Limit 1) From User WHERE Employee_id__c = :USER_DUAL_AFRM_EMPID Limit 1];

    	List<Account> accounts = new List<Account>();
    	Id recordTypeId = GlobalUtility.getRecordTypeId('Account', GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME);
    	
    	Account accountOwnerSME = Mockup_Test.newAccountWithSegment(ACCOUNTOWNER_RM,GlobalConstants.PORT,null,recordTypeId,GlobalConstants.SEGMENT_SE); 
    	accountOwnerSME.OwnerId = userSMERM.id;
    	accountOwnerSME.CIS__c = ACCOUNTOWNER_RM_CIS;
    	accountOwnerSME.Dual_RM_Name__c = userAFRMDual.id;
    	accountOwnerSME.SME_Temporary_Customer__c = userSMERMTemp.User_Extension__r[0].id;
    	accountOwnerSME.AF_Temporary_Customer__c = userAFRMDual.User_Extension__r[0].id;
    	accounts.add(accountOwnerSME);

    	Account accountOwnerCBS = Mockup_Test.newAccountWithSegment(ACCOUNTOWNER_CBSRM_CIS,GlobalConstants.PORT,null,recordTypeId,GlobalConstants.SEGMENT_CB); 
    	accountOwnerCBS.OwnerId = userCBSRM.id;
    	accountOwnerCBS.CIS__c = ACCOUNTOWNER_CBSRM_CIS;
    	accounts.add(accountOwnerCBS);

    	Account accountOwnerAF = Mockup_Test.newAccountWithSegment(ACCOUNTOWNER_RM,GlobalConstants.PORT,null,recordTypeId,GlobalConstants.SEGMENT_AF); 
    	accountOwnerAF.OwnerId = userAFRM.id;
    	accountOwnerAF.CIS__c = ACCOUNTOWNER_AFRM_CIS;
    	accounts.add(accountOwnerAF);
    	insert accounts;
    }

    private static Map<Id,User_MaskModel> mockUserMaskModel(List<User> userList,List<User> oldUsers) {
		Map<Id, User_MaskModel> userMaskMapByUserId = new Map<Id, User_MaskModel>();
		Integer count = 0;
		for(User eachUser : userList) {
			User_MaskModel userMask = new User_MaskModel();
	        userMask.userId = eachUser.Id;
	        userMask.profileName = eachUser.Profile.Name;
	        userMask.setNewUser(eachUser);
	        userMask.setOldUser(oldUsers.get(count));
	        userMaskMapByUserId.put(eachUser.Id, userMask);
	        count++;
		}
		return userMaskMapByUserId;
	}

	@isTest
	public static void rmSMEInActiveAccountOwnerOneLevelUp(){
		// Given
		User userRM = [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :USER_SMERM_EMPID Limit 1];
		User newuserRM = userRM.clone(true, true, false, false);
		newuserRM.isActive = false;
		Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{newuserRM},new List<User>{userRM});

		// When
		Test.startTest();
			Account_Service.isHRIS = true;
			BulkAssignmentManager bulkManager = new BulkAssignmentManager(userMaskMapByUserId);
			bulkManager.createBulkAssignment();
			bulkManager.insertBulkAssignmentQueueAndBulkAssignment();
			bulkManager.setAccountInfoFromBulkInfo();
			bulkManager.updateAccount();
		Test.stopTest();
		// Then
		Account accountTarget = [SELECT Id,OwnerId From Account WHERE CIS__c = :ACCOUNTOWNER_RM_CIS Limit 1];
		User userTM = [SELECT Id From User WHERE Employee_id__c = :USER_SMETM_EMPID Limit 1];
		System.assertEquals(userTM.id,accountTarget.OwnerId);
	}

	@isTest static void rmSMETempInActiveAccountTempOneLevelUp(){
		// Given
		User userRMTemp = [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :USER_SMERM_TEMP_EMPID Limit 1];
		User newuserRMTemp = userRMTemp.clone(true, true, false, false);
		newuserRMTemp.isActive = false;
		Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{newuserRMTemp},new List<User>{userRMTemp});

		// When
		Test.startTest();
			Account_Service.isHRIS = true;
			BulkAssignmentManager bulkManager = new BulkAssignmentManager(userMaskMapByUserId);
			bulkManager.createBulkAssignment();
			bulkManager.insertBulkAssignmentQueueAndBulkAssignment();
			bulkManager.setAccountInfoFromBulkInfo();
			bulkManager.updateAccount();
		Test.stopTest();
		// Then
		Account accountTarget = [SELECT Id,OwnerId,SME_Temporary_Customer__c From Account WHERE CIS__c = :ACCOUNTOWNER_RM_CIS Limit 1];
		User userTM = [SELECT Id,(SELECT Id From User_Extension__r Limit 1) From User WHERE Employee_id__c = :USER_SMETM_EMPID Limit 1];
		System.assertEquals(userTM.User_Extension__r[0].id,accountTarget.SME_Temporary_Customer__c);
	}

	//@isTest
	//public static void rmCBSChangeTeamAccountOneLevelUp(){
	//	//Given
	//	User userCBSRM = [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :USER_CBSRM_EMPID Limit 1];
	//	User newuserRM = userCBSRM.clone(true, true, false, false);
	//	newuserRM.RC_Code__c = '0000';
	//	Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{newuserRM},new List<User>{userCBSRM});
	//	//When
	//	Test.startTest();
	//		BulkAssignmentManager bulkManager = new BulkAssignmentManager(userMaskMapByUserId);
	//		bulkManager.createBulkAssignment();
	//		bulkManager.insertBulkAssignmentQueueAndBulkAssignment();
	//		bulkManager.setAccountInfoFromBulkInfo();
	//		bulkManager.updateAccount();
	//		bulkManager.completeJobUpdateBulkQueueAndBulkAssignmentStatus();
	//	Test.stopTest();
	//	//Then
	//	User userCBSTM = [SELECT Id From User WHERE Employee_id__c = :USER_CBSTM_EMPID Limit 1];
	//	Account account = [SELECT Id,OwnerId From Account where CIS__c = :ACCOUNTOWNER_CBSRM_CIS Limit 1];
	//	System.assertEquals(userCBSTM.id,account.OwnerId);
	//}

	@isTest static void rmAFInActiveAccountOwnerOneLevelUp(){
		// Given
		User userRM = [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :USER_AFRM_EMPID Limit 1];
		User newuserRM = userRM.clone(true, true, false, false);
		newuserRM.isActive = false;
		Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{newuserRM},new List<User>{userRM});
		// When
		Test.startTest();
			Account_Service.isHRIS = true;
			BulkAssignmentManager bulkManager = new BulkAssignmentManager(userMaskMapByUserId);
			bulkManager.createBulkAssignment();
			bulkManager.insertBulkAssignmentQueueAndBulkAssignment();
			bulkManager.setAccountInfoFromBulkInfo();
			bulkManager.updateAccount();
		Test.stopTest();
		// Then
		Account accountTarget = [SELECT Id,OwnerId From Account WHERE CIS__C =:ACCOUNTOWNER_AFRM_CIS Limit 1];
		User userTM = [SELECT Id From User WHERE Employee_id__c = :USER_AFTM_EMPID Limit 1];
		System.assertEquals(userTM.id,accountTarget.OwnerId);
	}

	@isTest static void rmAFChangeTeamAndSegmentAccountOwnerOneLevelUp(){
		// Given
		User userRM = [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :USER_AFRM_EMPID Limit 1];
		User newuserRM = userRM.clone(true, true, false, false);
		newuserRM.RC_Code__c = '23453';
		newuserRM.Segment__c = 'SD';
		Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{newuserRM},new List<User>{userRM});
		// When
		Test.startTest();
			Account_Service.isHRIS = true;
			BulkAssignmentManager bulkManager = new BulkAssignmentManager(userMaskMapByUserId);
			bulkManager.createBulkAssignment();
			bulkManager.insertBulkAssignmentQueueAndBulkAssignment();
			bulkManager.setAccountInfoFromBulkInfo();
			bulkManager.updateAccount();
		Test.stopTest();
		// Then
		Account accountTarget = [SELECT Id,OwnerId From Account WHERE CIS__C =:ACCOUNTOWNER_AFRM_CIS Limit 1];
		User userTM = [SELECT Id From User WHERE Employee_id__c = :USER_AFTM_EMPID Limit 1];
		System.assertEquals(userTM.id,accountTarget.OwnerId);
	}

	@isTest static void rmAFChangeTeamSameSegmentAccountOwnerNotChange(){
		// Given
		User userRM = [SELECT Id,FirstName,LastName,Segment__c,IsActive,ProfileId,Profile.Name,Job_Code__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c From User WHERE Employee_id__c = :USER_AFRM_EMPID Limit 1];
		User newuserRM = userRM.clone(true, true, false, false);
		newuserRM.RC_Code__c = '23453';
		Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{newuserRM},new List<User>{userRM});
		// When
		Test.startTest();
			Account_Service.isHRIS = true;
			BulkAssignmentManager bulkManager = new BulkAssignmentManager(userMaskMapByUserId);
			bulkManager.createBulkAssignment();
			bulkManager.insertBulkAssignmentQueueAndBulkAssignment();
			bulkManager.setAccountInfoFromBulkInfo();
			bulkManager.updateAccount();
		Test.stopTest();
		// Then
		Account accountTarget = [SELECT Id,OwnerId From Account WHERE CIS__C =:ACCOUNTOWNER_AFRM_CIS Limit 1];
		System.assertEquals(userRM.id,accountTarget.OwnerId);
	}

	@isTest static void dualRMInactiveDualRMOneLevelUp(){
		// Given
		User userAFRMDual = [SELECT Id,FirstName,LastName,Segment__c,Job_Code__c,RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c, IsActive, Profile.Name,SME_User__c,CBS_User__c,Is_RBS_User__c,
			(Select Id from User_Extension__r Limit 1) From User WHERE Employee_id__c = :USER_DUAL_AFRM_EMPID Limit 1];
		//when
		Account account2 = [SELECT Id,Dual_RM_Name__c From Account where CIS__c = :ACCOUNTOWNER_RM_CIS Limit 1];
		User newuserRM = userAFRMDual.clone(true, true, false, false);
		newuserRM.isActive = false;
		Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{newuserRM},new List<User>{userAFRMDual});
		Test.startTest();
			Account_Service.isHRIS = true;
			BulkAssignmentManager bulkManager = new BulkAssignmentManager(userMaskMapByUserId);
			bulkManager.createBulkAssignment();
			bulkManager.insertBulkAssignmentQueueAndBulkAssignment();
			bulkManager.setAccountInfoFromBulkInfo();
			bulkManager.updateAccount();
		Test.stopTest();
		//then
		User userAFTM = [SELECT Id From User WHERE Employee_id__c = :USER_AFTM_EMPID Limit 1];
		Account account = [SELECT Id,Dual_RM_Name__c From Account where CIS__c = :ACCOUNTOWNER_RM_CIS Limit 1];
		System.assertEquals(userAFTM.id,account.Dual_RM_Name__c);
	}

	@isTest static void afTemporaryInactiveAFTemporaryOneLevelUp(){
		//given
		User userAFRMTemp = [SELECT Id,FirstName,LastName,Segment__c,Job_Code__c,RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c, IsActive, Profile.Name,SME_User__c,CBS_User__c,Is_RBS_User__c,
			(Select Id from User_Extension__r Limit 1) From User WHERE Employee_id__c = :USER_DUAL_AFRM_EMPID Limit 1];
		//when
		User newuserAFRM = userAFRMTemp.clone(true, true, false, false);
		newuserAFRM.isActive = false;
		Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{newuserAFRM},new List<User>{userAFRMTemp});
		Test.startTest();
			Account_Service.isHRIS = true;
			BulkAssignmentManager bulkManager = new BulkAssignmentManager(userMaskMapByUserId);
			bulkManager.createBulkAssignment();
			bulkManager.insertBulkAssignmentQueueAndBulkAssignment();
			bulkManager.setAccountInfoFromBulkInfo();
			bulkManager.updateAccount();
		Test.stopTest();
		//Then
		User userAFTM = [SELECT Id,(SELECT Id From User_Extension__r Limit 1) From User WHERE Employee_id__c = :USER_AFTM_EMPID Limit 1];
		Account account = [SELECT Id,AF_Temporary_Customer__c From Account where CIS__c = :ACCOUNTOWNER_RM_CIS Limit 1];
		System.assertEquals(userAFTM.User_Extension__r[0].id,account.AF_Temporary_Customer__c);
	}

	@isTest static void testOwnershipAssignmentQueue(){

		User userAFRMTemp = [SELECT Id,FirstName,LastName,Segment__c,Job_Code__c,RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c, IsActive, Profile.Name,SME_User__c,CBS_User__c,Is_RBS_User__c,
			(Select Id from User_Extension__r Limit 1) From User WHERE Employee_id__c = :USER_DUAL_AFRM_EMPID Limit 1];
	
		User newuserAFRM = userAFRMTemp.clone(true, true, false, false);
		newuserAFRM.isActive = false;
		Map<Id,User_MaskModel> userMaskMapByUserId = mockUserMaskModel(new List<User>{newuserAFRM},new List<User>{userAFRMTemp});
		
		OwnershipAssignment_Queue.doChainJob = false;
		System.enqueueJob(new OwnershipAssignment_Queue(userMaskMapByUserId));
	}
}