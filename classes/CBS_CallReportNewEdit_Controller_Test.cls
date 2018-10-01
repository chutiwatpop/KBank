@isTest
private class CBS_CallReportNewEdit_Controller_Test {
	//public static String leadForSalesEDCName = 'leadForSalesEDC'; 
	//public static String leadForSalesValueChainName = 'leadForSalesValueChain'; 
	//public static String leadForSalesStrategicProvinceName = 'leadForSalesStrategicProvince'; 
	//public static String leadForSalesAccountPlanningName = 'leadForSalesAccountPlanning'; 

	//public static String leadForActionTradeDecreaseInterestName = 'leadForActionTradeDecreaseInt'; 
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

	//public static String pruductGruop_Transaction = 'Transaction';
	//public static String productName_Remittance = 'Remittance';
	//public static String productName_SBLC = 'SBLC';
	
	//@testSetup static void setup(){
	//	Test.startTest();
	//	Mockup_Test mt;

	//	User adminUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
	//	System.runAs(adminUser){
	//		mt = new Mockup_Test().setUpTest();
	//	}
		
	//	User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM LIMIT 1][0];
	//	User userRM2 = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM2 LIMIT 1][0];

	//	System.runAs(userRM2){
	//    	setUpUnRelated_Account_Contact_CallReport_Opportunity();
	//    }

	//    System.runAs(userRM){
	//    	setUpRelated_Account_Contact_CallReport_Opportunity();
	//    	setUpOpportunityPlanningData();
	//    }

	//    setUpProductMasterData();
	//    initOppPlanCustomSetting();

	//    Test.stopTest();
	//}

	//public static void setUpProductMasterData(){
	//	RecordType rc = [SELECT id From RecordType WHERE SObjectType ='Product_List_Master__c' AND DeveloperName =:GlobalConstants.RECORDTYPE_DEVNAME_PRODUCT_MASTER_CBS LIMIT 1];
	//	List<Product_List_Master__c> callReportProductListMaster = new List<Product_List_Master__c>();
	//	Product_List_Master__c productMaster = Mockup_Test.newProductMasterCBS(CBS_CallReportNewEdit_Controller_Test.pruductGruop_Transaction,1,CBS_CallReportNewEdit_Controller_Test.productName_SBLC,1,rc.id);
	//	callReportProductListMaster.add(productMaster);

	//	productMaster = Mockup_Test.newProductMasterCBS(CBS_CallReportNewEdit_Controller_Test.pruductGruop_Transaction,1,CBS_CallReportNewEdit_Controller_Test.productName_Remittance,2,rc.id);
	//	callReportProductListMaster.add(productMaster);

	//	insert callReportProductListMaster;
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
	//public static Opportunity getOpportunityRelatedAccount(){
	//	Opportunity opp = [SELECT Id From Opportunity WHERE Name = :opportunityName Limit 1][0];
	//	return opp;
	//}
	//public static Contact getOtherContact(){
	//	//Contact contact = [SELECT Id,FirstName,Account.id From Contact WHERE FirstName = :othercontactFirstName Limit 1][0];
	//	return Mockup_Test.getFirstContactFromFirstName(othercontactFirstName,'Id,FirstName,Account.id');
	//}

	//public static Opportunity getOtherOpportunity(){
	//	Opportunity opp = [SELECT Id From Opportunity WHERE Name = :otheropportunityName Limit 1][0];
	//	return opp;
	//}

	//public static Call_Report__c getRelatedCallReport(){
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//	Call_Report__c callreport = [Select Id From Call_Report__c WHERE CIS_ID__c = :account.id  Limit 1][0];
	//	return callreport;
	//}

	//public static User getUser(){
	//	User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM LIMIT 1][0];
	//	return userRM;
	//}

	//public static User getOtherUser(){
	//	User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userCBSFirstNameRM2 LIMIT 1][0];
	//	return userRM;
	//}

 //  public static Call_Report__c createCallReportWithCallPlan(){
 //   	Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
 //   	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
 //   	Call_Report__c callreport = new Call_Report__c(
 //   			CIS_ID__c = account.id,
 //   			Actual_Visit_Date__c = System.today(),
 //   			Status__c = 'Contacted',
 //   			Contact__c = contact.id,
 //   			Planned_Product_CBS__c = 'Credit & Non-Credit',
 //   			Planned_Visit_Objective_CBS__c = 'Sell', 
 //   			Plan_Date__c = System.today()
 //   			);
 //   	TriggerHandler.bypass('CallReportTriggerHandler');
 //   	insert callreport;
 //   	TriggerHandler.clearBypass('CallReportTriggerHandler');
 //   	return callreport;

 //   }

 //   public static Call_Report__c  createCallReportFromCustomerInfo(){
 //   		Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
 //   		Call_Report__c callreport = new Call_Report__c(
 //   			CIS_ID__c = account.id,
 //   			Actual_Visit_Date__c = System.today(),
 //   			Status__c = 'Contacted'
 //   		);
 //   	return callreport;
 //   }

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

 //   @isTest static void testCustomLookupAccount(){
 //   	Test.startTest();
 //   	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
 //   		Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
 //   		PageReference accountlookupPageRefer = Page.CBS_customLookupAccount_Page;
 //   		accountlookupPageRefer.getParameters().put('searchString',account.id);
 //   		CBS_customLookupAccount_Controller accountCustomLookupContoller = new CBS_customLookupAccount_Controller();
 //   		accountCustomLookupContoller.searchString = 'InvalidAccountName';
 //   		accountCustomLookupContoller.performSearch();

 //   	}
 //   	Account otheraccount = CBS_CallReportNewEdit_Controller_Test.getOthertAccount();
 //   	delete otheraccount;
 //   	System.runAs(CBS_CallReportNewEdit_Controller_Test.getOtherUser()){
 //   		PageReference accountlookupPageRefer = Page.CBS_customLookupAccount_Page;
 //   		CBS_customLookupAccount_Controller accountCustomLookupContoller = new CBS_customLookupAccount_Controller();

 //   	}
 //   	Test.stopTest();

 //   }

 //   @isTest static void testCustomLookupExistingContact(){
 //   	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
 //   		Test.startTest();
 //   		Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
 //   		Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
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

 //   @isTest static void testCustomLookupAddtoExistingOpportunity(){
 //   	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
 //   		Test.startTest();
 //   		Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
 //   		Opportunity opp = CBS_CallReportNewEdit_Controller_Test.getOpportunityRelatedAccount();
 //   		PageReference contactlookupPageRefer = Page.CBS_customLookupOpportunity_Page;
 //   		System.currentPageReference().getParameters().put('searchString', account.id);
 //   		System.currentPageReference().getParameters().put('index','0');
 //   		System.currentPageReference().getParameters().put('isGroupOppPlanning','false');
 //   		CBS_customLookupOpportunity_Controller opportunityCustomLookupContoller = new CBS_customLookupOpportunity_Controller();
 //   		opportunityCustomLookupContoller.searchString = 'OppName';
 //   		opportunityCustomLookupContoller.performSearch();

 //   		opportunityCustomLookupContoller.searchString = 'OtherOppName';
 //   		opportunityCustomLookupContoller.performSearch();

 //   		delete opp;
 //   		CBS_customLookupOpportunity_Controller opportunityCustomLookupContoller2 = new CBS_customLookupOpportunity_Controller();

 //   		Test.stopTest();
 //   	}
 //   }


 //   @isTest static void testCreateCallReportWithNoPlanAndBlankParameter(){
    	
