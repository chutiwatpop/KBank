@isTest
private class OpportunityPlanning_Test {
	
	public static String accountNameTM = 'tmAccountName';
    public static String accountNameRM = 'rmAccountName';
    public static String accountNameAH = 'ahAccountName';
    public static Map<String, Id> recordTypeIdMapByDevName;

    public static String pruductGruop_Transaction = 'Transaction';
	public static String productName_Remittance = 'Remittance';
	public static String productName_SBLC = 'SBLC';

	@testSetup static void setupAccount(){
		initOppPlanCustomSetting();
		initFilterView();
		setUpProductMasterData();
		TriggerHandler.bypass('UserTriggerHandler');
		Test.startTest();
		Mockup_Test mt = new Mockup_Test().setUpTest();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        Test.stopTest();
        TriggerHandler.clearBypass('UserTriggerHandler');
	}

	public static void setUpProductMasterData(){
		id recordTypeId = Schema.SObjectType.Product_List_Master__c.getRecordTypeInfosByName().get('For CBS').getRecordTypeId();
		//Id rt = Schema.SObjectType.Product_List_Master__c.getRecordTypeInfosByDeveloperName().get(GlobalConstants.RECORDTYPE_DEVNAME_PRODUCT_MASTER_CBS);
		List<Product_List_Master__c> callReportProductListMaster = new List<Product_List_Master__c>();
		Product_List_Master__c productMaster = Mockup_Test.newProductMasterCBS(OpportunityPlanning_Test.pruductGruop_Transaction,1,OpportunityPlanning_Test.productName_SBLC,1,recordTypeId);
		callReportProductListMaster.add(productMaster);

		productMaster = Mockup_Test.newProductMasterCBS(OpportunityPlanning_Test.pruductGruop_Transaction,1,OpportunityPlanning_Test.productName_Remittance,2,recordTypeId);
		callReportProductListMaster.add(productMaster);

		insert callReportProductListMaster;
	}

	public static void initFilterView(){
        CBS_OppPlanning_Filter_View__c cbsAdminFilter = new CBS_OppPlanning_Filter_View__c();
        cbsAdminFilter.All_Owner__c = true;
        cbsAdminFilter.All_Product__c = true;
        cbsAdminFilter.All_Stage__c = true;
        cbsAdminFilter.All_Status__c = true;
        cbsAdminFilter.All_Team__c = true;
        cbsAdminFilter.All_Product_Group__c = true;
        insert cbsAdminFilter;
    }


	public static Id getCampRecordTypeFromDevName(String devName){
		if(OpportunityPlanning_Test.recordTypeIdMapByDevName == null) {
			OpportunityPlanning_Test.recordTypeIdMapByDevName = new Map<String, Id>();
			OpportunityPlanning_Test.recordTypeIdMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Campaign');
		}
		return OpportunityPlanning_Test.recordTypeIdMapByDevName.get(devName);
	}

	public static Campaign mockCreateCampaign(String campaignName, String campaignType, Boolean campaignIsActive, String campaignStatus, String campaignSubType, String recordTypeDevName, String campaingProductList){
		Campaign mockCampaign = new Campaign();
		mockCampaign.Lead_Campaign_Event_Code__c = campaignName;
		mockCampaign.Type__c = campaignType;
		mockCampaign.Sub_Type_CBS__c = campaignSubType;
		mockCampaign.Name = campaignName;
		mockCampaign.Status = campaignStatus;
		mockCampaign.Product_List_CBS__c = campaingProductList;

		if(campaignIsActive || campaignStatus == GlobalConstants.ACTIVE) {
        	mockCampaign.IsActive = true;
        	mockCampaign.StartDate = System.today() - 1;
        } else {
        	mockCampaign.IsActive = false;
        	mockCampaign.StartDate = System.today() + 1;
        }

		mockCampaign.EndDate = System.Today() + 2;
		mockCampaign.RecordTypeId = OpportunityPlanning_Test.getCampRecordTypeFromDevName(recordTypeDevName);
		return mockCampaign;
	}

	public static Target_List__c mockCreateTargetList(String accountId, String campaignId){
		Target_List__c eachTargetList = new Target_List__c();
		eachTargetList.CIS_ID_Prospect_Name__c = accountId;
		eachTargetList.Lead_Campaign__c = campaignId;
		eachTargetList.Status__c = GlobalConstants.STATUS_NEW;
		return eachTargetList;
	}

	public static Map<String,String> mockInitialDataForNewOppPlanning(String campaignType, Boolean campaignIsActive, String campaignStatus, Boolean hasTargetList, String campaignSubType, String campRecTypeDevName, String campaingProductList){
		Map<String,String> resultIdMap = new Map<String,String>();
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :OpportunityPlanning_Test.accountNameRM LIMIT 1];
		resultIdMap.put('accountId',targetAccount.Id);

		Campaign mockCampaign = mockCreateCampaign('Lead1', campaignType,campaignIsActive,campaignStatus, campaignSubType, campRecTypeDevName, campaingProductList);
		insert mockCampaign;
		resultIdMap.put('campaignId',mockCampaign.Id);

		if(hasTargetList){
			Target_List__c eachTargetList = mockCreateTargetList(targetAccount.Id,mockCampaign.Id);
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

	@isTest static void testPositiveInsertOppPlanning() {
		String campaingProductList = OpportunityPlanning_Test.productName_SBLC;
        String oppPlannignProductList = OpportunityPlanning_Test.productName_SBLC;

		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		mockIdMap = mockInitialDataForNewOppPlanning(GlobalConstants.LEAD_FOR_SALES, campaignIsActive, campaignStatus, hasTargetList, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA, GlobalConstants.CBS_LEAD_DEVNAME,campaingProductList);
		Test.startTest();
			insert new Opportunity_Planning__c(
				CIS_ID__c = mockIdMap.get('accountId'),
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
				Project_Size__c = 100000,
				Expected_Income_to_KBank__c = 100000,
		        Expected_LimitVolume_Amount__c = 100000,
		        Remark__c = 'Test Remark',
		        Product_List_CBS__c = oppPlannignProductList
			);
		Test.stopTest();

		System.assertEquals(1, [SELECT Count() FROM Opportunity_Planning__c]);
		Target_List__c resultLead = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :mockIdMap.get('accountId') LIMIT 1];
		System.assertEquals(GlobalConstants.OPP_PLAN_EXPLORE, resultLead.Status__c);
	}

