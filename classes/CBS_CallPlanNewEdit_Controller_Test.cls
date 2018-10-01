@isTest
private class CBS_CallPlanNewEdit_Controller_Test {
	//public static String leadForSalesEDCName = 'leadForSalesEDC'; 
	//public static String leadForSalesValueChainName = 'leadForSalesValueChain'; 
	//public static String leadForSalesStrategicProvinceName = 'leadForSalesStrategicProvince'; 
	//public static String leadForSalesAccountPlanningName = 'leadForSalesAccountPlanning'; 

	//public static String leadForActionTradeDecreaseInterestName = 'leadForActionTradeDecreaseInterest'; 
	//public static String leadForActionTradeDecreaseFeeName = 'leadForActionTradeDecreaseFee';
	//public static String leadForActionTradeIncreaseLoanName = 'leadForActionTradeIncreaseLoan'; 
	//public static String leadForActionRefundFeeName = 'leadForActionRefundFee'; 

	//public static String accountName = 'AccountName1';
	//public static String accountName2 = 'AccountName2';
	//public static String prospectName = 'ProspectName';
	//public static String contactFirstName = 'ContactFirstName';
	//public static String opportunityName = 'OppName';


	//public static String otheraccountName = 'OtherAccountName';
	//public static String othercontactFirstName = 'OtherContactFirstName';
	//public static String otheropportunityName = 'OtherOppName';

	//@testSetup static void setup(){
	//	Test.startTest();
	//	Mockup_Test mt;

	//	User adminUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
	//	System.runAs(adminUser){
	//		mt = new Mockup_Test().setUpTest();
	//	}
		
	//	User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM LIMIT 1][0];
	//	User userRM2 = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM2 LIMIT 1][0];

	//	//System.runAs(userRM2){
	// //   	setUpUnRelated_Account_Contact_CallReport_Opportunity();
	// //   }

	//    System.runAs(userRM){
	//    	setUpRelated_Account_Contact_CallReport_Opportunity();
	//    }

	//    Test.stopTest();
	    

	//}

	//public static Account getAccount(){
	// 	//Account account = [SELECT Id,Name,CIS__c From Account WHERE Name = :accountName limit 1][0];
	//	return Mockup_Test.getFirstAccountFromName(accountName, 'Id,Name,CIS__c');
	//}

	//public static Account getAccountForLead(){
	// 	//Account account = [SELECT Id,Name,CIS__c From Account WHERE Name = :accountName2 limit 1][0];
	//	return Mockup_Test.getFirstAccountFromName(accountName2, 'Id,Name,CIS__c');
	//}
	//public static Account getProspectAccount(){
	//	//Account account = [SELECT Id,Name,CIS__c From Account WHERE Name = :prospectName limit 1][0];
	//	return Mockup_Test.getFirstAccountFromName(prospectName, 'Id,Name,CIS__c');
	//}

	//public static Account getOthertAccount(){
	// 	//Account account = [SELECT Id,Name From Account WHERE Name = :otheraccountName limit 1][0];
	//	return Mockup_Test.getFirstAccountFromName(otheraccountName, 'Id,Name,CIS__c');
	//}

	//public static Contact getContactOfRelatedAccount(){
	//	//Contact contact = [SELECT Id,FirstName,Account.id From Contact WHERE FirstName = :contactFirstName Limit 1][0];
	//	return Mockup_Test.getFirstContactFromFirstName(contactFirstName,'Id,FirstName,Account.id');
	//}

	//public static User getUser(){
	//	User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM LIMIT 1][0];
	//	return userRM;
	//}

	//public static User getOtherUser(){
	//	User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM2 LIMIT 1][0];
	//	return userRM;
	//}

 //   public static void setupPageParameterMap(Account account,Call_Report__c callreport){
 //   	Test.setCurrentPageReference(new PageReference('Page.CBS_CallReportNewEdit_Page'));
 //   	if(account != null){
	//		System.currentPageReference().getParameters().put('accountId', account.id);
	//		System.currentPageReference().getParameters().put('callReportForCISLookUpInputFieldCISID', account.id);
	//	}
	//	if(callreport != null){
	//		System.currentPageReference().getParameters().put('recid',callreport.id);
	//	}
	//	System.currentPageReference().getParameters().put('rowToFetchIndex', '0');
	//	System.currentPageReference().getParameters().put('rowToRemoveIndex', '0');

 //   }

 //   public static void setupPageParameterForLead(String leadId){
 //   	Test.setCurrentPageReference(new PageReference('Page.CBS_CallReportNewEdit_Page'));

