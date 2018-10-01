@isTest
private class CustomTaskSection_Test {

	public static String accountNameRM = 'rmCreatedAccountName';
	public static String accountNameCBSRM = 'rmCBSCreatedAccountName';

	public static String leadToDo = 'leadToDo';
	public static String leadForFeedback = 'leadForFeedback';

	@testSetup static void setUpTask(){
		Mockup_Test mt = new Mockup_Test().setUpTest();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameCBSRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }

	}
	
	@isTest static void testSelectFilterIsAllOpen() {
		Test.startTest();

		Task testTask = new Task(Subject = 'testTask', ActivityDate = System.today());
		insert testTask;

		String selectFilter = 'All_Open';

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.initCustomTasks(selectFilter);

		Task assertTask = customTaskSectionController.allTasks.get(0);

		Test.stopTest();

		System.assertEquals(testTask.Id,assertTask.Id);
	}

	@isTest static void testSelectFilterIsToday() {
		Test.startTest();

		Task testTask = new Task(Subject = 'testTask', ActivityDate = System.today());
		insert testTask;

		String selectFilter = 'Today';

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.initCustomTasks(selectFilter);

		Task assertTask = customTaskSectionController.allTasks.get(0);

		Test.stopTest();

		System.assertEquals(testTask.Id,assertTask.Id);
	}

	@isTest static void testSelectFilterIsOverdue() {
		Test.startTest();

		Task testTask = new Task(Subject = 'testTask', ActivityDate = System.today()-1);
		insert testTask;

		String selectFilter = 'Overdue';

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.initCustomTasks(selectFilter);

		Task assertTask = customTaskSectionController.allTasks.get(0);

		Test.stopTest();

		System.assertEquals(testTask.Id,assertTask.Id);
	}

	@isTest static void testSelectFilterIsTodayAndOverdue() {
		Task assertTask1;
		Task assertTask2;

		Test.startTest();
		List<Task> listTaskToInsert = new List<Task>();
		Task testTask1 = new Task(Subject = 'testTask1', ActivityDate = System.today());
		listTaskToInsert.add(testTask1);
		Task testTask2 = new Task(Subject = 'testTask2', ActivityDate = System.today()-1);
		listTaskToInsert.add(testTask2);
		insert listTaskToInsert;

		String selectFilter = 'Today_Overdue';

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.initCustomTasks(selectFilter);

		

		for(Task eachTask : customTaskSectionController.allTasks){
			if(eachTask.Id == testTask1.Id){
				assertTask1 = eachTask;
			}else if(eachTask.Id == testTask2.Id){
				assertTask2 = eachTask;
			}
		}

		Test.stopTest();

		System.assertEquals(testTask1.Id,assertTask1.Id);
		System.assertEquals(testTask2.Id,assertTask2.Id);
	}

	@isTest static void testSelectFilterIsTomorrow() {
		Test.startTest();

		Task testTask = new Task(Subject = 'testTask1', ActivityDate = System.today()+1);
		insert testTask;

		String selectFilter = 'Tomorrow';

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.initCustomTasks(selectFilter);

		Task assertTask = customTaskSectionController.allTasks.get(0);


		Test.stopTest();

		System.assertEquals(testTask.Id,assertTask.Id);

	}

	@isTest static void testSelectFilterIsNext7Days() {
		Test.startTest();

		Task testTask = new Task(Subject = 'testTask1', ActivityDate = System.today()+7);
		insert testTask;

		String selectFilter = 'Next_7_Days';

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.initCustomTasks(selectFilter);

		Task assertTask = customTaskSectionController.allTasks.get(0);


		Test.stopTest();

		System.assertEquals(testTask.Id,assertTask.Id);

	}

	@isTest static void testSelectFilterIsNext7DaysAndOverdue() {
		Task assertTask1;
		Task assertTask2;
		
		Test.startTest();
		List<Task> listTaskToInsert = new List<Task>();
		Task testTask1 = new Task(Subject = 'testTask1', ActivityDate = System.today()+7);
		listTaskToInsert.add(testTask1);
		Task testTask2 = new Task(Subject = 'testTask2', ActivityDate = System.today()-1);
		listTaskToInsert.add(testTask2);
		insert listTaskToInsert;

		String selectFilter = 'Next_7_Days_Overdue';

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.initCustomTasks(selectFilter);

		

		for(Task eachTask : customTaskSectionController.allTasks){
			if(eachTask.Id == testTask1.Id){
				assertTask1 = eachTask;
			}else if(eachTask.Id == testTask2.Id){
				assertTask2 = eachTask;
			}
		}
		

		Test.stopTest();

		System.assertEquals(testTask1.Id,assertTask1.Id);
		System.assertEquals(testTask2.Id,assertTask2.Id);
	}

	@isTest static void testSelectFilterIsThisMonth() {
		Test.startTest();

		Task testTask = new Task(Subject = 'testTask1', ActivityDate = System.today());
		insert testTask;

		String selectFilter = 'This_Month';

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.initCustomTasks(selectFilter);

		Task assertTask = customTaskSectionController.allTasks.get(0);


		Test.stopTest();

		System.assertEquals(testTask.Id,assertTask.Id);

	}

	@isTest static void testSelectFilterIsCompleted() {
		Test.startTest();

		Task testTask = new Task(Subject = 'testTask1', ActivityDate = System.today(), Status = GlobalConstants.STATUS_COMPLETED);
		insert testTask;

		String selectFilter = 'Completed';

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.initCustomTasks(selectFilter);

		Task assertTask = customTaskSectionController.allTasks.get(0);


		Test.stopTest();

		System.assertEquals(testTask.Id,assertTask.Id);

	}

	@isTest static void testInitialSelectFilter(){
		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();

		Test.startTest();
			String filter = customTaskSectionController.getselectFilter();
		Test.stopTest();

		System.assertEquals('All_Open',filter);
	}

	@isTest static void testFilterTask() {
		Test.startTest();
		Task testTask = new Task(Subject = 'testTask1', ActivityDate = System.today());
		insert testTask;
		

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.selectFilter = 'All_Open';
		customTaskSectionController.filterTasks();

		Task assertTask = customTaskSectionController.allTasks.get(0);

		Test.stopTest();

		System.assertEquals(testTask.Id,assertTask.Id);
	}

	@isTest static void testCheckMapIsSetFalse(){
		Task testTask = new Task(Subject = 'testTask1', ActivityDate = System.today());
		insert testTask;

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.mapCustomTasksById.get(testTask.Id).isChecked = true;

		customTaskSectionController.setMapIsCheckedFalse();

		System.assertEquals(false,customTaskSectionController.mapCustomTasksById.get(testTask.Id).isChecked);
	}

	@isTest static void testRedirectPopup(){
		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		
		System.assertEquals(null,customTaskSectionController.displaySubTypePopUp);

		customTaskSectionController.redirectPopup();

		System.assertEquals(true,customTaskSectionController.displaySubTypePopUp);
	}

	@isTest static void testShowDateInput(){
		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		
		System.assertEquals(false,customTaskSectionController.showDate);

		customTaskSectionController.showDateInput();

		System.assertEquals(true,customTaskSectionController.showDate);
	}

	@isTest static void testDisablePreviousWhenOffsetSizeIsGreaterThanZero(){
		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.offsetSize = 1;

		Boolean checkDisablePrevious = customTaskSectionController.getDisablePrevious();

		System.assertEquals(false,checkDisablePrevious);
	}

	@isTest static void testDisablePreviousWhenOffsetSizeIsZero(){
		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.offsetSize = 0;

		Boolean checkDisablePrevious = customTaskSectionController.getDisablePrevious();

		System.assertEquals(true,checkDisablePrevious);
	}

	@isTest static void testDisableNextIsFalse(){
		List<Task> taskListToInsert = new List<Task>();
		for(Integer i=0; i<16;i++){
			Task eachTask = new Task(Subject = 'Test'+i);
			taskListToInsert.add(eachTask);
		}
		insert taskListToInsert;

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();

		Boolean checkDisableNext = customTaskSectionController.getDisableNext();

		System.assertEquals(false,checkDisableNext);


	}

	@isTest static void testDisableNextIsTrue(){
		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.offsetSize = 0;

		Boolean checkDisableNext = customTaskSectionController.getDisableNext();

		System.assertEquals(true,checkDisableNext);
	}

	@isTest static void testNext(){
		List<Task> taskListToInsert = new List<Task>();
		for(Integer i=0; i<36;i++){
			Task eachTask = new Task(Subject = 'Test'+i);
			taskListToInsert.add(eachTask);
		}
		insert taskListToInsert;

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.Next();

		System.assertEquals(15, customTaskSectionController.offsetSize);
		System.assertEquals(16, customTaskSectionController.startSize);
		System.assertEquals(20,customTaskSectionController.sizeOfRecordsShowing);

	}

	@isTest static void testPrevious(){
		List<Task> taskListToInsert = new List<Task>();
		for(Integer i=0; i<40;i++){
			Task eachTask = new Task(Subject = 'Test'+i);
			taskListToInsert.add(eachTask);
		}
		insert taskListToInsert;

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.Next();

		System.assertEquals(15, customTaskSectionController.offsetSize);
		System.assertEquals(16, customTaskSectionController.startSize);
		System.assertEquals(20 ,customTaskSectionController.sizeOfRecordsShowing);

		customTaskSectionController.Previous();

		System.assertEquals(0, customTaskSectionController.offsetSize);
		System.assertEquals(1, customTaskSectionController.startSize);
		System.assertEquals(5,customTaskSectionController.sizeOfRecordsShowing);
	}

	@isTest static void testFilterIsCompleteAndTaskIsTargetList(){
		

		Set<String> taskClosedStatusSet = new Set<String>();
		String closed = '';

		for(TaskStatus ts: [select MasterLabel from TaskStatus WHERE IsClosed=TRUE]){
			closed = ts.MasterLabel;
		    taskClosedStatusSet.add(ts.MasterLabel);
		}

		System.debug('taskClosed : '+taskClosedStatusSet);

		Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c();
		leadToDoResponse.Campaign_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
		leadToDoResponse.Response_Level_1__c = '1. Lead ไม่ถูกต้อง';
		leadToDoResponse.Response_Level_2__c = null;
		insert leadToDoResponse;
		
		Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];

		Campaign mockLeadToDo = new Campaign();
		mockLeadToDo.Lead_Campaign_Event_Code__c = 'leadToDo';
		mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
		mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
		mockLeadToDo.Lead_Campaign_Event_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
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
		
		//Task task = new Task(Subject = 'Test',WhatId = targetList.Id);
		//insert task;

		Task task = [SELECT Id, Subject, Status, IsClosed, WhatId FROM Task WHERE WhatId =: targetList.Id];
		//Test.startTest();
		//task.Status = GlobalConstants.STATUS_COMPLETED;
		//update task;
		//Test.stopTest();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
            //customTaskSectionController.initCustomTasks('Completed');
            //System.debug('task id : '+task.Id+' '+task.IsClosed+ ' '+ task.What.Type);
            customTaskSectionController.singleSelect = true;
            customTaskSectionController.taskRecordSelected = task.Id;
			customTaskSectionController.answer();

            customTaskSectionController.selectedResponse = closed;
            customTaskSectionController.submitAnswer();

            

            //System.debug('mapCustomTasksById : '+customTaskSectionController.mapCustomTasksById);

            

			//System.assertEquals(true,customTaskSectionController.mapCustomTasksById.get(task.Id).isTargetList);
        }



        //System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
        //	CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
        //    customTaskSectionController.initCustomTasks('Completed');
        //    System.assertEquals(true,customTaskSectionController.mapCustomTasksById.get(task.Id).eachTask.IsClosed);
        //}
	}

	@isTest static void testFilterIsAllOpenAndTaskIsTargetList(){
		Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];
		Campaign mockLeadToDo = new Campaign();
		Target_List__c targetList = new Target_List__c();
		
			mockLeadToDo.Lead_Campaign_Event_Code__c = 'leadToDo';
			mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
			mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
			mockLeadToDo.Name = leadToDo;
			mockLeadToDo.Status = GlobalConstants.ACTIVE;
			mockLeadToDo.IsActive = true;
			mockLeadToDo.StartDate = System.today() - 1;
			mockLeadToDo.EndDate = System.Today() + 1;
			mockLeadToDo.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
			insert mockLeadToDo;

			
			
			targetList.Lead_Campaign__c = mockLeadToDo.Id;
			targetList.CIS_ID_Prospect_Name__c = account.Id;
			targetList.Status__c = GlobalConstants.STATUS_NEW;
			insert targetList;
		

		targetList = [SELECT Id, Active_Target_List__c FROM Target_List__c WHERE Id =: targetList.Id];
		System.debug('targetlist Active_Target_List__c : '+targetlist.Active_Target_List__c);
		//System.debug('targetList Id : '+targetlist.Id);


		Test.startTest();

		Task task = [SELECT Id, Subject, Status, IsClosed, WhatId, What.Type, Lead_Sub_Type__c  FROM Task WHERE WhatId =: targetList.Id];

		System.debug('taskTGL WhatId : '+task.WhatId);
		//System.debug('tasktype : '+task.What.Type);

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
            System.debug('task id : '+task.Id+' '+task.IsClosed+ ' '+ task.What.Type);

			System.debug(customTaskSectionController.mapCustomTasksById);

			System.assertEquals(true,customTaskSectionController.mapCustomTasksById.get(task.Id).isTargetList);
        }
        Test.stopTest();
    }

    @isTest static void testClosePopup(){
    	CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
    	customTaskSectionController.displayErrorAtLeastOneRecordChecked = true;
    	customTaskSectionController.displayErrorNotSameType = true;
    	customTaskSectionController.displaySubTypePopUp = true;
    	customTaskSectionController.showErrorDate = true;
    	customTaskSectionController.showDate = true;
    	customTaskSectionController.singleSelect = true;
    	customTaskSectionController.dummyOpp.CloseDate = Date.today();

    	customTaskSectionController.closePopUp();
    	System.assertEquals(false,customTaskSectionController.displayErrorAtLeastOneRecordChecked);
    	System.assertEquals(false,customTaskSectionController.displayErrorNotSameType);
    	System.assertEquals(false,customTaskSectionController.displaySubTypePopUp);
    	System.assertEquals(false,customTaskSectionController.showErrorDate);
    	System.assertEquals(false,customTaskSectionController.showDate);
    	System.assertEquals(false,customTaskSectionController.singleSelect);
    	System.assertEquals(null,customTaskSectionController.dummyOpp.CloseDate);
    }

    @isTest static void testGetCustomTaskWithOffsetIsNull(){
    	CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
    	System.assertEquals(null,customTaskSectionController.getCustomTasksWithOffset());
    }

    @isTest static void testGetCustomTaskWithOffsetIsNotNull(){

    	Task task = new Task(Subject = 'Test');
		insert task;

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();

		List<CustomTaskSection_Controller.CustomTasks> listCustomTasks = new List<CustomTaskSection_Controller.CustomTasks>();
		listCustomTasks = customTaskSectionController.getCustomTasksWithOffset();
		
		System.assertEquals(task.Id,listCustomTasks.get(0).eachTask.Id);
	}

	@isTest static void testGetCustomTaskWithOffsetAndTaskGreaterThanMaxIndex(){

    	List<Task> taskListToInsert = new List<Task>();
		for(Integer i=0; i<16;i++){
			Task eachTask = new Task(Subject = 'Test'+i);
			taskListToInsert.add(eachTask);
		}
		insert taskListToInsert;

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();

		List<CustomTaskSection_Controller.CustomTasks> listCustomTasks = new List<CustomTaskSection_Controller.CustomTasks>();
		listCustomTasks = customTaskSectionController.getCustomTasksWithOffset();
		
		System.assertEquals(15,customTaskSectionController.sizeOfRecordsShowing);
	}

	@isTest static void testAnswerNotSingleSelectAndNoneChecked(){

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){


			Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];

			Campaign mockLeadToDo = new Campaign();
			mockLeadToDo.Lead_Campaign_Event_Code__c = 'leadToDo';
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

			Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c(Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM, Required_Date__c = false, Response_Level_1__c = 'Test');
			insert leadToDoResponse;

			Task task = [SELECT Id, Subject, Status, IsClosed, WhatId, What.Type, Lead_Sub_Type__c FROM Task WHERE WhatId =: targetList.Id];
			

            CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
            customTaskSectionController.singleSelect = false;
            customTaskSectionController.taskRecordSelected = task.Id;
            customTaskSectionController.mapCustomTasksById.get(task.Id).isChecked = false;
            customTaskSectionController.answer();

            System.assertEquals(true, customTaskSectionController.displayErrorAtLeastOneRecordChecked);
        }
	}

	@isTest static void testAnswerNotSingleSelectAndAtLeastOneChecked(){

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){


			Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];

			Campaign mockLeadToDo = new Campaign();
			mockLeadToDo.Lead_Campaign_Event_Code__c = 'leadToDo';
			mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
			mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
			mockLeadToDo.Lead_Campaign_Event_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
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

			Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c(Campaign_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM, Required_Date__c = false, Response_Level_1__c = 'Test');
			insert leadToDoResponse;

			Task task = [SELECT Id, Subject, Status, IsClosed, WhatId, What.Type, Lead_Sub_Type__c FROM Task WHERE WhatId =: targetList.Id];
			

            CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
            customTaskSectionController.singleSelect = false;
            customTaskSectionController.taskRecordSelected = task.Id;
            customTaskSectionController.mapCustomTasksById.get(task.Id).isChecked = true;
            customTaskSectionController.answer();

            System.assertEquals(true, customTaskSectionController.displaySubTypePopUp);
            System.assertEquals(true,customTaskSectionController.sameTypeCheck);
            
        }
	}

	@isTest static void testAnswerNotSingleSelectAndAtLeastOneCheckedAndNotSameType(){

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];

			List<Campaign> leadToDoList = new List<Campaign>();
			

			Campaign mockLeadToDoInform = new Campaign();
			mockLeadToDoInform.Lead_Campaign_Event_Code__c = 'leadToDoInform';
			mockLeadToDoInform.Type__c = GlobalConstants.LEAD_TO_DO;
			mockLeadToDoInform.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
			mockLeadToDoInform.Name = leadToDo;
			mockLeadToDoInform.Status = GlobalConstants.ACTIVE;
			mockLeadToDoInform.IsActive = true;
			mockLeadToDoInform.StartDate = System.today() - 1;
			mockLeadToDoInform.EndDate = System.Today() + 1;
			mockLeadToDoInform.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
			leadToDoList.add(mockLeadToDoInform);

			Campaign mockLeadToDoFollowUp = new Campaign();
			mockLeadToDoFollowUp.Lead_Campaign_Event_Code__c = 'leadToDoFollowUp';
			mockLeadToDoFollowUp.Type__c = GlobalConstants.LEAD_TO_DO;
			mockLeadToDoFollowUp.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_FOLLOW_UP_RM;
			mockLeadToDoFollowUp.Name = leadToDo;
			mockLeadToDoFollowUp.Status = GlobalConstants.ACTIVE;
			mockLeadToDoFollowUp.IsActive = true;
			mockLeadToDoFollowUp.StartDate = System.today() - 1;
			mockLeadToDoFollowUp.EndDate = System.Today() + 1;
			mockLeadToDoFollowUp.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
			leadToDoList.add(mockLeadToDoFollowUp);

			insert leadToDoList;

			List<Target_List__c> targetListToDo = new List<Target_List__c>();

			Target_List__c targetListInform = new Target_List__c();
			targetListInform.Lead_Campaign__c = mockLeadToDoInform.Id;
			targetListInform.CIS_ID_Prospect_Name__c = account.Id;
			targetListInform.Status__c = GlobalConstants.STATUS_NEW;
			targetListToDo.add(targetListInform);

			Target_List__c targetListFollowUp = new Target_List__c();
			targetListFollowUp.Lead_Campaign__c = mockLeadToDoFollowUp.Id;
			targetListFollowUp.CIS_ID_Prospect_Name__c = account.Id;
			targetListFollowUp.Status__c = GlobalConstants.STATUS_NEW;
			targetListToDo.add(targetListFollowUp);

			insert targetListToDo;

			//Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c(Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM, Required_Date__c = false, Response_Level_1__c = 'Test');
			//insert leadToDoResponse;

			Task taskInform = [SELECT Id, Subject, Status, IsClosed, WhatId, What.Type, Lead_Sub_Type__c FROM Task WHERE WhatId =: targetListInform.Id];
			Task taskFollowUp = [SELECT Id, Subject, Status, IsClosed, WhatId, What.Type, Lead_Sub_Type__c FROM Task WHERE WhatId =: targetListFollowUp.Id];
			

            CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
            customTaskSectionController.singleSelect = false;
            customTaskSectionController.mapCustomTasksById.get(taskInform.Id).isChecked = true;
            customTaskSectionController.mapCustomTasksById.get(taskFollowUp.Id).isChecked = true;
            customTaskSectionController.answer();

            System.assertEquals(false,customTaskSectionController.sameTypeCheck);

            System.assertEquals(true, customTaskSectionController.displayErrorNotSameType);
            
            
        }
	}

	@isTest static void testSubmitAnswerNotSingleSelectShowDateFalse(){
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];

			Campaign mockLeadToDo = new Campaign();
			mockLeadToDo.Lead_Campaign_Event_Code__c = 'leadToDo';
			mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
			mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
			mockLeadToDo.Lead_Campaign_Event_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
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

			Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c(Campaign_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM, Required_Date__c = false, Response_Level_1__c = 'Test');
			insert leadToDoResponse;

			Task task = [SELECT Id, Subject, Status, IsClosed, WhatId, What.Type, Lead_Sub_Type__c FROM Task WHERE WhatId =: targetList.Id];
			

            CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
            customTaskSectionController.singleSelect = false;
            customTaskSectionController.mapCustomTasksById.get(task.Id).isChecked = true;
            customTaskSectionController.answer();
            customTaskSectionController.checkShowDate();

            System.assertEquals(true, customTaskSectionController.displaySubTypePopUp);
            System.assertEquals(leadToDoResponse.Response_Level_1__c,customTaskSectionController.selectedResponse);
            System.assertEquals(leadToDoResponse.Required_Date__c,customTaskSectionController.showDate);

            customTaskSectionController.submitAnswer();

            System.assertEquals(false, customTaskSectionController.displaySubTypePopUp);

        }
	}

	@isTest static void testSubmitAnswerNotSingleSelectShowDateTrueAndDummyOppCloseDateIsNull(){
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];

			Campaign mockLeadToDo = new Campaign();
			mockLeadToDo.Lead_Campaign_Event_Code__c = 'leadToDo';
			mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
			mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
			mockLeadToDo.Lead_Campaign_Event_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
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

			Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c(Campaign_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM, Required_Date__c = true, Response_Level_1__c = 'Test');
			insert leadToDoResponse;

			Task task = [SELECT Id, Subject, Status, IsClosed, WhatId, What.Type, Lead_Sub_Type__c FROM Task WHERE WhatId =: targetList.Id];
			

            CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
            customTaskSectionController.singleSelect = false;
            customTaskSectionController.mapCustomTasksById.get(task.Id).isChecked = true;
            customTaskSectionController.answer();
            customTaskSectionController.checkShowDate();

            customTaskSectionController.submitAnswer();

            System.assertEquals(true, customTaskSectionController.showErrorDate);

        }
	}

	@isTest static void testSubmitAnswerNotSingleSelectShowDateTrueAndDummyOppCloseDateIsNotNull(){
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];

			Campaign mockLeadToDo = new Campaign();
			mockLeadToDo.Lead_Campaign_Event_Code__c = 'leadToDo';
			mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
			mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
			mockLeadToDo.Lead_Campaign_Event_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
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

			Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c(Campaign_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM, Required_Date__c = true, Response_Level_1__c = 'Test');
			insert leadToDoResponse;

			Task task = [SELECT Id, Subject, Status, IsClosed, WhatId, What.Type, Lead_Sub_Type__c FROM Task WHERE WhatId =: targetList.Id];
			

            CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
            customTaskSectionController.singleSelect = false;
            customTaskSectionController.mapCustomTasksById.get(task.Id).isChecked = true;
            customTaskSectionController.answer();
            customTaskSectionController.checkShowDate();

            customTaskSectionController.dummyOpp.CloseDate = Date.today();

            customTaskSectionController.submitAnswer();

            System.assertEquals(Date.today(), customTaskSectionController.mapCustomTasksById.get(task.Id).eachTask.Answered_Date__c);

        }
	}



	@isTest static void testAnswerSingleSelect(){

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){


			Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];

			Campaign mockLeadToDo = new Campaign();
			mockLeadToDo.Lead_Campaign_Event_Code__c = 'leadToDo';
			mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
			mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
			mockLeadToDo.Lead_Campaign_Event_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
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

			Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c(Campaign_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM, Required_Date__c = false, Response_Level_1__c = 'Test');
			insert leadToDoResponse;

			Task task = [SELECT Id, Subject, Status, IsClosed, WhatId, What.Type, Lead_Sub_Type__c FROM Task WHERE WhatId =: targetList.Id];
			

            CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
            customTaskSectionController.singleSelect = true;
            customTaskSectionController.taskRecordSelected = task.Id;
            customTaskSectionController.answer();

            System.assertEquals(true, customTaskSectionController.displaySubTypePopUp);
            System.assertEquals(leadToDoResponse.Response_Level_1__c,customTaskSectionController.selectedResponse);
            System.assertEquals(leadToDoResponse.Required_Date__c,customTaskSectionController.showDate);
        }
	}

	@isTest static void testSubmitAnswerSingleSelectShowDateFalse(){
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];

			Campaign mockLeadToDo = new Campaign();
			mockLeadToDo.Lead_Campaign_Event_Code__c = 'leadToDo';
			mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
			mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
			mockLeadToDo.Lead_Campaign_Event_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
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

			Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c(Campaign_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM, Required_Date__c = false, Response_Level_1__c = 'Test');
			insert leadToDoResponse;

			Task task = [SELECT Id, Subject, Status, IsClosed, WhatId, What.Type, Lead_Sub_Type__c FROM Task WHERE WhatId =: targetList.Id];
			

            CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
            customTaskSectionController.singleSelect = true;
            customTaskSectionController.taskRecordSelected = task.Id;
            customTaskSectionController.answer();
            customTaskSectionController.checkShowDate();

            System.assertEquals(true, customTaskSectionController.displaySubTypePopUp);
            System.assertEquals(leadToDoResponse.Response_Level_1__c,customTaskSectionController.selectedResponse);
            System.assertEquals(leadToDoResponse.Required_Date__c,customTaskSectionController.showDate);

            customTaskSectionController.submitAnswer();

            System.assertEquals(false, customTaskSectionController.displaySubTypePopUp);

        }
	}

	@isTest static void testSubmitAnswerSingleSelectShowDateTrueDummyOppDateIsNull(){
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];

			Campaign mockLeadToDo = new Campaign();
			mockLeadToDo.Lead_Campaign_Event_Code__c = 'leadToDo';
			mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
			mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
			mockLeadToDo.Lead_Campaign_Event_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
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

			Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c(Campaign_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM, Required_Date__c = true, Response_Level_1__c = 'Test');
			insert leadToDoResponse;

			Task task = [SELECT Id, Subject, Status, IsClosed, WhatId, What.Type, Lead_Sub_Type__c FROM Task WHERE WhatId =: targetList.Id];
			

            CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
            customTaskSectionController.singleSelect = true;
            customTaskSectionController.taskRecordSelected = task.Id;
            customTaskSectionController.answer();
            customTaskSectionController.checkShowDate();

            System.assertEquals(true, customTaskSectionController.displaySubTypePopUp);
            System.assertEquals(leadToDoResponse.Response_Level_1__c,customTaskSectionController.selectedResponse);
            System.assertEquals(leadToDoResponse.Required_Date__c,customTaskSectionController.showDate);

            customTaskSectionController.submitAnswer();

            System.assertEquals(true, customTaskSectionController.showErrorDate);

        }
	}

	@isTest static void testSubmitAnswerSingleSelectShowDateTrueDummyOppDateIsNotNull(){
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account account = [SELECT Id, CIS__c FROM Account WHERE Name =: accountNameRM];

			Campaign mockLeadToDo = new Campaign();
			mockLeadToDo.Lead_Campaign_Event_Code__c = 'leadToDo';
			mockLeadToDo.Type__c = GlobalConstants.LEAD_TO_DO;
			mockLeadToDo.Sub_Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
			mockLeadToDo.Lead_Campaign_Event_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM;
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

			Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c(Campaign_Code__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM, Required_Date__c = true, Response_Level_1__c = 'Test');
			insert leadToDoResponse;

			Task task = [SELECT Id, Subject, Status, IsClosed, WhatId, What.Type, Lead_Sub_Type__c FROM Task WHERE WhatId =: targetList.Id];
			

            CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
            customTaskSectionController.singleSelect = true;
            customTaskSectionController.taskRecordSelected = task.Id;
            customTaskSectionController.answer();
            customTaskSectionController.checkShowDate();

   			customTaskSectionController.dummyOpp.CloseDate = Date.today();

            customTaskSectionController.submitAnswer();

            System.assertEquals(Date.today(), customTaskSectionController.mapCustomTasksById.get(task.Id).eachTask.Answered_Date__c);

        }
	}

	@isTest static void testResponseOptions(){
		Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c(Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM, Required_Date__c = false, Response_Level_1__c = 'Test');
		insert leadToDoResponse;

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.leadToDoResponseList.add(leadToDoResponse);
		customTaskSectionController.setResponseOptions();

		System.assertEquals(leadToDoResponse.Response_Level_1__c,customTaskSectionController.selectedResponse);
	}

	@isTest static void testShowDateTrue(){
		Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c(Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM, Required_Date__c = true, Response_Level_1__c = 'Test');
		insert leadToDoResponse;

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.leadToDoResponseList.add(leadToDoResponse);
		customTaskSectionController.setResponseOptions();
		customTaskSectionController.checkShowDate();

		System.assertEquals(leadToDoResponse.Required_Date__c,customTaskSectionController.showDate);
	}

	@isTest static void testShowDateFalse(){
		Lead_To_Do_Response__c leadToDoResponse = new Lead_To_Do_Response__c(Type__c = GlobalConstants.LEAD_SUB_TYPE_TO_INFORM, Required_Date__c = false, Response_Level_1__c = 'Test');
		insert leadToDoResponse;

		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		customTaskSectionController.leadToDoResponseList.add(leadToDoResponse);
		customTaskSectionController.setResponseOptions();
		customTaskSectionController.checkShowDate();

		System.assertEquals(leadToDoResponse.Required_Date__c,customTaskSectionController.showDate);
	}

	@isTest static void testShowMemo(){
		CustomTaskSection_Controller customTaskSectionController = new CustomTaskSection_Controller();
		
		System.assertEquals(false,customTaskSectionController.showMemo);

		customTaskSectionController.showMemoInput();

		System.assertEquals(true,customTaskSectionController.showMemo);
	}
}