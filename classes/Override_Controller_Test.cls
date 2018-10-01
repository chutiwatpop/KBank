@isTest
private class Override_Controller_Test {

    public static String accountNameRM = 'rmCreatedAccountName';
	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }

	}

	@isTest static void testCustomerOverride() {
		Customer_OverrideListView_Controller controller = new Customer_OverrideListView_Controller();
		controller.redirectToListView();
	}
	
	@isTest static void testContactOverride() {

		Account targetAccount = [SELECT Id FROM Account WHERE Name = :Override_Controller_Test.accountNameRM LIMIT 1];
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Call_Report__c callreportObj = new Call_Report__c(
				CIS_ID__c = targetAccount.Id,
				Status__c = GlobalConstants.PLAN,
				Plan_Date__c = System.Today()
			);
			insert callreportObj;

			ApexPages.StandardController stdController = new ApexPages.StandardController(callreportObj);
	        ApexPages.currentPage().getParameters().put('id',callreportObj.Id);
			Contact_Override_Controller controller = new Contact_Override_Controller(stdController);
		}
		
	}

}