	@isTest static void testNegativeInsertOppPlanningNoMatchProductList() {
		String campaingProductList = OpportunityPlanning_Test.productName_SBLC;
        String oppPlannignProductList = OpportunityPlanning_Test.productName_SBLC;

		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		mockIdMap = mockInitialDataForNewOppPlanning(GlobalConstants.LEAD_FOR_SALES, campaignIsActive, campaignStatus, hasTargetList, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA, GlobalConstants.CBS_LEAD_DEVNAME,campaingProductList);
		Test.startTest();
			insert new Opportunity_Planning__c(
				CIS_ID__c = mockIdMap.get('accountId'),
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
				Project_Size__c = 100000,
				Expected_Income_to_KBank__c = 100000,
		        Expected_LimitVolume_Amount__c = 100000,
		        Remark__c = 'Test Remark',
		        Product_List_CBS__c = OpportunityPlanning_Test.productName_Remittance
			);
		Test.stopTest();

		System.assertEquals(1, [SELECT Count() FROM Opportunity_Planning__c]);
		Target_List__c resultLead = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :mockIdMap.get('accountId') LIMIT 1];
		System.assertEquals(GlobalConstants.STATUS_NEW, resultLead.Status__c);
	}

	@isTest static void testPositiveUpdateOppPlanning() {

		String campaingProductList = OpportunityPlanning_Test.productName_SBLC;
        String oppPlannignProductList = OpportunityPlanning_Test.productName_SBLC;

		Map<String,String> mockIdMap = new Map<String,String>();
		Boolean campaignIsActive = true, hasTargetList = true;
		String campaignStatus = GlobalConstants.ACTIVE;
		mockIdMap = mockInitialDataForNewOppPlanning(GlobalConstants.LEAD_FOR_SALES, campaignIsActive, campaignStatus, hasTargetList, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA, GlobalConstants.CBS_LEAD_DEVNAME,campaingProductList);
		Opportunity_Planning__c targetOppPlanning = new Opportunity_Planning__c(
			CIS_ID__c = mockIdMap.get('accountId'),
			Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
			Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
			Project_Size__c = 100000,
			Expected_Income_to_KBank__c = 100000,
	        Expected_LimitVolume_Amount__c = 100000,
	        Remark__c = 'Test Remark',
	        Product_List_CBS__c = oppPlannignProductList
		);
		insert targetOppPlanning;

		System.assertEquals(1, [SELECT Count() FROM Opportunity_Planning__c]);
		Target_List__c resultLead = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :mockIdMap.get('accountId') LIMIT 1];
		System.assertEquals(GlobalConstants.OPP_PLAN_EXPLORE, resultLead.Status__c);

		Test.startTest();
			targetOppPlanning.Status__c = GlobalConstants.OPP_PLAN_NEGOTIATION;
			update targetOppPlanning;
		Test.stopTest();

		Target_List__c expectedLead = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :mockIdMap.get('accountId') LIMIT 1];
		System.assertEquals(GlobalConstants.OPP_PLAN_NEGOTIATION, expectedLead.Status__c);
	}

