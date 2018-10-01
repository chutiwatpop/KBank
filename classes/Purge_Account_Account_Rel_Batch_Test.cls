@isTest
private class Purge_Account_Account_Rel_Batch_Test {
	
	@testSetup static void setupMockData() {
        // Mock account Object
        List<Account> listAccoount = new List<Account>();
        Account companyA = new Account();
		companyA.CIS__c = 'x1';
		companyA.Encrypt_Name_TH__c = 'CompanyA';
		companyA.Name = 'CompanyA';
		companyA.Temporary_Customer__c  = true;
		companyA.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER);
		Account companyB = new Account();
		companyB.CIS__c = 'x2';
		companyB.Encrypt_Name_TH__c = 'CompanyB';
		companyB.Name = 'CompanyB';
		companyB.Temporary_Customer__c  = true;
		companyB.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER);
		Account companyC = new Account();
		companyC.CIS__c = 'x3';
		companyC.Encrypt_Name_TH__c = 'CompanyC';
		companyC.Name = 'CompanyC';
		companyC.Temporary_Customer__c  = true;
		companyC.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER);
		listAccoount.add(companyA);
		listAccoount.add(companyB);
		listAccoount.add(companyC);
		insert listAccoount;
		// Mock reciprocal role
		List<FinServ__ReciprocalRole__c> listRole = new List<FinServ__ReciprocalRole__c>();
		FinServ__ReciprocalRole__c reciprocalRole = new FinServ__ReciprocalRole__c();
		reciprocalRole.Name = 'เป็นผู้ถือหุ้น';
		reciprocalRole.Role_Code__c = '205';
		reciprocalRole.FinServ__InverseRole__c = 'ถูกถือหุ้นโดย';
		reciprocalRole.Inverse_Role_Code__c = 'B05';
		reciprocalRole.Role_External_ID__c = '205_B05_A';
		reciprocalRole.FinServ__RelationshipType__c = 'Account Account Relation';
		reciprocalRole.FinServ__CreateInverseRole__c = false;
		listRole.add(reciprocalRole);

		FinServ__ReciprocalRole__c reciprocalRoleInverse = new FinServ__ReciprocalRole__c();
		reciprocalRoleInverse.Name = 'ถูกถือหุ้นโดย';
		reciprocalRoleInverse.Role_Code__c = 'B05';
		reciprocalRoleInverse.FinServ__InverseRole__c = 'เป็นผู้ถือหุ้น';
		reciprocalRoleInverse.Inverse_Role_Code__c = '205';
		reciprocalRoleInverse.Role_External_ID__c = 'B05_205_A';
		reciprocalRoleInverse.FinServ__RelationshipType__c = 'Account Account Relation';
		reciprocalRoleInverse.FinServ__CreateInverseRole__c = false;
		listRole.add(reciprocalRoleInverse);
		insert listRole;
		listRole.clear();
		reciprocalRole.FinServ__InverseRelationship__c = reciprocalRoleInverse.Id;
		reciprocalRoleInverse.FinServ__InverseRelationship__c = reciprocalRole.Id;
		listRole.add(reciprocalRole);
		listRole.add(reciprocalRoleInverse);
		update listRole;

		List<FinServ__AccountAccountRelation__c> listAccAccRel = new List<FinServ__AccountAccountRelation__c>();
		FinServ__AccountAccountRelation__c accountAccountRelation1 = new FinServ__AccountAccountRelation__c();
		accountAccountRelation1.FinServ__Role__c = reciprocalRole.Id;
		accountAccountRelation1.FinServ__Account__c = companyA.Id;
		accountAccountRelation1.FinServ__RelatedAccount__c = companyB.Id;
		accountAccountRelation1.Is_Createby_Integration__c = true;
		listAccAccRel.add(accountAccountRelation1);

		FinServ__AccountAccountRelation__c accountAccountRelation2 = new FinServ__AccountAccountRelation__c();
		accountAccountRelation2.FinServ__Role__c = reciprocalRole.Id;
		accountAccountRelation2.FinServ__Account__c = companyA.Id;
		accountAccountRelation2.FinServ__RelatedAccount__c = companyC.Id;
		accountAccountRelation2.Is_Createby_Integration__c = true;
		listAccAccRel.add(accountAccountRelation2);

		FinServ__AccountAccountRelation__c accountAccountRelation3 = new FinServ__AccountAccountRelation__c();
		accountAccountRelation3.FinServ__Role__c = reciprocalRole.Id;
		accountAccountRelation3.FinServ__Account__c = companyB.Id;
		accountAccountRelation3.FinServ__RelatedAccount__c = companyC.Id;
		accountAccountRelation3.Is_Createby_Integration__c = false;
		listAccAccRel.add(accountAccountRelation3);
		insert new User_Management__c(Allow_Edit_Customer_Relationship__c=true);
		insert listAccAccRel;
    }

	@isTest static void purgeAccountAccountRelOneTime_PurgeAllData() {
		System.assertEquals(6,[SELECT Count() FROM FinServ__AccountAccountRelation__c]);
		Test.startTest();
            Database.executeBatch(new Purge_Account_Account_Rel_Batch(true));
        Test.stopTest();
        System.assertEquals(0,[SELECT Count() FROM FinServ__AccountAccountRelation__c]);
	}
	
	@isTest static void purgeAccountAccountRelOnGoing_OnlyIsCreatebyIntegrationEqualTrue() {
		System.assertEquals(6,[SELECT Count() FROM FinServ__AccountAccountRelation__c]);
		Test.startTest();
            Database.executeBatch(new Purge_Account_Account_Rel_Batch());
        Test.stopTest();
        System.assertEquals(2,[SELECT Count() FROM FinServ__AccountAccountRelation__c]);
	}
	
}