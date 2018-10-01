@isTest
private class Task_Test {

	public static String leadToDo = 'leadToDo';
	public static String leadForFeedback = 'leadForFeedback';

	public static String accountNameRM = 'rmCreatedAccountName';
	public static String lastNameRM = 'rmCreatedLastName';
	public static String contactNameRM = 'rmCreatedContactName';

	@testSetup static void setupTask(){
		Mockup_Test mt = new Mockup_Test().setUpTest();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccountWithContact(accountNameRM,contactNameRM,lastNameRM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
	}

	/*@isTest static void testInsertTaskCheckRecordTypeEqualsNormalTask() {
		Task task = new Task(Subject = 'Test');

		Test.startTest();
			System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
				insert task;
			}
		Test.stopTest();

		task = [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM Task WHERE Id =: task.Id];
		System.assertEquals(GlobalConstants.NORMAL_TASK, task.RecordType.DeveloperName);

	}
	
	@isTest static void testUpdateTaskToCompleteRecordTypeMustEqualCompletedTaskAndOnlyUsedWithTargetList() {
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c,OwnerId');
		Campaign mockLeadToDo = new Campaign();
		mockLeadToDo.Lead_Campaign_Event_Code__c = leadToDo;
		mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
		mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
		mockLeadToDo.Name = leadToDo;
		mockLeadToDo.Status = GlobalConstants.PLANNED;
		mockLeadToDo.IsActive = true;
		mockLeadToDo.StartDate = System.today() - 1;
		mockLeadToDo.EndDate = System.Today() + 1;
		mockLeadToDo.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
		insert mockLeadToDo;

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = mockLeadToDo.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.STATUS_NEW;
		insert targetList;

		mockLeadToDo = [SELECT Id, Status FROM Campaign WHERE Id =: mockLeadToDo.Id];
		mockLeadToDo.Status = GlobalConstants.ACTIVE;
		update mockLeadToDo;
		
		Task task = [SELECT Id, Subject, Status, IsClosed, WhatId, RecordType.DeveloperName FROM Task WHERE WhatId =: targetList.Id];


		Test.startTest();
			task.Status = GlobalConstants.LEAD_EXPIRED;
			update task;
		Test.stopTest();

		task = [SELECT Id, RecordTypeId, RecordType.DeveloperName, IsClosed FROM Task WHERE Id =: task.Id];

		List<TaskStatus> taskStatus = [SELECT IsClosed, MasterLabel FROM TaskStatus];
		System.debug('taskStatus : '+taskStatus);

		System.debug('task isclosed : '+task.IsClosed);

		System.assertEquals(GlobalConstants.COMPLETED_TASK, task.RecordType.DeveloperName);
	}

	@isTest static void testTaskIsTargetList(){
		//Account account = [SELECT Id, CIS__c, OwnerId FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c,OwnerId');
		Campaign mockLeadToDo = new Campaign();
		mockLeadToDo.Lead_Campaign_Event_Code__c = leadToDo;
		mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
		mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
		mockLeadToDo.Name = leadToDo;
		mockLeadToDo.Status = GlobalConstants.ACTIVE;
		mockLeadToDo.IsActive = true;
		mockLeadToDo.StartDate = System.today() - 1;
		mockLeadToDo.EndDate = System.Today() + 1;
		mockLeadToDo.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
		insert mockLeadToDo;

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = mockLeadToDo.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.STATUS_NEW;
		insert targetList;

		targetList = [SELECT Id, CIS_ID_Prospect_Name__r.OwnerId,Status__c,Personalised_Message__c,Lead_Type__c,Lead_Subtype__c,Lead_Campaign__r.Name,Priority__c,Priority_Group__c,Lead_Campaign__r.EndDate,Lead_Campaign__r.StartDate,Lead_Campaign__c FROM Target_List__c WHERE Id =: targetList.Id];
		
		Task task = [SELECT Id,OwnerId,WhatId,Status,Personalised_Message__c,Type,Lead_Sub_Type__c,Subject,Priority,Priority_Group__c,ActivityDate,Start_Date__c,Lead_Campaign_Event__c,IsReminderSet,ReminderDateTime FROM Task WHERE WhatId =: targetList.Id];
		System.assertEquals(targetList.CIS_ID_Prospect_Name__r.OwnerId,task.OwnerId);
		System.assertEquals(targetList.Id,task.WhatId);
		System.assertEquals(targetList.Status__c,task.Status);
		System.assertEquals(targetList.Personalised_Message__c,task.Personalised_Message__c);
		System.assertEquals(targetList.Lead_Type__c,task.Type);
		System.assertEquals(targetList.Lead_Subtype__c,task.Lead_Sub_Type__c);
		System.assertEquals(targetList.Lead_Campaign__r.Name,task.Subject);
		System.assertEquals('-',task.Priority);
		System.assertEquals('-',task.Priority_Group__c);
		System.assertEquals(targetList.Lead_Campaign__r.EndDate,task.ActivityDate);
		System.assertEquals(targetList.Lead_Campaign__r.StartDate,task.Start_Date__c);
		System.assertEquals(targetList.Lead_Campaign__c,task.Lead_Campaign_Event__c);
		System.assertEquals(true,task.IsReminderSet);
		System.assertEquals(targetList.Lead_Campaign__r.EndDate,task.ReminderDateTime);
	}

	@isTest static void testTaskAnsweredDate(){
		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c,OwnerId');
		RecordType leadrec = [SELECT Id, DeveloperName, Name FROM RecordType WHERE DeveloperName =: GlobalConstants.LEAD_TASK];
		System.debug('leadRec'+leadrec);

		Campaign mockLeadToDo = new Campaign();
		mockLeadToDo.Lead_Campaign_Event_Code__c = leadToDo;
		mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
		mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
		mockLeadToDo.Name = leadToDo;
		mockLeadToDo.Status = GlobalConstants.ACTIVE;
		mockLeadToDo.IsActive = true;
		mockLeadToDo.StartDate = System.today() - 1;
		mockLeadToDo.EndDate = System.Today() + 1;
		mockLeadToDo.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
		insert mockLeadToDo;

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = mockLeadToDo.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.STATUS_NEW;
		insert targetList;

		Date today = System.today();

		Task task = [SELECT Id, Subject, Status, IsClosed, WhatId, Answered_Date__c, RecordType.DeveloperName FROM Task WHERE WhatId =: targetList.Id];

		System.debug('task record type : '+task.RecordType.DeveloperName);

		Test.startTest();
			task.Status = GlobalConstants.LEAD_RESPONSE_BAD_LEAD;
			task.Answered_Date__c = today;
			update task;
		Test.stopTest();

		task = [SELECT Id, Subject, Status, IsClosed, WhatId, Answered_Date__c FROM Task WHERE Id =: task.Id];
		targetList = [SELECT Id, Response_Level_2__c FROM Target_List__c WHERE Id =: targetList.Id];

		System.assertEquals(task.Answered_Date__c.format(), targetList.Response_Level_2__c);
	}*/

	@isTest static void testReassignTaskIsTargetList(){
		User tmUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
		User rmUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];

		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c,OwnerId');
		Campaign mockLeadToDo = new Campaign();
		mockLeadToDo.Lead_Campaign_Event_Code__c = leadToDo;
		mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
		mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
		mockLeadToDo.Name = leadToDo;
		mockLeadToDo.Status = GlobalConstants.ACTIVE;
		mockLeadToDo.IsActive = true;
		mockLeadToDo.StartDate = System.today() - 1;
		mockLeadToDo.EndDate = System.Today() + 1;
		mockLeadToDo.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
		insert mockLeadToDo;

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = mockLeadToDo.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.STATUS_NEW;
		insert targetList;

		Bulk_Assignment__c testBulkAssignment = new Bulk_Assignment__c(AssignmentOwner__c = tmUser.Id);

		Map<Id,Bulk_Assignment__c> mapTestBulkAssignment = new Map<Id,Bulk_Assignment__c>{rmUser.Id => testBulkAssignment};
		
		Task task = new Task(Subject = 'Test', OwnerId = rmUser.Id, WhatId = targetList.Id);
		insert task;

		System.assertEquals(rmUser.Id,task.OwnerId);

		Task_Service.reassignTask(mapTestBulkAssignment);

		task = [SELECT Id, OwnerId, WhatId FROM Task WHERE Id =: task.Id];

		System.assertEquals(tmUser.Id,task.OwnerId);
	}

