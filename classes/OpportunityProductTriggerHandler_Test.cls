@isTest
private class OpportunityProductTriggerHandler_Test
{
	private static final String accountNameRM = 'accountNameRM';
	private static final String oppName = 'Test Opp 1';
	private static final String FOR_SALE_CALL_REPORT = 'เพื่อขาย';

	@testSetup static void setupMockData(){
		Mockup_Test mt = new Mockup_Test().setUpTestWithExtension();
		User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		
		List<User_Extension__c> userextList  = [SELECT Id,User__r.Name FROM User_Extension__c];
		System.runAs(rmUser){
			mt.newAccount(accountNameRM,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
		}

		Opportunity newOpp;
		Account account = Mockup_Test.getFirstAccountFromName(accountNameRM, 'Id,Name,CIS__c');
		System.runAs(rmUser){
			Test.startTest();
			newOpp = Mockup_Test.newOpportunity(account.Id, oppName, GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
			insert newOpp;
			// Mock Call Report
			Event newEvent = new Event(
				WhatId = newOpp.Id,
				OwnerId = UserInfo.getUserId(),
				StartDateTime = System.now(),
				EndDateTime = System.now().addDays(7),
				Subject = 'Call report',
				RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME),
				Status__c = 'Contacted'
			);
			insert newEvent;
			Test.stopTest();
		}

		PriceBook2 priceBook2 = new PriceBook2(
			Name = 'Standard Price Book'
		);
		insert priceBook2;
		Product2 product2 = new Product2(
			Name = 'Product2'
		);
		insert product2;
		Id pricebookId = Test.getStandardPricebookId();
		PricebookEntry standardPrice = new PricebookEntry(
			Pricebook2Id = pricebookId, 
			Product2Id = product2.Id, 
			UnitPrice = 10, 
			UseStandardPrice = false,
			IsActive = true
		);
        insert standardPrice;
		PriceBookEntry priceBook = new PriceBookEntry(
			UnitPrice = 1,
			PriceBook2Id = priceBook2.Id,
			Product2Id = product2.Id,
			UseStandardPrice = false,
			IsActive = true
		);
		insert priceBook;
	}

	@isTest
	static void itShouldStampDataNotForSaleItemWhenOppProductCreated()
	{
		// Given
		Opportunity jobItem = [SELECT Id, Name FROM Opportunity LIMIT 1];
		PriceBookEntry priceBook = [SELECT Id FROM PriceBookEntry LIMIT 1];
		OpportunityLineItem oppProduct = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Quantity = 1,
			TotalPrice = 100
		);
		// When
		insert oppProduct;

		// Then
		Event callReport = [SELECT Id, StartDateTime, Subject FROM Event LIMIT 1];
		OpportunityLineItem oppProductInfo = [SELECT Id, Report_Latest_Actual_Visit_Date__c, Report_Latest_Call_Report_ID__c, Report_Latest_Call_Report_Name__c FROM OpportunityLineItem LIMIT 1];
		System.assertEquals(callReport.StartDateTime.date(), oppProductInfo.Report_Latest_Actual_Visit_Date__c);
		System.assertEquals(callReport.Id, oppProductInfo.Report_Latest_Call_Report_ID__c);
		System.assertEquals(callReport.Subject, oppProductInfo.Report_Latest_Call_Report_Name__c);
	}

