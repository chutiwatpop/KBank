@isTest
private class CalculatePerformanceFromCallReportTest {
	public static String O_CUSTOMER_RM_TEMP_POOL    = 'CustomerCalculatePerformancePool';
    public static String O_CUSTOMER_RM_PER_PORT     = 'CustomerCalculatePerformancePort';
    public static String O_CUSTOMER_RM_OTHER     = 'CustomerO_CUSTOMER_RM_OTHER';
    public static String INTEREST_PRODUCT_RESULT     = '1. สนใจ และขายได้';
    public static String INTEREST_PRODUCT_REASON     = '1.1 และสมัครใช้บริการ';

	@testSetup static void setupAccount(){
        Test.startTest();
        Mockup_Test mt = new Mockup_Test().setUpTestAdmin().setUpTestWithExtension();
        PriceBook2 priceBook2 = new PriceBook2(
			Name = 'Price Book'
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
        Test.stopTest();

        System.runAs(new User(Id = UserInfo.getUserId())){
            User userRM = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
            userRM.Segment__c  = 'SE';
            TriggerHandler.bypass('UserTriggerHandler');
            update userRM;
            TriggerHandler.clearbypass('UserTriggerHandler');
        }
    }
	
	@isTest static void GivenCustomerPortAndCallReportFaceToFaceForSaleAndOppLineItemFinalApproveAndApp_WhenRunBatchCalcualtePerformanceFromCallReport_ThenCountToUserExtension() {
        User userRM = [SELECT Id,Segment__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Opportunity oppPerPort;
        System.runAs(userRM){
            Account accountPerPort = Mockup_Test.newAccountWithSegment(O_CUSTOMER_RM_PER_PORT, GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER), GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
            insert accountPerPort;

            oppPerPort = Mockup_Test.newOpportunity(accountPerPort.Id, 'oppPerPort', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
            insert oppPerPort;
            insert new Event(
                WhatId = oppPerPort.Id,
                Job__c = oppPerPort.Id,
                OwnerId = userRM.Id,
                StartDateTime = System.now(),
                EndDateTime = System.now(),
                RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
                Visit_Objective__c = 'เพื่อขาย',
                Collect_Documents__c = true,
                Offer_Credit_Product__c = false,
                Status__c = GlobalConstants.CONTACTED,
                Contact_Channel__c = GlobalConstants.FACE_TO_FACE
            );
        }

        Test.startTest();
        System.runAs(userRM){
            Application_History__c newApp = new Application_History__c(
            	OppName__c = oppPerPort.Id,
	            RMCreditModel__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_DLA,
	            RMSubmitChannel__c = GlobalConstants.NON_CMAS,
	            TentativeSubmitDate__c = System.today() + 1,
	            RMSubmitRound__c = 'ส่งครั้งแรก',
	            AppInDate__c = System.today(),
                RMSubmitToCAPFDate__c = System.today(),
                SP_CAPF_Received_DT__c = System.today(),
            	App_Result__c = GlobalConstants.WORK_IN_PROGRESS
            );
            insert newApp;
            PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :Test.getStandardPricebookId() LIMIT 1];
            insert new OpportunityLineItem(
            	OpportunityId = oppPerPort.Id,
            	Product2Id = pbEntry.Id,
            	Application__c = newApp.Id,
            	Status__c = GlobalConstants.FINAL_APPROVE,
                Status_CBS__c = GlobalConstants.FINAL_APPROVE,
            	Report_Latest_Call_Report_ID__c = String.valueOf(Event.Id),
            	Product_Results__c = INTEREST_PRODUCT_RESULT,
            	Reasons__c = INTEREST_PRODUCT_REASON
            );
        }

            Database.executeBatch(new CalculatePerformanceFromCallReport_Batch(CalculatePerformanceFromCallReport_Batch.RUN_FOR_SME));
        Test.stopTest();

        User_Extension__c userExt = [SELECT Id, Call_Report__c,Call_Report_Customer_Port__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Others__c,Face_to_Face__c,Phone_Call__c,Call_Report_for_Sales__c,Call_Report_for_Relationship__c,Call_Report_Product_Interested__c,Product_Interested__c,Product_Final_Approved__c,Product_Set_Up__c,Call_Report_Credit_for_Sales__c,Call_Report_Credit_Product_Interested__c,Credit_Product_Interested__c,Total_Opportunity_App_In__c,Total_Opportunity_Setup__c,Total_Opportunity_Close_Lost__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM];
		System.assertEquals(1, userExt.Call_Report__c);
        System.assertEquals(1, userExt.Call_Report_Customer_Port__c);
        System.assertEquals(0, userExt.Call_Report_Customer_Pool__c);
		System.assertEquals(0, userExt.Call_Report_Customer_Others__c);
        System.assertEquals(1, userExt.Face_to_Face__c);
        System.assertEquals(0, userExt.Phone_Call__c);
        System.assertEquals(1, userExt.Call_Report_for_Sales__c);
        System.assertEquals(0, userExt.Call_Report_for_Relationship__c);

        System.assertEquals(1, userExt.Call_Report_Product_Interested__c);
        System.assertEquals(1, userExt.Product_Interested__c);
        //System.assertEquals(1, userExt.Product_Final_Approved__c);
        //System.assertEquals(0, userExt.Product_Set_Up__c);
        System.assertEquals(1, userExt.Call_Report_Credit_for_Sales__c);
        System.assertEquals(0, userExt.Call_Report_Credit_Product_Interested__c);
        System.assertEquals(0, userExt.Credit_Product_Interested__c);
        System.assertEquals(1, userExt.Total_Opportunity_App_In__c);
        System.assertEquals(0, userExt.Total_Opportunity_Setup__c);
        System.assertEquals(0, userExt.Total_Opportunity_Close_Lost__c);
	}
	
	@isTest static void GivenCustomerPoolAndOtherAndCallReportFaceToFaceForSaleAndOppLineItemFinalApproveAndApp_WhenRunBatchCalcualtePerformanceFromCallReport_ThenCountToUserExtension() {
        User userRM = [SELECT Id,Segment__c  FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Opportunity oppTempPool,oppPerPort;
        System.runAs(userRM){
        	List<Account> listAcc = new List<Account>();
            Account accountTempPool = Mockup_Test.newAccountWithSegment(O_CUSTOMER_RM_TEMP_POOL, GlobalConstants.POOL, GlobalConstants.OWNERSHIP_TEMPORARY, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER), GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
            Account accountPerPort = Mockup_Test.newAccountWithSegment(O_CUSTOMER_RM_OTHER, null, GlobalConstants.OWNERSHIP_PERMANENT, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER), GlobalConstants.PRIMARY_SEGMENT_CODE_SM);
            listAcc.add(accountTempPool);
            listAcc.add(accountPerPort);
            insert listAcc;

            List<Opportunity> listOpp = new List<Opportunity>();
            oppTempPool = Mockup_Test.newOpportunity(accountTempPool.Id, 'oppTempPool', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
            oppPerPort = Mockup_Test.newOpportunity(accountPerPort.Id, 'oppPerPort', GlobalConstants.STATUS_OPEN, GlobalConstants.NON_CMAS);
            listOpp.add(oppPerPort);
            listOpp.add(oppTempPool);
            insert listOpp;

            List<Event> listEvent = new List<Event>();
            Event event1 = new Event(
                WhatId = oppTempPool.Id,
                Job__c = oppTempPool.Id,
                OwnerId = userRM.Id,
                StartDateTime = System.now(),
                EndDateTime = System.now(),
                RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
                Visit_Objective__c = 'เพื่อขาย',
                Collect_Documents__c = true,
                Offer_Credit_Product__c = false,
                Status__c = GlobalConstants.CONTACTED,
                Contact_Channel__c = GlobalConstants.FACE_TO_FACE
            );

            Event event2 = new Event(
                WhatId = oppPerPort.Id,
                Job__c = oppPerPort.Id,
                OwnerId = userRM.Id,
                StartDateTime = System.now(),
                EndDateTime = System.now(),
                RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Event').get(GlobalConstants.SME_CALL_REPORT_WITHOUT_PLAN_DEVNAME),
                Visit_Objective__c = 'สานสัมพันธ์',
                Collect_Documents__c = false,
                Customer_Insight__c = true,
                Offer_Credit_Product__c = false,
                Status__c = GlobalConstants.CONTACTED,
                Contact_Channel__c = GlobalConstants.PHONE_CALL
            );
            listEvent.add(event1);
            listEvent.add(event2);
            insert listEvent;
        }
        Test.startTest();
        System.runAs(userRM){
            List<Application_History__c> listApp = new List<Application_History__c>();
            Application_History__c newApp1 = new Application_History__c(
            	OppName__c = oppTempPool.Id,
	            RMCreditModel__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_DLA,
	            RMSubmitChannel__c = GlobalConstants.NON_CMAS,
	            TentativeSubmitDate__c = System.today() + 1,
	            RMSubmitRound__c = 'ส่งครั้งแรก',
	            AppInDate__c = System.today(),
            	RMSubmitToCAPFDate__c = System.today(),
                SP_CAPF_Received_DT__c = System.today(),
            	App_Result__c = GlobalConstants.WORK_IN_PROGRESS,
                RunningRC__c = '1'
            );

            Application_History__c newApp2 = new Application_History__c(
            	OppName__c = oppPerPort.Id,
	            RMCreditModel__c = GlobalConstants.ESTIMATE_CREDIT_MODEL_DLA,
	            RMSubmitChannel__c = GlobalConstants.NON_CMAS,
	            TentativeSubmitDate__c = System.today() + 1,
	            RMSubmitRound__c = 'ส่งครั้งแรก',
	            AppInDate__c = System.today(),
                RMSubmitToCAPFDate__c = System.today(),
                SP_CAPF_Received_DT__c = System.today(),
            	App_Result__c = GlobalConstants.WORK_IN_PROGRESS,
                RunningRC__c = '2'
            );
            listApp.add(newApp1);
            listApp.add(newApp2);
            insert listApp;
            
            PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :Test.getStandardPricebookId() LIMIT 1];
            List<OpportunityLineItem> listOppLine = new List<OpportunityLineItem>();
            listOppLine.add(new OpportunityLineItem(
            	OpportunityId = oppTempPool.Id,
            	Product2Id = pbEntry.Id,
            	Application__c = newApp1.Id,
            	Status__c = GlobalConstants.FINAL_APPROVE,
                Status_CBS__c = GlobalConstants.FINAL_APPROVE,
            	Report_Latest_Call_Report_ID__c = String.valueOf(Event.Id),
            	Product_Results__c = INTEREST_PRODUCT_RESULT,
            	Reasons__c = INTEREST_PRODUCT_REASON
	        ));

            listOppLine.add(new OpportunityLineItem(
            	OpportunityId = oppPerPort.Id,
            	Product2Id = pbEntry.Id,
            	Application__c = newApp2.Id,
            	Status__c = GlobalConstants.SETUP,
                Status_CBS__c = GlobalConstants.SETUP,
            	Report_Latest_Call_Report_ID__c = String.valueOf(Event.Id),
            	Product_Results__c = 'Not Interest'
            ));
            insert listOppLine;

            newApp2.App_Result__c = GlobalConstants.CLOSE_LOST;
            update newApp2;
        }
            Database.executeBatch(new CalculatePerformanceFromCallReport_Batch(CalculatePerformanceFromCallReport_Batch.RUN_FOR_SME));
        Test.stopTest();

        User_Extension__c userExt = [SELECT Id, Call_Report__c,Call_Report_Customer_Port__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Others__c,Face_to_Face__c,Phone_Call__c,Call_Report_for_Sales__c,Call_Report_for_Relationship__c,Call_Report_Product_Interested__c,Product_Interested__c,Product_Final_Approved__c,Product_Set_Up__c,Call_Report_Credit_for_Sales__c,Call_Report_Credit_Product_Interested__c,Credit_Product_Interested__c,Total_Opportunity_App_In__c,Total_Opportunity_Setup__c,Total_Opportunity_Close_Lost__c FROM User_Extension__c WHERE User__r.Firstname=:Mockup_Test.userFirstNameRM];
		System.assertEquals(2, userExt.Call_Report__c);
        System.assertEquals(0, userExt.Call_Report_Customer_Port__c);
        System.assertEquals(1, userExt.Call_Report_Customer_Pool__c);
		System.assertEquals(1, userExt.Call_Report_Customer_Others__c);
        System.assertEquals(1, userExt.Face_to_Face__c);
        System.assertEquals(1, userExt.Phone_Call__c);
        System.assertEquals(1, userExt.Call_Report_for_Sales__c);
        System.assertEquals(1, userExt.Call_Report_for_Relationship__c);

        System.assertEquals(1, userExt.Call_Report_Product_Interested__c);
        System.assertEquals(1, userExt.Product_Interested__c);
        //System.assertEquals(1, userExt.Product_Final_Approved__c);
        //System.assertEquals(1, userExt.Product_Set_Up__c);
        System.assertEquals(1, userExt.Call_Report_Credit_for_Sales__c);
        System.assertEquals(0, userExt.Call_Report_Credit_Product_Interested__c);
        System.assertEquals(0, userExt.Credit_Product_Interested__c);
        System.assertEquals(1, userExt.Total_Opportunity_App_In__c);
        System.assertEquals(0, userExt.Total_Opportunity_Setup__c);
        System.assertEquals(1, userExt.Total_Opportunity_Close_Lost__c);
	}
	
}