@isTest
private class CBS_EditOwnerIssueLog_Controller_Test
{
	public static String userRMCB_FirstName = 'userCB_FirstName';
	public static String userRMCB_LastName = 'userCB_LastName';
	public static String userRMCB_EmpId = '8800000000';

	public static String accountNameRMCB = 'accountNameRMCB';
	public static String IssueLog1Subject = 'IssueLog1';

	@testSetup static void setupData(){
		Test.startTest();
		List<User> userList = new List<User>();
		Profile rmProfile = [SELECT Id From Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];
			User useRMCB = Mockup_Test.newUser(userRMCB_FirstName,userRMCB_LastName,userRMCB_EmpId,true,rmProfile.id,null,null);
				useRMCB.Segment__c = GlobalConstants.SEGMENT_CB;
				userList.add(useRMCB);
			insert userList;

			Issue_Master__c issueMaster = new Issue_Master__c(Available_Closed_Status__c = 'Done;Closed',Division__c='CBS', Product__c ='Customer Transfer',Category__c='อื่นๆ',Required_Product__c = false,Require_Category__c=false, Require_Sub_Category__c=false,Assigned_To__c ='SC');
			insert issueMaster;
		Test.stopTest();

		String recoedTypeIdAccountCustomer = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER);
		System.runAs(useRMCB){
			Account accountOwnerRMCB = Mockup_Test.newAccountWithSegment(accountNameRMCB,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,recoedTypeIdAccountCustomer,GlobalConstants.PRIMARY_SEGMENT_CODE_CB);
			insert accountOwnerRMCB;
			
			Issue_Log__c issueLog1 = new Issue_Log__c(CIS_ID_or_Prospect_Name__c = accountOwnerRMCB.id,Subject__c = IssueLog1Subject);
			insert issueLog1;
		}

	}


	@isTest
	static void testgetCoverage()
	{
		Issue_Log__c issueLog1 = [SELECT Id,Name From Issue_Log__c WHERE Subject__c = :IssueLog1Subject LIMIT 1];
		CBS_EditOwnerIssueLog_Controller editOwnerIssueLog = new CBS_EditOwnerIssueLog_Controller(new ApexPages.StandardController(issueLog1));
		editOwnerIssueLog.getDivisionList();
		editOwnerIssueLog.getProductList();
		editOwnerIssueLog.getCategoryList();
		editOwnerIssueLog.getSubCategoryList();
		editOwnerIssueLog.getStatusList();
		editOwnerIssueLog.renderStatusHelpText();
		editOwnerIssueLog.renderDivisionHelpText();
		editOwnerIssueLog.validateSelectDivision();
		editOwnerIssueLog.validateSelectProduct();
		editOwnerIssueLog.validateSelectCategory();
		editOwnerIssueLog.validataSelectSubCategory();

	}

	@isTest
	static void testsaveDraftANDsaveSubmit(){
		Issue_Log__c issueLog1 = [SELECT Id,Name From Issue_Log__c WHERE Subject__c = :IssueLog1Subject LIMIT 1];
		CBS_EditOwnerIssueLog_Controller editOwnerIssueLog = new CBS_EditOwnerIssueLog_Controller(new ApexPages.StandardController(issueLog1));

		editOwnerIssueLog.selectDivision = 'CBS';
		editOwnerIssueLog.saveDraft();

		editOwnerIssueLog.selectDivision = 'CBS';
		editOwnerIssueLog.selectProduct = 'Customer Transfer';
		editOwnerIssueLog.saveDraft();

		editOwnerIssueLog.selectDivision = 'CBS';
		editOwnerIssueLog.selectProduct = 'Customer Transfer';
		editOwnerIssueLog.selectCategory = 'อื่นๆ';
		editOwnerIssueLog.selectSubCategory = '';
		editOwnerIssueLog.saveDraft();

		editOwnerIssueLog.selectDivision = 'CBS';
		editOwnerIssueLog.selectProduct = 'Customer Transfer';
		editOwnerIssueLog.selectCategory = 'อื่นๆ';
		editOwnerIssueLog.selectStatus = GlobalConstants.STATUS_DONE;
		editOwnerIssueLog.saveDraft();

		// save submit
		editOwnerIssueLog.saveSubmit();

		editOwnerIssueLog.selectStatus = GlobalConstants.STATUS_NEW;
		editOwnerIssueLog.saveSubmit();

	}

	@isTest
	static void testRenderDivisionHelpText(){
		Issue_Log__c issueLog1 = [SELECT Id,Name From Issue_Log__c WHERE Subject__c = :IssueLog1Subject LIMIT 1];
		CBS_EditOwnerIssueLog_Controller editOwnerIssueLog = new CBS_EditOwnerIssueLog_Controller(new ApexPages.StandardController(issueLog1));
		editOwnerIssueLog.selectDivision = 'None';
		editOwnerIssueLog.renderDivisionHelpText();
		editOwnerIssueLog.selectDivision = 'CBS';
		editOwnerIssueLog.renderDivisionHelpText();
		editOwnerIssueLog.selectDivision = 'CMB';
		editOwnerIssueLog.renderDivisionHelpText();
		editOwnerIssueLog.selectDivision = 'CSF';
		editOwnerIssueLog.renderDivisionHelpText();
		editOwnerIssueLog.selectDivision = 'CSP';
		editOwnerIssueLog.renderDivisionHelpText();
		editOwnerIssueLog.selectDivision = 'ERM';
		editOwnerIssueLog.renderDivisionHelpText();
		editOwnerIssueLog.selectDivision = 'FCL';
		editOwnerIssueLog.renderDivisionHelpText();
		editOwnerIssueLog.selectDivision = 'IBB';
		editOwnerIssueLog.renderDivisionHelpText();
		editOwnerIssueLog.selectDivision = 'RBS';
		editOwnerIssueLog.renderDivisionHelpText();
		editOwnerIssueLog.selectDivision = 'WBS';
		editOwnerIssueLog.renderDivisionHelpText();
		editOwnerIssueLog.selectDivision = 'else';
		editOwnerIssueLog.renderDivisionHelpText();
	}
}