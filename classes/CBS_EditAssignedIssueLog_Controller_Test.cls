@isTest
private class CBS_EditAssignedIssueLog_Controller_Test
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

			Issue_Master__c issueMaster = new Issue_Master__c(Available_Closed_Status__c = 'Done;Closed',Division__c='CBS', Product__c ='Customer Transfer',Category__c='อื่นๆ',Required_Product__c = false,Require_Category__c=false, Require_Sub_Category__c=false,Assigned_To__c ='SC;PM;SP;TL;FSVP');
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
		CBS_EditAssignedIssueLog_Controller editOwnerIssueLog = new CBS_EditAssignedIssueLog_Controller(new ApexPages.StandardController(issueLog1));
		editOwnerIssueLog.getReAssignToList();
		editOwnerIssueLog.getDivisionList();
		editOwnerIssueLog.getProductList();
		editOwnerIssueLog.escalateOwnerAndSave();
		editOwnerIssueLog.getCategoryList();
		editOwnerIssueLog.getSubCategoryList();

	}

	@isTest
	static void testdoSaveReAssignAndRejectIssue(){
		Issue_Log__c issueLog1 = [SELECT Id,Name From Issue_Log__c WHERE Subject__c = :IssueLog1Subject LIMIT 1];
		CBS_EditAssignedIssueLog_Controller editOwnerIssueLog = new CBS_EditAssignedIssueLog_Controller(new ApexPages.StandardController(issueLog1));
		
		editOwnerIssueLog.selectReassignTo = GlobalConstants.CBS_FSVP;
		editOwnerIssueLog.doSaveReAssign();
		editOwnerIssueLog.selectReassignTo = GlobalConstants.CBS_TL;
		editOwnerIssueLog.doSaveReAssign();
		editOwnerIssueLog.selectReassignTo = GlobalConstants.CBS_SP;
		editOwnerIssueLog.doSaveReAssign();
		editOwnerIssueLog.selectReassignTo = GlobalConstants.CBS_SC;
		editOwnerIssueLog.doSaveReAssign();
		editOwnerIssueLog.selectReassignTo = GlobalConstants.CBS_PM;
		editOwnerIssueLog.doSaveReAssign();

		editOwnerIssueLog.rejectIssue();
	}

	@isTest
	static void testSave(){
		Issue_Log__c issueLog1 = [SELECT Id,Name From Issue_Log__c WHERE Subject__c = :IssueLog1Subject LIMIT 1];
		CBS_EditAssignedIssueLog_Controller editOwnerIssueLog = new CBS_EditAssignedIssueLog_Controller(new ApexPages.StandardController(issueLog1));
		
		editOwnerIssueLog.renderForAdmin = true;
		editOwnerIssueLog.selectDivision = 'CBS';
		editOwnerIssueLog.selectProduct = 'Customer Transfer';
		editOwnerIssueLog.selectCategory = 'อื่นๆ';
		editOwnerIssueLog.save();

	}

	@isTest
	static void testValidateSelectDivisionAndValidateSelectProduct(){
		Issue_Log__c issueLog1 = [SELECT Id,Name From Issue_Log__c WHERE Subject__c = :IssueLog1Subject LIMIT 1];
		CBS_EditAssignedIssueLog_Controller editOwnerIssueLog = new CBS_EditAssignedIssueLog_Controller(new ApexPages.StandardController(issueLog1));
			editOwnerIssueLog.selectProduct = 'None';
			editOwnerIssueLog.validateSelectProduct();
			editOwnerIssueLog.selectProduct = 'Customer Transfer';
			editOwnerIssueLog.validateSelectProduct();

			editOwnerIssueLog.validateSelectDivision();

	}

	@isTest
	static void testgetReAssignNameList(){
		Issue_Log__c issueLog1 = [SELECT Id,Name From Issue_Log__c WHERE Subject__c = :IssueLog1Subject LIMIT 1];
		CBS_EditAssignedIssueLog_Controller editOwnerIssueLog = new CBS_EditAssignedIssueLog_Controller(new ApexPages.StandardController(issueLog1));
		editOwnerIssueLog.selectReassignTo = null;
		editOwnerIssueLog.getReAssignNameList();
		editOwnerIssueLog.selectReassignTo = GlobalConstants.CBS_TL;
		editOwnerIssueLog.getReAssignNameList();
		editOwnerIssueLog.selectReassignTo = GlobalConstants.CBS_FSVP;
		editOwnerIssueLog.getReAssignNameList();
		editOwnerIssueLog.selectReassignTo = GlobalConstants.CBS_SC;
		editOwnerIssueLog.getReAssignNameList();
		editOwnerIssueLog.selectReassignTo = GlobalConstants.CBS_SP;
		editOwnerIssueLog.getReAssignNameList();
		editOwnerIssueLog.selectReassignTo = GlobalConstants.CBS_PM;
		editOwnerIssueLog.getReAssignNameList();
	}

	@isTest
	static void testValidataSelectSubCategoryAndValidateSelectCategory(){
		Issue_Log__c issueLog1 = [SELECT Id,Name From Issue_Log__c WHERE Subject__c = :IssueLog1Subject LIMIT 1];
		CBS_EditAssignedIssueLog_Controller editOwnerIssueLog = new CBS_EditAssignedIssueLog_Controller(new ApexPages.StandardController(issueLog1));
		editOwnerIssueLog.validataSelectSubCategory();
		editOwnerIssueLog.validateSelectCategory();
	}



}