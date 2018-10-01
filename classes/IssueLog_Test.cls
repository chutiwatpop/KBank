@isTest
private class IssueLog_Test {
	
	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameTL = 'tlCreatedAccountName';

    public static String contactNameTM = 'tmCreatedContactName';
    public static String contactNameRM = 'rmCreatedContactName';
    public static String contactNameTL = 'tlCreatedContactName';

    public static String lastNameTM = 'tmCreatedLastName';
    public static String lastNameRM = 'rmCreatedLastName';
    public static String lastNameTL = 'tlCreatedLastName';

	@testSetup static void setupUser(){
        TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1][0]){
            mt.newAccountWithContact(accountNameTM,contactNameTM,lastNameTM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
            mt.newAccountWithContact(accountNameRM,contactNameRM,lastNameRM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1][0]){
            mt.newAccountWithContact(accountNameTL,contactNameTL,lastNameTL,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        TriggerHandler.clearBypass('UserTriggerHandler');
    }

	private static void mockIssueMaster(Id scUserId) {
		List<Issue_Master__c> issueMasterList = new List<Issue_Master__c>();
		Issue_Master__c issueMasterTLFSVP = new Issue_Master__c();
		issueMasterTLFSVP.Division__c = 'Division1'; // Req
		issueMasterTLFSVP.Product__c = 'Product1'; // Req
		issueMasterTLFSVP.Category__c = 'Category1'; // Req
		issueMasterTLFSVP.Sub_Category__c = 'SubCategory1'; // Req
		issueMasterTLFSVP.Available_Closed_Status__c = 'Done;Closed';
		issueMasterTLFSVP.Assigned_To__c = 'TL;FSVP';
		issueMasterTLFSVP.Enable_Rating_and_Comment__c = true;
		issueMasterList.add(issueMasterTLFSVP);

		Issue_Master__c issueMasterPM = new Issue_Master__c();
		issueMasterPM.Division__c = 'Division2'; // Req
		issueMasterPM.Product__c = 'Product2'; // Req
		issueMasterPM.Category__c = 'Category2'; // Req
		issueMasterPM.Sub_Category__c = 'SubCategory2'; // Req
		issueMasterPM.Available_Closed_Status__c = 'Closed Won;Closed Lost';
		issueMasterPM.Assigned_To__c = 'PM';
		issueMasterList.add(issueMasterPM);

		Issue_Master__c issueMasterSC = new Issue_Master__c();
		issueMasterSC.Division__c = 'Division3'; // Req
		issueMasterSC.Product__c = 'Product3'; // Req
		issueMasterSC.Category__c = 'Category3'; // Req
		issueMasterSC.Sub_Category__c = 'SubCategory3'; // Req
		issueMasterSC.Available_Closed_Status__c = 'Closed Won;Closed Lost';
		issueMasterSC.Assigned_To__c = 'SC';
		issueMasterSC.Assign_To_Internal_User__c = scUserId;
		issueMasterList.add(issueMasterSC);

		insert issueMasterList;
	}

	private static Id newIssueLog(Id issueMasterId, Id accountId) {
		Map<String, Id> recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');

		Issue_Log__c issueLog = new Issue_Log__c();
		issueLog.Subject__c = 'Subject'; // Req
		issueLog.CIS_ID_or_Prospect_Name__c = accountId; // Req
		issueLog.Issue_Master__c = issueMasterId; // Req
		issueLog.Status__c = 'New'; // Req
		issueLog.Date_Time_Opened__c = System.now(); // Req
		issueLog.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_OPEN_ISSUE_NORMAL_REC);
		insert issueLog;

		return issueLog.Id;
	}

	private static Map<String, Id> newGroupAndGroupMember(Id userId, String groupName) {
		Map<String, Id> mapId = new Map<String, Id>();

		Group testGroup = new Group();
		testGroup.Name = groupName;
		insert testGroup;
		mapId.put('GROUP_ID', testGroup.Id);

		GroupMember gMember = new GroupMember();
		gMember.GroupId = testGroup.Id;
		gMember.UserOrGroupId = userId;
		insert gMember;
		mapId.put('MEMBER_ID', gMember.Id);

		return mapId;
	}

	@isTest static void testCreateIssueLog() {
		User CB_TM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1];
		Map<String, Id> mapGroupId = newGroupAndGroupMember(CB_TM.Id, 'CBS-SC');

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
            // Mock Account
            Account testAcc = new Account();
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

            mockIssueMaster(UserInfo.getUserId());
            Issue_Master__c issueMasterPM = [SELECT Id FROM Issue_Master__c WHERE Assigned_To__c = 'PM'];
            Id issueLogId = newIssueLog(issueMasterPM.Id, testAcc.Id);
        }
	}

	@isTest static void testCreateDoneIssueLog() {
		Map<String, Id> recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');
		User CB_TM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1];
		Map<String, Id> mapGroupId = newGroupAndGroupMember(CB_TM.Id, 'CBS-SC');

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
            // Mock Account
            Account testAcc = new Account();
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

            mockIssueMaster(UserInfo.getUserId());
            Issue_Master__c issueMasterPM = [SELECT Id  FROM Issue_Master__c WHERE Assigned_To__c = 'PM'];
            Issue_Log__c issueLog = new Issue_Log__c();
			issueLog.Subject__c = 'Subject'; // Req
			issueLog.CIS_ID_or_Prospect_Name__c = testAcc.Id; // Req
			issueLog.Issue_Master__c = issueMasterPM.Id; // Req
			issueLog.Status__c = GlobalConstants.STATUS_DONE; // Req
			issueLog.Date_Time_Opened__c = System.now(); // Req
			issueLog.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_OPEN_ISSUE_PARENT_REC);
			insert issueLog;
        }
	}
	
	@isTest static void testChangeIssueLogOwner() {
		Map<String, Id> recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');
		Id issueLogId;
		Account testAcc = new Account();
		mockIssueMaster(UserInfo.getUserId());
		// Implement test code
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1][0]){
            // Mock Account
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

            Issue_Master__c issueMasterPM = [SELECT Id FROM Issue_Master__c WHERE Assigned_To__c = 'PM'];
            issueLogId = newIssueLog(issueMasterPM.Id, testAcc.Id);
        }
        User userTL = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1];
        User userRm = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1];
        Issue_Log__c updateIssue = new Issue_Log__c(Id = issueLogId);
        updateIssue.Issue_Log_Owner__c = userRm.Id;
        updateIssue.Status__c = GlobalConstants.STATUS_DONE;
        update updateIssue;
	}

	@isTest static void testChangeIssueLogAssignee() {
		Map<String, Id> recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');
		Id issueLogId;
		Account testAcc = new Account();
		mockIssueMaster(UserInfo.getUserId());
		// Implement test code
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1][0]){
            // Mock Account
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

            Issue_Master__c issueMasterPM = [SELECT Id FROM Issue_Master__c WHERE Assigned_To__c = 'PM'];
            issueLogId = newIssueLog(issueMasterPM.Id, testAcc.Id);
        }
        User userTL = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1];
        User userRm = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1];
        Issue_Log__c updateIssue = new Issue_Log__c(Id = issueLogId);
        updateIssue.Assigned_Internal_Lookup__c = userTL.Id;
        update updateIssue;
	}

	@isTest static void testOwnerUpdateIssueLogStatusToDone() {
		Map<String, Id> recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');
		Id issueLogId;
		Account testAcc = new Account();
		mockIssueMaster(UserInfo.getUserId());
		// Implement test code
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1][0]){
            // Mock Account
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

            Issue_Master__c issueMasterPM = [SELECT Id FROM Issue_Master__c WHERE Assigned_To__c = 'PM'];
            issueLogId = newIssueLog(issueMasterPM.Id, testAcc.Id);
        	
        	Issue_Log__c updateIssue = new Issue_Log__c(Id = issueLogId);
	        updateIssue.Status__c = GlobalConstants.STATUS_DONE;
	        update updateIssue;
        }
	}

	@isTest static void testOwnerUpdateIssueLogStatusToDoneMasterTLFSVP() {
		Map<String, Id> recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');
		Id issueLogId;
		Account testAcc = new Account();
		mockIssueMaster(UserInfo.getUserId());
		// Implement test code
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1][0]){
            // Mock Account
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

            Issue_Master__c issueMasterTLFSVP = [SELECT Id FROM Issue_Master__c WHERE Assigned_To__c = 'TL;FSVP'];
            issueLogId = newIssueLog(issueMasterTLFSVP.Id, testAcc.Id);
        	
        	Issue_Log__c updateIssue = new Issue_Log__c(Id = issueLogId);
	        updateIssue.Status__c = GlobalConstants.STATUS_DONE;
	        update updateIssue;
        }
	}

	@isTest static void testChildIssueLog() {
		Map<String, Id> recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');
		User CB_TM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1];
		Map<String, Id> mapGroupId = newGroupAndGroupMember(CB_TM.Id, 'CBS-SC');

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
            // Mock Account
            Account testAcc = new Account();
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

            mockIssueMaster(UserInfo.getUserId());
            Issue_Master__c issueMasterSC = [SELECT Id FROM Issue_Master__c WHERE Assigned_To__c = 'SC'];
            Issue_Log__c issueLog = new Issue_Log__c();
			issueLog.Subject__c = 'Subject'; // Req
			issueLog.CIS_ID_or_Prospect_Name__c = testAcc.Id; // Req
			issueLog.Issue_Master__c = issueMasterSC.Id; // Req
			issueLog.Status__c = GlobalConstants.STATUS_DONE; // Req
			issueLog.Date_Time_Opened__c = System.now(); // Req
			issueLog.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_OPEN_ISSUE_PARENT_REC);
			insert issueLog;

			Issue_Log__c childIssueLog = new Issue_Log__c();
			childIssueLog.Subject__c = 'Subject'; // Req
			childIssueLog.CIS_ID_or_Prospect_Name__c = testAcc.Id; // Req
			childIssueLog.Issue_Master__c = issueMasterSC.Id; // Req
			childIssueLog.Status__c = GlobalConstants.STATUS_NEW; // Req
			childIssueLog.Parent_Issue__c = issueLog.Id;
			childIssueLog.Date_Time_Opened__c = System.now(); // Req
			childIssueLog.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_OPEN_ISSUE_SECOND_REC);
			insert childIssueLog;
        }
	}

	@isTest static void testCreateDoneChildIssueLog() {
		Map<String, Id> recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');
		User CB_TM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1];
		Map<String, Id> mapGroupId = newGroupAndGroupMember(CB_TM.Id, 'CBS-SC');

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
            // Mock Account
            Account testAcc = new Account();
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

            mockIssueMaster(UserInfo.getUserId());
            Issue_Master__c issueMasterPM = [SELECT Id FROM Issue_Master__c WHERE Assigned_To__c = 'PM'];
            Issue_Log__c issueLog = new Issue_Log__c();
			issueLog.Subject__c = 'Subject'; // Req
			issueLog.CIS_ID_or_Prospect_Name__c = testAcc.Id; // Req
			issueLog.Issue_Master__c = issueMasterPM.Id; // Req
			issueLog.Status__c = GlobalConstants.STATUS_DONE; // Req
			issueLog.Date_Time_Opened__c = System.now(); // Req
			issueLog.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_OPEN_ISSUE_SECOND_REC);
			insert issueLog;
        }
	}

	@isTest static void testCreateIssueLogWithAssigned() {
		Map<String, Id> recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');
		User CB_TM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1];
		Map<String, Id> mapGroupId = newGroupAndGroupMember(CB_TM.Id, 'CBS-SC');

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
            // Mock Account
            Account testAcc = new Account();
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

            mockIssueMaster(UserInfo.getUserId());
            Issue_Master__c issueMasterPM = [SELECT Id FROM Issue_Master__c WHERE Assigned_To__c = 'PM'];
            Issue_Log__c issueLog = new Issue_Log__c();
			issueLog.Subject__c = 'Subject'; // Req
			issueLog.CIS_ID_or_Prospect_Name__c = testAcc.Id; // Req
			issueLog.Issue_Master__c = issueMasterPM.Id; // Req
			issueLog.Status__c = GlobalConstants.STATUS_NEW; // Req
			issueLog.Assigned_Team_Person_Text__c = 'test';
			issueLog.Date_Time_Opened__c = System.now(); // Req
			issueLog.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_OPEN_ISSUE_SECOND_REC);
			insert issueLog;
        }
	}

	@isTest static void testCreateIssueLogWithAssignedInternal() {
		Map<String, Id> recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');
		User CB_TM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1];
		Map<String, Id> mapGroupId = newGroupAndGroupMember(CB_TM.Id, 'CBS-SC');

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1][0]){
            // Mock Account
            Account testAcc = new Account();
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

            mockIssueMaster(UserInfo.getUserId());
            Issue_Master__c issueMasterPM = [SELECT Id FROM Issue_Master__c WHERE Assigned_To__c = 'PM'];
            Issue_Log__c issueLog = new Issue_Log__c();
			issueLog.Subject__c = 'Subject'; // Req
			issueLog.CIS_ID_or_Prospect_Name__c = testAcc.Id; // Req
			issueLog.Issue_Master__c = issueMasterPM.Id; // Req
			issueLog.Status__c = GlobalConstants.STATUS_NEW; // Req
			issueLog.Assigned_Internal_Lookup__c = UserInfo.getUserId();
			issueLog.Date_Time_Opened__c = System.now(); // Req
			issueLog.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_OPEN_ISSUE_SECOND_REC);
			insert issueLog;
        }
	}

	@isTest static void testOwnerUpdateIssueLogWithAssignedStatusToDone() {
		Map<String, Id> recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');
		Id issueLogId;
		Account testAcc = new Account();
		mockIssueMaster(UserInfo.getUserId());
		// Implement test code
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1][0]){
            // Mock Account
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

            Issue_Master__c issueMasterPM = [SELECT Id FROM Issue_Master__c WHERE Assigned_To__c = 'PM'];
            Issue_Log__c issueLog = new Issue_Log__c();
			issueLog.Subject__c = 'Subject'; // Req
			issueLog.CIS_ID_or_Prospect_Name__c = testAcc.Id; // Req
			issueLog.Issue_Master__c = issueMasterPM.Id; // Req
			issueLog.Status__c = GlobalConstants.STATUS_NEW; // Req
			issueLog.Assigned_Team_Person_Text__c = 'test';
			issueLog.Date_Time_Opened__c = System.now(); // Req
			issueLog.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_OPEN_ISSUE_SECOND_REC);
			insert issueLog;
        	
        	Issue_Log__c updateIssue = new Issue_Log__c(Id = issueLog.Id);
	        updateIssue.Status__c = GlobalConstants.STATUS_DONE;
	        updateIssue.Assigned_Team_Person_Text__c = 'new';
	        update updateIssue;
        }
	}

	@isTest static void testOwnerUpdateIssueLogWithAssignedStatusToRecalled() {
		Map<String, Id> recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Issue_Log__c');
		Id issueLogId;
		Account testAcc = new Account();
		mockIssueMaster(UserInfo.getUserId());
		// Implement test code
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTM LIMIT 1][0]){
            // Mock Account
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

            Issue_Master__c issueMasterPM = [SELECT Id FROM Issue_Master__c WHERE Assigned_To__c = 'PM'];
            Issue_Log__c issueLog = new Issue_Log__c();
			issueLog.Subject__c = 'Subject'; // Req
			issueLog.CIS_ID_or_Prospect_Name__c = testAcc.Id; // Req
			issueLog.Issue_Master__c = issueMasterPM.Id; // Req
			issueLog.Status__c = GlobalConstants.STATUS_NEW; // Req
			issueLog.Assigned_Team_Person_Text__c = 'test';
			issueLog.Date_Time_Opened__c = System.now(); // Req
			issueLog.RecordTypeId = recordTypeIdMapByDevName.get(GlobalConstants.CBS_OPEN_ISSUE_SECOND_REC);
			insert issueLog;
        	
        	Issue_Log__c updateIssue = new Issue_Log__c(Id = issueLog.Id);
	        updateIssue.Status__c = GlobalConstants.RECALLED;
	        update updateIssue;
        }
	}
}