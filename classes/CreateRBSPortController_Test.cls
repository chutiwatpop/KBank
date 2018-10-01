@isTest
private class CreateRBSPortController_Test {

	public static String accountNameRM = 'rmCreateRBSPort';
	public static String contactFirstName = 'contactFirstName';
	public static String contactLastName = 'contactLastName';
	public static String userRBS = 'RBSUser';

	@testSetup static void setupAccount(){

		Test.startTest();
        Mockup_Test mt;
        System.runAs(new User(Id=UserInfo.getUserId())){
            mt = new Mockup_Test().setUpTestWithExtension();
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccountWithContact(accountNameRM,contactFirstName,contactLastName,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
        }
        Team_Structure__c tsNh = new Team_Structure__c(
                External_ID__c = null,
                RC_Code__c = '41201',
                AH_RC_Code__c = null,
                NH_RC_Code__c = null,
                Name = 'nhTeamName',
                Segment__c = 'teamSegment1',
                Type__c = 'Network',
                Province__c = 'Bangkok'
            );
            insert tsNh;
        Test.stopTest();
	}
	
	@isTest static void test_saveRBSPort_MustHaveRecordInRBSPortSelection() {
		
		Test.startTest();
		List<Account> accounts = [Select Id,Name from Account];
		  Test.setCurrentPage(Page.CreateRBSPortView);
		  ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(accounts);
		  stdSetController.setSelected(accounts);
		  CreateRBSPortController ext = new CreateRBSPortController(stdSetController);
		  ext.saveRBSPort();
		 Test.stopTest();

		 RBS_Port_Selection__c createRBSPorts = [Select Id, Customer__c from RBS_Port_Selection__c limit 1];
		 System.assertEquals(accounts[0].Id, createRBSPorts.Customer__c);
	}

	@isTest static void test_createCustomerRBSPort_MustHaveRecordInRBSPortSelection() {
		
		Test.startTest();
		createRBSUser();
		List<Account> accounts = [Select Id,Name from Account];
		System.runAs([SELECT Id FROM User WHERE Firstname=:userRBS LIMIT 1][0]){
		 	CreateRBSPortController.createCustomerRBSPort(accounts[0].Id);
		}
		Test.stopTest();

		 RBS_Port_Selection__c createRBSPorts = [Select Id, Customer__c from RBS_Port_Selection__c limit 1];
		 System.assertEquals(accounts[0].Id, createRBSPorts.Customer__c);
	}

	@isTest static void test_createCustomerRBSPortByNotRBSUser_MustNotHaveRecordInRBSPortSelection() {
		
		Test.startTest();
		List<Account> accounts = [Select Id,Name from Account];
		CreateRBSPortController.createCustomerRBSPort(accounts[0].Id);
		Test.stopTest();

		 List<RBS_Port_Selection__c> createRBSPorts = [Select Id, Customer__c from RBS_Port_Selection__c];
		 System.assertEquals(0, createRBSPorts.size());
	}

	private static void createRBSUser(){

		Id nhProfileId = [SELECT Id FROM Profile WHERE Name = 'RBS-BM' LIMIT 1].Id;
		User nhUser = Mockup_Test.newUser(
                    userRBS,
                    Mockup_Test.userLastNameNH,
                    true,
                    userRBS+'@mail.com',
                    userRBS+'@mail.com',
                    userRBS.substring(0, 4),
                    nhProfileId,
                    null,
                    null,
                    '1000009007'
            );
            nhUser.RC_Code__c = null;
            nhUser.Job_Code__c = 'ME1A';
            nhUser.Status__c = 'A';
            insert nhUser;
	}
	
	
}