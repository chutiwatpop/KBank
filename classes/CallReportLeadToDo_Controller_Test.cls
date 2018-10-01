@isTest
private class CallReportLeadToDo_Controller_Test {
	public static final String ANSWER1 = 'Answer1';
	public static final String ANSWER2 = 'Answer2';
	public static final String ANSWER_OFFER_CUSTOMER_1 = '1. '+GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER+ANSWER1;
	public static final String ANSWER_OFFER_CUSTOMER_2 = '2. '+GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER+ANSWER2;
	public static final String ANSWER_DPD_1 = '1. '+GlobalConstants.LEAD_SUB_TYPE_DPD+ANSWER1;
	public static final String ANSWER_DPD_2 = '2. '+GlobalConstants.LEAD_SUB_TYPE_DPD+ANSWER2;
	private static final String SELECT_NONE = '-';

	@testSetup static void setupUser(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
    }

    private static void createListAnswer(String campaignCode){
    	System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            List<Lead_To_Do_Response__c> listAnswer = new List<Lead_To_Do_Response__c>();

            listAnswer.add(createAnswer(campaignCode,ANSWER_OFFER_CUSTOMER_1,'1. '+campaignCode+ANSWER1+'-1',true,false));
            listAnswer.add(createAnswer(campaignCode,ANSWER_OFFER_CUSTOMER_1,'2. '+campaignCode+ANSWER1+'-2',true,false));
            listAnswer.add(createAnswer(campaignCode,ANSWER_OFFER_CUSTOMER_1,'3. '+campaignCode+ANSWER1+'-3',true,true));
            listAnswer.add(createAnswer(campaignCode,ANSWER_OFFER_CUSTOMER_2,'1. '+campaignCode+ANSWER2+'-1',true,false));
            listAnswer.add(createAnswer(campaignCode,ANSWER_OFFER_CUSTOMER_2,'2. '+campaignCode+ANSWER2+'-2',true,false));
            listAnswer.add(createAnswer(campaignCode,ANSWER_OFFER_CUSTOMER_2,'3. '+campaignCode+ANSWER2+'-3',true,false));
            listAnswer.add(createAnswer(campaignCode,ANSWER_OFFER_CUSTOMER_2,'4. '+campaignCode+ANSWER2+'-4',true,false));
            listAnswer.add(createAnswer(campaignCode,ANSWER_OFFER_CUSTOMER_2,'5. '+campaignCode+ANSWER2+'-5',true,false));
            
            //listAnswer.add(createAnswer(GlobalConstants.LEAD_SUB_TYPE_DPD,ANSWER_DPD_1,'1. '+GlobalConstants.LEAD_SUB_TYPE_DPD+ANSWER1+'-1',true,false));
            //listAnswer.add(createAnswer(GlobalConstants.LEAD_SUB_TYPE_DPD,ANSWER_DPD_1,'2. '+GlobalConstants.LEAD_SUB_TYPE_DPD+ANSWER1+'-2',true,false));
            //listAnswer.add(createAnswer(GlobalConstants.LEAD_SUB_TYPE_DPD,ANSWER_DPD_1,'3. '+GlobalConstants.LEAD_SUB_TYPE_DPD+ANSWER1+'-3',true,false));
            //listAnswer.add(createAnswer(GlobalConstants.LEAD_SUB_TYPE_DPD,ANSWER_DPD_2,'1. '+GlobalConstants.LEAD_SUB_TYPE_DPD+ANSWER2+'-1',true,false));
            //listAnswer.add(createAnswer(GlobalConstants.LEAD_SUB_TYPE_DPD,ANSWER_DPD_2,'2. '+GlobalConstants.LEAD_SUB_TYPE_DPD+ANSWER2+'-2',true,false));
            //listAnswer.add(createAnswer(GlobalConstants.LEAD_SUB_TYPE_DPD,ANSWER_DPD_2,'3. '+GlobalConstants.LEAD_SUB_TYPE_DPD+ANSWER2+'-3',true,false));
            //listAnswer.add(createAnswer(GlobalConstants.LEAD_SUB_TYPE_DPD,ANSWER_DPD_2,'4. '+GlobalConstants.LEAD_SUB_TYPE_DPD+ANSWER2+'-4',true,false));
            //listAnswer.add(createAnswer(GlobalConstants.LEAD_SUB_TYPE_DPD,ANSWER_DPD_2,'5. '+GlobalConstants.LEAD_SUB_TYPE_DPD+ANSWER2+'-5',true,false));
            
            insert listAnswer;
        }
    }

    private static Lead_To_Do_Response__c createAnswer(String campaignCode,String answer_1,String answer_2,Boolean require2,Boolean requireMemo){
    	Lead_To_Do_Response__c newAnswer = new Lead_To_Do_Response__c();
    	//newAnswer.Type__c = type;
    	newAnswer.Campaign_Code__c = campaignCode;
    	newAnswer.Response_Level_1__c = answer_1;
    	newAnswer.Response_Level_2__c = answer_2;
    	newAnswer.Required_Level_2__c = require2;
    	newAnswer.Required_Memo__c = requireMemo;
    	newAnswer.Team__c = 'SME';
    	return newAnswer;
    }

	@isTest static void testCallReportLeadHasLeadTypeToDoAndForSalesThenListCustomCallReportLeadOnlyToDo() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		createListAnswer('leadToDoSubTypeOfferCustomer');
		System.runAs(adminUser){
			Campaign leadToDoSubTypeOfferCustomer = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadToDoSubTypeOfferCustomer', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);
			Campaign leadForSales = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadForSales', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
			listCampaign.add(leadToDoSubTypeOfferCustomer);
			listCampaign.add(leadForSales);
			insert listCampaign;

			Target_List__c targetListLeadToDo = Mockup_Test.newTargetList(newAccount1.Id, leadToDoSubTypeOfferCustomer.Id, 'externalId1', 'New');
			Target_List__c targetListForSales = Mockup_Test.newTargetList(newAccount1.Id, leadForSales.Id, 'externalId2', 'New');
			listTargetList.add(targetListLeadToDo);
			listTargetList.add(targetListForSales);
			insert listTargetList;
		}

		Call_Report__c newReport = new Call_Report__c();

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}
			
		System.runAs(adminUser){
			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));

			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.size());
			System.assertEquals(false,callReportLeadController.refreshPage);
			System.assertEquals(true,callReportLeadController.hasData);
		}
			
		
		Test.stopTest();
	}

	@isTest static void testCallReportLeadNoLeadTypeToDoThenHasDataEqualFalse() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		Campaign leadForSales = new Campaign();
		Target_List__c targetListForSales = new Target_List__c();

		System.runAs(adminUser){
			leadForSales = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadForSales', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_FOR_SALES, GlobalConstants.LEAD_SUB_TYPE_STRONG_FORMULA);
			listCampaign.add(leadForSales);
			insert listCampaign;

			targetListForSales = Mockup_Test.newTargetList(newAccount1.Id, leadForSales.Id, 'externalId2', 'New');
			listTargetList.add(targetListForSales);
			insert listTargetList;
		}

		Call_Report__c newReport = new Call_Report__c();

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}
			
		System.runAs(adminUser){
			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));

			System.assertEquals(new List<CallReportLeadToDo_Controller.CustomCallReportLeadObject>(),callReportLeadController.listCustomCallReportLead);
			System.assertEquals(false,callReportLeadController.hasData);
		}
		Test.stopTest();
	}

	@isTest static void testCallReportLeadLeadTypeToDoAndLeadSubtypeOfferCustomerThenGetListAnswerLevel1TypeOfferCustomerEqual3AndGetListAnswerLevel2TypeOfferCustomerEqual1() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		Campaign leadToDoSubTypeOfferCustomer = new Campaign();
		Target_List__c targetListLeadToDo = new Target_List__c();
		createListAnswer('leadToDoSubTypeOfferCustomer');
		System.runAs(adminUser){
			leadToDoSubTypeOfferCustomer = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadToDoSubTypeOfferCustomer', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);			
			listCampaign.add(leadToDoSubTypeOfferCustomer);
			insert listCampaign;

			targetListLeadToDo = Mockup_Test.newTargetList(newAccount1.Id, leadToDoSubTypeOfferCustomer.Id, 'externalId1', 'New');
			listTargetList.add(targetListLeadToDo);
			insert listTargetList;
		}

		Call_Report__c newReport = new Call_Report__c();

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}
			
			
		System.runAs(adminUser){
			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));

			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.size());
			System.assertEquals(false,callReportLeadController.refreshPage);
			System.assertEquals(true,callReportLeadController.hasData);
			System.assertEquals(3,callReportLeadController.listCustomCallReportLead.get(0).listLevel1.size());
			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
		}
		Test.stopTest();
	}

	@isTest static void testCallReportLeadLeadTypeToDoAndLeadSubtypeOfferCustomerLevel1Answer1ThenGetListAnswerLevel1TypeOfferCustomerEqual3AndGetListAnswerLevel2TypeOfferCustomerEqual4() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		Campaign leadToDoSubTypeOfferCustomer = new Campaign();
		Target_List__c targetListLeadToDo = new Target_List__c();
		createListAnswer('leadToDoSubTypeOfferCustomer');
		System.runAs(adminUser){
			leadToDoSubTypeOfferCustomer = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadToDoSubTypeOfferCustomer', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);			
			listCampaign.add(leadToDoSubTypeOfferCustomer);
			insert listCampaign;

			targetListLeadToDo = Mockup_Test.newTargetList(newAccount1.Id, leadToDoSubTypeOfferCustomer.Id, 'externalId1', 'New');
			targetListLeadToDo.Response_Level_1__c = ANSWER_OFFER_CUSTOMER_1;
			listTargetList.add(targetListLeadToDo);
			insert listTargetList;
		}

		Call_Report__c newReport = new Call_Report__c();

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}
			
			
		System.runAs(adminUser){
			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));

			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.size());
			System.assertEquals(false,callReportLeadController.refreshPage);
			System.assertEquals(true,callReportLeadController.hasData);
			System.assertEquals(3,callReportLeadController.listCustomCallReportLead.get(0).listLevel1.size());
			System.assertEquals(4,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isRequireLv2);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isRequireMemo);
		}
		Test.stopTest();
	}

	@isTest static void testCallReportLeadLeadTypeToDoAndLeadSubtypeOfferCustomerLevel1Answer2ThenGetListAnswerLevel1TypeOfferCustomerEqual3AndGetListAnswerLevel2TypeOfferCustomerEqual6() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		Campaign leadToDoSubTypeOfferCustomer = new Campaign();
		Target_List__c targetListLeadToDo = new Target_List__c();
		createListAnswer('leadToDoSubTypeOfferCustomer');
		System.runAs(adminUser){
			leadToDoSubTypeOfferCustomer = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadToDoSubTypeOfferCustomer', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);			
			listCampaign.add(leadToDoSubTypeOfferCustomer);
			insert listCampaign;

			targetListLeadToDo = Mockup_Test.newTargetList(newAccount1.Id, leadToDoSubTypeOfferCustomer.Id, 'externalId1', 'New');
			targetListLeadToDo.Response_Level_1__c = ANSWER_OFFER_CUSTOMER_2;
			listTargetList.add(targetListLeadToDo);
			insert listTargetList;
		}

		Call_Report__c newReport = new Call_Report__c();

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}

			
		System.runAs(adminUser){

			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));

			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.size());
			System.assertEquals(false,callReportLeadController.refreshPage);
			System.assertEquals(true,callReportLeadController.hasData);
			System.debug('callReportLeadController.listCustomCallReportLead.get(0).listLevel1 = '+callReportLeadController.listCustomCallReportLead.get(0).listLevel1);
			System.assertEquals(3,callReportLeadController.listCustomCallReportLead.get(0).listLevel1.size());
			System.assertEquals(6,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isRequireLv2);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isRequireMemo);

		}
		Test.stopTest();
	}

	@isTest static void testCallReportLeadLeadTypeToDoAndLeadSubtypeOfferCustomerLevel1Answer1ThenGetListAnswerLevel1TypeOfferCustomerEqual3AndGetListAnswerLevel2TypeOfferCustomerEqual4AndSelectAnswerLevel1ToAnswer2ThenGetListAnswerLevel2TypeOfferCustomerEqual6() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		Campaign leadToDoSubTypeOfferCustomer = new Campaign();
		Target_List__c targetListLeadToDo = new Target_List__c();
		createListAnswer('leadToDoSubTypeOfferCustomer');
		System.runAs(adminUser){
			leadToDoSubTypeOfferCustomer = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadToDoSubTypeOfferCustomer', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);			
			listCampaign.add(leadToDoSubTypeOfferCustomer);
			insert listCampaign;

			targetListLeadToDo = Mockup_Test.newTargetList(newAccount1.Id, leadToDoSubTypeOfferCustomer.Id, 'externalId1', 'New');
			targetListLeadToDo.Response_Level_1__c = ANSWER_OFFER_CUSTOMER_1;
			listTargetList.add(targetListLeadToDo);
			insert listTargetList;
		}

		Call_Report__c newReport = new Call_Report__c();

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}
			
			
			
		System.runAs(adminUser){
			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));

			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.size());
			System.assertEquals(false,callReportLeadController.refreshPage);
			System.assertEquals(true,callReportLeadController.hasData);
			System.assertEquals(3,callReportLeadController.listCustomCallReportLead.get(0).listLevel1.size());
			System.assertEquals(4,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isRequireLv2);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isRequireMemo);

			Call_Report_Lead__c callReportLead = callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData; 
			callReportLead.Target_List__r.Response_Level_1__c = ANSWER_OFFER_CUSTOMER_2;
			apexpages.currentpage().getParameters().put('clickedId',callReportLead.Id);
			callReportLeadController.loadListLevel2ByCampaignCodeAndLevel1();
			System.assertEquals(6,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isEditMode);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
		}
		Test.stopTest();
	}

	@isTest static void testCallReportLeadLeadTypeToDoAndLeadSubtypeOfferCustomerLevel1Answer1ThenGetListAnswerLevel1TypeOfferCustomerEqual3AndGetListAnswerLevel2TypeOfferCustomerEqual4AndSelectAnswerLevel1ToSelectNoneThenGetListAnswerLevel2TypeOfferCustomerEqual1() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		Campaign leadToDoSubTypeOfferCustomer = new Campaign();
		Target_List__c targetListLeadToDo = new Target_List__c();
		createListAnswer('leadToDoSubTypeOfferCustomer');
		System.runAs(adminUser){
			leadToDoSubTypeOfferCustomer = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadToDoSubTypeOfferCustomer', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);			
			listCampaign.add(leadToDoSubTypeOfferCustomer);
			insert listCampaign;

			targetListLeadToDo = Mockup_Test.newTargetList(newAccount1.Id, leadToDoSubTypeOfferCustomer.Id, 'externalId1', 'New');
			targetListLeadToDo.Response_Level_1__c = ANSWER_OFFER_CUSTOMER_1;
			listTargetList.add(targetListLeadToDo);
			insert listTargetList;
		}

		Call_Report__c newReport = new Call_Report__c();

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}
			
			
		System.runAs(adminUser){
			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));

			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.size());
			System.assertEquals(false,callReportLeadController.refreshPage);
			System.assertEquals(true,callReportLeadController.hasData);
			System.assertEquals(3,callReportLeadController.listCustomCallReportLead.get(0).listLevel1.size());
			System.assertEquals(4,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isRequireLv2);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isRequireMemo);


			Call_Report_Lead__c callReportLead = callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData; 
			callReportLead.Target_List__r.Response_Level_1__c = SELECT_NONE;
			apexpages.currentpage().getParameters().put('clickedId',callReportLead.Id);
			callReportLeadController.loadListLevel2ByCampaignCodeAndLevel1();
			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isEditMode);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
		}
		Test.stopTest();
	}

	@isTest static void testCallReportLeadLeadTypeToDoAndLeadSubtypeOfferCustomerLevel1Answer1AndSelectLevel2RequireMemoAndCallCheckMemoThenIsRequireMemoTrue() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		Campaign leadToDoSubTypeOfferCustomer = new Campaign();
		Target_List__c targetListLeadToDo = new Target_List__c();
		createListAnswer('leadToDoSubTypeOfferCustomer');
		System.runAs(adminUser){
			leadToDoSubTypeOfferCustomer = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadToDoSubTypeOfferCustomer', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);			
			listCampaign.add(leadToDoSubTypeOfferCustomer);
			insert listCampaign;

			targetListLeadToDo = Mockup_Test.newTargetList(newAccount1.Id, leadToDoSubTypeOfferCustomer.Id, 'externalId1', 'New');
			targetListLeadToDo.Response_Level_1__c = ANSWER_OFFER_CUSTOMER_1;
			listTargetList.add(targetListLeadToDo);
			insert listTargetList;
		}

		Call_Report__c newReport = new Call_Report__c();

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}
			
			
		System.runAs(adminUser){
			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));

			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.size());
			System.assertEquals(false,callReportLeadController.refreshPage);
			System.assertEquals(true,callReportLeadController.hasData);
			System.assertEquals(3,callReportLeadController.listCustomCallReportLead.get(0).listLevel1.size());
			System.assertEquals(4,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isRequireLv2);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isRequireMemo);


			Call_Report_Lead__c callReportLead = callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData; 
			callReportLead.Target_List__r.Response_Level_2__c = '3. '+'leadToDoSubTypeOfferCustomer'+ANSWER1+'-3';
			apexpages.currentpage().getParameters().put('clickedId',callReportLead.Id);
			callReportLeadController.checkMemo();
			callReportLeadController.checkRequireMemo();
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isEditMode);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isRequireLv2);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isRequireMemo);
		}
		Test.stopTest();
	}

	@isTest static void testCallReportLeadLeadTypeToDoAndLeadSubtypeOfferCustomerLevel1Answer1AndSelectLevel2RequireMemoAndChangeAnswerLevel2ToSelectNoneThenIsRequireMemoFalse() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		Campaign leadToDoSubTypeOfferCustomer = new Campaign();
		Target_List__c targetListLeadToDo = new Target_List__c();
		createListAnswer('leadToDoSubTypeOfferCustomer');
		System.runAs(adminUser){
			leadToDoSubTypeOfferCustomer = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadToDoSubTypeOfferCustomer', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);			
			listCampaign.add(leadToDoSubTypeOfferCustomer);
			insert listCampaign;

			targetListLeadToDo = Mockup_Test.newTargetList(newAccount1.Id, leadToDoSubTypeOfferCustomer.Id, 'externalId1', 'New');
			targetListLeadToDo.Response_Level_1__c = ANSWER_OFFER_CUSTOMER_1;
			listTargetList.add(targetListLeadToDo);
			insert listTargetList;
		}

		Call_Report__c newReport = new Call_Report__c();

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}
			
			
		System.runAs(adminUser){
			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));

			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.size());
			System.assertEquals(false,callReportLeadController.refreshPage);
			System.assertEquals(true,callReportLeadController.hasData);
			System.assertEquals(3,callReportLeadController.listCustomCallReportLead.get(0).listLevel1.size());
			System.assertEquals(4,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isRequireLv2);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isRequireMemo);


			Call_Report_Lead__c callReportLead = callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData; 
			callReportLead.Target_List__r.Response_Level_2__c = SELECT_NONE;
			apexpages.currentpage().getParameters().put('clickedId',callReportLead.Id);
			callReportLeadController.checkMemo();
			callReportLeadController.checkRequireMemo();
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isEditMode);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isRequireLv2);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isRequireMemo);
		}
		Test.stopTest();
	}

	@isTest static void testCallReportLeadLeadTypeToDoAndLeadSubtypeOfferCustomerAnswerLevel2IsRequireButNotAnswerThenSaveThenErrorMsgNotNullAndShowErrorIsTrue() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		Campaign leadToDoSubTypeOfferCustomer = new Campaign();
		Target_List__c targetListLeadToDo = new Target_List__c();
		createListAnswer('leadToDoSubTypeOfferCustomer');
		System.runAs(adminUser){
			leadToDoSubTypeOfferCustomer = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadToDoSubTypeOfferCustomer', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);			
			listCampaign.add(leadToDoSubTypeOfferCustomer);
			insert listCampaign;

			targetListLeadToDo = Mockup_Test.newTargetList(newAccount1.Id, leadToDoSubTypeOfferCustomer.Id, 'externalId1', 'New');
			targetListLeadToDo.Response_Level_1__c = ANSWER_OFFER_CUSTOMER_1;
			listTargetList.add(targetListLeadToDo);
			insert listTargetList;
		}

		Call_Report__c newReport = new Call_Report__c();

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}	
			
		System.runAs(adminUser){
			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));

			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.size());
			System.assertEquals(false,callReportLeadController.refreshPage);
			System.assertEquals(true,callReportLeadController.hasData);
			System.assertEquals(3,callReportLeadController.listCustomCallReportLead.get(0).listLevel1.size());
			System.assertEquals(4,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isRequireLv2);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isRequireMemo);

			Call_Report_Lead__c callReportLead = callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData; 
			callReportLead.Target_List__r.Response_Level_2__c = SELECT_NONE;
			callReportLeadController.save();
			
			System.assertEquals(true,callReportLeadController.showError);
		}

		Test.stopTest();
	}

	@isTest static void testCallReportLeadLeadTypeToDoAndLeadSubtypeOfferCustomerAnswerLevel1AndAnswerLevel2AndMemoAndSaveThenUpdateCallReportLeadAndTargetList() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		Campaign leadToDoSubTypeOfferCustomer = new Campaign();
		Target_List__c targetListLeadToDo = new Target_List__c();
		Call_Report__c newReport = new Call_Report__c();
		createListAnswer('leadToDoSubTypeOfferCustomer');
		System.runAs(adminUser){
			leadToDoSubTypeOfferCustomer = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadToDoSubTypeOfferCustomer', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);			
			listCampaign.add(leadToDoSubTypeOfferCustomer);
			insert listCampaign;

			targetListLeadToDo = Mockup_Test.newTargetList(newAccount1.Id, leadToDoSubTypeOfferCustomer.Id, 'externalId1', 'New');
			listTargetList.add(targetListLeadToDo);
			insert listTargetList;
		}

		

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}	

		System.runAs(adminUser){	
			

			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));

			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.size());
			System.assertEquals(false,callReportLeadController.refreshPage);
			System.assertEquals(true,callReportLeadController.hasData);
			System.assertEquals(3,callReportLeadController.listCustomCallReportLead.get(0).listLevel1.size());
			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isRequireLv2);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isRequireMemo);

			Call_Report_Lead__c callReportLead = callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData; 
			callReportLead.Target_List__r.Response_Level_1__c = ANSWER_OFFER_CUSTOMER_1;
			apexpages.currentpage().getParameters().put('clickedId',callReportLead.Id);
			callReportLeadController.loadListLevel2ByCampaignCodeAndLevel1();
			callReportLead.Target_List__r.Response_Level_2__c = '2. '+GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER+ANSWER1+'-2';
			callReportLead.Target_List__r.Memo__c = 'test memo';
			callReportLeadController.save();
			
			Target_List__c targetListAfterSave = [SELECT Id,Memo__c,Response_Level_1__c,Response_Level_2__c,IsRespLeadToDo__c,Status__c FROM Target_List__c WHERE Id = :targetListLeadToDo.Id];
			System.assertEquals(ANSWER_OFFER_CUSTOMER_1,targetListAfterSave.Response_Level_1__c);
			System.assertEquals('2. '+GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER+ANSWER1+'-2',targetListAfterSave.Response_Level_2__c);
			System.assertEquals(true,targetListAfterSave.IsRespLeadToDo__c);
			System.assertEquals('test memo',targetListAfterSave.Memo__c);
			System.assertEquals('2. '+GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER+ANSWER1+'-2',targetListAfterSave.Status__c);

			Call_Report_Lead__c callReportLeadAfterSave = [SELECT Id,Memo__c,Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Id = :callReportLead.Id];
			System.assertEquals('test memo',callReportLeadAfterSave.Memo__c);
			System.assertEquals('2. '+GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER+ANSWER1+'-2',callReportLeadAfterSave.Call_Report_Lead_Status__c);
		}
		Test.stopTest();
	}

	@isTest static void testCallReportLeadLeadTypeToDoAndLeadSubtypeOfferCustomerNotAnswerAndSaveThenDoNothing() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		Campaign leadToDoSubTypeOfferCustomer = new Campaign();
		Target_List__c targetListLeadToDo = new Target_List__c();
		createListAnswer('leadToDoSubTypeOfferCustomer');
		System.runAs(adminUser){
			leadToDoSubTypeOfferCustomer = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadToDoSubTypeOfferCustomer', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);			
			listCampaign.add(leadToDoSubTypeOfferCustomer);
			insert listCampaign;

			targetListLeadToDo = Mockup_Test.newTargetList(newAccount1.Id, leadToDoSubTypeOfferCustomer.Id, 'externalId1', 'New');
			listTargetList.add(targetListLeadToDo);
			insert listTargetList;
		}

		Call_Report__c newReport = new Call_Report__c();

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}
			
			
		System.runAs(adminUser){
			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));

			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.size());
			System.assertEquals(false,callReportLeadController.refreshPage);
			System.assertEquals(true,callReportLeadController.hasData);
			System.assertEquals(3,callReportLeadController.listCustomCallReportLead.get(0).listLevel1.size());
			System.assertEquals(1,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isRequireLv2);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isRequireMemo);

			Call_Report_Lead__c callReportLead = callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData; 
			callReportLeadController.save();
			
			Target_List__c targetListAfterSave = [SELECT Id,Memo__c,Response_Level_1__c,Response_Level_2__c,IsRespLeadToDo__c,Status__c FROM Target_List__c WHERE Id = :targetListLeadToDo.Id];
			System.assertEquals(null,targetListAfterSave.Response_Level_1__c);
			System.assertEquals(null,targetListAfterSave.Response_Level_2__c);
			System.assertEquals(false,targetListAfterSave.IsRespLeadToDo__c);
			System.assertEquals(null,targetListAfterSave.Memo__c);
			System.assertEquals(GlobalConstants.PLAN,targetListAfterSave.Status__c);

			Call_Report_Lead__c callReportLeadAfterSave = [SELECT Id,Memo__c,Call_Report_Lead_Status__c FROM Call_Report_Lead__c WHERE Id = :callReportLead.Id];
			System.assertEquals(null,callReportLeadAfterSave.Memo__c);
			System.assertEquals(GlobalConstants.PLAN,callReportLeadAfterSave.Call_Report_Lead_Status__c);
		}
		Test.stopTest();
	}

	@isTest static void testCallReportLeadLeadTypeToDoAndLeadSubtypeOfferCustomerClickEditThenLoadListLevelWithoutSelectNoneAndIsSelectedLv1TrueAndIsEditModeTrue() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		createListAnswer('leadToDoSubTypeOfferCustomer');
		System.runAs(adminUser){
			Campaign leadToDoSubTypeOfferCustomer = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadToDoSubTypeOfferCustomer', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);			
			listCampaign.add(leadToDoSubTypeOfferCustomer);
			insert listCampaign;

			Target_List__c targetListLeadToDo = Mockup_Test.newTargetList(newAccount1.Id, leadToDoSubTypeOfferCustomer.Id, 'externalId1', 'New');
			targetListLeadToDo.Response_Level_1__c = ANSWER_OFFER_CUSTOMER_1;
			targetListLeadToDo.Response_Level_2__c = '3. '+GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER+ANSWER1+'-3';
			listTargetList.add(targetListLeadToDo);
			insert listTargetList;
		}

		Call_Report__c newReport = new Call_Report__c();

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}
			
			
			
		System.runAs(adminUser){
			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));
			Call_Report_Lead__c callReportLead = callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData; 
			callReportLeadController.editId = callReportLead.Id;
			callReportLeadController.edit();
			
			System.assertEquals(2,callReportLeadController.listCustomCallReportLead.get(0).listLevel1.size());
			System.assertEquals(4,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isSelectedLv1);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isEditMode);
		}
		Test.stopTest();
	}

	@isTest static void testCallReportLeadLeadTypeToDoAndLeadSubtypeOfferCustomerClickEditAndChangeDataAndClickCancelThenRestoreData() {
		Test.startTest();
		List<Campaign> listCampaign = new List<Campaign>();
		List<Account> listAccount = new List<Account>();
		List<Target_List__c> listTargetList = new List<Target_List__c>();	
		
		Account newAccount1;
		User adminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0];
		System.runAs(rmUser){
			newAccount1 = Mockup_Test.newAccountObj('newAccount1',GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
			newAccount1.Owner = rmUser;
			listAccount.add(newAccount1);
			insert listAccount;
		}

		Campaign leadToDoSubTypeOfferCustomer = new Campaign();
		Target_List__c targetListLeadToDo = new Target_List__c();
		createListAnswer('leadToDoSubTypeOfferCustomer');
		System.runAs(adminUser){
			leadToDoSubTypeOfferCustomer = Mockup_Test.newCampaign(UserInfo.getUserId(), 'leadToDoSubTypeOfferCustomer', System.now().addDays(-1), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.CAMPAIGN_REC, GlobalConstants.LEAD_TO_DO,GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER);			
			listCampaign.add(leadToDoSubTypeOfferCustomer);
			insert listCampaign;

			targetListLeadToDo = Mockup_Test.newTargetList(newAccount1.Id, leadToDoSubTypeOfferCustomer.Id, 'externalId1', 'New');
			targetListLeadToDo.Response_Level_1__c = ANSWER_OFFER_CUSTOMER_1;
			targetListLeadToDo.Response_Level_2__c = '3. '+GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER+ANSWER1+'-3';
			listTargetList.add(targetListLeadToDo);
			insert listTargetList;
		}

		Call_Report__c newReport = new Call_Report__c();

		System.runAs(rmUser){
			newReport.CIS_ID__c = newAccount1.Id;
			newReport.Actual_Visit_Date__c = System.today();
			newReport.Contact_Firstname__c = 'TestContact';
			newReport.Contact_Lastname__c = 'TestContact';
			newReport.Contact_Phone__c = '0123456789';
			newReport.Collect_Documents__c = true;
			newReport.Offer_Interest__c = 'Customer interested';
			insert newReport;
		}
			
			
		System.runAs(adminUser){
			CallReportLeadToDo_Controller callReportLeadController = new CallReportLeadToDo_Controller(new ApexPages.StandardController(newReport));
			Call_Report_Lead__c callReportLead = callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData; 
			
			callReportLeadController.editId = callReportLead.Id;
			callReportLeadController.edit();
			callReportLead.Target_List__r.Response_Level_1__c = 'change response 1';
			callReportLead.Target_List__r.Response_Level_2__c = 'change response 2';
			callReportLead.Target_List__r.Memo__c = 'change memo';

			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).isEditMode);
			System.assertEquals(true,callReportLeadController.listCustomCallReportLead.get(0).showCancel);
			System.assertEquals('change response 1',callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData.Target_List__r.Response_Level_1__c);
			System.assertEquals('change response 2',callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData.Target_List__r.Response_Level_2__c);
			System.assertEquals('change memo',callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData.Target_List__r.Memo__c);

			callReportLeadController.cancelId = callReportLead.Id;
			callReportLeadController.cancelRow();
			
			System.assertEquals(3,callReportLeadController.listCustomCallReportLead.get(0).listLevel1.size());
			System.assertEquals(4,callReportLeadController.listCustomCallReportLead.get(0).listLevel2.size());
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).showCancel);
			System.assertEquals(false,callReportLeadController.listCustomCallReportLead.get(0).isEditMode);
			System.assertEquals(ANSWER_OFFER_CUSTOMER_1,callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData.Target_List__r.Response_Level_1__c);
			System.assertEquals('3. '+GlobalConstants.LEAD_SUB_TYPE_OFFER_CUSTOMER+ANSWER1+'-3',callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData.Target_List__r.Response_Level_2__c);
			System.assertEquals(null,callReportLeadController.listCustomCallReportLead.get(0).callReportLeadData.Target_List__r.Memo__c);
		}
		Test.stopTest();
	}
}