@isTest
private class Account_Service_Test {
	public static final String accountname = 'Account1';
	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account account1 = new Account(
            Name = Account_Service_Test.accountname,
            Port_Pool__c = GlobalConstants.PORT,
            RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
            Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT,
            OwnerId = userRM.Id,
            Primary_Segment_Code__c = 'SM',
            Customer_Segment_Code__c = 'SM',
            OwnerChangeExecutedByTrigger__c = true,
            Is_createby_Integration__c = true
        );
		insert account1;
	}

	@isTest static void testGetAccountByID() {
		Test.startTest();
		Account finalAccount = Mockup_Test.getFirstAccountFromName(Account_Service_Test.accountname, 'Id');
		List<Account> accountlist = Account_Service.getAccountByID(finalAccount.id);
		System.assertEquals(1,accountlist.size());
		Test.stopTest();
	}

	@isTest static void testGetAccountInformation() {
		Test.startTest();
		Account finalAccount = Mockup_Test.getFirstAccountFromName(Account_Service_Test.accountname, 'Id,Name');
		Account accountobj = Account_Service.getAccountInformation(finalAccount.id);
		System.assertEquals(GlobalConstants.ORGANIZATION_CUSTOMER,accountobj.RecordType.Name);
		Test.stopTest();
	}
}