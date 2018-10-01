@isTest
private class Purge_Household_Batch_Test {
	@testSetup static void setupMockData() {
		final String RECORD_TYPE_CONTACT_ROLE = 'ContactRole';
        // Mock account Object
        List<Account> listAccoount = new List<Account>();
        Account householdA = new Account();
		householdA.CIS__c = 'x1';
		householdA.Encrypt_Name_TH__c = 'householdA';
		householdA.Name = 'householdA';
		householdA.Temporary_Customer__c  = true;
		householdA.RecordTypeId =  GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.INDUSTRIESHOUSEHOLD_DEVNAME);
		Account householdB = new Account();
		householdB.CIS__c = 'x2';
		householdB.Encrypt_Name_TH__c = 'householdB';
		householdB.Name = 'householdB';
		householdB.Temporary_Customer__c  = true;
		householdB.RecordTypeId =  GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.INDUSTRIESHOUSEHOLD_DEVNAME);
		Account customerC = new Account();
		customerC.CIS__c = 'x3';
		customerC.Encrypt_Name_TH__c = 'customerC';
		customerC.LastName = 'customerC';
		customerC.Temporary_Customer__c  = true;
		customerC.RecordTypeId =  GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME);
		Account companyC = new Account();
		companyC.CIS__c = 'x4';
		companyC.Encrypt_Name_TH__c = 'CompanyC';
		companyC.Name = 'CompanyC';
		companyC.Temporary_Customer__c  = true;
		companyC.RecordTypeId =  GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME);
		listAccoount.add(householdA);
		listAccoount.add(householdB);
		listAccoount.add(customerC);
		listAccoount.add(companyC);
		insert listAccoount;
    }

	@isTest static void purgeAllHousehold() {
		System.assertEquals(4,[SELECT Count() FROM Account]);
		Test.startTest();
            Database.executeBatch(new Purge_Household_Batch());
        Test.stopTest();
        System.assertEquals(2,[SELECT Count() FROM Account]);
	}
	
}