 //   	System.currentPageReference().getParameters().put('leadId',leadId);
 //   }

 //   private static void setUpRelated_Account_Contact_CallReport_Opportunity(){
	//	Account acc = new Account(
	//    	Name = accountName,
	//		CIS__c = '111111',
	//		Primary_Segment_Code__c = 'CB',
	//		Port_Pool__c = GlobalConstants.PORT,
	//		Birthdate_Registration_Date__c = System.today().addYears(-10),
	//		Encrypt_Identification_No__c = '111111111111111'
	//	);
	//	insert acc;
	//	Account acc2 = new Account(
	//    	Name = accountName2,
	//		CIS__c = '33333',
	//		Primary_Segment_Code__c = 'CB',
	//		Port_Pool__c = GlobalConstants.PORT,
	//		Birthdate_Registration_Date__c = System.today().addYears(-10),
	//		Encrypt_Identification_No__c = '333333333333333'
	//	);
	//	insert acc2;

	//	Account prospectAccount = new Account(
	//    	Name = prospectName,
	//		CIS__c = '33333',
	//		Primary_Segment_Code__c = 'CB',
	//		Port_Pool__c = GlobalConstants.PORT
	//	);
	//	insert prospectAccount;


	//	Contact contact = new Contact(
	//		FirstName = contactFirstName, 
	//		LastName = 'ContactLastName',
	//		Phone_Number__c = '000000000',
	//		Business_Email__c = '0000@hotmail.com',
	//		Contact_Position__c = 'กรรมการ',
	//		AccountID = acc.Id
	//	);
	//	insert contact;
	//	Call_Report__c callreport = new Call_Report__c(
 //   				CIS_ID__c = acc.id,
 //   				Actual_Visit_Date__c = System.today(),
 //   				Status__c = 'Contacted'
 //   	);
 //   	TriggerHandler.bypass('CallReportTriggerHandler');
	//	insert callreport;
	//	TriggerHandler.clearBypass('CallReportTriggerHandler');
	//	Opportunity opp = Mockup_Test.newOpportunity(acc.Id, opportunityName, GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
	//	insert opp;

 //   }
    
 //   private static void setupLeadForSalesValueChain(){
	//	//Account account = [SELECT Id FROM Account WHERE Name =: accountName2 LIMIT 1];
	//	Account account = Mockup_Test.getFirstAccountFromName(accountName2, 'Id,Name,CIS__c');
	//	System.runAs(CBS_CallPlanNewEdit_Controller_Test.getUser()){
	//		Campaign leadForSalesValueChain = new Campaign();
	//        leadForSalesValueChain.Lead_Campaign_Event_Code__c = leadForSalesValueChainName;
	//        leadForSalesValueChain.Type__c = GlobalConstants.LEAD_FOR_SALES;
	//        leadForSalesValueChain.Name = leadForSalesValueChainName;
	//        leadForSalesValueChain.Sub_Type_CBS__c = GlobalConstants.LEAD_SUB_TYPE_VALUE_CHAIN_CHAIN;
	//        leadForSalesValueChain.Status = GlobalConstants.ACTIVE;
	//        leadForSalesValueChain.IsActive = true;
	//        leadForSalesValueChain.StartDate = System.today() - 1;
	//		leadForSalesValueChain.EndDate = System.Today() + 1;
	//        leadForSalesValueChain.Effective_Date__c = System.Today() - 1;
	//        leadForSalesValueChain.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_CBS_REC);
	//        leadForSalesValueChain.Product_List_CBS__c = 'EDC';
	//        insert leadForSalesValueChain;

	//        Target_List__c tglLeadForSalesValueChain = new Target_List__c();
	//        tglLeadForSalesValueChain.Lead_Campaign__c = leadForSalesValueChain.Id;
	//        tglLeadForSalesValueChain.CIS_ID_Prospect_Name__c = account.Id;
	//        tglLeadForSalesValueChain.Status__c = GlobalConstants.STATUS_NEW;
	//        insert tglLeadForSalesValueChain;
	        

	//        List<Lead_To_Do_Response__c> listResponseAction = new List<Lead_To_Do_Response__c>();

	//        Lead_To_Do_Response__c interested = new Lead_To_Do_Response__c();
	//        interested.Type__c = GlobalConstants.LEAD_SUB_TYPE_VALUE_CHAIN_CHAIN;
	//        interested.Response_Level_1__c = '1. สนใจ';
	//        interested.Required_Level_2__c = false;
	//        interested.Required_Memo__c = false;
	//        interested.Required_Product_c__c = false;
	//        interested.Team__c = GlobalConstants.CBS;
	//        listResponseAction.add(interested);


