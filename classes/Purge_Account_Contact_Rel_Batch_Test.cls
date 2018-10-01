@isTest
private class Purge_Account_Contact_Rel_Batch_Test {
	
	@testSetup static void setupMockData() {
		final String RECORD_TYPE_CONTACT_ROLE = 'ContactRole';
        // Mock account Object
        List<Account> listAccoount = new List<Account>();
        Account customerA = new Account();
		customerA.CIS__c = 'x1';
		customerA.Encrypt_Name_TH__c = 'customerA';
		customerA.LastName = 'customerA';
		customerA.Temporary_Customer__c  = true;
		customerA.RecordTypeId =  GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME);
		Account customerB = new Account();
		customerB.CIS__c = 'x2';
		customerB.Encrypt_Name_TH__c = 'customerB';
		customerB.LastName = 'customerB';
		customerB.Temporary_Customer__c  = true;
		customerB.RecordTypeId =  GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME);
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
		listAccoount.add(customerA);
		listAccoount.add(customerB);
		listAccoount.add(customerC);
		listAccoount.add(companyC);
		insert listAccoount;

		Map<Id,Account> mapAccWithContact = new Map<Id,Account>([SELECT Id,PersonContactId FROM Account WHERE Id IN :listAccoount]);
		List<AccountContactRelation> listAccConRel = new List<AccountContactRelation>();

		AccountContactRelation accountContactRelation1 = new AccountContactRelation();
		accountContactRelation1.AccountId = companyC.Id;
		accountContactRelation1.ContactId = mapAccWithContact.get(customerA.Id).PersonContactId;
		accountContactRelation1.Roles = 'roleName';
		accountContactRelation1.IsActive = true;
		accountContactRelation1.FinServ__IncludeInGroup__c = false;
		accountContactRelation1.FinServ__PrimaryGroup__c = false;
		accountContactRelation1.FinServ__Primary__c = false;
		accountContactRelation1.FinServ__Rollups__c = 'All';
		accountContactRelation1.Is_Createby_Integration__c = true;
		listAccConRel.add(accountContactRelation1);

		AccountContactRelation accountContactRelation2 = new AccountContactRelation();
		accountContactRelation2.AccountId = companyC.Id;
		accountContactRelation2.ContactId = mapAccWithContact.get(customerB.Id).PersonContactId;
		accountContactRelation2.Roles = 'roleName';
		accountContactRelation2.IsActive = true;
		accountContactRelation2.FinServ__IncludeInGroup__c = false;
		accountContactRelation2.FinServ__PrimaryGroup__c = false;
		accountContactRelation2.FinServ__Primary__c = false;
		accountContactRelation2.FinServ__Rollups__c = 'All';
		accountContactRelation2.Is_Createby_Integration__c = true;
		listAccConRel.add(accountContactRelation2);

		AccountContactRelation accountContactRelation3 = new AccountContactRelation();
		accountContactRelation3.AccountId = companyC.Id;
		accountContactRelation3.ContactId = mapAccWithContact.get(customerC.Id).PersonContactId;
		accountContactRelation3.Roles = 'roleName';
		accountContactRelation3.IsActive = true;
		accountContactRelation3.FinServ__IncludeInGroup__c = false;
		accountContactRelation3.FinServ__PrimaryGroup__c = false;
		accountContactRelation3.FinServ__Primary__c = false;
		accountContactRelation3.FinServ__Rollups__c = 'All';
		accountContactRelation3.Is_Createby_Integration__c = false;
		listAccConRel.add(accountContactRelation3);
		insert listAccConRel;
    }

	@isTest static void purgeAccountContactRelOneTime_PurgeAllData() {
		System.assertEquals(3,[SELECT Count() FROM AccountContactRelation]);
		Test.startTest();
            Database.executeBatch(new Purge_Account_Contact_Rel_Batch(true));
        Test.stopTest();
        System.assertEquals(0,[SELECT Count() FROM AccountContactRelation]);
	}
	
	@isTest static void purgeAccountContactRelOnGoing_OnlyIsCreatebyIntegrationEqualTrue() {
		System.assertEquals(3,[SELECT Count() FROM AccountContactRelation]);
		Test.startTest();
            Database.executeBatch(new Purge_Account_Contact_Rel_Batch());
        Test.stopTest();
        System.assertEquals(1,[SELECT Count() FROM AccountContactRelation]);
	}
	
}