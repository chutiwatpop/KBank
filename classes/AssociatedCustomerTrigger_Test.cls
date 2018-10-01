@isTest
private class AssociatedCustomerTrigger_Test {
	public static final String accountNameTM = 'accountNameTM';
	public static final String accountNameRM = 'accountNameRM';
	public static Map<String, Id> recordTypeIdMapByDevName;

	@testSetup static void setupAccount(){
		Test.startTest();
		TriggerHandler.bypass('UserTriggerHandler');
		Mockup_Test mt = new Mockup_Test().setUpTestAdmin().setUpTestWithExtension();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        TriggerHandler.clearBypass('UserTriggerHandler');
        Test.stopTest();
	}

	public static Id getRecordTypeIdMapByDevName(String devName){
		if(AssociatedCustomerTrigger_Test.recordTypeIdMapByDevName == null) {
			AssociatedCustomerTrigger_Test.recordTypeIdMapByDevName = new Map<String, Id>();
			AssociatedCustomerTrigger_Test.recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Call_Report__c');
		}
		return AssociatedCustomerTrigger_Test.recordTypeIdMapByDevName.get(devName);
	}

	public static Campaign mockCreateCampaign(String campaignName, String campaignType, Boolean campaignIsActive, String campaignStatus){
		Campaign mockCampaign = new Campaign();
		mockCampaign.Lead_Campaign_Event_Code__c = campaignName;
		mockCampaign.Type__c = campaignType;
		mockCampaign.Name = campaignName;
		mockCampaign.Status = campaignStatus;

		if(campaignIsActive || campaignStatus == GlobalConstants.ACTIVE) {
        	mockCampaign.IsActive = true;
        	mockCampaign.StartDate = System.today() - 1;
        } else {
        	mockCampaign.IsActive = false;
        	mockCampaign.StartDate = System.today() + 1;
        }
        mockCampaign.Add_Associated_Lead__c = true;
		mockCampaign.EndDate = System.Today() + 1;
		mockCampaign.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_REC);
		return mockCampaign;
	}

	public static Target_List__c mockCreateTargerList(String accountId, String campaignId){
		Target_List__c eachTargetList = new Target_List__c();
		eachTargetList.CIS_ID_Prospect_Name__c = accountId;
		eachTargetList.Lead_Campaign__c = campaignId;
		eachTargetList.Status__c = GlobalConstants.STATUS_NEW;
		return eachTargetList;
	}

	public static Map<String,String> mockDataForNewCallReport (String campaignType, Boolean campaignIsActive, Boolean hasTargetList, String campaignStatus){
		Map<String,String> resultIdMap = new Map<String,String>();
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :AssociatedCustomerTrigger_Test.accountNameTM LIMIT 1];
		resultIdMap.put('accountId',targetAccount.Id);

		Campaign mockCampaign = mockCreateCampaign('Lead1', campaignType,campaignIsActive,campaignStatus);
		insert mockCampaign;
		resultIdMap.put('campaignId',mockCampaign.Id);

		if(hasTargetList){
			Target_List__c eachTargetList = mockCreateTargerList(targetAccount.Id,mockCampaign.Id);
			insert eachTargetList;
			resultIdMap.put('targetListId',eachTargetList.Id);
		}		

		Contact mockContact = new Contact(
            	LastName = 'lastname',
				Contact_Firstname__c = 'Firstname',
				AccountId = targetAccount.Id,
				Phone_Number__c = '023450789'
            );
		insert mockContact;
		resultIdMap.put('contactId',mockContact.Id);
		return resultIdMap;
	}

	public static Call_Report__c mockCallReportBeforeCreate (Map<String,String> mockIdMap){
		Call_Report__c callReport = new Call_Report__c(
                CIS_ID__c = mockIdMap.get('accountId'),
                Status__c = GlobalConstants.CONTACTED,
                Actual_Visit_Date__c = Date.today()-1,
                Contact_Channel__c = 'Phone Call',
                Contact__c = mockIdMap.get('contactId'),
                Expected_Credit_Amount__c = 500000,
                RecordtypeId = getRecordTypeIdMapByDevName(GlobalConstants.CALL_REPORT_DEVNAME)
            );
		return callReport;
	}

	public static Call_Report__c mockCallPlanBeforeCreate (String accountId){
		Call_Report__c callPlan = new Call_Report__c(
			RecordTypeId = getRecordTypeIdMapByDevName(GlobalConstants.NEW_CALL_PLAN_DEVNAME),
			CIS_ID__c = accountId,
			Status__c = GlobalConstants.PLAN,
			Plan_Date__c = System.Today()
		);
		return callPlan;
	}

	//@isTest static void testInsertAssociatedCustomerRecordTypeInterestedAndBowwerTypeEqualCoBowwerThenInsertCallReportInterest() {
	//	Id recordType = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Associated_Customer__c','Interested');
	//	Account tmAccount = [SELECT Id FROM Account WHERE Name = :accountNameTM];
	//	Account rmAccount = [SELECT Id FROM Account WHERE Name = :accountNameRM];

	//	Call_Report__c callReport = new Call_Report__c(
	//		CIS_ID__c = tmAccount.Id
	//	);
	//	insert callReport;

	//	Associated_Customer__c assoCus = new Associated_Customer__c(
	//		RecordTypeId = recordType,
	//		Associated_Customer_Type__c = 'Interested',
	//		Borrower_Type__c = 'Co Borrower',
	//		Call_Plan_Call_Report__c = callReport.Id,
	//		Customer__c = rmAccount.Id
	//	);

	//	Test.startTest();
	//		insert assoCus;
	//	Test.stopTest();

	//	Associated_Customer__c assoCusResult = [SELECT Id,Secondary_Call_Plan_Call_Report__c FROM Associated_Customer__c WHERE Id = :assoCus.Id];
	//	Call_Report__c callReportResult = [SELECT Id,Offer_Interest__c FROM Call_Report__c WHERE CIS_ID__c = :rmAccount.Id];

	//	System.assertNotEquals(null,callReportResult.Id);
	//	System.assertEquals('Interest and can apply',callReportResult.Offer_Interest__c);
		
	//	System.assertEquals(assoCusResult.Secondary_Call_Plan_Call_Report__c,callReportResult.Id);
	//}
	
	//@isTest static void testInsertAssociatedCustomerRecordTypeNotInterestedAndBowwerTypeEqualCoBowwerThenInsertCallReportNotInterest() {
	//	Id recordType = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Associated_Customer__c','Not_Interested');
	//	Account tmAccount = [SELECT Id FROM Account WHERE Name = :accountNameTM];
	//	Account rmAccount = [SELECT Id FROM Account WHERE Name = :accountNameRM];

	//	Call_Report__c callReport = new Call_Report__c(
	//		CIS_ID__c = tmAccount.Id
	//	);
	//	insert callReport;

	//	Associated_Customer__c assoCus = new Associated_Customer__c(
	//		RecordTypeId = recordType,
	//		Associated_Customer_Type__c = 'Not Interest',
	//		Borrower_Type__c = 'Co Borrower',
	//		Call_Plan_Call_Report__c = callReport.Id,
	//		Customer__c = rmAccount.Id
	//	);

	//	Test.startTest();
	//		insert assoCus;
	//	Test.stopTest();

	//	Associated_Customer__c assoCusResult = [SELECT Id,Secondary_Call_Plan_Call_Report__c FROM Associated_Customer__c WHERE Id = :assoCus.Id];
	//	Call_Report__c callReportResult = [SELECT Id,Offer_Interest__c FROM Call_Report__c WHERE CIS_ID__c = :rmAccount.Id];

	//	System.assertNotEquals(null,callReportResult.Id);
	//	System.assertEquals('Not interest',callReportResult.Offer_Interest__c);
		
	//	System.assertEquals(assoCusResult.Secondary_Call_Plan_Call_Report__c,callReportResult.Id);
	//}
	
	@isTest static void testCreateCampaignInsertAssociatedInterestedAndCoBorrowwerThenInsertCallReportInterest() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		TriggerHandler.bypass('CampaignTriggerHandler');
		TriggerHandler.bypass('TargetListTriggerHandler');
		TriggerHandler.bypass('ContactTriggerHandler');
		mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		TriggerHandler.clearAllBypasses();	

		Id recordType = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Associated_Customer__c','Interested');
		Account rmAccount = [SELECT Id FROM Account WHERE Name = :accountNameRM];

		Call_Report__c callReport = mockCallPlanBeforeCreate(mockIdMap.get('accountId'));
		insert callReport;

		Associated_Customer__c assoCus = new Associated_Customer__c(
			RecordTypeId = recordType,
			Associated_Customer_Type__c = 'Interested',
			Borrower_Type__c = 'Co Borrower',
			Call_Plan_Call_Report__c = callReport.Id,
			Customer__c = rmAccount.Id
		);

		Test.startTest();
			insert assoCus;
		Test.stopTest();

		Associated_Customer__c assoCusResult = [SELECT Id,Secondary_Call_Plan_Call_Report__c FROM Associated_Customer__c WHERE Id = :assoCus.Id];
		Call_Report__c callReportResult = [SELECT Id,Offer_Interest__c FROM Call_Report__c WHERE CIS_ID__c = :rmAccount.Id];

		System.assertNotEquals(null,callReportResult.Id);
		System.assertEquals('Interest and can apply',callReportResult.Offer_Interest__c);
		
		System.assertEquals(assoCusResult.Secondary_Call_Plan_Call_Report__c,callReportResult.Id);
		System.assertEquals(1,[SELECT Count() FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :rmAccount.Id]);
		System.assertEquals(1,[SELECT Count() FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReportResult.Id]);
		Call_Report_Lead__c resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReportResult.Id LIMIT 1];
		System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED, resultLead.Call_Report_Lead_Status__c);
	}
	
	@isTest static void testCreateCampaignInsertAssociatedRecordTypeNotInterestedAndCoBorrowwerThenInsertCallReportNotInterest() {
		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		TriggerHandler.bypass('CampaignTriggerHandler');
		TriggerHandler.bypass('TargetListTriggerHandler');
		TriggerHandler.bypass('ContactTriggerHandler');
		mockIdMap = mockDataForNewCallReport(GlobalConstants.LEAD_FOR_SALES,campaignIsActive,hasTargetList,campaignStatus);
		TriggerHandler.clearAllBypasses();	

		Id recordType = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Associated_Customer__c','Not_Interested');
		Account rmAccount = [SELECT Id FROM Account WHERE Name = :accountNameRM];

		Call_Report__c callReport = mockCallPlanBeforeCreate(mockIdMap.get('accountId'));
		insert callReport;

		Associated_Customer__c assoCus = new Associated_Customer__c(
			RecordTypeId = recordType,
			Associated_Customer_Type__c = 'Not Interest',
			Borrower_Type__c = 'Co Borrower',
			Call_Plan_Call_Report__c = callReport.Id,
			Customer__c = rmAccount.Id
		);

		Test.startTest();
			insert assoCus;
		Test.stopTest();

		Associated_Customer__c assoCusResult = [SELECT Id,Secondary_Call_Plan_Call_Report__c FROM Associated_Customer__c WHERE Id = :assoCus.Id];
		Call_Report__c callReportResult = [SELECT Id,Offer_Interest__c FROM Call_Report__c WHERE CIS_ID__c = :rmAccount.Id];

		System.assertNotEquals(null,callReportResult.Id);
		System.assertEquals('Not interest',callReportResult.Offer_Interest__c);
		
		System.assertEquals(assoCusResult.Secondary_Call_Plan_Call_Report__c,callReportResult.Id);
		System.assertEquals(1,[SELECT Count() FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :rmAccount.Id]);
		System.assertEquals(1,[SELECT Count() FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReportResult.Id]);
		Call_Report_Lead__c resultLead = [SELECT Id, Target_List__c, Status__c, Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callReportResult.Id LIMIT 1];
		System.assertEquals(GlobalConstants.NOT_INTERESTED, resultLead.Call_Report_Lead_Status__c);
	}
}