/////////////////////////////// Call report ////////////////////

	@isTest static void testCreateCallReportCreatOppPlanWinCreditOpp() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account targetAccount = [SELECT Id, Name,Customer_s_Business_Code__c FROM Account WHERE Name = :OpportunityPlanning_Test.accountNameRM LIMIT 1];
			Product_List_Master__c productMaster_SBLC = [SELECT Id,Product_Name__c From Product_List_Master__c WHERE  Product_Name__c = :OpportunityPlanning_Test.productName_SBLC LIMIT 1];

	        List<Opportunity_Planning_Line_Item__c> newLineItems = new List<Opportunity_Planning_Line_Item__c>();

	        TriggerHandler.bypass('CallReportTriggerHandler');
	        Call_Report__c callreportObj = new Call_Report__c(
	            Contact_Firstname__c = 'abc',
	            Contact_Lastname__c = 'def',
	            Contact_Phone__c = '123456789',
	            CIS_ID__c = targetAccount.Id,
	            Status__c = GlobalConstants.PLAN,
	            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
	            Plan_Date__c = System.Today(),
	            Offer_Credit_Product__c = true,
	            Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
	            Customer_Important_Note__c = 'test',
	            Expected_Credit_Amount__c = 600000
	        );
			insert callreportObj;

			Opportunity_Planning__c targetOppPlanning = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE,
				Fee__c = 10000,
		        Remark__c = 'Test Remark',
		        Product_List_CBS__c = productMaster_SBLC.Product_Name__c
			);

			Opportunity_Planning_Line_Item__c productLineItem1 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = productMaster_SBLC.Product_Name__c,
	        	Opportunity_Planning__c = targetOppPlanning.Id,
	        	Call_Report_Product_List_Master__c = productMaster_SBLC.id
	        );
	        newLineItems.add(productLineItem1);

	        CBS_OpportunityPlanningWrapper eachOppWrapper = new CBS_OpportunityPlanningWrapper(targetOppPlanning,newLineItems);
			eachOppWrapper.oldStatus = GlobalConstants.OPP_PLAN_EXPLORE;
			List<CBS_OpportunityPlanningWrapper> oppPlanningWrapperList = new List<CBS_OpportunityPlanningWrapper>{eachOppWrapper};
			List<GroupOpportunityPlanningWrapper> groupOpportunityPlanningList = new List<GroupOpportunityPlanningWrapper>();
			
			Test.startTest();
				OpportunityPlanning_Service.createOpportunityFromCallReport(targetAccount,callreportObj, oppPlanningWrapperList,groupOpportunityPlanningList);
			Test.stopTest();

			System.assertEquals(1, [SELECT Count() FROM Opportunity_Planning__c]);
			System.assertEquals(1, [SELECT Count() FROM Opportunity_Planning_Line_Item__c]);

			System.assertEquals(1, [SELECT Count() FROM Opportunity]);
			System.assertEquals(1, [SELECT Count() FROM Opportunity_Product_CBS__c]);
			
		}
	}

	@isTest static void testCreateCallReportCreatOppPlanWinNonCreditOpp() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account targetAccount = [SELECT Id, Name,Customer_s_Business_Code__c FROM Account WHERE Name = :OpportunityPlanning_Test.accountNameRM LIMIT 1];
			Product_List_Master__c productMaster_SBLC = [SELECT Id,Product_Name__c From Product_List_Master__c WHERE  Product_Name__c = :OpportunityPlanning_Test.productName_SBLC LIMIT 1];

	        List<Opportunity_Planning_Line_Item__c> newLineItems = new List<Opportunity_Planning_Line_Item__c>();

	        TriggerHandler.bypass('CallReportTriggerHandler');
	        Call_Report__c callreportObj = new Call_Report__c(
	            Contact_Firstname__c = 'abc',
	            Contact_Lastname__c = 'def',
	            Contact_Phone__c = '123456789',
	            CIS_ID__c = targetAccount.Id,
	            Status__c = GlobalConstants.PLAN,
	            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
	            Plan_Date__c = System.Today(),
	            Offer_Credit_Product__c = true,
	            Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
	            Customer_Important_Note__c = 'test',
	            Expected_Credit_Amount__c = 600000
	        );
			insert callreportObj;

			Opportunity_Planning__c targetOppPlanning = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_RENEW,
				Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE,
		        Remark__c = 'Test Remark',
		        Product_List_CBS__c = productMaster_SBLC.Product_Name__c
			);

			Opportunity_Planning_Line_Item__c productLineItem1 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  =  productMaster_SBLC.Product_Name__c,
	        	Opportunity_Planning__c = targetOppPlanning.Id,
	        	Call_Report_Product_List_Master__c = productMaster_SBLC.id
	        );
	        newLineItems.add(productLineItem1);

	        CBS_OpportunityPlanningWrapper eachOppWrapper = new CBS_OpportunityPlanningWrapper(targetOppPlanning,newLineItems);
			eachOppWrapper.oldStatus = GlobalConstants.OPP_PLAN_EXPLORE;
			List<CBS_OpportunityPlanningWrapper> oppPlanningWrapperList = new List<CBS_OpportunityPlanningWrapper>{eachOppWrapper};
			List<GroupOpportunityPlanningWrapper> groupOpportunityPlanningList = new List<GroupOpportunityPlanningWrapper>();
			Test.startTest();
				OpportunityPlanning_Service.createOpportunityFromCallReport(targetAccount,callreportObj, oppPlanningWrapperList,groupOpportunityPlanningList);
			Test.stopTest();

			System.assertEquals(1, [SELECT Count() FROM Opportunity_Planning__c]);
			System.assertEquals(1, [SELECT Count() FROM Opportunity_Planning_Line_Item__c]);

			System.assertEquals(1, [SELECT Count() FROM Opportunity]);
			System.assertEquals(1, [SELECT Count() FROM Opportunity_Product_CBS__c]);
		}
	}

	@isTest static void testCreateCallReportandGroupOppPlan(){
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account targetAccount = [SELECT Id, Name,Customer_s_Business_Code__c FROM Account WHERE Name = :OpportunityPlanning_Test.accountNameRM LIMIT 1];
			Product_List_Master__c productMaster_SBLC = [SELECT Id,Product_Name__c From Product_List_Master__c WHERE  Product_Name__c = :OpportunityPlanning_Test.productName_SBLC LIMIT 1];
			Product_List_Master__c productMaster_Remittance = [SELECT Id,Product_Name__c From Product_List_Master__c WHERE  Product_Name__c = :OpportunityPlanning_Test.productName_Remittance LIMIT 1];

	        TriggerHandler.bypass('CallReportTriggerHandler');
	        Call_Report__c callreportObj = new Call_Report__c(
	            Contact_Firstname__c = 'abc',
	            Contact_Lastname__c = 'def',
	            Contact_Phone__c = '123456789',
	            CIS_ID__c = targetAccount.Id,
	            Status__c = GlobalConstants.PLAN,
	            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
	            Plan_Date__c = System.Today(),
	            Offer_Credit_Product__c = true,
	            Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
	            Customer_Important_Note__c = 'test',
	            Expected_Credit_Amount__c = 600000
	        );
			insert callreportObj;

			Opportunity_Planning__c targetOppPlanning1 = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE,
		        Remark__c = 'Test Remark',
		        Product_List_CBS__c = productMaster_SBLC.Product_Name__c
			);

			Opportunity_Planning_Line_Item__c productLineItem1 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  =  productMaster_SBLC.Product_Name__c,
	        	Opportunity_Planning__c = targetOppPlanning1.Id,
	        	Call_Report_Product_List_Master__c = productMaster_SBLC.id
	        );

	        CBS_OpportunityPlanningWrapper oppWrapper1 = new CBS_OpportunityPlanningWrapper(targetOppPlanning1,new List<Opportunity_Planning_Line_Item__c>{productLineItem1});
			oppWrapper1.oldStatus = GlobalConstants.OPP_PLAN_EXPLORE;

			Opportunity_Planning__c targetOppPlanning2 = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE,
		        Remark__c = 'Test Remark',
		        Product_List_CBS__c = productMaster_Remittance.Product_Name__c
			);

			Opportunity_Planning_Line_Item__c productLineItem2 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  =  productMaster_Remittance.Product_Name__c,
	        	Opportunity_Planning__c = targetOppPlanning2.Id,
	        	Call_Report_Product_List_Master__c = productMaster_Remittance.id
	        );

	        CBS_OpportunityPlanningWrapper oppWrapper2 = new CBS_OpportunityPlanningWrapper(targetOppPlanning2,new List<Opportunity_Planning_Line_Item__c>{productLineItem2});
			oppWrapper2.oldStatus = GlobalConstants.OPP_PLAN_EXPLORE;

			List<CBS_OpportunityPlanningWrapper> oppPlanningWrapperList = new List<CBS_OpportunityPlanningWrapper>{oppWrapper1,oppWrapper2};
			List<GroupOpportunityPlanningWrapper> groupOpportunityPlanningList = new List<GroupOpportunityPlanningWrapper>{new GroupOpportunityPlanningWrapper(oppPlanningWrapperList)};
			Test.startTest();
				OpportunityPlanning_Service.createOpportunityFromCallReport(targetAccount,callreportObj, oppPlanningWrapperList,groupOpportunityPlanningList);
			Test.stopTest();

			System.assertEquals(2, [SELECT Count() FROM Opportunity_Planning__c]);
			System.assertEquals(2, [SELECT Count() FROM Opportunity_Planning_Line_Item__c]);

			System.assertEquals(1, [SELECT Count() FROM Opportunity]);
			System.assertEquals(2, [SELECT Count() FROM Opportunity_Product_CBS__c]);
		}
	}

	@isTest static void testCreateCallReportCreatOppPlannAddtoExistingOpp() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account targetAccount = [SELECT Id, Name,Customer_s_Business_Code__c FROM Account WHERE Name = :OpportunityPlanning_Test.accountNameRM LIMIT 1];
			Product_List_Master__c productMaster_SBLC = [SELECT Id,Product_Name__c From Product_List_Master__c WHERE  Product_Name__c = :OpportunityPlanning_Test.productName_SBLC LIMIT 1];
			Opportunity existingOpp = new Opportunity(
	            Name = targetAccount.Name, 
	            AccountId = targetAccount.Id,
	            CloseDate = System.today(),
	            Expected_Fee_CBS__c = 100000,
	            Amount = 200000,
	            Project_Size_CBS__c = 300000,
	            Remark__c = 'Remark',
	            Product_List_CBS__c = 'Cash',
	            StageName = GlobalConstants.STOCK_NEGOTIATION
	        );
	        insert existingOpp;

	        List<Opportunity_Planning_Line_Item__c> newLineItems = new List<Opportunity_Planning_Line_Item__c>();

	        TriggerHandler.bypass('CallReportTriggerHandler');
	        Call_Report__c callreportObj = new Call_Report__c(
	            Contact_Firstname__c = 'abc',
	            Contact_Lastname__c = 'def',
	            Contact_Phone__c = '123456789',
	            CIS_ID__c = targetAccount.Id,
	            Status__c = GlobalConstants.PLAN,
	            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
	            Plan_Date__c = System.Today(),
	            Offer_Credit_Product__c = true,
	            Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
	            Customer_Important_Note__c = 'test',
	            Expected_Credit_Amount__c = 600000
	        );
			insert callreportObj;

			Opportunity_Planning__c targetOppPlanning = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE,
		        Remark__c = 'Test Remark',
		        Add_to_Existing_Opportunity__c = existingOpp.Id,
		        Product_List_CBS__c = productMaster_SBLC.Product_Name__c
			);

			Opportunity_Planning_Line_Item__c productLineItem1 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = productMaster_SBLC.Product_Name__c,
	        	Opportunity_Planning__c = targetOppPlanning.Id,
	        	Call_Report_Product_List_Master__c = productMaster_SBLC.id
	        );
	        newLineItems.add(productLineItem1);
	
	        
	        CBS_OpportunityPlanningWrapper eachOppWrapper = new CBS_OpportunityPlanningWrapper(targetOppPlanning,newLineItems);
			eachOppWrapper.oldStatus = GlobalConstants.OPP_PLAN_EXPLORE;
			List<CBS_OpportunityPlanningWrapper> oppPlanningWrapperList = new List<CBS_OpportunityPlanningWrapper>{eachOppWrapper};
			List<GroupOpportunityPlanningWrapper> groupOpportunityPlanningList = new List<GroupOpportunityPlanningWrapper>();
			Test.startTest();
				OpportunityPlanning_Service.createOpportunityFromCallReport(targetAccount,callreportObj, oppPlanningWrapperList,groupOpportunityPlanningList);
			Test.stopTest();

			System.assertEquals(1, [SELECT Count() FROM Opportunity_Planning__c]);
			System.assertEquals(1, [SELECT Count() FROM Opportunity_Planning_Line_Item__c]);

			System.assertEquals(1, [SELECT Count() FROM Opportunity]);
			System.assertEquals(1, [SELECT Count() FROM Opportunity_Product_CBS__c]);
		}
	}