	//        Lead_To_Do_Response__c notInterested = new Lead_To_Do_Response__c();
	//        notInterested.Type__c = GlobalConstants.LEAD_SUB_TYPE_VALUE_CHAIN_CHAIN;
	//        notInterested.Response_Level_1__c = '2. ไม่สนใจ';
	//        notInterested.Response_Level_2__c = '6. อื่นๆ โปรดระบุ';
	//        notInterested.Required_Level_2__c = true;
	//        notInterested.Required_Memo__c = true;
	//        notInterested.Required_Product_c__c = false;
	//        notInterested.Team__c = GlobalConstants.CBS;
	//        listResponseAction.add(notInterested);

	//        insert listResponseAction;
	//	}

		
	//}

 //   public static Call_Report__c  createCallReportFromCustomerInfo(){
 //   		Account account = CBS_CallPlanNewEdit_Controller_Test.getAccount();
 //   		Call_Report__c callreport = new Call_Report__c(
 //   			CIS_ID__c = account.id,
 //   			Actual_Visit_Date__c = System.today(),
 //   			Status__c = 'Contacted'
 //   		);
 //   	return callreport;
 //   }
 //   public static Call_Report__c  createCallReportFromCustomerInfoCisNull(){
 //   		Account account = CBS_CallPlanNewEdit_Controller_Test.getAccount();
 //   		Call_Report__c callreport = new Call_Report__c(
 //   			CIS_ID__c = null,
 //   			Actual_Visit_Date__c = System.today(),
 //   			Status__c = 'Contacted'
 //   		);
 //   	return callreport;
 //   }

	//@isTest static void testCustomLookupAccount(){
 //   	Test.startTest();
 //   	System.runAs(CBS_CallPlanNewEdit_Controller_Test.getUser()){
 //   		Account account = CBS_CallPlanNewEdit_Controller_Test.getAccount();
 //   		PageReference accountlookupPageRefer = Page.CBS_customLookupAccount_Page;
 //   		accountlookupPageRefer.getParameters().put('searchString',account.id);
 //   		CBS_customLookupAccount_Controller accountCustomLookupContoller = new CBS_customLookupAccount_Controller();
 //   		accountCustomLookupContoller.searchString = 'InvalidAccountName';
 //   		accountCustomLookupContoller.performSearch();

 //   	}
 //   	Test.stopTest();

 //   }

 //   @isTest static void testCreateCallPlanBlankParameter(){
    	
 //   	System.runAs(CBS_CallPlanNewEdit_Controller_Test.getUser()){
 //   		Test.startTest();
	//    	Call_Report__c callreport = new Call_Report__c();
	//		setupPageParameterMap(null,null);
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallPlanNewEdit_Controller callReportController = new CBS_CallPlanNewEdit_Controller(stdController);

	//		System.currentPageReference().getParameters().clear();
	//		ApexPages.StandardController stdController2 = new ApexPages.StandardController(callreport);
	//		CBS_CallPlanNewEdit_Controller callReportController2 = new CBS_CallPlanNewEdit_Controller(stdController2);
	//		Test.stopTest();
 //   	}
 //   }

 //   @isTest static void testCustomLookupExistingContact(){
 //   	System.runAs(CBS_CallPlanNewEdit_Controller_Test.getUser()){
 //   		Test.startTest();
 //   		Account account = CBS_CallPlanNewEdit_Controller_Test.getAccount();
 //   		Contact contact = CBS_CallPlanNewEdit_Controller_Test.getContactOfRelatedAccount();
 //   		PageReference contactlookupPageRefer = Page.CBS_customLookupContact_Page;
 //   		System.currentPageReference().getParameters().put('searchString', account.id);
 //   		System.currentPageReference().getParameters().put('index','0');
 //   		CBS_customLookupContact_Controller contactCustomLookupContoller = new CBS_customLookupContact_Controller();
 //   		contactCustomLookupContoller.searchString = 'ContactFirstName';
 //   		contactCustomLookupContoller.performSearch();

 //   		System.currentPageReference().getParameters().put('searchString','');
 //   		CBS_customLookupContact_Controller contactCustomLookupContoller2 = new CBS_customLookupContact_Controller();
 //   		contactCustomLookupContoller2.searchString = 'OtherContactFirstName';
 //   		contactCustomLookupContoller2.performSearch();

 //   		delete contact;
 //   		System.currentPageReference().getParameters().put('searchString',account.id);
 //   		System.currentPageReference().getParameters().put('index','0');
 //   		CBS_customLookupContact_Controller contactCustomLookupContoller3 = new CBS_customLookupContact_Controller();

