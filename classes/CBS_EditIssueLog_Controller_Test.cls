@isTest
private class CBS_EditIssueLog_Controller_Test {
	//test for increase class coverage without assert
	private static String accountName = 'accountName';
	@testSetup static void setupUser(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCodeCBS();
        User cbsRmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1];
        System.runAs(cbsRmUser){
            mt.newAccount(accountName,'Port',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        List<Issue_Master__c> listMaster = new List<Issue_Master__c>();
        Issue_Master__c newMaster1 = new Issue_Master__c();
        newMaster1.Division__c = 'Division1';
        newMaster1.Product__c = 'Product1';
        newMaster1.Category__c = 'Category1';
        newMaster1.Sub_Category__c = 'SubCategory1';
        listMaster.add(newMaster1);

        Issue_Master__c newMaster2 = new Issue_Master__c();
        newMaster2.Division__c = 'Division2';
        newMaster2.Product__c = 'Product2';
        newMaster2.Category__c = 'Category2';
        newMaster2.Sub_Category__c = 'SubCategory2';
        listMaster.add(newMaster2);

        insert listMaster;
    }
	@isTest static void testInitMethod() {
		Account cbsAccount = Mockup_Test.getFirstAccountFromName(accountName,'Id,Name');
		Issue_Log__c newIssue = new Issue_Log__c(
			Subject__c = 'test', 
			Status__c = GlobalConstants.ON_PROCESS_BY_PM, 
			CIS_ID_or_Prospect_Name__c = cbsAccount.Id,
			Issue_Description__c = 'aaaa'
		);
		insert newIssue;
		CBS_EditIssueLog_Controller pageController = new CBS_EditIssueLog_Controller(new ApexPages.StandardController(newIssue));
	}
	
	@isTest static void testGetListMethod() {
		Account cbsAccount = Mockup_Test.getFirstAccountFromName(accountName,'Id,Name');
		Issue_Log__c newIssue = new Issue_Log__c(
			Subject__c = 'test', 
			Status__c = GlobalConstants.ON_PROCESS_BY_PM, 
			CIS_ID_or_Prospect_Name__c = cbsAccount.Id,
			Issue_Description__c = 'aaaa'
		);
		insert newIssue;
		CBS_EditIssueLog_Controller pageController = new CBS_EditIssueLog_Controller(new ApexPages.StandardController(newIssue));
		pageController.getIssueMaster();
		pageController.getDivisionList();
		pageController.getProductList();
		pageController.getCategoryList();
		pageController.getSubCategoryList();
	}

	@isTest static void testGetReAssignToMethod() {
		Account cbsAccount = Mockup_Test.getFirstAccountFromName(accountName,'Id,Name');
		Issue_Log__c newIssue = new Issue_Log__c(
			Subject__c = 'test', 
			Status__c = GlobalConstants.ON_PROCESS_BY_PM, 
			CIS_ID_or_Prospect_Name__c = cbsAccount.Id,
			Issue_Description__c = 'aaaa'
		);
		insert newIssue;
		CBS_EditIssueLog_Controller pageController = new CBS_EditIssueLog_Controller(new ApexPages.StandardController(newIssue));
		//cbs admin profile
		User cbsAdminUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBSAdmin LIMIT 1];
		System.runAs(cbsAdminUser){
			//pageController.selectReassignTo ='';
			pageController.getReAssignToList();
		}
		//cbs fsvp profile
		User cbsTlUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBTL LIMIT 1];
		System.runAs(cbsTlUser){
			//pageController.selectReassignTo ='';
			pageController.getReAssignToList();
		}
		//cbs admin profile
		User cbsFsvpUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBFSVP LIMIT 1];
		System.runAs(cbsFsvpUser){
			//pageController.selectReassignTo ='';
			pageController.getReAssignToList();
		}
	}
	
	@isTest static void testGetReAssignNameListMethod() {
		Account cbsAccount = Mockup_Test.getFirstAccountFromName(accountName,'Id,Name');
		CBS_Issue_Log_Management__c newManage = new CBS_Issue_Log_Management__c();
     	newManage.Name = 'newManage';
     	insert newManage;

		Issue_Log__c newIssue = new Issue_Log__c(
			Subject__c = 'test', 
			Status__c = GlobalConstants.ON_PROCESS_BY_PM, 
			CIS_ID_or_Prospect_Name__c = cbsAccount.Id,
			Issue_Description__c = 'aaaa'
		);
		insert newIssue;
		CBS_EditIssueLog_Controller pageController = new CBS_EditIssueLog_Controller(new ApexPages.StandardController(newIssue));
		pageController.selectReassignTo =GlobalConstants.CBS_TL;
		pageController.getReAssignNameList();
		
		pageController.selectReassignTo =GlobalConstants.CBS_FSVP;
		pageController.getReAssignNameList();
		
		pageController.selectReassignTo =GlobalConstants.CBS_SC;
		pageController.getReAssignNameList();

		pageController.selectReassignTo =GlobalConstants.CBS_SP;
		pageController.getReAssignNameList();
	}

	@isTest static void testRenderDivisionHelpText(){
		Account cbsAccount = Mockup_Test.getFirstAccountFromName(accountName,'Id,Name');
		Issue_Log__c newIssue = new Issue_Log__c(
			Subject__c = 'test', 
			Status__c = GlobalConstants.ON_PROCESS_BY_PM, 
			CIS_ID_or_Prospect_Name__c = cbsAccount.Id,
			Issue_Description__c = 'aaaa'
		);
		insert newIssue;
		CBS_EditIssueLog_Controller pageController = new CBS_EditIssueLog_Controller(new ApexPages.StandardController(newIssue));
		pageController.selectDivision = 'None';
		pageController.renderDivisionHelpText();

		pageController.selectDivision = 'CBS';
        pageController.renderDivisionHelpText();

        pageController.selectDivision = 'CMB';
        pageController.renderDivisionHelpText();

        pageController.selectDivision = 'CSF';
        pageController.renderDivisionHelpText();

        pageController.selectDivision = 'CSP';
        pageController.renderDivisionHelpText();
        
        pageController.selectDivision = 'ERM';
        pageController.renderDivisionHelpText();

    	pageController.selectDivision = 'FCL';
        pageController.renderDivisionHelpText();

        pageController.selectDivision = 'IBB';
        pageController.renderDivisionHelpText();

        pageController.selectDivision = 'RBS';
        pageController.renderDivisionHelpText();

        pageController.selectDivision = 'WBS';
        pageController.renderDivisionHelpText();

        pageController.selectDivision = 'other';
        pageController.renderDivisionHelpText();
	}

	@isTest static void testValidateSelectDivision(){
		Account cbsAccount = Mockup_Test.getFirstAccountFromName(accountName,'Id,Name');
		Issue_Log__c newIssue = new Issue_Log__c(
			Subject__c = 'test', 
			Status__c = GlobalConstants.ON_PROCESS_BY_PM, 
			CIS_ID_or_Prospect_Name__c = cbsAccount.Id,
			Issue_Description__c = 'aaaa'
		);
		insert newIssue;
		CBS_EditIssueLog_Controller pageController = new CBS_EditIssueLog_Controller(new ApexPages.StandardController(newIssue));
		pageController.validateSelectDivision();
	}

	@isTest static void testValidateSelectProduct(){
		Account cbsAccount = Mockup_Test.getFirstAccountFromName(accountName,'Id,Name');
		Issue_Log__c newIssue = new Issue_Log__c(
			Subject__c = 'test', 
			Status__c = GlobalConstants.ON_PROCESS_BY_PM, 
			CIS_ID_or_Prospect_Name__c = cbsAccount.Id,
			Issue_Description__c = 'aaaa'
		);
		insert newIssue;
		CBS_EditIssueLog_Controller pageController = new CBS_EditIssueLog_Controller(new ApexPages.StandardController(newIssue));
		pageController.validateSelectProduct();
	}

	@isTest static void testValidateSelectCategory(){
		Account cbsAccount = Mockup_Test.getFirstAccountFromName(accountName,'Id,Name');
		Issue_Log__c newIssue = new Issue_Log__c(
			Subject__c = 'test', 
			Status__c = GlobalConstants.ON_PROCESS_BY_PM, 
			CIS_ID_or_Prospect_Name__c = cbsAccount.Id,
			Issue_Description__c = 'aaaa'
		);
		insert newIssue;
		CBS_EditIssueLog_Controller pageController = new CBS_EditIssueLog_Controller(new ApexPages.StandardController(newIssue));
		pageController.validateSelectCategory();
	}

	@isTest static void testDoSaveReAssign(){
		CBS_Issue_Log_Management__c newManage = new CBS_Issue_Log_Management__c();
     	newManage.Name = 'newManage';
     	insert newManage;
     	Account cbsAccount = Mockup_Test.getFirstAccountFromName(accountName,'Id,Name');
     	Issue_Log__c newIssue = new Issue_Log__c(
			Subject__c = 'test', 
			Status__c = GlobalConstants.ON_PROCESS_BY_PM, 
			CIS_ID_or_Prospect_Name__c = cbsAccount.Id,
			Issue_Description__c = 'aaaa'
		);
		insert newIssue;
		CBS_EditIssueLog_Controller pageController = new CBS_EditIssueLog_Controller(new ApexPages.StandardController(newIssue));
		pageController.selectReassignTo = GlobalConstants.CBS_FSVP;
		pageController.doSaveReAssign();

		pageController.selectReassignTo = GlobalConstants.CBS_TL;
		pageController.doSaveReAssign();

		pageController.selectReassignTo = GlobalConstants.CBS_SP;
		pageController.doSaveReAssign();

		pageController.selectReassignTo = GlobalConstants.CBS_SC;
		pageController.doSaveReAssign();

		pageController.selectReassignTo = GlobalConstants.CBS_PM;
		pageController.doSaveReAssign();
    }

    @isTest static void testOtherPublicMethod(){
		Account cbsAccount = Mockup_Test.getFirstAccountFromName(accountName,'Id,Name');
		User cbsRmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameCBRM LIMIT 1];
		Issue_Log__c newIssue;
        System.runAs(cbsRmUser){
			newIssue = new Issue_Log__c(
				Subject__c = 'test', 
				Status__c = GlobalConstants.ON_PROCESS_BY_PM, 
				CIS_ID_or_Prospect_Name__c = cbsAccount.Id,
				Issue_Description__c = 'aaaa'
			);
			insert newIssue;
		}
		CBS_EditIssueLog_Controller pageController = new CBS_EditIssueLog_Controller(new ApexPages.StandardController(newIssue));
		pageController.getRejectedRecordTypeID(GlobalConstants.CBS_OPEN_ISSUE_PARENT_REC);
		pageController.getRejectedRecordTypeID(GlobalConstants.CBS_OPEN_ISSUE_SECOND_REC);

		pageController.save();
		pageController.cancelEdit();
		//pageController.rejectIssue();
		pageController.setEditableIssueModeTrue();
		pageController.doSaveDraftAfterRecall();
		pageController.escalateOwnerAndSave();
		pageController.doSaveAfterRecall();
	}
}