/////////////////////////////// End Call report ////////////////////

	@isTest static void testUpdate2OppPlanWin1OppPlanFromOppTab() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account targetAccount = [SELECT Id, Name FROM Account WHERE Name = :OpportunityPlanning_Test.accountNameRM LIMIT 1];
			Product_List_Master__c productMaster_SBLC = [SELECT Id,Product_Name__c From Product_List_Master__c WHERE Product_Name__c = :OpportunityPlanning_Test.productName_SBLC LIMIT 1];
			Product_List_Master__c productMaster_Remittance = [SELECT Id,Product_Name__c From Product_List_Master__c WHERE  Product_Name__c = :OpportunityPlanning_Test.productName_Remittance LIMIT 1]; 
	        
	        List<Opportunity_Planning_Line_Item__c> newLineItems = new List<Opportunity_Planning_Line_Item__c>();
	        List<Opportunity_Planning_Line_Item__c> newLineItems2 = new List<Opportunity_Planning_Line_Item__c>();

	        TriggerHandler.bypass('CallReportTriggerHandler');
	        Call_Report__c callreportObj = new Call_Report__c(
	            Contact_Firstname__c = 'abc',
	            Contact_Lastname__c = 'def',
	            Contact_Phone__c = '123456789',
	            CIS_ID__c = targetAccount.Id,
	            Status__c = GlobalConstants.PLAN,
	            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
	            Plan_Date__c = System.Today(),
	            Offer_Credit_Product__c = true,
	            Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
	            Customer_Important_Note__c = 'test',
	            Expected_Credit_Amount__c = 600000
	        );
			insert callreportObj;

			Opportunity_Planning__c targetOppPlanning = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_NEGOTIATION,
				Project_Size__c = 100000,
				Expected_Income_to_KBank__c = 100000,
		        Expected_LimitVolume_Amount__c = 100000,
		        Remark__c = 'Test Remark',
		        Product_List_CBS__c = productMaster_SBLC.Product_Name__c
			);
			insert targetOppPlanning;

			Opportunity_Planning_Line_Item__c productLineItem1 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = productMaster_SBLC.Product_Name__c,
	        	Opportunity_Planning__c = targetOppPlanning.Id,
	        	Call_Report_Product_List_Master__c = productMaster_SBLC.id
	        );
	        newLineItems.add(productLineItem1);

	        Opportunity_Planning__c targetOppPlanning2 = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
				Project_Size__c = 100000,
				Expected_Income_to_KBank__c = 100000,
		        Expected_LimitVolume_Amount__c = 100000,
		        Remark__c = 'Test Remark',
		        Product_List_CBS__c = productMaster_Remittance.Product_Name__c
			);
			insert targetOppPlanning2;

			Opportunity_Planning_Line_Item__c productLine2Item1 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = productMaster_Remittance.Product_Name__c,
	        	Opportunity_Planning__c = targetOppPlanning2.Id,
	        	Call_Report_Product_List_Master__c = productMaster_Remittance.id
	        );
	        newLineItems2.add(productLine2Item1);

	        insert newLineItems;
	        insert newLineItems2;

	        targetOppPlanning = [SELECT ID,Product_List_CBS__c,CIS_ID__r.CIS__c,CIS_ID__r.Name,Call_Report_CBS__c,Expected_Income_to_KBank__c,Expected_LimitVolume_Amount__c,Project_Size__c,Status__c,Remark__c,Add_to_Existing_Opportunity__c,Product_Type__c,(SELECT Id,Product_Name__c,Opportunity_Planning__c FROM Opportunity_Planning_Line_Items__r) FROM Opportunity_Planning__c WHERE Id = :targetOppPlanning.Id];
	        targetOppPlanning2 = [SELECT ID,Product_List_CBS__c,CIS_ID__r.CIS__c,CIS_ID__r.Name,Call_Report_CBS__c,Expected_Income_to_KBank__c,Expected_LimitVolume_Amount__c,Project_Size__c,Status__c,Remark__c,Add_to_Existing_Opportunity__c,Product_Type__c,(SELECT Id,Product_Name__c,Opportunity_Planning__c FROM Opportunity_Planning_Line_Items__r) FROM Opportunity_Planning__c WHERE Id = :targetOppPlanning2.Id];
	        targetOppPlanning.Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE;
	        targetOppPlanning2.Status__c = GlobalConstants.OPP_PLAN_REJECTED;

	        Map<Id, List<Opportunity_Planning__c>> oppPlanningMapByCallReport = new Map<Id, List<Opportunity_Planning__c>>{callreportObj.Id => new List<Opportunity_Planning__c>{targetOppPlanning, targetOppPlanning2}};
	        Map<Id, List<Opportunity_Planning_Line_Item__c>> oppLineItemMapByOppPlanning = new Map<Id, List<Opportunity_Planning_Line_Item__c>>{targetOppPlanning.Id => newLineItems};
	        oppLineItemMapByOppPlanning.put(targetOppPlanning2.Id, newLineItems2);
	        Map<Id, Account> accountNameMapByOppPlanning = new Map<Id, Account>{targetOppPlanning.Id => targetAccount};
	        accountNameMapByOppPlanning.put(targetOppPlanning2.Id, targetAccount);

			System.assertEquals(2, [SELECT Count() FROM Opportunity_Planning__c]);
			System.assertEquals(2, [SELECT Count() FROM Opportunity_Planning_Line_Item__c]);

			Map<String,Opportunity_Custom_Controller.OppPlanningWrapper> mapAllGroupedOppPlanningMapByOppPlanId = new Map<String,Opportunity_Custom_Controller.OppPlanningWrapper>(); 
			Map<Integer,GroupOpportunityPlanningWrapper> mapGroupingOppPlanningService = new Map<Integer,GroupOpportunityPlanningWrapper>();
			Map<String,String> mapBusinessCodeByOppPlanId = new Map<String,String>();

			Test.startTest();
				Set<Id> returnedOppIdSet = OpportunityPlanning_Service.createOpportunityFromOpportunityTab(
					oppPlanningMapByCallReport, oppLineItemMapByOppPlanning, accountNameMapByOppPlanning,
					mapAllGroupedOppPlanningMapByOppPlanId, mapGroupingOppPlanningService, mapBusinessCodeByOppPlanId);
				if(returnedOppIdSet != null)
					update oppPlanningMapByCallReport.get(callreportObj.Id);
 			Test.stopTest();

			System.assertEquals(1, [SELECT Count() FROM Opportunity]);
			System.assertEquals(1, [SELECT Count() FROM Opportunity_Product_CBS__c]);
		}
	}

	@isTest static void testUpdate2OppPlanningServiceToExistingOppFromOppTab() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account targetAccount = [SELECT Id, Name FROM Account WHERE Name = :OpportunityPlanning_Test.accountNameRM LIMIT 1];
			Opportunity existingOpp = new Opportunity(
	            Name = targetAccount.Name, 
	            AccountId = targetAccount.Id,
	            CloseDate = System.today(),
	            Expected_Fee_CBS__c = 100000,
	            Amount = 200000,
	            Project_Size_CBS__c = 300000,
	            Remark__c = 'Remark',
	            Product_List_CBS__c = 'Cash',
	            StageName = GlobalConstants.STOCK_NEGOTIATION
	        );
	        insert existingOpp;

			String campaingProductList = 'FX;EDC;SBLC;Cash';
	        String oppPlannignProductList = 'IPO,EDC,FX';
	        List<Opportunity_Planning_Line_Item__c> newLineItems = new List<Opportunity_Planning_Line_Item__c>();
	        List<Opportunity_Planning_Line_Item__c> newLineItems2 = new List<Opportunity_Planning_Line_Item__c>();

	        TriggerHandler.bypass('CallReportTriggerHandler');
	        Call_Report__c callreportObj = new Call_Report__c(
	            Contact_Firstname__c = 'abc',
	            Contact_Lastname__c = 'def',
	            Contact_Phone__c = '123456789',
	            CIS_ID__c = targetAccount.Id,
	            Status__c = GlobalConstants.PLAN,
	            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
	            Plan_Date__c = System.Today(),
	            Offer_Credit_Product__c = true,
	            Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
	            Customer_Important_Note__c = 'test',
	            Expected_Credit_Amount__c = 600000
	        );
			insert callreportObj;

			Opportunity_Planning__c targetOppPlanning = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_NEGOTIATION,
				Project_Size__c = 100000,
				Expected_Income_to_KBank__c = 100000,
		        Expected_LimitVolume_Amount__c = 100000,
		        Remark__c = 'Test Remark',
		        Add_to_Existing_Opportunity__c = existingOpp.Id,
		        Product_List_CBS__c = oppPlannignProductList
			);
			insert targetOppPlanning;

			Opportunity_Planning_Line_Item__c productLineItem1 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'FX',
	        	Opportunity_Planning__c = targetOppPlanning.Id
	        );
	        newLineItems.add(productLineItem1);
	        Opportunity_Planning_Line_Item__c productLineItem2 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'EDC',
	        	Opportunity_Planning__c = targetOppPlanning.Id
	        );
	        newLineItems.add(productLineItem2);
	        Opportunity_Planning_Line_Item__c productLineItem3 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'IPO',
	        	Opportunity_Planning__c = targetOppPlanning.Id
	        );
	        newLineItems.add(productLineItem3);

	        Opportunity_Planning__c targetOppPlanning2 = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
				Project_Size__c = 100000,
				Expected_Income_to_KBank__c = 100000,
		        Expected_LimitVolume_Amount__c = 100000,
		        Remark__c = 'Test Remark',
		        Add_to_Existing_Opportunity__c = existingOpp.Id,
		        Product_List_CBS__c = oppPlannignProductList
			);
			insert targetOppPlanning2;

			Opportunity_Planning_Line_Item__c productLine2Item1 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'FX',
	        	Opportunity_Planning__c = targetOppPlanning2.Id
	        );
	        newLineItems2.add(productLine2Item1);
	        Opportunity_Planning_Line_Item__c productLine2Item2 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'EDC',
	        	Opportunity_Planning__c = targetOppPlanning2.Id
	        );
	        newLineItems2.add(productLine2Item2);
	        Opportunity_Planning_Line_Item__c productLine2Item3 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'IPO',
	        	Opportunity_Planning__c = targetOppPlanning2.Id
	        );
	        newLineItems2.add(productLine2Item3);
	        insert newLineItems;
	        insert newLineItems2;

	        targetOppPlanning = [SELECT ID,Product_List_CBS__c,CIS_ID__r.CIS__c,CIS_ID__r.Name,Call_Report_CBS__c,Expected_Income_to_KBank__c,Expected_LimitVolume_Amount__c,Project_Size__c,Status__c,Remark__c,Add_to_Existing_Opportunity__c,Product_Type__c,(SELECT Id,Product_Name__c,Opportunity_Planning__c FROM Opportunity_Planning_Line_Items__r) FROM Opportunity_Planning__c WHERE Id = :targetOppPlanning.Id];
	        targetOppPlanning2 = [SELECT ID,Product_List_CBS__c,CIS_ID__r.CIS__c,CIS_ID__r.Name,Call_Report_CBS__c,Expected_Income_to_KBank__c,Expected_LimitVolume_Amount__c,Project_Size__c,Status__c,Remark__c,Add_to_Existing_Opportunity__c,Product_Type__c,(SELECT Id,Product_Name__c,Opportunity_Planning__c FROM Opportunity_Planning_Line_Items__r) FROM Opportunity_Planning__c WHERE Id = :targetOppPlanning2.Id];
	        targetOppPlanning.Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE;
	        targetOppPlanning2.Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE;

	        Map<Id, List<Opportunity_Planning__c>> oppPlanningMapByCallReport = new Map<Id, List<Opportunity_Planning__c>>{callreportObj.Id => new List<Opportunity_Planning__c>{targetOppPlanning, targetOppPlanning2}};
	        Map<Id, List<Opportunity_Planning_Line_Item__c>> oppLineItemMapByOppPlanning = new Map<Id, List<Opportunity_Planning_Line_Item__c>>{targetOppPlanning.Id => newLineItems};
	        oppLineItemMapByOppPlanning.put(targetOppPlanning2.Id, newLineItems2);
	        Map<Id, Account> accountNameMapByOppPlanning = new Map<Id, Account>{targetOppPlanning.Id => targetAccount};
	        accountNameMapByOppPlanning.put(targetOppPlanning2.Id, targetAccount);

			System.assertEquals(2, [SELECT Count() FROM Opportunity_Planning__c]);
			System.assertEquals(6, [SELECT Count() FROM Opportunity_Planning_Line_Item__c]);

			Map<String,Opportunity_Custom_Controller.OppPlanningWrapper> mapAllGroupedOppPlanningMapByOppPlanId = new Map<String,Opportunity_Custom_Controller.OppPlanningWrapper>(); 
			Map<Integer,GroupOpportunityPlanningWrapper> mapGroupingOppPlanningService = new Map<Integer,GroupOpportunityPlanningWrapper>();
			Map<String,String> mapBusinessCodeByOppPlanId = new Map<String,String>();


			Test.startTest();
				Set<Id> returnedOppIdSet = OpportunityPlanning_Service.createOpportunityFromOpportunityTab(
					oppPlanningMapByCallReport,oppLineItemMapByOppPlanning,accountNameMapByOppPlanning,
					mapAllGroupedOppPlanningMapByOppPlanId,mapGroupingOppPlanningService,mapBusinessCodeByOppPlanId);
				if(returnedOppIdSet != null)
					update oppPlanningMapByCallReport.get(callreportObj.Id);
 			Test.stopTest();

			System.assertEquals(1, [SELECT Count() FROM Opportunity]);
			System.assertEquals(6, [SELECT Count() FROM Opportunity_Product_CBS__c]);
		}
	}

	@isTest static void testUpdateWin2OppPlanFromOppTab() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account targetAccount = [SELECT Id, Name FROM Account WHERE Name = :OpportunityPlanning_Test.accountNameRM LIMIT 1];
			Opportunity existingOpp = new Opportunity(
	            Name = targetAccount.Name, 
	            AccountId = targetAccount.Id,
	            CloseDate = System.today(),
	            Expected_Fee_CBS__c = 100000,
	            Amount = 200000,
	            Project_Size_CBS__c = 300000,
	            Remark__c = 'Remark',
	            Product_List_CBS__c = 'Cash',
	            StageName = GlobalConstants.STOCK_NEGOTIATION
	        );
	        insert existingOpp;

			String campaingProductList = 'FX;EDC;SBLC;Cash';
	        String oppPlannignProductList = 'IPO,EDC,FX';
	        List<Opportunity_Planning_Line_Item__c> newLineItems = new List<Opportunity_Planning_Line_Item__c>();
	        List<Opportunity_Planning_Line_Item__c> newLineItems2 = new List<Opportunity_Planning_Line_Item__c>();

	        TriggerHandler.bypass('CallReportTriggerHandler');
	        Call_Report__c callreportObj = new Call_Report__c(
	            Contact_Firstname__c = 'abc',
	            Contact_Lastname__c = 'def',
	            Contact_Phone__c = '123456789',
	            CIS_ID__c = targetAccount.Id,
	            Status__c = GlobalConstants.PLAN,
	            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
	            Plan_Date__c = System.Today(),
	            Offer_Credit_Product__c = true,
	            Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
	            Customer_Important_Note__c = 'test',
	            Expected_Credit_Amount__c = 600000
	        );
			insert callreportObj;

			Opportunity_Planning__c targetOppPlanning = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_NEGOTIATION,
				Project_Size__c = 120000,
				Expected_Income_to_KBank__c = 120000,
		        Expected_LimitVolume_Amount__c = 120000,
		        Remark__c = 'Test Remark',
		        Product_List_CBS__c = oppPlannignProductList
			);
			insert targetOppPlanning;

			Opportunity_Planning_Line_Item__c productLineItem1 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'FX',
	        	Opportunity_Planning__c = targetOppPlanning.Id
	        );
	        newLineItems.add(productLineItem1);
	        Opportunity_Planning_Line_Item__c productLineItem2 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'EDC',
	        	Opportunity_Planning__c = targetOppPlanning.Id
	        );
	        newLineItems.add(productLineItem2);
	        Opportunity_Planning_Line_Item__c productLineItem3 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'IPO',
	        	Opportunity_Planning__c = targetOppPlanning.Id
	        );
	        newLineItems.add(productLineItem3);

	        Opportunity_Planning__c targetOppPlanning2 = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_NON_CREDIT,
				Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
				Project_Size__c = 100000,
				Expected_Income_to_KBank__c = 100000,
		        Expected_LimitVolume_Amount__c = 100000,
		        Remark__c = 'Test Remark',
		        Product_List_CBS__c = oppPlannignProductList
			);
			insert targetOppPlanning2;

			Opportunity_Planning_Line_Item__c productLine2Item1 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'FX',
	        	Opportunity_Planning__c = targetOppPlanning2.Id
	        );
	        newLineItems2.add(productLine2Item1);
	        Opportunity_Planning_Line_Item__c productLine2Item2 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'EDC',
	        	Opportunity_Planning__c = targetOppPlanning2.Id
	        );
	        newLineItems2.add(productLine2Item2);
	        Opportunity_Planning_Line_Item__c productLine2Item3 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'IPO',
	        	Opportunity_Planning__c = targetOppPlanning2.Id
	        );
	        newLineItems2.add(productLine2Item3);
	        insert newLineItems;
	        insert newLineItems2;

	        targetOppPlanning = [SELECT ID,Product_List_CBS__c,CIS_ID__r.CIS__c,CIS_ID__r.Name,Call_Report_CBS__c,Expected_Income_to_KBank__c,Expected_LimitVolume_Amount__c,Project_Size__c,Status__c,Remark__c,Add_to_Existing_Opportunity__c,Product_Type__c,(SELECT Id,Product_Name__c,Opportunity_Planning__c FROM Opportunity_Planning_Line_Items__r) FROM Opportunity_Planning__c WHERE Id = :targetOppPlanning.Id];
	        targetOppPlanning2 = [SELECT ID,Product_List_CBS__c,CIS_ID__r.CIS__c,CIS_ID__r.Name,Call_Report_CBS__c,Expected_Income_to_KBank__c,Expected_LimitVolume_Amount__c,Project_Size__c,Status__c,Remark__c,Add_to_Existing_Opportunity__c,Product_Type__c,(SELECT Id,Product_Name__c,Opportunity_Planning__c FROM Opportunity_Planning_Line_Items__r) FROM Opportunity_Planning__c WHERE Id = :targetOppPlanning2.Id];
	        targetOppPlanning.Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE;
	        targetOppPlanning2.Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE;

	        Map<Id, List<Opportunity_Planning__c>> oppPlanningMapByCallReport = new Map<Id, List<Opportunity_Planning__c>>{callreportObj.Id => new List<Opportunity_Planning__c>{targetOppPlanning, targetOppPlanning2}};
	        Map<Id, List<Opportunity_Planning_Line_Item__c>> oppLineItemMapByOppPlanning = new Map<Id, List<Opportunity_Planning_Line_Item__c>>{targetOppPlanning.Id => newLineItems};
	        oppLineItemMapByOppPlanning.put(targetOppPlanning2.Id, newLineItems2);
	        Map<Id, Account> accountNameMapByOppPlanning = new Map<Id, Account>{targetOppPlanning.Id => targetAccount};
	        accountNameMapByOppPlanning.put(targetOppPlanning2.Id, targetAccount);

			System.assertEquals(2, [SELECT Count() FROM Opportunity_Planning__c]);
			System.assertEquals(6, [SELECT Count() FROM Opportunity_Planning_Line_Item__c]);

			Map<String,Opportunity_Custom_Controller.OppPlanningWrapper> mapAllGroupedOppPlanningMapByOppPlanId = new Map<String,Opportunity_Custom_Controller.OppPlanningWrapper>(); 
			Map<Integer,GroupOpportunityPlanningWrapper> mapGroupingOppPlanningService = new Map<Integer,GroupOpportunityPlanningWrapper>();
			Map<String,String> mapBusinessCodeByOppPlanId = new Map<String,String>();

			Test.startTest();
				Set<Id> returnedOppIdSet = OpportunityPlanning_Service.createOpportunityFromOpportunityTab(
					oppPlanningMapByCallReport, oppLineItemMapByOppPlanning, accountNameMapByOppPlanning,
					mapAllGroupedOppPlanningMapByOppPlanId,mapGroupingOppPlanningService,mapBusinessCodeByOppPlanId
					);
				if(returnedOppIdSet != null)
					update oppPlanningMapByCallReport.get(callreportObj.Id);
 			Test.stopTest();

			System.assertEquals(3, [SELECT Count() FROM Opportunity]);
			System.assertEquals(6, [SELECT Count() FROM Opportunity_Product_CBS__c]);
		}
	}

	@isTest static void testUpdateOppPlanningServiceFromOppTab() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account targetAccount = [SELECT Id, Name FROM Account WHERE Name = :OpportunityPlanning_Test.accountNameRM LIMIT 1];

			String campaingProductList = 'FX;EDC;SBLC;Cash';
	        String oppPlannignProductList = 'IPO,EDC,FX';
	        List<Opportunity_Planning_Line_Item__c> newLineItems = new List<Opportunity_Planning_Line_Item__c>();

	        TriggerHandler.bypass('CallReportTriggerHandler');
	        Call_Report__c callreportObj = new Call_Report__c(
	            Contact_Firstname__c = 'abc',
	            Contact_Lastname__c = 'def',
	            Contact_Phone__c = '123456789',
	            CIS_ID__c = targetAccount.Id,
	            Status__c = GlobalConstants.PLAN,
	            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
	            Plan_Date__c = System.Today(),
	            Offer_Credit_Product__c = true,
	            Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
	            Customer_Important_Note__c = 'test',
	            Expected_Credit_Amount__c = 600000
	        );
			insert callreportObj;

			Opportunity_Planning__c targetOppPlanning = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE,
				Project_Size__c = 100000,
				Expected_Income_to_KBank__c = 100000,
		        Expected_LimitVolume_Amount__c = 100000,
		        Remark__c = 'Test Remark',
		        Product_List_CBS__c = oppPlannignProductList
			);
			insert targetOppPlanning;

			Opportunity_Planning_Line_Item__c productLineItem1 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'FX',
	        	Opportunity_Planning__c = targetOppPlanning.Id
	        );
	        newLineItems.add(productLineItem1);
	        Opportunity_Planning_Line_Item__c productLineItem2 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'EDC',
	        	Opportunity_Planning__c = targetOppPlanning.Id
	        );
	        newLineItems.add(productLineItem2);
	        Opportunity_Planning_Line_Item__c productLineItem3 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = 'IPO',
	        	Opportunity_Planning__c = targetOppPlanning.Id
	        );
	        newLineItems.add(productLineItem3);
	        insert newLineItems;

	        targetOppPlanning = [SELECT ID,Product_List_CBS__c,CIS_ID__r.CIS__c,CIS_ID__r.Name,Call_Report_CBS__c,Expected_Income_to_KBank__c,Expected_LimitVolume_Amount__c,Project_Size__c,Status__c,Remark__c,Add_to_Existing_Opportunity__c,Product_Type__c,Fee__c,New_Limit__c,Volume_Outstanding__c,Front_End_Fee__c,(SELECT Id,Product_Name__c,Opportunity_Planning__c FROM Opportunity_Planning_Line_Items__r) FROM Opportunity_Planning__c WHERE Id = :targetOppPlanning.Id];

	        Map<Id, List<Opportunity_Planning__c>> oppPlanningMapByCallReport = new Map<Id, List<Opportunity_Planning__c>>{callreportObj.Id => new List<Opportunity_Planning__c>{targetOppPlanning}};
	        Map<Id, List<Opportunity_Planning_Line_Item__c>> oppLineItemMapByOppPlanning = new Map<Id, List<Opportunity_Planning_Line_Item__c>>{targetOppPlanning.Id => newLineItems};
	        Map<Id, Account> accountNameMapByOppPlanning = new Map<Id, Account>{targetOppPlanning.Id => targetAccount};


			System.assertEquals(1, [SELECT Count() FROM Opportunity_Planning__c]);
			System.assertEquals(3, [SELECT Count() FROM Opportunity_Planning_Line_Item__c]);

			Map<String,Opportunity_Custom_Controller.OppPlanningWrapper> mapAllGroupedOppPlanningMapByOppPlanId = new Map<String,Opportunity_Custom_Controller.OppPlanningWrapper>(); 
			Map<Integer,GroupOpportunityPlanningWrapper> mapGroupingOppPlanningService = new Map<Integer,GroupOpportunityPlanningWrapper>();
			Map<String,String> mapBusinessCodeByOppPlanId = new Map<String,String>();

			Test.startTest();
				OpportunityPlanning_Service.createOpportunityFromOpportunityTab(
					oppPlanningMapByCallReport, oppLineItemMapByOppPlanning, accountNameMapByOppPlanning,
					mapAllGroupedOppPlanningMapByOppPlanId,mapGroupingOppPlanningService,mapBusinessCodeByOppPlanId);
			Test.stopTest();

			System.assertEquals(1, [SELECT Count() FROM Opportunity]);
			System.assertEquals(3, [SELECT Count() FROM Opportunity_Product_CBS__c]);
		}
	}

	@isTest static void testGroupOpportunityPlanningFromOppTab(){
	
			System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Account targetAccount = [SELECT Id, Name FROM Account WHERE Name = :OpportunityPlanning_Test.accountNameRM LIMIT 1];
			Product_List_Master__c productMaster_SBLC = [SELECT Id,Product_Name__c From Product_List_Master__c WHERE Product_Name__c = :OpportunityPlanning_Test.productName_SBLC LIMIT 1];
			Product_List_Master__c productMaster_Remittance = [SELECT Id,Product_Name__c From Product_List_Master__c WHERE  Product_Name__c = :OpportunityPlanning_Test.productName_Remittance LIMIT 1]; 
	        
	        List<Opportunity_Planning_Line_Item__c> newLineItems = new List<Opportunity_Planning_Line_Item__c>();
	        List<Opportunity_Planning_Line_Item__c> newLineItems2 = new List<Opportunity_Planning_Line_Item__c>();

	        TriggerHandler.bypass('CallReportTriggerHandler');
	        Call_Report__c callreportObj = new Call_Report__c(
	            Contact_Firstname__c = 'abc',
	            Contact_Lastname__c = 'def',
	            Contact_Phone__c = '123456789',
	            CIS_ID__c = targetAccount.Id,
	            Status__c = GlobalConstants.PLAN,
	            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
	            Plan_Date__c = System.Today(),
	            Offer_Credit_Product__c = true,
	            Offer_Interest__c = GlobalConstants.OFFER_INTEREST_AND_CAN_APPLY,
	            Customer_Important_Note__c = 'test',
	            Expected_Credit_Amount__c = 600000
	        );
			insert callreportObj;

			Opportunity_Planning__c targetOppPlanning = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
				Project_Size__c = 100000,
				Expected_Income_to_KBank__c = 100000,
		        Expected_LimitVolume_Amount__c = 100000,
		        Remark__c = 'Test Remark',
		        Product_List_CBS__c = productMaster_SBLC.Product_Name__c
			);
			insert targetOppPlanning;

			Opportunity_Planning_Line_Item__c productLineItem1 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = productMaster_SBLC.Product_Name__c,
	        	Opportunity_Planning__c = targetOppPlanning.Id,
	        	Call_Report_Product_List_Master__c = productMaster_SBLC.id
	        );
	        newLineItems.add(productLineItem1);

	        Opportunity_Planning__c targetOppPlanning2 = new Opportunity_Planning__c(
				Call_Report_CBS__c = callreportObj.Id,
				CIS_ID__c = targetAccount.Id,
				Product_Type__c = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,
				Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
				Project_Size__c = 100000,
				Expected_Income_to_KBank__c = 100000,
		        Expected_LimitVolume_Amount__c = 100000,
		        Remark__c = 'Test Remark',
		        Product_List_CBS__c = productMaster_Remittance.Product_Name__c
			);
			insert targetOppPlanning2;

			Opportunity_Planning_Line_Item__c productLine2Item1 = new Opportunity_Planning_Line_Item__c(
	        	Product_Name__c  = productMaster_Remittance.Product_Name__c,
	        	Opportunity_Planning__c = targetOppPlanning2.Id,
	        	Call_Report_Product_List_Master__c = productMaster_Remittance.id
	        );
	        newLineItems2.add(productLine2Item1);

	        insert newLineItems;
	        insert newLineItems2;

	        targetOppPlanning = [SELECT ID,Product_List_CBS__c,CIS_ID__r.CIS__c,CIS_ID__r.Name,Call_Report_CBS__c,Expected_Income_to_KBank__c,Expected_LimitVolume_Amount__c,Project_Size__c,Status__c,Remark__c,Add_to_Existing_Opportunity__c,Product_Type__c,(SELECT Id,Product_Name__c,Opportunity_Planning__c FROM Opportunity_Planning_Line_Items__r) FROM Opportunity_Planning__c WHERE Id = :targetOppPlanning.Id];
	        targetOppPlanning2 = [SELECT ID,Product_List_CBS__c,CIS_ID__r.CIS__c,CIS_ID__r.Name,Call_Report_CBS__c,Expected_Income_to_KBank__c,Expected_LimitVolume_Amount__c,Project_Size__c,Status__c,Remark__c,Add_to_Existing_Opportunity__c,Product_Type__c,(SELECT Id,Product_Name__c,Opportunity_Planning__c FROM Opportunity_Planning_Line_Items__r) FROM Opportunity_Planning__c WHERE Id = :targetOppPlanning2.Id];

	        Map<Id, List<Opportunity_Planning__c>> oppPlanningMapByCallReport = new Map<Id, List<Opportunity_Planning__c>>{callreportObj.Id => new List<Opportunity_Planning__c>{targetOppPlanning, targetOppPlanning2}};
	        Map<Id, List<Opportunity_Planning_Line_Item__c>> oppLineItemMapByOppPlanning = new Map<Id, List<Opportunity_Planning_Line_Item__c>>{targetOppPlanning.Id => newLineItems};
	        oppLineItemMapByOppPlanning.put(targetOppPlanning2.Id, newLineItems2);
	        Map<Id, Account> accountNameMapByOppPlanning = new Map<Id, Account>{targetOppPlanning.Id => targetAccount};
	        accountNameMapByOppPlanning.put(targetOppPlanning2.Id, targetAccount);

			System.assertEquals(2, [SELECT Count() FROM Opportunity_Planning__c]);
			System.assertEquals(2, [SELECT Count() FROM Opportunity_Planning_Line_Item__c]);

		}

		Opportunity_Custom_Controller oppCustomContoller = new Opportunity_Custom_Controller();
		oppCustomContoller.oppPlanningWrapperList.get(0).isChecked = true;
		oppCustomContoller.oppPlanningWrapperList.get(0).newOppPlanning.Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE;
		oppCustomContoller.oppPlanningWrapperList.get(1).isChecked = true;
		oppCustomContoller.oppPlanningWrapperList.get(1).newOppPlanning.Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE;
		oppCustomContoller.groupOppPlanning();
		Test.startTest();
			oppCustomContoller.saveAll();
		Test.stopTest();

		System.assertEquals(1, [SELECT Count() FROM Opportunity]);
		System.assertEquals(2, [SELECT Count() FROM Opportunity_Product_CBS__c]);


	}

    public static void initOppPlanCustomSetting(){
        List<Opportunity_Planning_Type__c> oppPlanCSList = new List<Opportunity_Planning_Type__c>();
        Opportunity_Planning_Type__c oppPlanCS = Mockup_Test.newOpplanningCustomSetting('New Booking',GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,true,true,GlobalConstants.NEW_CREDIT,'New_Limit__c','Credit');
        Opportunity_Planning_Type__c oppPlanCS2 = Mockup_Test.newOpplanningCustomSetting('Non-Credit',GlobalConstants.OPP_PLAN_NON_CREDIT,false,false,null,'New_Limit__c','Non-Credit');
         Opportunity_Planning_Type__c oppPlanCS3 = Mockup_Test.newOpplanningCustomSetting('Renew',GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_RENEW,true,false,GlobalConstants.RENEW_SERVICING,'New_Limit__c','Credit');
        oppPlanCSList.add(oppPlanCS);
        oppPlanCSList.add(oppPlanCS2);
        oppPlanCSList.add(oppPlanCS3);
        insert oppPlanCSList;
    }
}