	@isTest static void testReassignTaskIsNotTargetList(){
		User tmUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
		User rmUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];

		//Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c,OwnerId');
		Bulk_Assignment__c testBulkAssignment = new Bulk_Assignment__c(AssignmentOwner__c = tmUser.Id);

		Task task = new Task(Subject = 'Test', OwnerId = rmUser.Id, WhatId = account.Id);
		System.runAs(rmUser){
			insert task;
		}

		Map<Id,Bulk_Assignment__c> mapTestBulkAssignment = new Map<Id,Bulk_Assignment__c>{rmUser.Id => testBulkAssignment};

		System.assertEquals(rmUser.Id,task.OwnerId);

		Task_Service.reassignTask(mapTestBulkAssignment);

		task = [SELECT Id, OwnerId, WhatId, Status FROM Task WHERE Id =: task.Id];

		System.assertEquals(GlobalConstants.CLOSED_BY_SYSTEM,task.Status);
	}

	/*@isTest static void testChangeOwnerAndMoveTask(){
		User tmUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
		User rmUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];

		Account tempAccount = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c,OwnerId');
		Account targetAccount = [SELECT Id, CIS__c, (SELECT Id FROM Contacts) FROM Account WHERE Id =: tempAccount.Id];

		Campaign mockLeadToDo = new Campaign();
		mockLeadToDo.Lead_Campaign_Event_Code__c = leadToDo;
		mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
		mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
		mockLeadToDo.Name = leadToDo;
		mockLeadToDo.Status = GlobalConstants.ACTIVE;
		mockLeadToDo.IsActive = true;
		mockLeadToDo.StartDate = System.today() - 1;
		mockLeadToDo.EndDate = System.Today() + 1;
		mockLeadToDo.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
		insert mockLeadToDo;

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = mockLeadToDo.Id;
		targetList.CIS_ID_Prospect_Name__c = targetAccount.Id;
		targetList.Status__c = GlobalConstants.STATUS_NEW;
		insert targetList;

		Task task = [SELECT Id, OwnerId, WhatId FROM Task WHERE WhatId =: targetList.Id];
		System.assertEquals(rmUser.Id,task.OwnerId);

		System.runAs(rmUser){
			rmUser.Segment__c = GlobalConstants.SEGMENT_ME;
			TriggerHandler.bypass('UserTriggerHandler');
            update rmUser;
            TriggerHandler.clearBypass('UserTriggerHandler');
        }
		System.runAs(tmUser){
			tmUser.Segment__c = GlobalConstants.SEGMENT_ME;
			TriggerHandler.bypass('UserTriggerHandler');
            update tmUser;
            TriggerHandler.clearBypass('UserTriggerHandler');
        }
        Business_Code__c buCodeTest = new Business_Code__c(Name = '123456',Segment__c=GlobalConstants.SEGMENT_ME,External_ID__c='123456:'+GlobalConstants.SEGMENT_ME);
        insert buCodeTest;
		Customer_Business_Code__c customerBusinessCode = new Customer_Business_Code__c(Name=Customer_BusinessCode_Service.getDefaultValue(),CIS__c=targetAccount.id,Business_Code__c=buCodeTest.id,External__c=targetAccount.CIS__c+':'+buCodeTest.External_ID__c,Account_Owner_Segment__c=GlobalConstants.SEGMENT_ME);
        insert customerBusinessCode;
        System.runAs(tmUser){
            Call_Report__c callreportObj;
            callreportObj = new Call_Report__c(
                CIS_ID__c = targetAccount.Id,
                Status__c = GlobalConstants.CONTACTED,
                Plan_Date__c = System.Today(),
                Contact__c = targetAccount.Contacts[0].Id,
                Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
                Expected_Credit_Amount__c = 100000,
                RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME),
                Offer_Credit_Product__c = true,
                Actual_Visit_Date__c  = System.Today()-1,
                Customer_Business_Code__c = customerBusinessCode.id,
                Estimate_Credit_Model__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_FL
            );
            Test.startTest();
                insert callreportObj;
            Test.stopTest();
            Account finalAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c FROM Account WHERE Id = : tempAccount.Id LIMIT 1];
            Contact finalContact = [SELECT Id,OwnerId FROM Contact WHERE Account.Id = : tempAccount.Id LIMIT 1];
        }

		task = [SELECT Id, OwnerId, WhatId FROM Task WHERE WhatId =: targetList.Id];

		System.assertEquals(tmUser.Id,task.OwnerId);
	}*/

	@isTest static void testReassignTaskIsTargetListWithMaskModel(){
		User tmUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
		User rmUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];

		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c,OwnerId,Share_With__c');
		Campaign mockLeadToDo = new Campaign();
		mockLeadToDo.Lead_Campaign_Event_Code__c = leadToDo;
		mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
		mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
		mockLeadToDo.Name = leadToDo;
		mockLeadToDo.Status = GlobalConstants.ACTIVE;
		mockLeadToDo.IsActive = true;
		mockLeadToDo.StartDate = System.today() - 1;
		mockLeadToDo.EndDate = System.Today() + 1;
		mockLeadToDo.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
		insert mockLeadToDo;

		Target_List__c targetList = new Target_List__c();
		targetList.Lead_Campaign__c = mockLeadToDo.Id;
		targetList.CIS_ID_Prospect_Name__c = account.Id;
		targetList.Status__c = GlobalConstants.STATUS_NEW;
		insert targetList;

		Account_MaskModel accountMaskModel = new Account_MaskModel(account);
		accountMaskModel.setOwner(tmUser);
		List<Account_MaskModel> testAccountMaskModel = new List<Account_MaskModel>();
		testAccountMaskModel.add(accountMaskModel);
		Set<Id> setAccountId = new Set<Id>{account.Id};
		
		Task task = new Task(Subject = 'Test', OwnerId = rmUser.Id, WhatId = targetList.Id);
		insert task;

		System.assertEquals(rmUser.Id,task.OwnerId);

		Test.startTest();
		Task_Service.reassignTaskList(testAccountMaskModel, setAccountId);
		Task_Service.reassignTask(testAccountMaskModel, setAccountId);
		Test.stopTest();

		System.assertNotEquals(0, Task_Service.relateTaskList.size());
		task = [SELECT Id, OwnerId, WhatId FROM Task WHERE Id =: task.Id];
		System.assertEquals(tmUser.Id,task.OwnerId);
	}

	@isTest static void testReassignTaskIsNotTargetListWithMaskModel(){
		User tmUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameTM];
		User rmUser = [SELECT Id FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];

		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,CIS__c,OwnerId,Share_With__c');
		Account_MaskModel accountMaskModel = new Account_MaskModel(account);
		accountMaskModel.setOwner(tmUser);
		List<Account_MaskModel> testAccountMaskModel = new List<Account_MaskModel>();
		testAccountMaskModel.add(accountMaskModel);
		Set<Id> setAccountId = new Set<Id>{account.Id};

		Task task = new Task(Subject = 'Test', OwnerId = rmUser.Id, WhatId = account.Id);
		System.runAs(rmUser){
			insert task;
		}

		System.assertEquals(rmUser.Id,task.OwnerId);

		Test.startTest();
		Task_Service.reassignTaskList(testAccountMaskModel, setAccountId);
		Task_Service.reassignTask(testAccountMaskModel, setAccountId);
		Test.stopTest();

		System.assertNotEquals(0, Task_Service.relateTaskList.size());
		task = [SELECT Id, OwnerId, WhatId, Status FROM Task WHERE Id =: task.Id];
		System.assertEquals(GlobalConstants.CLOSED_BY_SYSTEM,task.Status);
	}
}