 //   		Test.stopTest();
 //   	}

 //   }
 //   @isTest static void testCallPlanLeadForSales(){
	//	System.debug('------------------testCallReportLeadForSales--------------------');
	//	Test.startTest();
	//	Account account = CBS_CallPlanNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallPlanNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	//Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();

	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	System.runAs(CBS_CallPlanNewEdit_Controller_Test.getUser()){
	//		Call_Report__c callreport = CBS_CallPlanNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallPlanNewEdit_Controller callReportController = new CBS_CallPlanNewEdit_Controller(stdController);
	//		callReportController.save();
	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testFetchPreviosCallReport(){
	//	Test.startTest();
	//	System.debug('============testFetchPreviosCallReport===========');
	//		Account account = CBS_CallPlanNewEdit_Controller_Test.getAccount();
	//	System.runAs(CBS_CallPlanNewEdit_Controller_Test.getUser()){
	//		setupPageParameterMap(account,null);
	//		Call_Report__c callreport = new Call_Report__c();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallPlanNewEdit_Controller callReportController = new CBS_CallPlanNewEdit_Controller(stdController);
	//		callReportController.fetchPreviousCallReport();
	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testEditCallPlanLeadForSales(){
	//	System.debug('------------------testCallReportLeadForSales--------------------');
	//	Test.startTest();
	//	Account account = CBS_CallPlanNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallPlanNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	//Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();

	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	System.runAs(CBS_CallPlanNewEdit_Controller_Test.getUser()){
	//		Call_Report__c callreport = CBS_CallPlanNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallPlanNewEdit_Controller callReportController = new CBS_CallPlanNewEdit_Controller(stdController);
	//		callReportController.save();

	//		callreport.Actual_Visit_Date__c = System.today()+1;
	//		ApexPages.StandardController stdControllerEdit = new ApexPages.StandardController(callreport);
	//		CBS_CallPlanNewEdit_Controller callReportControllerEdit = new CBS_CallPlanNewEdit_Controller(stdControllerEdit);
	//		callReportControllerEdit.save();

	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testEditCallPlanCisNull(){
	//	System.debug('------------------testCallReportLeadForSales--------------------');
	//	Test.startTest();
	//	Account account = CBS_CallPlanNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallPlanNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	//Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();

	//	setupPageParameterMap(null,null);
	//	setupLeadForSalesValueChain();

	//	System.runAs(CBS_CallPlanNewEdit_Controller_Test.getUser()){
	//		Call_Report__c callreport = CBS_CallPlanNewEdit_Controller_Test.createCallReportFromCustomerInfoCisNull();
	//		callreport.CIS_ID__c = null;
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallPlanNewEdit_Controller callReportController = new CBS_CallPlanNewEdit_Controller(stdController);
	//		callReportController.save();

	//	}
	//	Test.stopTest();
	//}
	////@isTest static void testNewCallPlanOtherOwner(){
	////	System.debug('------------------testCallReportLeadForSales--------------------');
	////	Test.startTest();
	////	Account account = CBS_CallPlanNewEdit_Controller_Test.getAccountForLead();
	////	Contact contact = CBS_CallPlanNewEdit_Controller_Test.getContactOfRelatedAccount();

	////	setupPageParameterMap(account,null);
	////	setupLeadForSalesValueChain();

	////	String callReportId = '';

	////	System.runAs(CBS_CallPlanNewEdit_Controller_Test.getUser()){
	////		Call_Report__c callreport = CBS_CallPlanNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	////		callReportId = callreport.Id;
	////		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	////		CBS_CallPlanNewEdit_Controller callReportController = new CBS_CallPlanNewEdit_Controller(stdController);
	////		callReportController.save();
	////	}

	////	System.runAs(CBS_CallPlanNewEdit_Controller_Test.getOtherUser()){
	////		Call_Report__c callReportOtherOwner = new Call_Report__c();
	////		callReportOtherOwner = [SELECT Id, CIS_ID__c, Actual_Visit_Date__c,Status__c FROM Call_Report__c WHERE Id =: callReportId LIMIT 1];
	////		//Call_Report__c callreport = CBS_CallPlanNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	////		ApexPages.StandardController stdController = new ApexPages.StandardController(callReportOtherOwner);
	////		CBS_CallPlanNewEdit_Controller callReportController2 = new CBS_CallPlanNewEdit_Controller(stdController);
	////		callReportController2.save();
	////	}
		
	////	Test.stopTest();
		
	////}

}