@isTest
private class Purge_Contact_Contact_Rel_Batch_Test {
	
	@testSetup static void setupMockData() {
		final String RECORD_TYPE_CONTACT_ROLE = 'ContactRole';
        // Mock account Object
        List<Account> listAccoount = new List<Account>();
        Account companyA = new Account();
		companyA.CIS__c = 'x1';
		companyA.Encrypt_Name_TH__c = 'CompanyA';
		companyA.LastName = 'CompanyA';
		companyA.Temporary_Customer__c  = true;
		companyA.RecordTypeId =  GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME);
		Account companyB = new Account();
		companyB.CIS__c = 'x2';
		companyB.Encrypt_Name_TH__c = 'CompanyB';
		companyB.LastName = 'CompanyB';
		companyB.Temporary_Customer__c  = true;
		companyB.RecordTypeId =  GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME);
		Account companyC = new Account();
		companyC.CIS__c = 'x3';
		companyC.Encrypt_Name_TH__c = 'CompanyC';
		companyC.LastName = 'CompanyC';
		companyC.Temporary_Customer__c  = true;
		companyC.RecordTypeId =  GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME);
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
		reciprocalRole.FinServ__RelationshipType__c = 'Contact Contact Relation';
		reciprocalRole.RecordtypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('FinServ__ReciprocalRole__c').get(RECORD_TYPE_CONTACT_ROLE);
		reciprocalRole.FinServ__CreateInverseRole__c = false;
		listRole.add(reciprocalRole);

		FinServ__ReciprocalRole__c reciprocalRoleInverse = new FinServ__ReciprocalRole__c();
		reciprocalRoleInverse.Name = 'ถูกถือหุ้นโดย';
		reciprocalRoleInverse.Role_Code__c = 'B05';
		reciprocalRoleInverse.FinServ__InverseRole__c = 'เป็นผู้ถือหุ้น';
		reciprocalRoleInverse.Inverse_Role_Code__c = '205';
		reciprocalRoleInverse.Role_External_ID__c = 'B05_205_A';
		reciprocalRoleInverse.FinServ__RelationshipType__c = 'Contact Contact Relation';
		reciprocalRoleInverse.RecordtypeId = GlobalUtility.getRecordTypeMapByDevNameFromSObject('FinServ__ReciprocalRole__c').get(RECORD_TYPE_CONTACT_ROLE);
		reciprocalRoleInverse.FinServ__CreateInverseRole__c = false;
		listRole.add(reciprocalRoleInverse);
		insert listRole;
		listRole.clear();
		reciprocalRole.FinServ__InverseRelationship__c = reciprocalRoleInverse.Id;
		reciprocalRoleInverse.FinServ__InverseRelationship__c = reciprocalRole.Id;
		listRole.add(reciprocalRole);
		listRole.add(reciprocalRoleInverse);
		update listRole;

		Map<Id,Account> mapAccWithContact = new Map<Id,Account>([SELECT Id,PersonContactId FROM Account WHERE Id IN :listAccoount]);
		List<FinServ__ContactContactRelation__c> listConConRel = new List<FinServ__ContactContactRelation__c>();
		FinServ__ContactContactRelation__c contactContactRelation1 = new FinServ__ContactContactRelation__c();
		contactContactRelation1.FinServ__Role__c = reciprocalRole.Id;
		contactContactRelation1.FinServ__Contact__c = mapAccWithContact.get(companyA.Id).PersonContactId;
		contactContactRelation1.FinServ__RelatedContact__c = mapAccWithContact.get(companyB.Id).PersonContactId;
		contactContactRelation1.Is_Createby_Integration__c = true;
		listConConRel.add(contactContactRelation1);

		FinServ__ContactContactRelation__c contactContactRelation2 = new FinServ__ContactContactRelation__c();
		contactContactRelation2.FinServ__Role__c = reciprocalRole.Id;
		contactContactRelation2.FinServ__Contact__c = mapAccWithContact.get(companyA.Id).PersonContactId;
		contactContactRelation2.FinServ__RelatedContact__c = mapAccWithContact.get(companyC.Id).PersonContactId;
		contactContactRelation2.Is_Createby_Integration__c = true;
		listConConRel.add(contactContactRelation2);

		FinServ__ContactContactRelation__c contactContactRelation3 = new FinServ__ContactContactRelation__c();
		contactContactRelation3.FinServ__Role__c = reciprocalRole.Id;
		contactContactRelation3.FinServ__Contact__c = mapAccWithContact.get(companyB.Id).PersonContactId;
		contactContactRelation3.FinServ__RelatedContact__c = mapAccWithContact.get(companyC.Id).PersonContactId;
		contactContactRelation3.Is_Createby_Integration__c = false;
		listConConRel.add(contactContactRelation3);
		insert new User_Management__c(Allow_Edit_Customer_Relationship__c=true);
		insert listConConRel;
    }

	@isTest static void purgeContactContactRelOneTime_PurgeAllData() {
		System.assertEquals(6,[SELECT Count() FROM FinServ__ContactContactRelation__c]);
		Test.startTest();
            Database.executeBatch(new Purge_Contact_Contact_Rel_Batch(true));
        Test.stopTest();
        System.assertEquals(0,[SELECT Count() FROM FinServ__ContactContactRelation__c]);
	}
	
	@isTest static void purgeContactContactRelOnGoing_OnlyIsCreatebyIntegrationEqualTrue() {
		System.assertEquals(6,[SELECT Count() FROM FinServ__ContactContactRelation__c]);
		Test.startTest();
            Database.executeBatch(new Purge_Contact_Contact_Rel_Batch());
        Test.stopTest();
        System.assertEquals(2,[SELECT Count() FROM FinServ__ContactContactRelation__c]);
	}
	
}