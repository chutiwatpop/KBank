@isTest
private class CBS_Site_IssueLog_Controller_Test {
	@isTest static void test_constructor() {
		CBS_Site_IssueLog_Controller site = new CBS_Site_IssueLog_Controller();
	}
	@isTest static void test_getIssueLog() {
		PageReference pageRef = Page.CBS_Site_IssueLog_Page;
		Test.setCurrentPage(pageRef);

		CBS_Site_IssueLog_Controller site = new CBS_Site_IssueLog_Controller();
		Issue_Master__c issueMaster = new Issue_Master__c();

		issueMaster.Division__c = 'CBS';
		issueMaster.Product__c = 'Customer Transfer';
		issueMaster.Category__c = 'อื่นๆ';
		issueMaster.Sub_Category__c = '';
		issueMaster.Available_Closed_Status__c = 'Done; Closed';
		insert issueMaster;
		Issue_Log__c issueLog = new Issue_Log__c();
		issueLog.Issue_Master__c = issueMaster.Id;
		insert issueLog;
		site.refId = issueLog.Id;
		
		site.getIssue();
	}
	@isTest static void test_statusHelpText(){
		PageReference pageRef = Page.CBS_Site_IssueLog_Page;
		Test.setCurrentPage(pageRef);

		CBS_Site_IssueLog_Controller site = new CBS_Site_IssueLog_Controller();

		site.issue.Status__c = GlobalConstants.CBS_ISSUELOG_DONE;
		site.CheckStatusReject();
		site.issue.Status__c = GlobalConstants.CBS_ISSUELOG_CLOSE;
		site.CheckStatusReject();
		site.issue.Status__c = GlobalConstants.CBS_ISSUELOG_REJECT;
		site.CheckStatusReject();
	}
	@isTest static void test_submit(){
		PageReference pageRef = Page.CBS_Site_IssueLog_Page;
		Test.setCurrentPage(pageRef);

		CBS_Site_IssueLog_Controller site = new CBS_Site_IssueLog_Controller();

		site.Submit();
	}
}