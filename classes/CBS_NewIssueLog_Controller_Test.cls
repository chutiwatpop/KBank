@isTest
private class CBS_NewIssueLog_Controller_Test {
	
	@isTest static void test_constructor() {
		User rmUser = new User();
		rmUser = createRMUser();
		System.runAs(rmUser){
			//initiateTestObject();			
			Issue_Master__c issueMaster = new Issue_Master__c();
			issueMaster.Division__c = 'CBS';
			issueMaster.Product__c = 'Customer Transfer';
			issueMaster.Category__c = 'อื่นๆ';
			issueMaster.Sub_Category__c = 'อื่นๆ';
			issueMaster.Available_Closed_Status__c = 'Done; Closed';
			insert issueMaster;
			Issue_Log__c parentIssueLog = new Issue_Log__c();
			parentIssueLog.Issue_Master__c = issueMaster.Id;
			insert parentIssueLog;
			Issue_Log__c issueLog = new Issue_Log__c();
			issueLog.Issue_Master__c = issueMaster.Id;
			insert issueLog;			

			Account testAcc = new Account();
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

			ApexPages.StandardController sc = new ApexPages.StandardController(issueLog);

			PageReference pageRef = Page.Opportunity_Custom_page; 
			pageRef.getParameters().put('accountId', String.valueOf(testAcc.Id));
			pageRef.getParameters().put('parentId', String.valueOf(parentIssueLog.Id));
	        Test.setCurrentPage(pageRef);

	        CBS_NewIssueLog_Controller controller = new CBS_NewIssueLog_Controller(sc);
		}
	}
	@isTest static void test_relatedList() {
		User rmUser = new User();
		rmUser = createRMUser();
		System.runAs(rmUser){
			//initiateTestObject();			
			Issue_Master__c issueMaster = new Issue_Master__c();
			issueMaster.Division__c = 'CBS';
			issueMaster.Product__c = 'Customer Transfer';
			issueMaster.Category__c = 'อื่นๆ';
			issueMaster.Sub_Category__c = 'อื่นๆ';
			issueMaster.Available_Closed_Status__c = 'Done; Closed';
			insert issueMaster;
			Issue_Log__c parentIssueLog = new Issue_Log__c();
			parentIssueLog.Issue_Master__c = issueMaster.Id;
			insert parentIssueLog;
			Issue_Log__c issueLog = new Issue_Log__c();
			issueLog.Issue_Master__c = issueMaster.Id;
			insert issueLog;			

			Account testAcc = new Account();
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

			ApexPages.StandardController sc = new ApexPages.StandardController(issueLog);

			PageReference pageRef = Page.Opportunity_Custom_page; 
			pageRef.getParameters().put('accountId', String.valueOf(testAcc.Id));
			pageRef.getParameters().put('parentId', String.valueOf(parentIssueLog.Id));
	        Test.setCurrentPage(pageRef);

	        CBS_NewIssueLog_Controller controller = new CBS_NewIssueLog_Controller(sc);
	        List<SelectOption>  statusList = controller.getStatusList();
	        List<SelectOption>  divisionList = controller.getDivisionList();	        
	        controller.selectDivision = 'CBS';
	        List<SelectOption>  productList = controller.getProductList();
			controller.selectProduct = 'Customer Transfer';
			List<SelectOption>  categoryList = controller.getCategoryList();
			controller.selectCategory = 'อื่นๆ';
			List<SelectOption>  subCategoryList = controller.getSubCategoryList();
			controller.selectSubCategory = 'อื่นๆ';
		}
	}
	@isTest static void test_helpText() {
		User rmUser = new User();
		rmUser = createRMUser();
		System.runAs(rmUser){
			//initiateTestObject();			
			Issue_Master__c issueMaster = new Issue_Master__c();
			issueMaster.Division__c = 'CBS';
			issueMaster.Product__c = 'Customer Transfer';
			issueMaster.Category__c = 'อื่นๆ';
			issueMaster.Sub_Category__c = 'อื่นๆ';
			issueMaster.Available_Closed_Status__c = 'Done; Closed';
			insert issueMaster;
			Issue_Log__c parentIssueLog = new Issue_Log__c();
			parentIssueLog.Issue_Master__c = issueMaster.Id;
			insert parentIssueLog;
			Issue_Log__c issueLog = new Issue_Log__c();
			issueLog.Issue_Master__c = issueMaster.Id;
			insert issueLog;			

			Account testAcc = new Account();
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

			ApexPages.StandardController sc = new ApexPages.StandardController(issueLog);

			PageReference pageRef = Page.Opportunity_Custom_page; 
			pageRef.getParameters().put('accountId', String.valueOf(testAcc.Id));
			pageRef.getParameters().put('parentId', String.valueOf(parentIssueLog.Id));
	        Test.setCurrentPage(pageRef);

	        CBS_NewIssueLog_Controller controller = new CBS_NewIssueLog_Controller(sc);

	        controller.selectStatus = GlobalConstants.STATUS_NEW;
	        controller.checkCloseDate();
	        controller.selectStatus = GlobalConstants.CBS_ISSUELOG_DONE;
	        controller.checkCloseDate();
	        controller.selectStatus = GlobalConstants.CBS_ISSUELOG_CLOSE;
	        controller.checkCloseDate();

	        controller.selectDivision = 'CBS';
	        controller.renderDivisionHelpText();
	        controller.selectDivision = 'CMB';
	        controller.renderDivisionHelpText();
	        controller.selectDivision = 'CSF';
	        controller.renderDivisionHelpText();
	        controller.selectDivision = 'CSP';
	        controller.renderDivisionHelpText();
	        controller.selectDivision = 'ERM';
	        controller.renderDivisionHelpText();
	        controller.selectDivision = 'FCL';
	        controller.renderDivisionHelpText();
	        controller.selectDivision = 'IBB';
	        controller.renderDivisionHelpText();
	        controller.selectDivision = 'RBS';
	        controller.renderDivisionHelpText();
	        controller.selectDivision = 'WBS';
	        controller.renderDivisionHelpText();
		}
	}
	@isTest static void test_save() {
		User rmUser = new User();
		rmUser = createRMUser();
		System.runAs(rmUser){
			//initiateTestObject();			
			Issue_Master__c issueMaster = new Issue_Master__c();
			issueMaster.Division__c = 'CBS';
			issueMaster.Product__c = 'Customer Transfer';
			issueMaster.Category__c = 'อื่นๆ';
			issueMaster.Sub_Category__c = 'อื่นๆ';
			issueMaster.Available_Closed_Status__c = 'Done; Closed';
			insert issueMaster;
			Issue_Log__c parentIssueLog = new Issue_Log__c();
			parentIssueLog.Issue_Master__c = issueMaster.Id;
			insert parentIssueLog;
			Issue_Log__c issueLog = new Issue_Log__c();
			issueLog.Issue_Master__c = issueMaster.Id;
			insert issueLog;			

			Account testAcc = new Account();
			testAcc.Name = 'Testname';
			testAcc.CIS__c = '12345';
			testAcc.Is_createby_Integration__c = true;
			insert testAcc;

			ApexPages.StandardController sc = new ApexPages.StandardController(issueLog);

			PageReference pageRef = Page.Opportunity_Custom_page; 
			pageRef.getParameters().put('accountId', String.valueOf(testAcc.Id));
			pageRef.getParameters().put('parentId', String.valueOf(parentIssueLog.Id));
	        Test.setCurrentPage(pageRef);

	        CBS_NewIssueLog_Controller controller = new CBS_NewIssueLog_Controller(sc);

	        controller.selectStatus = GlobalConstants.STATUS_DONE;
	        controller.selectDivision = 'CBS';
			controller.selectProduct = 'Customer Transfer';
			controller.selectCategory = 'อื่นๆ';
			controller.selectSubCategory = 'อื่นๆ';
	        controller.save();
		}
	}
	public static User createRMUser(){
		String rmProfile = GlobalConstants.CBS_RM;
		Profile p = [SELECT Id FROM Profile WHERE Name=:rmProfile]; 
		User u = new User(Alias = 'reUser', Email='rmUser@kasikornbank.com', 
		EmailEncodingKey='UTF-8', LastName='rm1', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='Asia/Bangkok', UserName='rmUser@kasikornbank.com',Employee_Id__c='1231231231');
		return u; 
	}
	
}