	@isTest
	static void itShouldStampDataLatestNotForSaleItemWhenOppProductCreated()
	{
		// Given
		Opportunity jobItem = [SELECT Id, Name FROM Opportunity LIMIT 1];
		PriceBookEntry priceBook = [SELECT Id FROM PriceBookEntry LIMIT 1];
		Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = :oppName LIMIT 1];
		User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			Event newEvent = new Event(
				WhatId = opp.Id,
				OwnerId = UserInfo.getUserId(),
				StartDateTime = System.now(),
				EndDateTime = System.now().addDays(7),
				Subject = 'Call report 2',
				RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME),
				Status__c = 'Contacted'
			);
			insert newEvent;
			Test.setCreatedDate(newEvent.Id, System.now().addMinutes(1));
		}
		OpportunityLineItem oppProduct = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Quantity = 1,
			TotalPrice = 100
		);
		// When
		insert oppProduct;

		// Then
		Event callReport = [SELECT Id, StartDateTime, Subject FROM Event WHERE Subject = 'Call report 2' LIMIT 1];
		OpportunityLineItem oppProductInfo = [SELECT Id, Report_Latest_Actual_Visit_Date__c, Report_Latest_Call_Report_ID__c, Report_Latest_Call_Report_Name__c FROM OpportunityLineItem LIMIT 1];
		System.assertEquals(callReport.StartDateTime.date(), oppProductInfo.Report_Latest_Actual_Visit_Date__c);
		System.assertEquals(callReport.Id, oppProductInfo.Report_Latest_Call_Report_ID__c);
		System.assertEquals(callReport.Subject, oppProductInfo.Report_Latest_Call_Report_Name__c);
	}

	@isTest
	static void itShouldStampDataForSaleItemWhenOppProductCreated()
	{
		// Given
		Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = :oppName LIMIT 1];
		// Mock Call Report for sale
		Event newEvent = new Event(
			WhatId = opp.Id,
			OwnerId = UserInfo.getUserId(),
			StartDateTime = System.now(),
			EndDateTime = System.now().addDays(7),
			Subject = 'Call report for sale 1',
			RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME),
			Visit_Objective__c = GlobalConstants.CALL_REPORT_FOR_SALE,
			Status__c = 'Contacted'
		);
		insert newEvent;
		Opportunity jobItem = [SELECT Id, Name FROM Opportunity LIMIT 1];
		PriceBookEntry priceBook = [SELECT Id FROM PriceBookEntry LIMIT 1];
		OpportunityLineItem oppProduct = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Quantity = 1,
			TotalPrice = 100
		);
		// When
		insert oppProduct;

		// Then
		Event callReport = [SELECT Id, StartDateTime, Subject FROM Event WHERE Subject = 'Call report for sale 1' LIMIT 1];
		OpportunityLineItem oppProductInfo = [SELECT Id, Report_Latest_Actual_Visit_Date_Sales__c, Report_Latest_Call_Report_ID_Sales__c, Report_Latest_Call_Report_Name_Sales__c FROM OpportunityLineItem LIMIT 1];
		System.assertEquals(callReport.StartDateTime.date(), oppProductInfo.Report_Latest_Actual_Visit_Date_Sales__c);
		System.assertEquals(callReport.Id, oppProductInfo.Report_Latest_Call_Report_ID_Sales__c);
		System.assertEquals(callReport.Subject, oppProductInfo.Report_Latest_Call_Report_Name_Sales__c);
	}

	@isTest
	static void itShouldStampDataLatestForSaleItemWhenOppProductCreated()
	{
		// Given
		Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = :oppName LIMIT 1];
		// Mock Call Report for sale
		User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		Test.startTest();
		System.runAs(rmUser){
			Event newEvent = new Event(
				WhatId = opp.Id,
				OwnerId = UserInfo.getUserId(),
				StartDateTime = System.now(),
				EndDateTime = System.now().addDays(7),
				Subject = 'Call report for sale 1',
				RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME),
				Visit_Objective__c = GlobalConstants.CALL_REPORT_FOR_SALE,
				Status__c = 'Contacted'
			);
			insert newEvent;
		}
		System.runAs(rmUser){
			Event newEvent = new Event(
				WhatId = opp.Id,
				OwnerId = UserInfo.getUserId(),
				StartDateTime = System.now(),
				EndDateTime = System.now().addDays(7),
				Subject = 'Call report for sale 2',
				RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME),
				Visit_Objective__c = GlobalConstants.CALL_REPORT_FOR_SALE,
				Status__c = 'Contacted'
			);
			insert newEvent;
		}		
		Test.stopTest();
		Opportunity jobItem = [SELECT Id, Name FROM Opportunity LIMIT 1];
		PriceBookEntry priceBook = [SELECT Id FROM PriceBookEntry LIMIT 1];
		OpportunityLineItem oppProduct = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Quantity = 1,
			TotalPrice = 100
		);
		// When
		insert oppProduct;

		// Then
		Event callReport = [SELECT Id, StartDateTime, Subject FROM Event WHERE Subject = 'Call report for sale 2' LIMIT 1];
		OpportunityLineItem oppProductInfo = [SELECT Id, Report_Latest_Actual_Visit_Date_Sales__c, Report_Latest_Call_Report_ID_Sales__c, Report_Latest_Call_Report_Name_Sales__c FROM OpportunityLineItem LIMIT 1];
		System.assertEquals(callReport.StartDateTime.date(), oppProductInfo.Report_Latest_Actual_Visit_Date_Sales__c);
		//System.assertEquals(callReport.Id, oppProductInfo.Report_Latest_Call_Report_ID_Sales__c);
		//System.assertEquals(callReport.Subject, oppProductInfo.Report_Latest_Call_Report_Name_Sales__c);
	}

	@isTest
	static void itShouldStampActualVisitDateWhenOppProductCreated()
	{
		// Given
		Opportunity jobItem = [SELECT Id, Name FROM Opportunity LIMIT 1];
		PriceBookEntry priceBook = [SELECT Id FROM PriceBookEntry LIMIT 1];
		Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = :oppName LIMIT 1];
		User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			Event newEvent = new Event(
				WhatId = opp.Id,
				Job__c = opp.Id,
				OwnerId = UserInfo.getUserId(),
				StartDateTime = System.now(),
				EndDateTime = System.now().addDays(7),
				Subject = 'Call report 2',
				RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME),
				Status__c = 'Contacted'
			);
			insert newEvent;
		}
			Test.startTest();
			Application_History__c appHis = Mockup_Test.newApplicationHistory(opp.Id, '111222', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
			insert appHis;
			Test.stopTest();

		OpportunityLineItem oppProduct = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Application__c = appHis.Id,
			Quantity = 1,
			TotalPrice = 100
		);
		// When
		insert oppProduct;

		// Then
		Event callReport = [SELECT Id, StartDateTime, Subject FROM Event WHERE Subject = 'Call report 2' LIMIT 1];
		OpportunityLineItem oppProductInfo = [SELECT Id, Application__r.Report_Actual_Visit_Date__c, Report_Latest_Actual_Visit_Date__c, Report_Latest_Call_Report_ID__c, Report_Latest_Call_Report_Name__c FROM OpportunityLineItem LIMIT 1];
		System.assertEquals(callReport.StartDateTime.date(), oppProductInfo.Report_Latest_Actual_Visit_Date__c);
		System.assertEquals(callReport.Id, oppProductInfo.Report_Latest_Call_Report_ID__c);
		System.assertEquals(callReport.Subject, oppProductInfo.Report_Latest_Call_Report_Name__c);
		System.assertEquals(oppProductInfo.Report_Latest_Actual_Visit_Date__c, oppProductInfo.Application__r.Report_Actual_Visit_Date__c);
	}

	@isTest
	static void itShouldStampOlderActualVisitDateWhenOppProductCreatedAndHaveTwoApp()
	{
		// Given		
		Opportunity jobItem = [SELECT Id, Name FROM Opportunity LIMIT 1];
		PriceBookEntry priceBook = [SELECT Id FROM PriceBookEntry LIMIT 1];
		Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = :oppName LIMIT 1];
		Test.startTest();
		Event newEvent = new Event(
			WhatId = opp.Id,
			Job__c = opp.Id,
			OwnerId = UserInfo.getUserId(),
			StartDateTime = System.now(),
			EndDateTime = System.now().addDays(7),
			Subject = 'Call report 2',
			RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME),
			Status__c = 'Contacted'
		);
		insert newEvent;

		Application_History__c appHis = Mockup_Test.newApplicationHistory(opp.Id, '111222', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
		insert appHis;

		OpportunityLineItem oppProduct = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Application__c = appHis.Id,
			Quantity = 1,
			TotalPrice = 100
		);
		insert oppProduct;

		Event newEvent2 = new Event(
			WhatId = opp.Id,
			Job__c = opp.Id,
			OwnerId = UserInfo.getUserId(),
			StartDateTime = System.now().addDays(-5),
			EndDateTime = System.now().addDays(5),
			Subject = 'Call report 3',
			RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.CBS_CALL_REPORT_WITHOUT_PLAN_EDITABLE_DEVNAME),
			Status__c = 'Contacted'
		);
		insert newEvent2;
		Test.stopTest();
		
		// When
		OpportunityLineItem oppProduct2 = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Application__c = appHis.Id,
			Quantity = 1,
			TotalPrice = 100
		);

		insert oppProduct2;

		// Then
		Event callReport = [SELECT Id, StartDateTime, Subject FROM Event WHERE Subject = 'Call report 2' LIMIT 1];
		Event callReportOld = [SELECT Id, StartDateTime, Subject FROM Event WHERE Subject = 'Call report 3' LIMIT 1];
		List<OpportunityLineItem> oppProductInfo = [select Id, name, Application__c,Application__r.Report_Actual_Visit_Date__c, Report_Latest_Actual_Visit_Date__c, OpportunityId 
													from OpportunityLineItem where Application__c =: appHis.Id order by Report_Latest_Actual_Visit_Date__c ASC];
		System.debug('OppProduct_Phon : '+oppProductInfo);											
		System.assertEquals(callReportOld.StartDateTime.date(), oppProductInfo[0].Report_Latest_Actual_Visit_Date__c);
		System.assertEquals(callReport.StartDateTime.date(), oppProductInfo[1].Report_Latest_Actual_Visit_Date__c);
		System.assertEquals(callReportOld.StartDateTime.date(), oppProductInfo[0].Application__r.Report_Actual_Visit_Date__c);
		System.assertEquals(callReportOld.StartDateTime.date(), oppProductInfo[1].Application__r.Report_Actual_Visit_Date__c);
		
	}

	@isTest
	static void itShouldStampOlderActualVisitDateWhenUpdateOppProductApplication()
	{
		// Given		
		Opportunity jobItem = [SELECT Id, Name FROM Opportunity LIMIT 1];
		PriceBookEntry priceBook = [SELECT Id FROM PriceBookEntry LIMIT 1];
		Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = :oppName LIMIT 1];
		List<Application_History__c> insertList = new List<Application_History__c>();
		Application_History__c appHis = Mockup_Test.newApplicationHistory(opp.Id, '111222', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
		insertList.add(appHis);
		Application_History__c appHis2 = Mockup_Test.newApplicationHistory(opp.Id, '111223', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
		insertList.add(appHis2);
		Application_History__c appHis3 = Mockup_Test.newApplicationHistory(opp.Id, '111224', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
		insertList.add(appHis3);
		Application_History__c appHis4 = Mockup_Test.newApplicationHistory(opp.Id, '111225', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
		insertList.add(appHis4);

		insert insertList;	

		List<OpportunityLineItem> insertOppProductList = new List<OpportunityLineItem>();	

		Test.startTest();
		OpportunityLineItem oppProduct = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Application__c = appHis.Id,
			Quantity = 1,
			TotalPrice = 100,
			Report_Latest_Actual_Visit_Date__c = System.now().date()
		);
		insertOppProductList.add(oppProduct);

		OpportunityLineItem oppProduct2 = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Application__c = appHis2.Id,
			Quantity = 1,
			TotalPrice = 100,
			Report_Latest_Actual_Visit_Date__c = System.now().addDays(-1).date()
		);
		insertOppProductList.add(oppProduct2);

		OpportunityLineItem oppProduct3 = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Application__c = appHis3.Id,
			Quantity = 1,
			TotalPrice = 100,
			Report_Latest_Actual_Visit_Date__c = System.now().addDays(-2).date()
		);
		insertOppProductList.add(oppProduct3);

		TriggerHandler.bypass('OpportunityProductTriggerHandler');
            insert insertOppProductList;
        TriggerHandler.clearBypass('OpportunityProductTriggerHandler');
		
		//When	
		OpportunityLineItem oppProductUpdateAppId = [select Id, name, Application__c,Application__r.Report_Actual_Visit_Date__c, Report_Latest_Actual_Visit_Date__c, OpportunityId 
													from OpportunityLineItem where Application__c =: appHis3.Id LIMIT 1];
		oppProductUpdateAppId.Application__c = appHis.Id;
		update oppProductUpdateAppId;

		// Then
		OpportunityLineItem oppItemResult = [SELECT Id, Name, Report_Latest_Actual_Visit_Date__c, Application__c, Application__r.Report_Actual_Visit_Date__c FROM OpportunityLineItem where Application__c =: appHis.Id LIMIT 1];
		System.assertEquals(oppProductUpdateAppId.Report_Latest_Actual_Visit_Date__c, oppItemResult.Application__r.Report_Actual_Visit_Date__c);	
		Test.stopTest();	
	}

	@isTest
	static void itShouldStampOlderActualVisitDateWhenInsertOppProductListAndUpdateOppProductAppList()
	{
		// Given		
		Opportunity jobItem = [SELECT Id, Name FROM Opportunity LIMIT 1];
		PriceBookEntry priceBook = [SELECT Id FROM PriceBookEntry LIMIT 1];
		Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = :oppName LIMIT 1];
			List<Application_History__c> insertList = new List<Application_History__c>();
			Application_History__c appHis = Mockup_Test.newApplicationHistory(opp.Id, '111222', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
			insertList.add(appHis);
			Application_History__c appHis2 = Mockup_Test.newApplicationHistory(opp.Id, '111223', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
			insertList.add(appHis2);
			Application_History__c appHis3 = Mockup_Test.newApplicationHistory(opp.Id, '111224', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
			insertList.add(appHis3);
			Application_History__c appHis4 = Mockup_Test.newApplicationHistory(opp.Id, '111225', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
			insertList.add(appHis4);

			insert insertList;

		Test.startTest();	
		List<OpportunityLineItem> insertOppProductList = new List<OpportunityLineItem>();

		OpportunityLineItem oppProduct = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Application__c = appHis.Id,
			Report_Latest_Actual_Visit_Date__c = System.now().addDays(-1).date(),
			Quantity = 1,
			TotalPrice = 100
		);
		insertOppProductList.add(oppProduct);


		OpportunityLineItem oppProduct2 = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Application__c = appHis2.Id,
			Report_Latest_Actual_Visit_Date__c = System.now().addDays(-2).date(),
			Quantity = 1,
			TotalPrice = 100
		);
		insertOppProductList.add(oppProduct2);

		OpportunityLineItem oppProduct3 = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Application__c = appHis2.Id,
			Report_Latest_Actual_Visit_Date__c = System.now().addDays(-4).date(),
			Quantity = 1,
			TotalPrice = 100
		);
		insertOppProductList.add(oppProduct3);

		OpportunityLineItem oppProduct4 = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Application__c = appHis2.Id,
			Report_Latest_Actual_Visit_Date__c = System.now().addDays(-3).date(),
			Quantity = 1,
			TotalPrice = 100
		);
		insertOppProductList.add(oppProduct4);

		OpportunityLineItem oppProduct5 = new OpportunityLineItem(
			Opportunity = jobItem,
			OpportunityId = jobItem.Id,
			PricebookEntryId = priceBook.Id,
			Application__c = appHis2.Id,
			Report_Latest_Actual_Visit_Date__c = System.now().addDays(-1).date(),
			Quantity = 1,
			TotalPrice = 100
		);
		insertOppProductList.add(oppProduct5);


		TriggerHandler.bypass('OpportunityProductTriggerHandler');
            insert insertOppProductList;
        TriggerHandler.clearBypass('OpportunityProductTriggerHandler');

        	update insertOppProductList;

		//When
		List<OpportunityLineItem> updateOppProductList = new List<OpportunityLineItem>();
		List<OpportunityLineItem> oppProductUpdateAppList = [select Id, name, Application__c,Application__r.Report_Actual_Visit_Date__c, Report_Latest_Actual_Visit_Date__c, OpportunityId 
													from OpportunityLineItem where Id =: oppProduct3.Id or Id =: oppProduct4.Id];
		
		for(OpportunityLineItem updateOppProduct : oppProductUpdateAppList){

			updateOppProduct.Application__c = appHis3.Id;
			updateOppProductList.add(updateOppProduct);
		}
		
		update updateOppProductList;	
		Test.stopTest();				
		
		// Then
		OpportunityLineItem oppItemResults = [SELECT Id, Name, Report_Latest_Actual_Visit_Date__c, Application__c, Application__r.Report_Actual_Visit_Date__c FROM OpportunityLineItem where Id =: oppProduct2.Id];
		OpportunityLineItem oppItemResults2 = [SELECT Id, Name, Report_Latest_Actual_Visit_Date__c, Application__c, Application__r.Report_Actual_Visit_Date__c FROM OpportunityLineItem where Id =: oppProduct3.Id];
		OpportunityLineItem oppItemResults3 = [SELECT Id, Name, Report_Latest_Actual_Visit_Date__c, Application__c, Application__r.Report_Actual_Visit_Date__c FROM OpportunityLineItem where Id =: oppProduct4.Id];
		System.assertEquals(oppProduct2.Report_Latest_Actual_Visit_Date__c, oppItemResults.Application__r.Report_Actual_Visit_Date__c);
		System.assertEquals(oppProduct3.Report_Latest_Actual_Visit_Date__c, oppItemResults2.Application__r.Report_Actual_Visit_Date__c);
		System.assertEquals(oppProduct3.Report_Latest_Actual_Visit_Date__c, oppItemResults3.Application__r.Report_Actual_Visit_Date__c);
		/*System.debug('OppResult_Phon : '+oppItemResults);
		system.debug('Phon_OppItem1 : '+oppItemResults[0].Application__r.Report_Actual_Visit_Date__c);
		system.debug('Phon_OppItem2 : '+oppItemResults[1].Application__r.Report_Actual_Visit_Date__c);
		system.debug('Phon_OppItem3 : '+oppItemResults[2].Application__r.Report_Actual_Visit_Date__c);
		system.debug('Phon_OppItem4 : '+oppItemResults[3].Application__r.Report_Actual_Visit_Date__c);*/
	}

	@isTest
	static void itShouldUpdateTeamStructureWhenUpdateOppProductMustHaveStatusCompleted()
	{
		// Given
		User rmUser = [SELECT Id,Job_Code__c,Rc_Code__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		Id oppProductId;
		System.runAs(rmUser){
			Opportunity jobItem = [SELECT Id, Name FROM Opportunity LIMIT 1];
			PriceBookEntry priceBook = [SELECT Id FROM PriceBookEntry LIMIT 1];
			OpportunityLineItem oppProduct = new OpportunityLineItem(
				Opportunity = jobItem,
				OpportunityId = jobItem.Id,
				PricebookEntryId = priceBook.Id,
				Quantity = 1,
				TotalPrice = 100
			);
			insert oppProduct;
			// When
			oppProduct.Status__c = 'Completed';
			update oppProduct;
			oppProductId = oppProduct.Id;
		}

		// Then
		User_Extension__c user = [select id,User__c,name,Team_Structure__c,Team_Structure__r.name, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c from User_Extension__c where user__c = :rmUser.Id];
		System.debug('User_InfoPhon : '+user);
		OpportunityLineItem oppProductInfo = [SELECT Id, OwnerExtension__c, TeamName__c FROM OpportunityLineItem where Id =: oppProductId LIMIT 1];
		System.assertEquals(user.Id, oppProductInfo.OwnerExtension__c);
		System.assertEquals(user.Team_Structure__c, oppProductInfo.TeamName__c);
	}

	@isTest
	static void itShouldUpdateStatusWhenInsertOppProductAndUpdateOppProductAppList()
	{
		// Given
		User rmUser = [SELECT Id, Profile.Name FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];	
		PriceBookEntry priceBook = [SELECT Id FROM PriceBookEntry LIMIT 1];
		Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = :oppName LIMIT 1];
		List<Application_History__c> insertList = new List<Application_History__c>();
		Application_History__c appHis = Mockup_Test.newApplicationHistory(opp.Id, '111222', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
		appHis.App_Result__c = GlobalConstants.WORK_IN_PROGRESS;
		insertList.add(appHis);
		Application_History__c appHis2 = Mockup_Test.newApplicationHistory(opp.Id, '111223', GlobalConstants.ESTIMATE_CREDIT_MODEL_HPL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
		appHis2.App_Result__c = GlobalConstants.WORK_IN_PROGRESS;
		insertList.add(appHis2);
		Application_History__c appHis3 = Mockup_Test.newApplicationHistory(opp.Id, '111224', GlobalConstants.ESTIMATE_CREDIT_MODEL_PL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
		appHis3.App_Result__c = GlobalConstants.CLOSE_LOST;
		insertList.add(appHis3);
		Application_History__c appHis4 = Mockup_Test.newApplicationHistory(opp.Id, '111225', GlobalConstants.ESTIMATE_CREDIT_MODEL_DLA, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
		appHis4.App_Result__c = GlobalConstants.AUTO_CLOSED;
		insertList.add(appHis4);

		System.runAs(rmUser) {
			TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
			insert insertList;
			TriggerHandler.clearbypass('ApplicationHistoryTriggerHandler');
		}
		
		Test.startTest();	
		List<OpportunityLineItem> insertOppProductList = new List<OpportunityLineItem>();

		OpportunityLineItem oppProduct = new OpportunityLineItem(
			Opportunity = opp,
			OpportunityId = opp.Id,
			PricebookEntryId = priceBook.Id,
			Application_CBS__c = appHis.Id,
			Report_Latest_Actual_Visit_Date__c = System.now().addDays(-1).date(),
			Product_Results__c = '1. สนใจ และขายได้',
			Quantity = 1,
			TotalPrice = 100
		);
		insertOppProductList.add(oppProduct);

		OpportunityLineItem oppProduct2 = new OpportunityLineItem(
			Opportunity = opp,
			OpportunityId = opp.Id,
			PricebookEntryId = priceBook.Id,
			Application__c = appHis2.Id,
			Report_Latest_Actual_Visit_Date__c = System.now().addDays(-2).date(),
			Product_Results__c = '1. สนใจ และขายได้',
			Quantity = 1,
			TotalPrice = 100
		);
		insertOppProductList.add(oppProduct2);

		OpportunityLineItem oppProduct3 = new OpportunityLineItem(
			Opportunity = opp,
			OpportunityId = opp.Id,
			PricebookEntryId = priceBook.Id,
			Application_CBS__c = appHis2.Id,
			Report_Latest_Actual_Visit_Date__c = System.now().addDays(-4).date(),
			Product_Results__c = '1. สนใจ และขายได้',
			Quantity = 1,
			TotalPrice = 100
		);
		insertOppProductList.add(oppProduct3);

		System.runAs(rmUser) {
			insert insertOppProductList;
		}

		//When
		OpportunityLineItem oppProductUpdateApp = [SELECT Id, name, Application__c, OpportunityId FROM OpportunityLineItem WHERE Id =: oppProduct2.Id];
		OpportunityLineItem oppProductUpdateApp2 = [SELECT Id, name, Application_CBS__c, OpportunityId FROM OpportunityLineItem WHERE Id =: oppProduct3.Id];
		oppProductUpdateApp.Application__c = appHis3.Id;
		oppProductUpdateApp2.Application_CBS__c = appHis4.Id;

		System.runAs(rmUser) {
			update oppProductUpdateApp;
			update oppProductUpdateApp2;
		}
		Test.stopTest();				
		
		// Then
		OpportunityLineItem oppItemResults = [SELECT Id, Name, Status_CBS__c FROM OpportunityLineItem where Id =: oppProduct.Id];
		OpportunityLineItem oppItemResults2 = [SELECT Id, Name, Status_CBS__c FROM OpportunityLineItem where Id =: oppProduct2.Id];
		OpportunityLineItem oppItemResults3 = [SELECT Id, Name, Status_CBS__c FROM OpportunityLineItem where Id =: oppProduct3.Id];
		System.assertEquals(GlobalConstants.ON_PROCESS, oppItemResults.Status_CBS__c);
		System.assertEquals(GlobalConstants.CLOSE_LOST, oppItemResults2.Status_CBS__c);
		System.assertEquals(GlobalConstants.AUTO_CLOSED, oppItemResults3.Status_CBS__c);
	}

	@isTest
	static void itShouldErrorWhenUpdateOppProductAppList()
	{
		// Given
		User rmUser = [SELECT Id, Profile.Name FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];	
		PriceBookEntry priceBook = [SELECT Id FROM PriceBookEntry LIMIT 1];
		Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = :oppName LIMIT 1];
		List<Application_History__c> insertList = new List<Application_History__c>();
		Application_History__c appHis = Mockup_Test.newApplicationHistory(opp.Id, '111222', GlobalConstants.ESTIMATE_CREDIT_MODEL_FL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
		appHis.App_Result__c = GlobalConstants.CLOSE_LOST;
		insertList.add(appHis);
		Application_History__c appHis2 = Mockup_Test.newApplicationHistory(opp.Id, '111223', GlobalConstants.ESTIMATE_CREDIT_MODEL_HPL, 'ส่งครั้งแรก', GlobalConstants.NON_CMAS, System.today(), 100000);
		appHis2.App_Result__c = GlobalConstants.CLOSE_LOST;
		insertList.add(appHis2);

		System.runAs(rmUser) {
			TriggerHandler.bypass('ApplicationHistoryTriggerHandler');
			insert insertList;
			TriggerHandler.clearbypass('ApplicationHistoryTriggerHandler');
		}
		
		Test.startTest();	
		List<OpportunityLineItem> insertOppProductList = new List<OpportunityLineItem>();

		OpportunityLineItem oppProduct = new OpportunityLineItem(
			Opportunity = opp,
			OpportunityId = opp.Id,
			PricebookEntryId = priceBook.Id,
			Application_CBS__c = appHis.Id,
			Report_Latest_Actual_Visit_Date__c = System.now().addDays(-1).date(),
			Product_Results__c = '1. สนใจ และขายได้',
			Quantity = 1,
			TotalPrice = 100
		);
		insertOppProductList.add(oppProduct);

		OpportunityLineItem oppProduct2 = new OpportunityLineItem(
			Opportunity = opp,
			OpportunityId = opp.Id,
			PricebookEntryId = priceBook.Id,
			Application__c = appHis2.Id,
			Report_Latest_Actual_Visit_Date__c = System.now().addDays(-2).date(),
			Product_Results__c = '1. สนใจ และขายได้',
			Quantity = 1,
			TotalPrice = 100
		);
		insertOppProductList.add(oppProduct2);

		System.runAs(rmUser) {
			insert insertOppProductList;
		}

		//When
		OpportunityLineItem oppProductUpdateApp = [SELECT Id, name, Status_CBS__c, OpportunityId FROM OpportunityLineItem WHERE Id =: oppProduct.Id];
		OpportunityLineItem oppProductUpdateApp2 = [SELECT Id, name, Status_CBS__c, OpportunityId FROM OpportunityLineItem WHERE Id =: oppProduct2.Id];
		oppProductUpdateApp.Status_CBS__c = GlobalConstants.ON_PROCESS;
		oppProductUpdateApp2.Status_CBS__c = GlobalConstants.ON_PROCESS;
		List<OpportunityLineItem> updateOppProductList = new List<OpportunityLineItem>();
		updateOppProductList.add(oppProductUpdateApp);
		updateOppProductList.add(oppProductUpdateApp2);

		List<Database.SaveResult> results;
		System.runAs(rmUser) {
			results = Database.update(updateOppProductList, false);
		}
		Test.stopTest();				
		
		// Then
		System.assertEquals(false, results.get(0).isSuccess());
		System.assertEquals(false, results.get(1).isSuccess());
	}
}