 //   	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
 //   		Test.startTest();
	//    	Call_Report__c callreport = new Call_Report__c();
	//		setupPageParameterMap(null,null);
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);

	//		System.currentPageReference().getParameters().clear();
	//		ApexPages.StandardController stdController2 = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController2 = new CBS_CallReportNewEdit_Controller(stdController2);
	//		Test.stopTest();
 //   	}
 //   }

 //   @isTest static void testAdd_Delete_New_ExistingContact() {
    	
 //   	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
 //   		Test.startTest();
	//    	Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//		setupPageParameterMap(account,null);
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);

	//		callReportController.addExistingContact();
	//		callReportController.addNewContact();

	//		callReportController.deleteThisExistingContact();
	//		callReportController.deleteThisNewContact();
	//		Test.stopTest();
 //   	}	
 //   }
	



	//@isTest static void testFetchPreviosCallReport(){
	//	Test.startTest();
	//		Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//		Account otherAccount = CBS_CallReportNewEdit_Controller_Test.getOthertAccount();
	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		setupPageParameterMap(account,null);
	//		Call_Report__c callreport = new Call_Report__c();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		/// Select account that belong to this user
	//		callReportController.callReportForCISLookUpInputField.CIS_ID__c = account.id;
	//		callReportController.fetchPreviousCallReport();
	//		/// select account that is not belong to this user
	//		setupPageParameterMap(otherAccount,null);
	//		callReportController.callReportForCISLookUpInputField.CIS_ID__c = otherAccount.id;
	//		callReportController.fetchPreviousCallReport();

	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testNew_Edit_Cancel_OpportunityPlanningFromPage(){
	//	Test.startTest();
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//	Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//	ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//	setupPageParameterMap(account,null);
	//	CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);

	//	List<CBS_CallReportWrapper.ProductWrapper> productList = callReportController.callReportProductModal.productWrapperMapByProductGroup.get(CBS_CallReportNewEdit_Controller_Test.pruductGruop_Transaction);
	//	for(CBS_CallReportWrapper.ProductWrapper eachProduct : productList){
	//		if(eachProduct.name == CBS_CallReportNewEdit_Controller_Test.productName_SBLC){
	//			eachProduct.isSelected = true;
	//			eachProduct.interest = true;
	//			eachProduct.productType = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING;
	//			eachProduct.newLimit = '10000';
	//			eachProduct.outstanding = '10000';
	//			eachProduct.frontEndFee = '10000';
	//			eachProduct.fee = '10000';
	//		}
	//	}

	//	callReportController.newOpportunityPlanning();
	//	List<CBS_OpportunityPlanningWrapper> oppPlanningGroup_TransactionList = callReportController.oppPlanningMapByproductGroup.get(CBS_CallReportNewEdit_Controller_Test.pruductGruop_Transaction);
	//	System.assertEquals(1,oppPlanningGroup_TransactionList.size());

	//	//////////////////// Start Cancel ///////////////
	//	System.currentPageReference().getParameters().put('groupName', CBS_CallReportNewEdit_Controller_Test.pruductGruop_Transaction);
	//	System.currentPageReference().getParameters().put('indexInGroup','0');

	//	callReportController.editOpportunityPlanning();
	//	CBS_OpportunityPlanningWrapper editOppplanning = oppPlanningGroup_TransactionList.get(0);
	//	editOppplanning.opportunityPlanning.Fee__c = 20000;
	//	callReportController.cancelEditOpportunityPlanning();
	//	System.assertEquals(10000,editOppplanning.opportunityPlanning.Fee__c);

	//	//////////////////// Start Edit ///////////////
	//	callReportController.editOpportunityPlanning();
	//	editOppplanning.opportunityPlanning.Fee__c = 20000;
	//	callReportController.saveEditOpportunityPlanning();
	//	System.assertEquals(20000,editOppplanning.opportunityPlanning.Fee__c);

	//	Test.stopTest();
	//}

	//@isTest static void testGroup_UnGroup_OpportunityPlanningFromPage(){
	//	Test.startTest();

	//		Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		setupPageParameterMap(account,null);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);

	//		List<CBS_CallReportWrapper.ProductWrapper> productList = callReportController.callReportProductModal.productWrapperMapByProductGroup.get(CBS_CallReportNewEdit_Controller_Test.pruductGruop_Transaction);
	//		for(CBS_CallReportWrapper.ProductWrapper eachProduct : productList){
	//			eachProduct.isSelected = true;
	//			eachProduct.interest = true;
	//			eachProduct.productType = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING;
	//			eachProduct.newLimit = '10000';
	//			eachProduct.outstanding = '10000';
	//			eachProduct.frontEndFee = '10000';
	//			eachProduct.fee = '10000';
	//		}

	//		callReportController.newOpportunityPlanning();
	//		List<CBS_OpportunityPlanningWrapper> oppPlanningGroup_TransactionList = callReportController.oppPlanningMapByproductGroup.get(CBS_CallReportNewEdit_Controller_Test.pruductGruop_Transaction);
	//		for(CBS_OpportunityPlanningWrapper eachOppPlanningWrapper : oppPlanningGroup_TransactionList){
	//			eachOppPlanningWrapper.opportunityPlanning.Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE;
	//			eachOppPlanningWrapper.isChecked = true;
	//		}
	//		callReportController.groupOpportunityPlanning();
	//		System.assertEquals(1,callReportController.groupOppPlanningList.size());
	//		System.assertEquals(2,callReportController.groupOppPlanningList.get(0).oppPlanningWrapperList.size());
	//		System.assertEquals(20000,callReportController.groupOppPlanningList.get(0).sum_newLimit );

	//		///// Start UnGroup ////
	//		callReportController.groupOppPlanningIndex = 0;
	//		callReportController.unGroupOpportunityPlanning();
	//		System.assertEquals(0,callReportController.groupOppPlanningList.size());

	//	Test.stopTest();
	//}

	//@isTest static void testCallReportLeadForAction(){
		
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();

	//	setupPageParameterMap(account,null);
	//	setupLeadForActionTradeDecreaseInterest();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
			
	//		callReportController.myCallReport.callreport.Actual_Visit_Date__c = System.today()-1;
	//		callReportController.myCallReport.callreport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
	//		callReportController.myCallReport.callreport.Visit_Objective_CBS__c = 'Relationship';

	//		callReportController.existingContacts.get(0).existingContact.Contact_Name__c = contact.id;
	//		callReportController.fetchExistingContactInformation();

	//		callReportController.leads.get(0).responseLevel1 = '1. ลดแล้ว';
	//		Test.startTest();
	//		callReportController.saveAll();
	//		Test.stopTest();


	//	}

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	
	//	}	
	//}

	//@isTest static void testCallReportLeadForActionChangeResponse(){
	//	Test.startTest();
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();

	//	setupPageParameterMap(account,null);
	//	setupLeadForActionTradeDecreaseInterest();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
			
	//		callReportController.myCallReport.callreport.Actual_Visit_Date__c = System.today()-1;
	//		callReportController.myCallReport.callreport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
	//		callReportController.myCallReport.callreport.Visit_Objective_CBS__c = 'Relationship';

	//		callReportController.existingContacts.get(0).existingContact.Contact_Name__c = contact.id;
	//		callReportController.fetchExistingContactInformation();

	//		setupPageParameterForLead(callReportController.leads.get(0).targetList.Id);
	//		System.currentPageReference().getParameters().put('targetListId',callReportController.leads.get(0).targetList.Id);

	//		callReportController.leads.get(0).responseLevel1 = '2. ยกเลิก (โปรดระบุ)';
	//		callReportController.updateResponseLevel2ByPickedResponseLevel1();
	//		callReportController.leads.get(0).targetList.Memo__c = 'testMemo';
			
	//		callReportController.saveAll();


	//	}

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);

			
	//	}

	//	Test.stopTest();
	//}

	//@isTest static void testCallReportLeadForSales(){
	//	System.debug('------------------testCallReportLeadForSales--------------------');
	//	Test.startTest();
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();

	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
			
	//		callReportController.myCallReport.callreport.Actual_Visit_Date__c = System.today()-1;
	//		callReportController.myCallReport.callreport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
	//		callReportController.myCallReport.callreport.Visit_Objective_CBS__c = 'Relationship';

	//		callReportController.existingContacts.get(0).existingContact.Contact_Name__c = contact.id;
	//		callReportController.fetchExistingContactInformation();

	//		//callReportController.fetchPreviousCallReport();

	//		setupPageParameterForLead(callReportController.leads.get(0).targetList.Id);
	//		System.currentPageReference().getParameters().put('targetListId',callReportController.leads.get(0).targetList.Id);

	//		callReportController.leads.get(0).responseLevel1 = '2. ไม่สนใจ';
	//		callReportController.updateResponseLevel2ByPickedResponseLevel1();
	//		callReportController.leads.get(0).responseLevel2 = '6. อื่นๆ โปรดระบุ';
	//		callReportController.updateRequiredMemoByPickedResponseLevel2();
	//		callReportController.leads.get(0).targetList.Memo__c = 'testMemo';
			
	//		callReportController.saveAll();


	//	}

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		System.debug('-----------------New Controller----------------');
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);

			
			
	//	}

	//	Test.stopTest();
	//}

	//@isTest static void testCallReportLeadForSalesWithResponse(){
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();

	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	Campaign campaignForSalesValueChain = new Campaign();
	//	campaignForSalesValueChain = [SELECT Id FROM Campaign WHERE Name =: leadForSalesValueChainName];

	//	Target_List__c targetListValueChain = new Target_List__c();
	//	targetListValueChain = [SELECT Id, Response_Level_1__c, Response_Level_2__c, Memo__c, Lead_Subtype_CBS__c,Lead_Campaign__c FROM Target_List__c WHERE Lead_Campaign__c =: campaignForSalesValueChain.Id];

	//	Lead_To_Do_Response__c leadResponseNotInterested = new Lead_To_Do_Response__c();
	//	leadResponseNotInterested = [SELECT Id, Type__c, Response_Level_1__c, Response_Level_2__c FROM Lead_To_Do_Response__c WHERE Response_Level_1__c =: '2. ไม่สนใจ'];

	//	targetListValueChain.Response_Level_1__c = leadResponseNotInterested.Response_Level_1__c;
	//	targetListValueChain.Response_Level_2__c = leadResponseNotInterested.Response_Level_2__c;
	//	targetListValueChain.Memo__c = 'testMemo';

	//	TriggerHandler.bypass('TargetListTriggerHandler');
	//	update targetListValueChain;
	//	TriggerHandler.clearBypass('TargetListTriggerHandler');
		
	//	Test.startTest();
	//		System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//			Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//			ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//			CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
				
	//			callReportController.myCallReport.callreport.Actual_Visit_Date__c = System.today()-1;
	//			callReportController.myCallReport.callreport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
	//			callReportController.myCallReport.callreport.Visit_Objective_CBS__c = 'Relationship';

	//			callReportController.existingContacts.get(0).existingContact.Contact_Name__c = contact.id;
	//			callReportController.fetchExistingContactInformation();

	//			setupPageParameterForLead(callReportController.leads.get(0).targetList.Id);
	//			System.currentPageReference().getParameters().put('targetListId',callReportController.leads.get(0).targetList.Id);

	//			callReportController.leads.get(0).responseLevel1 = '2. ไม่สนใจ';
	//			callReportController.updateResponseLevel2ByPickedResponseLevel1();
	//			callReportController.leads.get(0).responseLevel2 = '6. อื่นๆ โปรดระบุ';
	//			callReportController.updateRequiredMemoByPickedResponseLevel2();
	//			callReportController.leads.get(0).targetList.Memo__c = 'testMemo';
				
	//			callReportController.saveAll();


	//		}

	//		System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//			Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//			ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//			CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);	
	//		}

	//	Test.stopTest();
	//}

	//@isTest static void testValidateCallPlan(){
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();

	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		System.debug('-----------------New Controller----------------');
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);

	//		callReportController.myCallReport.callreport.Visit_Objective_CBS__c = 'Sell';
	//		callReportController.myCallReport.callreport.Actual_Visit_Date__c = null;
	//		callReportController.myCallReport.callreport.Contact_Channel__c = GlobalConstants.NONE;

	//		callReportController.saveAll();
	//	}

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		System.debug('-----------------New Controller----------------');
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);

	//		callReportController.myCallReport.callreport.Visit_Objective_CBS__c = 'Sell';
	//		callReportController.myCallReport.callreport.Actual_Visit_Date__c = System.today()+1;
	//		callReportController.myCallReport.callreport.Contact_Channel__c = GlobalConstants.NONE;

	//		callReportController.saveAll();
	//	}
	//}

	//@isTest static void testValidateNewContactNoPhoneNumber(){
	//	Test.startTest();
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();


	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){

	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		Contact newContact = new Contact(Contact_Position__c = 'อื่นๆ โปรดระบุ',
	//															Firstname = 'test',
	//															LastName = 'test',
	//															Phone_Number__c = '',
	//															Ext_CBS__c = '123232sdfd',
	//															Business_Email__c = 'Testtest.com'
	//															);

			
	//		CBS_CallReportWrapper.NewContactWrapper newContactWrap = new CBS_CallReportWrapper.NewContactWrapper(newContact);
	//		newContactWrap.lastName = 'test';
	//		callReportController.newContacts = new List<CBS_CallReportWrapper.NewContactWrapper>();
	//		callReportController.newContacts.add(newContactWrap);
	//		callReportController.saveAll();
	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testValidateNewContactInvalidAll(){
	//	Test.startTest();
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();


	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		System.debug('-----------------New Controller----------------');
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		Contact newContact = new Contact(Contact_Position__c = 'อื่นๆ โปรดระบุ',
	//															Firstname = 'test',
	//															LastName = 'test',
	//															Phone_Number__c = '123456789sdfd',
	//															Ext_CBS__c = '123232sdfd',
	//															Business_Email__c = 'Testtest.com'
	//															);

	//		CBS_CallReportWrapper.NewContactWrapper newContactWrap = new CBS_CallReportWrapper.NewContactWrapper(newContact);
	//		newContactWrap.lastName = 'test';

	//		callReportController.newContacts = new List<CBS_CallReportWrapper.NewContactWrapper>();
	//		callReportController.newContacts.add(newContactWrap);
	//		callReportController.saveAll();
	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testValidateNewContactNoLastNameNoPhoneNumber(){
	//	Test.startTest();
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();


	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		System.debug('-----------------New Controller----------------');
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		Contact newContact = new Contact(Contact_Position__c = 'อื่นๆ โปรดระบุ',
	//															Firstname = 'test',
	//															LastName = '',
	//															Phone_Number__c = '',
	//															Ext_CBS__c = '123232sdfd',
	//															Business_Email__c = 'Testtest.com'
	//															);

			
	//		CBS_CallReportWrapper.NewContactWrapper newContactWrap = new CBS_CallReportWrapper.NewContactWrapper(newContact);
	//		newContactWrap.lastName = '';

	//		callReportController.newContacts = new List<CBS_CallReportWrapper.NewContactWrapper>();
	//		callReportController.newContacts.add(newContactWrap);
	//		callReportController.saveAll();
	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testValidateNewContactNoFirstName(){
	//	Test.startTest();
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();


	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		System.debug('-----------------New Controller----------------');
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		Contact newContact = new Contact(Contact_Position__c = 'อื่นๆ โปรดระบุ',
	//															Firstname = '',
	//															LastName = 'test',
	//															Phone_Number__c = '123456789',
	//															Ext_CBS__c = '123232sdfd',
	//															Business_Email__c = 'Testtest.com'
	//															);

			
	//		CBS_CallReportWrapper.NewContactWrapper newContactWrap = new CBS_CallReportWrapper.NewContactWrapper(newContact);
	//		newContactWrap.lastName = 'test';
	//		callReportController.newContacts = new List<CBS_CallReportWrapper.NewContactWrapper>();
	//		callReportController.newContacts.add(newContactWrap);
	//		callReportController.saveAll();
	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testValidateNewContactNoLastName(){
	//	Test.startTest();
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();


	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		System.debug('-----------------New Controller----------------');
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		Contact newContact = new Contact(Contact_Position__c = 'อื่นๆ โปรดระบุ',
	//															Firstname = 'test',
	//															LastName = '',
	//															Phone_Number__c = '123456789',
	//															Ext_CBS__c = '123232sdfd',
	//															Business_Email__c = 'Testtest.com'
	//															);

	
	//		CBS_CallReportWrapper.NewContactWrapper newContactWrap = new CBS_CallReportWrapper.NewContactWrapper(newContact);
	//		newContactWrap.lastName = '';
			
	//		callReportController.newContacts = new List<CBS_CallReportWrapper.NewContactWrapper>();
	//		callReportController.newContacts.add(newContactWrap);
	//		callReportController.saveAll();
	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testValidateNewContactNoFirstNameNoLastNameNoPhoneNumber(){
	//	Test.startTest();
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();


	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		System.debug('-----------------New Controller----------------');
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		Contact newContact = new Contact(Contact_Position__c = 'อื่นๆ โปรดระบุ',
	//															Firstname = '',
	//															LastName = '',
	//															Phone_Number__c = '',
	//															Ext_CBS__c = '123232sdfd',
	//															Business_Email__c = 'Test@test.com',
	//															Title = 'testTitle'
	//															);

			
	//		CBS_CallReportWrapper.NewContactWrapper newContactWrap = new CBS_CallReportWrapper.NewContactWrapper(newContact);
	//		newContactWrap.lastName = '';

	//		callReportController.newContacts = new List<CBS_CallReportWrapper.NewContactWrapper>();
	//		callReportController.newContacts.add(newContactWrap);
	//		callReportController.saveAll();
	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testValidateNewContactNoRepresentativeTypeNoLastName(){
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();


	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	Test.startTest();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		System.debug('-----------------New Controller----------------');
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		Contact newContact = new Contact(Contact_Position__c = 'อื่นๆ โปรดระบุ',
	//															Firstname = 'test',
	//															LastName = '',
	//															Phone_Number__c = '123456789',
	//															Ext_CBS__c = '123232',
	//															Business_Email__c = 'Test@test.com',
	//															Contact_Representative_Type__c = 'User'
	//															);

			
	//		CBS_CallReportWrapper.NewContactWrapper newContactWrap = new CBS_CallReportWrapper.NewContactWrapper(newContact);
	//		newContactWrap.lastName = '';

	//		callReportController.newContacts = new List<CBS_CallReportWrapper.NewContactWrapper>();
	//		callReportController.newContacts.add(newContactWrap);
	//		callReportController.saveAll();
	//	}

	//	Test.stopTest();
	//}

	//@isTest static void testValidateNewContactNoRepresentativeTypeNoFirstName(){
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();


	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	Test.startTest();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		System.debug('-----------------New Controller----------------');
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		Contact newContact = new Contact(Contact_Position__c = 'อื่นๆ โปรดระบุ',
	//															Firstname = '',
	//															LastName = 'test',
	//															Phone_Number__c = '123456789',
	//															Ext_CBS__c = '123232',
	//															Business_Email__c = 'Test@test.com',
	//															Contact_Representative_Type__c = 'User'
	//															);

			
	//		CBS_CallReportWrapper.NewContactWrapper newContactWrap = new CBS_CallReportWrapper.NewContactWrapper(newContact);
	//		newContactWrap.lastName = 'test';

	//		callReportController.newContacts = new List<CBS_CallReportWrapper.NewContactWrapper>();
	//		callReportController.newContacts.add(newContactWrap);
	//		callReportController.saveAll();
	//	}

	//	Test.stopTest();
	//}

	//@isTest static void testValidateNewContactNoRepresentativeTypeNoPhoneNumber(){
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();


	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	Test.startTest();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		System.debug('-----------------New Controller----------------');
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		Contact newContact = new Contact(Contact_Position__c = 'อื่นๆ โปรดระบุ',
	//															Firstname = 'test',
	//															LastName = 'test',
	//															Phone_Number__c = '',
	//															Ext_CBS__c = '123232',
	//															Business_Email__c = 'Test@test.com',
	//															Contact_Representative_Type__c = 'User'
	//															);

			
	//		CBS_CallReportWrapper.NewContactWrapper newContactWrap = new CBS_CallReportWrapper.NewContactWrapper(newContact);
	//		newContactWrap.lastName = 'test';
	//		callReportController.newContacts = new List<CBS_CallReportWrapper.NewContactWrapper>();
	//		callReportController.newContacts.add(newContactWrap);
	//		callReportController.saveAll();
	//	}

	//	Test.stopTest();
	//}

	//@isTest static void testValidateNewContactNoContactPositionNoFirstName(){
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();


	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	Test.startTest();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		System.debug('-----------------New Controller----------------');
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		Contact newContact = new Contact(Contact_Position__c = '',
	//															Firstname = '',
	//															LastName = 'test',
	//															Phone_Number__c = '123456789',
	//															Ext_CBS__c = '123232',
	//															Business_Email__c = 'Test@test.com'
	//															);

			
	//		CBS_CallReportWrapper.NewContactWrapper newContactWrap = new CBS_CallReportWrapper.NewContactWrapper(newContact);
	//		newContactWrap.lastName = 'test';
	//		callReportController.newContacts = new List<CBS_CallReportWrapper.NewContactWrapper>();
	//		callReportController.newContacts.add(newContactWrap);
	//		callReportController.saveAll();
	//	}
	//}

	//@isTest static void testValidateNewContactNoContactPositionNoPhoneNumber(){
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccountForLead();
	//	Contact contact = CBS_CallReportNewEdit_Controller_Test.getContactOfRelatedAccount();
	//	Contact otherContact = CBS_CallReportNewEdit_Controller_Test.getOtherContact();


	//	setupPageParameterMap(account,null);
	//	setupLeadForSalesValueChain();

	//	Test.startTest();

	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		System.debug('-----------------New Controller----------------');
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		Contact newContact = new Contact(Contact_Position__c = '',
	//															Firstname = 'test',
	//															LastName = 'test',
	//															Phone_Number__c = '',
	//															Ext_CBS__c = '123232',
	//															Business_Email__c = 'Test@test.com'
	//															);

			
	//		CBS_CallReportWrapper.NewContactWrapper newContactWrap = new CBS_CallReportWrapper.NewContactWrapper(newContact);
	//		newContactWrap.lastName = 'test';

	//		callReportController.newContacts = new List<CBS_CallReportWrapper.NewContactWrapper>();
	//		callReportController.newContacts.add(newContactWrap);
	//		callReportController.saveAll();
	//	}
	//}

	//@isTest static void testhandleContactPostionChanged(){
	//	Test.startTest();
	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		System.currentPageReference().getParameters().put('rowToCheckContactPositionIndex','0');
	//		callReportController.newContacts.get(0).contact.Contact_Position__c = 'กรรมการ';
	//		callReportController.handleContactPostionChanged();
	//		/// Blank contacts
	//		callReportController.newContacts.get(0).contact.Contact_Position__c = '';
	//		callReportController.handleContactPostionChanged();
	//	}
	//	Test.stopTest();
	//}
	//@isTest static void testSaveAllCallReportNoPlanPositiveCase(){
	//	Test.startTest();
	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		setupPageParameterMap(account,null);
	//		System.currentPageReference().getParameters().put('callReportForCISLookUpInputFieldCISID',account.id);
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		callReportController.myCallReport.callReport.Status__c =  GlobalConstants.CONTACTED;
	//		callReportController.myCallReport.callReport.Visit_Objective_CBS__c = 'Relationship';
	//		callReportController.myCallReport.callReport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
	//		callReportController.myCallReport.callReport.CIS_ID__c = account.id;

	//		Contact newContact = new Contact(Firstname = 'NewContactFirstName',
	//										LastName = 'NewContactLastName',
	//										Phone_Number__c = '123456789',
	//										Ext_CBS__c = '9',
	//										Contact_Position__c = 'กรรมการ',
	//										Business_Email__c = 'NewContact@gmail.com'
	//			);
	//		callReportController.newContacts.get(0).contact = newContact;
	//		callReportController.newContacts.get(0).lastName = newContact.LastName;
	//		callReportController.saveAll();
				

	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testSaveAllCallReportWithPlanPositiveCase(){
	//	Test.startTest();
	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportWithCallPlan();
	//		setupPageParameterMap(account,callreport);
	//		System.currentPageReference().getParameters().put('callReportForCISLookUpInputFieldCISID',account.id);
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		callReportController.myCallReport.callReport.Status__c =  GlobalConstants.CONTACTED;
	//		callReportController.myCallReport.callReport.Visit_Objective_CBS__c = 'Sell';
	//		callReportController.myCallReport.callReport.Planned_Product_CBS__c = 'Credit & Non-Credit';
	//		callReportController.myCallReport.callReport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;

	//		Contact newContact = new Contact(Firstname = 'NewContactFirstName',
	//										LastName = 'NewContactLastName',
	//										Phone_Number__c = '123456789',
	//										Ext_CBS__c = '9',
	//										Contact_Position__c = 'กรรมการ',
	//										Business_Email__c = 'NewContact@gmail.com'
	//			);
	//		callReportController.newContacts.get(0).contact = newContact;
	//		callReportController.newContacts.get(0).lastName = newContact.LastName;
	//		callReportController.saveAll();
				

	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testSaveAllPassButInsertCallReportNoPlanFailNegativeCase(){
	//	Test.startTest();
	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		setupPageParameterMap(account,null);
	//		System.currentPageReference().getParameters().put('callReportForCISLookUpInputFieldCISID',account.id);
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		callReportController.myCallReport.callReport.Status__c =  GlobalConstants.CONTACTED;
	//		callReportController.myCallReport.callReport.Visit_Objective_CBS__c = 'UnknownType';
	//		//callReportController.myCallReport.callReport.Planned_Product_CBS__c = 'Credit & Non-Credit';
	//		callReportController.myCallReport.callReport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
	//		callReportController.myCallReport.callReport.CIS_ID__c = account.id;

	//		Contact newContact = new Contact(Firstname = 'NewContactFirstName',
	//										LastName = 'NewContactLastName',
	//										Phone_Number__c = '123456789',
	//										Ext_CBS__c = '9',
	//										Contact_Position__c = 'กรรมการ',
	//										Business_Email__c = 'NewContact@gmail.com'
	//			);
	//		callReportController.newContacts.get(0).contact = newContact;
	//		callReportController.newContacts.get(0).lastName = newContact.LastName;
	//		callReportController.saveAll();
				

	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testSaveAllPassButInsertCallReportWithPlanFailNegativeCase(){
	//	Test.startTest();
	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportWithCallPlan();
	//		setupPageParameterMap(account,callreport);
	//		System.currentPageReference().getParameters().put('callReportForCISLookUpInputFieldCISID',account.id);
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		callReportController.myCallReport.callReport.Status__c =  GlobalConstants.CONTACTED;
	//		callReportController.myCallReport.callReport.Visit_Objective_CBS__c = 'UnknownType';
	//		callReportController.myCallReport.callReport.Planned_Product_CBS__c = 'UnknownType';
	//		callReportController.myCallReport.callReport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;

	//		Contact newContact = new Contact(Firstname = 'NewContactFirstName',
	//										LastName = 'NewContactLastName',
	//										Phone_Number__c = '123456789',
	//										Ext_CBS__c = '9',
	//										Contact_Position__c = 'UnknowPosition',
	//										Business_Email__c = 'NewContact@gmail.com'
	//			);
	//		callReportController.newContacts.get(0).contact = newContact;
	//		callReportController.newContacts.get(0).lastName = newContact.LastName;
	//		callReportController.saveAll();
				

	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testSaveAllPassButUpdateTargetListFailNegativeCase(){
	//	CBS_CallReportNewEdit_Controller_Test.setupLeadForSalesAccountPlanning();
	//	Test.startTest();
	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		setupPageParameterMap(account,null);
	//		System.currentPageReference().getParameters().put('callReportForCISLookUpInputFieldCISID',account.id);
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);
	//		callReportController.myCallReport.callReport.Status__c =  GlobalConstants.CONTACTED;
	//		callReportController.myCallReport.callReport.Visit_Objective_CBS__c = 'Relationship';
	//		callReportController.myCallReport.callReport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
	//		callReportController.myCallReport.callReport.CIS_ID__c = account.id;

	//		Contact newContact = new Contact(Firstname = 'NewContactFirstName',
	//										LastName = 'NewContactLastName',
	//										Phone_Number__c = '123456789',
	//										Ext_CBS__c = '9',
	//										Contact_Position__c = 'กรรมการ',
	//										Business_Email__c = 'NewContact@gmail.com'
	//			);
	//		callReportController.newContacts.get(0).contact = newContact;
	//		callReportController.newContacts.get(0).lastName = newContact.LastName;

	//		callReportController.leads.get(0).targetList.Status__c = 'UnknownStatus';
	//		callReportController.saveAll();
	//	}
	//	Test.stopTest();
	//}

	//@isTest static void testSaveAllWithWinMandateOppPlanning(){
	//		Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//		Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//		ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//		setupPageParameterMap(account,null);
	//		CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);

	//		List<CBS_CallReportWrapper.ProductWrapper> productList = callReportController.callReportProductModal.productWrapperMapByProductGroup.get(CBS_CallReportNewEdit_Controller_Test.pruductGruop_Transaction);
	//		for(CBS_CallReportWrapper.ProductWrapper eachProduct : productList){
	//			eachProduct.isSelected = true;
	//			eachProduct.interest = true;
	//			eachProduct.productType = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING;
	//			eachProduct.newLimit = '10000';
	//			eachProduct.outstanding = '10000';
	//			eachProduct.frontEndFee = '10000';
	//			eachProduct.fee = '10000';
	//		}

	//		callReportController.newOpportunityPlanning();
	//		List<CBS_OpportunityPlanningWrapper> oppPlanningGroup_TransactionList = callReportController.oppPlanningMapByproductGroup.get(CBS_CallReportNewEdit_Controller_Test.pruductGruop_Transaction);
	//		for(CBS_OpportunityPlanningWrapper eachOppPlanningWrapper : oppPlanningGroup_TransactionList){
	//			eachOppPlanningWrapper.opportunityPlanning.Status__c = GlobalConstants.OPP_PLAN_WIN_MANDATE;
	//		}
	//		callReportController.saveAll();
	//}

	//@isTest static void testRenderOppPlanningWrapperOnPageBasedOnCustomSetting(){
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//	Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.createCallReportFromCustomerInfo();
	//	ApexPages.StandardController stdController = new ApexPages.StandardController(callreport);
	//	setupPageParameterMap(account,null);
	//	CBS_CallReportNewEdit_Controller callReportController = new CBS_CallReportNewEdit_Controller(stdController);

	//	List<CBS_CallReportWrapper.ProductWrapper> productList = callReportController.callReportProductModal.productWrapperMapByProductGroup.get(CBS_CallReportNewEdit_Controller_Test.pruductGruop_Transaction);
	//	for(CBS_CallReportWrapper.ProductWrapper eachProduct : productList){
	//		eachProduct.isSelected = true;
	//		eachProduct.interest = true;
	//		eachProduct.productType = GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING;
	//		eachProduct.newLimit = '10000';
	//		eachProduct.outstanding = '10000';
	//		eachProduct.frontEndFee = '10000';
	//		eachProduct.fee = '10000';
	//	}

	//	callReportController.newOpportunityPlanning();
	//	List<CBS_OpportunityPlanningWrapper> oppPlanningGroup_TransactionList = callReportController.oppPlanningMapByproductGroup.get(CBS_CallReportNewEdit_Controller_Test.pruductGruop_Transaction);
		
	//	CBS_OpportunityPlanningWrapper oppPlanning = oppPlanningGroup_TransactionList.get(0);
	//	System.assertEquals(true,oppPlanning.getrenderAddtoExistingOpportunity());
	//	System.assertEquals(true,oppPlanning.getrenderGroupOppPlanningWrapper());
	//	System.assertEquals(true,oppPlanning.getIsOppPlanningWrapperEditable());
	//}

	
	//////////////////////////////////////////////////////////////////////////

	//public static void setUpOpportunityPlanningData(){
 //   	Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
 //   	Call_Report__c callreport = CBS_CallReportNewEdit_Controller_Test.getRelatedCallReport();

 //   	Opportunity_Planning__c oppPlanningCreditProduct = new Opportunity_Planning__c(	
 //   		CIS_ID__c = account.id,
 //   		Expected_Income_to_KBank__c = 10.0,
 //   		Expected_LimitVolume_Amount__c = 20.0,
 //   		Project_Size__c = 30.0,
 //   		Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
 //   		Call_Report_CBS__c =  callreport.id,
 //   		Product_Type__c = 'Credit'
 //   	);
 //   	insert oppPlanningCreditProduct;

	//    List<Opportunity_Planning_Line_Item__c> oppPlaningLineItemCreditProductList = new List<Opportunity_Planning_Line_Item__c>{
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'OD/PN/LI'),
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'LC/TR/PC/DLC'),
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'Long Term'),
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'KL/KF&E'),
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'OD/PN/LI'),
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'FXDE'),
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'SBLC'),
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'PO/SPO/PP/Advisory/IFF'),
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'M&A'),
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'REIT'),
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'IPO'),
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'Syndicated Loan'),
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'Debenture'),
	//    	new Opportunity_Planning_Line_Item__c(Opportunity_Planning__c = oppPlanningCreditProduct.id,
	//    											Product_Name__c = 'OtherProductCredit')

	//    };
	//    insert oppPlaningLineItemCreditProductList;

	//    List<Opportunity_Planning__c> oppPlanningNonCreditProductList = new List<Opportunity_Planning__c>{
	//	    new Opportunity_Planning__c(	
	//    		CIS_ID__c = account.id,
	//    		Expected_Income_to_KBank__c = 10.0,
	//    		Expected_LimitVolume_Amount__c = 20.0,
	//    		Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
	//    		Call_Report_CBS__c =  callreport.id,
	//    		Product_Type__c = 'Non-Credit'
	//    	),
	//	    new Opportunity_Planning__c(	
	//    		CIS_ID__c = account.id,
	//    		Expected_Income_to_KBank__c = 10.0,
	//    		Expected_LimitVolume_Amount__c = 20.0,
	//    		Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
	//    		Call_Report_CBS__c =  callreport.id,
	//    		Product_Type__c = 'Non-Credit'
 //   		),
	//	    new Opportunity_Planning__c(	
	//    		CIS_ID__c = account.id,
	//    		Expected_Income_to_KBank__c = 10.0,
	//    		Expected_LimitVolume_Amount__c = 20.0,
	//    		Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
	//    		Call_Report_CBS__c =  callreport.id,
	//    		Product_Type__c = 'Non-Credit'
 //   		),
	//	    new Opportunity_Planning__c(	
	//    		CIS_ID__c = account.id,
	//    		Expected_Income_to_KBank__c = 10.0,
	//    		Expected_LimitVolume_Amount__c = 20.0,
	//    		Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
	//    		Call_Report_CBS__c =  callreport.id,
	//    		Product_Type__c = 'Non-Credit'
 //   		),
 //   		new Opportunity_Planning__c(	
	//    		CIS_ID__c = account.id,
	//    		Expected_Income_to_KBank__c = 10.0,
	//    		Expected_LimitVolume_Amount__c = 20.0,
	//    		Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
	//    		Call_Report_CBS__c =  callreport.id,
	//    		Product_Type__c = 'Non-Credit'
 //   		),
 //   		new Opportunity_Planning__c(	
	//    		CIS_ID__c = account.id,
	//    		Expected_Income_to_KBank__c = 10.0,
	//    		Expected_LimitVolume_Amount__c = 20.0,
	//    		Status__c = GlobalConstants.OPP_PLAN_EXPLORE,
	//    		Call_Report_CBS__c =  callreport.id,
	//    		Product_Type__c = 'Non-Credit'
 //   		)
	//    };
	//    insert oppPlanningNonCreditProductList;

	//    List<Opportunity_Planning_Line_Item__c> oppPlaningLineItemNonCreditProductList = new List<Opportunity_Planning_Line_Item__c>{
	//	    	new Opportunity_Planning_Line_Item__c(
	//    		Opportunity_Planning__c = oppPlanningNonCreditProductList.get(0).id,
	//    		Product_Name__c = 'Trade'
	//    		),
	//    		new Opportunity_Planning_Line_Item__c(
	//    		Opportunity_Planning__c = oppPlanningNonCreditProductList.get(1).id,
	//    		Product_Name__c = 'FX'
	//    		),
	//    		new Opportunity_Planning_Line_Item__c(
	//    		Opportunity_Planning__c = oppPlanningNonCreditProductList.get(2).id,
	//    		Product_Name__c = 'Deposit'
	//    		),
	//    		new Opportunity_Planning_Line_Item__c(
	//    		Opportunity_Planning__c = oppPlanningNonCreditProductList.get(3).id,
	//    		Product_Name__c = 'Cash'
	//    		),
	//    		new Opportunity_Planning_Line_Item__c(
	//    		Opportunity_Planning__c = oppPlanningNonCreditProductList.get(4).id,
	//    		Product_Name__c = 'EDC'
	//    		),
	//    		new Opportunity_Planning_Line_Item__c(
	//    		Opportunity_Planning__c = oppPlanningNonCreditProductList.get(5).id,
	//    		Product_Name__c = 'OtherProductNonCredit'
	//    		)
	//	};
	//	insert oppPlaningLineItemNonCreditProductList;

 //   }

 //   private static void setupLeadForSalesEDC(){
	//	Account account = CBS_CallReportNewEdit_Controller_Test.getAccount();
	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		Campaign leadForSalesEDC = new Campaign();
	//        leadForSalesEDC.Lead_Campaign_Event_Code__c = leadForSalesEDCName;
	//        leadForSalesEDC.Type__c = GlobalConstants.LEAD_FOR_SALES;
	//        leadForSalesEDC.Name = leadForSalesEDCName;
	//        leadForSalesEDC.Sub_Type_CBS__c = GlobalConstants.LEAD_SUB_TYPE_EDC;
	//        leadForSalesEDC.Status = GlobalConstants.ACTIVE;
	//        leadForSalesEDC.IsActive = true;
	//        leadForSalesEDC.StartDate = System.today() - 1;
	//		leadForSalesEDC.EndDate = System.Today() + 1;
	//        leadForSalesEDC.Effective_Date__c = System.Today() - 1;
	//        leadForSalesEDC.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_CBS_REC);
	//        leadForSalesEDC.Product_List_CBS__c = 'EDC';
	//        insert leadForSalesEDC;

	//        Target_List__c tglLeadForSalesEDC = new Target_List__c();
	//        tglLeadForSalesEDC.Lead_Campaign__c = leadForSalesEDC.Id;
	//        tglLeadForSalesEDC.CIS_ID_Prospect_Name__c = account.Id;
	//        tglLeadForSalesEDC.Status__c = GlobalConstants.STATUS_NEW;
	//        insert tglLeadForSalesEDC;
	//	}
	//}

	//private static void setupLeadForSalesValueChain(){
	//	//Account account = [SELECT Id FROM Account WHERE Name =: accountName2 LIMIT 1];
	//	Account account = Mockup_Test.getFirstAccountFromName(accountName2, 'Id,Name,CIS__c');
	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
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

	//private static void setupLeadForSalesStrategicProvince(){
	//	//Account account = [SELECT Id FROM Account WHERE Name =: accountName LIMIT 1];
	//	Account account = Mockup_Test.getFirstAccountFromName(accountName, 'Id,Name,CIS__c');
	//	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
	//		Campaign leadForSalesStrategicProvince = new Campaign();
	//        leadForSalesStrategicProvince.Lead_Campaign_Event_Code__c = leadForSalesStrategicProvinceName;
	//        leadForSalesStrategicProvince.Type__c = GlobalConstants.LEAD_FOR_SALES;
	//        leadForSalesStrategicProvince.Name = leadForSalesStrategicProvinceName;
	//        leadForSalesStrategicProvince.Sub_Type_CBS__c = GlobalConstants.LEAD_SUB_TYPE_STRATEGIC_PROVINCE;
	//        leadForSalesStrategicProvince.Status = GlobalConstants.ACTIVE;
	//        leadForSalesStrategicProvince.IsActive = true;
	//        leadForSalesStrategicProvince.StartDate = System.today() - 1;
	//		leadForSalesStrategicProvince.EndDate = System.Today() + 1;
	//        leadForSalesStrategicProvince.Effective_Date__c = System.Today() - 1;
	//        leadForSalesStrategicProvince.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_CBS_REC);
	//        leadForSalesStrategicProvince.Product_List_CBS__c = 'EDC';
	//        insert leadForSalesStrategicProvince;

	//        Target_List__c tglLeadForSalesStrategicProvince = new Target_List__c();
	//        tglLeadForSalesStrategicProvince.Lead_Campaign__c = leadForSalesStrategicProvince.Id;
	//        tglLeadForSalesStrategicProvince.CIS_ID_Prospect_Name__c = account.Id;
	//        tglLeadForSalesStrategicProvince.Status__c = GlobalConstants.STATUS_NEW;
	//        insert tglLeadForSalesStrategicProvince;


	//	}
		
	//}

	//private static void setupLeadForSalesAccountPlanning(){
	//	//Account account = [SELECT Id FROM Account WHERE Name =: accountName LIMIT 1];
	//	Account account = Mockup_Test.getFirstAccountFromName(accountName, 'Id,Name,CIS__c');    	
 //   	Campaign leadForSalesAccountPlanning = new Campaign();
 //       leadForSalesAccountPlanning.Lead_Campaign_Event_Code__c = leadForSalesAccountPlanningName;
 //       leadForSalesAccountPlanning.Type__c = GlobalConstants.LEAD_FOR_SALES;
 //       leadForSalesAccountPlanning.Name = leadForSalesAccountPlanningName;
 //       leadForSalesAccountPlanning.Sub_Type_CBS__c = GlobalConstants.LEAD_SUB_TYPE_ACCOUNT_PLANNING_HUB;
 //       leadForSalesAccountPlanning.Status = GlobalConstants.ACTIVE;
 //       leadForSalesAccountPlanning.IsActive = true;
 //       leadForSalesAccountPlanning.StartDate = System.today() - 1;
	//	leadForSalesAccountPlanning.EndDate = System.Today() + 1;
 //       leadForSalesAccountPlanning.Effective_Date__c = System.Today() - 1;
 //       leadForSalesAccountPlanning.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_CBS_REC);
 //       leadForSalesAccountPlanning.Product_List_CBS__c = 'EDC';
 //       insert leadForSalesAccountPlanning;

 //       Target_List__c tglLeadForSalesAccountPlanning = new Target_List__c();
 //       tglLeadForSalesAccountPlanning.Lead_Campaign__c = leadForSalesAccountPlanning.Id;
 //       tglLeadForSalesAccountPlanning.CIS_ID_Prospect_Name__c = account.Id;
 //       tglLeadForSalesAccountPlanning.Status__c = GlobalConstants.STATUS_NEW;
 //       insert tglLeadForSalesAccountPlanning;
 //   }

 //   private static void setupLeadForActionTradeDecreaseInterest(){

 //   	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
 //   		//Account account = [SELECT Id FROM Account WHERE Name =: accountName LIMIT 1];
 //   		Account account = Mockup_Test.getFirstAccountFromName(accountName, 'Id,Name,CIS__c');
	//    	Campaign leadForActionTradeDecreaseInterest = new Campaign();
	//        leadForActionTradeDecreaseInterest.Lead_Campaign_Event_Code__c = leadForActionTradeDecreaseInterestName;
	//        leadForActionTradeDecreaseInterest.Type__c = GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER;
	//        leadForActionTradeDecreaseInterest.Name = leadForActionTradeDecreaseInterestName;
	//        leadForActionTradeDecreaseInterest.Sub_Type_CBS__c = GlobalConstants.LEAD_SUB_TYPE_TRADE_DECREASE_INTEREST;
	//        leadForActionTradeDecreaseInterest.Status = GlobalConstants.ACTIVE;
	//        leadForActionTradeDecreaseInterest.IsActive = true;
	//        leadForActionTradeDecreaseInterest.StartDate = System.today() - 1;
	//		leadForActionTradeDecreaseInterest.EndDate = System.Today() + 1;
	//        leadForActionTradeDecreaseInterest.Effective_Date__c = System.Today() - 1;
	//        leadForActionTradeDecreaseInterest.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_CBS_REC);
	//        insert leadForActionTradeDecreaseInterest;

	//        Target_List__c tglLeadForActionTradeDecreaseInterest = new Target_List__c();
	//        tglLeadForActionTradeDecreaseInterest.Lead_Campaign__c = leadForActionTradeDecreaseInterest.Id;
	//        tglLeadForActionTradeDecreaseInterest.CIS_ID_Prospect_Name__c = account.Id;
	//        tglLeadForActionTradeDecreaseInterest.Status__c = GlobalConstants.STATUS_NEW;
	//        insert tglLeadForActionTradeDecreaseInterest;

	//        List<Lead_To_Do_Response__c> listResponseAction = new List<Lead_To_Do_Response__c>();

	//        Lead_To_Do_Response__c confirmDecrease = new Lead_To_Do_Response__c();
	//        confirmDecrease.Type__c = GlobalConstants.LEAD_SUB_TYPE_TRADE_DECREASE_INTEREST;
	//        confirmDecrease.Response_Level_1__c = '1. ลดแล้ว';
	//        confirmDecrease.Required_Level_2__c = false;
	//        confirmDecrease.Required_Memo__c = false;
	//        confirmDecrease.Required_Product_c__c = false;
	//        confirmDecrease.Team__c = GlobalConstants.CBS;
	//        listResponseAction.add(confirmDecrease);


	//        Lead_To_Do_Response__c cancelDecrease = new Lead_To_Do_Response__c();
	//        cancelDecrease.Type__c = GlobalConstants.LEAD_SUB_TYPE_TRADE_DECREASE_INTEREST;
	//        cancelDecrease.Response_Level_1__c = '2. ยกเลิก (โปรดระบุ)';
	//        cancelDecrease.Required_Level_2__c = false;
	//        cancelDecrease.Required_Memo__c = true;
	//        cancelDecrease.Required_Product_c__c = false;
	//        cancelDecrease.Team__c = GlobalConstants.CBS;
	//        listResponseAction.add(cancelDecrease);

	//        insert listResponseAction;
 //   	}
    	
 //   }

 //   private static void setupLeadForActionTradeDecreaseInterestStatusNotNew(){

 //   	System.runAs(CBS_CallReportNewEdit_Controller_Test.getUser()){
 //   		//Account account = [SELECT Id FROM Account WHERE Name =: accountName LIMIT 1];
 //   		Account account = Mockup_Test.getFirstAccountFromName(accountName, 'Id,Name,CIS__c');
	//    	Campaign leadForActionTradeDecreaseInterest = new Campaign();
	//        leadForActionTradeDecreaseInterest.Lead_Campaign_Event_Code__c = leadForActionTradeDecreaseInterestName;
	//        leadForActionTradeDecreaseInterest.Type__c = GlobalConstants.LEAD_FOR_ACTION_WITH_CUSTOMER;
	//        leadForActionTradeDecreaseInterest.Name = leadForActionTradeDecreaseInterestName;
	//        leadForActionTradeDecreaseInterest.Sub_Type_CBS__c = GlobalConstants.LEAD_SUB_TYPE_TRADE_DECREASE_INTEREST;
	//        leadForActionTradeDecreaseInterest.Status = GlobalConstants.ACTIVE;
	//        leadForActionTradeDecreaseInterest.IsActive = true;
	//        leadForActionTradeDecreaseInterest.StartDate = System.today() - 1;
	//		leadForActionTradeDecreaseInterest.EndDate = System.Today() + 1;
	//        leadForActionTradeDecreaseInterest.Effective_Date__c = System.Today() - 1;
	//        leadForActionTradeDecreaseInterest.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName(GlobalConstants.CAMPAIGN_CBS_REC);
	//        insert leadForActionTradeDecreaseInterest;

	//        Target_List__c tglLeadForActionTradeDecreaseInterest = new Target_List__c();
	//        tglLeadForActionTradeDecreaseInterest.Lead_Campaign__c = leadForActionTradeDecreaseInterest.Id;
	//        tglLeadForActionTradeDecreaseInterest.CIS_ID_Prospect_Name__c = account.Id;
	//        tglLeadForActionTradeDecreaseInterest.Status__c = GlobalConstants.CREATE_WRITE_UP;
	//        insert tglLeadForActionTradeDecreaseInterest;

	//        List<Lead_To_Do_Response__c> listResponseAction = new List<Lead_To_Do_Response__c>();

	//        Lead_To_Do_Response__c confirmDecrease = new Lead_To_Do_Response__c();
	//        confirmDecrease.Type__c = GlobalConstants.LEAD_SUB_TYPE_TRADE_DECREASE_INTEREST;
	//        confirmDecrease.Response_Level_1__c = '1. ลดแล้ว';
	//        confirmDecrease.Required_Level_2__c = false;
	//        confirmDecrease.Required_Memo__c = false;
	//        confirmDecrease.Required_Product_c__c = false;
	//        confirmDecrease.Team__c = GlobalConstants.CBS;
	//        listResponseAction.add(confirmDecrease);


	//        Lead_To_Do_Response__c cancelDecrease = new Lead_To_Do_Response__c();
	//        cancelDecrease.Type__c = GlobalConstants.LEAD_SUB_TYPE_TRADE_DECREASE_INTEREST;
	//        cancelDecrease.Response_Level_1__c = '2. ยกเลิก (โปรดระบุ)';
	//        cancelDecrease.Required_Level_2__c = false;
	//        cancelDecrease.Required_Memo__c = true;
	//        cancelDecrease.Required_Product_c__c = false;
	//        cancelDecrease.Team__c = GlobalConstants.CBS;
	//        listResponseAction.add(cancelDecrease);

	//        insert listResponseAction;
 //   	}
    	
 //   }

	
 //   private static void setUpRelated_Account_Contact_CallReport_Opportunity(){
	//	Account acc = new Account(
	//    	Name = accountName,
	//		CIS__c = '111111',
	//		Primary_Segment_Code__c = 'CB',
	//		Port_Pool__c = GlobalConstants.PORT,
	//		Birthdate_Registration_Date__c = System.today().addYears(-10),
	//		Encrypt_Identification_No__c = '111111111111111',
	//		RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME)
	//	);
	//	insert acc;
	//	Account acc2 = new Account(
	//    	Name = accountName2,
	//		CIS__c = '33333',
	//		Primary_Segment_Code__c = 'CB',
	//		Port_Pool__c = GlobalConstants.PORT,
	//		Birthdate_Registration_Date__c = System.today().addYears(-10),
	//		Encrypt_Identification_No__c = '333333333333333',
	//		RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME)
	//	);
	//	insert acc2;

	//	Account prospectAccount = new Account(
	//    	Name = prospectName,
	//		CIS__c = '33334',
	//		Primary_Segment_Code__c = 'CB',
	//		Port_Pool__c = GlobalConstants.PORT,
	//		RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME)
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

 //   private static void setUpUnRelated_Account_Contact_CallReport_Opportunity(){
	//	Account acc2 = new Account(
	//    	Name = otheraccountName,
	//		CIS__c = '22222',
	//		Primary_Segment_Code__c = 'CB',
	//		Port_Pool__c = GlobalConstants.PORT,
	//		Birthdate_Registration_Date__c = System.today().addYears(-10),
	//		Encrypt_Identification_No__c = '222222222222222',
	//		RecordTypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME)
	//	);
	//	insert acc2;

	//	Contact contact2 = new Contact(
	//		FirstName = othercontactFirstName, 
	//		LastName = 'OtherContactLastName',
	//		Phone_Number__c = '000000000',
	//		Business_Email__c = '0000@hotmail.com',
	//		Contact_Position__c = 'กรรมการ'
	//	);
	//	insert contact2;
	//	Call_Report__c callreport = new Call_Report__c(
 //   				CIS_ID__c = acc2.id,
 //   				Actual_Visit_Date__c = System.today(),
 //   				Status__c = 'Contacted'
 //   	);
 //   }

 //   public static void initOppPlanCustomSetting(){
 //       List<Opportunity_Planning_Type__c> oppPlanCSList = new List<Opportunity_Planning_Type__c>();
 //       Opportunity_Planning_Type__c oppPlanCS = Mockup_Test.newOpplanningCustomSetting('New Booking',GlobalConstants.OPP_PLAN_PRODUCT_TYPE_UW_DLA_NEW_BOOKING,true,true,GlobalConstants.NEW_CREDIT,'New_Limit__c','Credit');
 //       Opportunity_Planning_Type__c oppPlanCS2 = Mockup_Test.newOpplanningCustomSetting('Non-Credit',GlobalConstants.OPP_PLAN_NON_CREDIT,false,false,null,'New_Limit__c','Non-Credit');
 //       oppPlanCSList.add(oppPlanCS);
 //       oppPlanCSList.add(oppPlanCS2);
 //       insert oppPlanCSList;
 //   }

}