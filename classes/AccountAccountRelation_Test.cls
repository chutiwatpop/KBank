@isTest
private class AccountAccountRelation_Test
{
	public static final String ORGANIZATION_CUSTOMER = 'Organization Customer';
    
	@testSetup static void setupMockData() {
        Test.startTest();

        // Mock account Object
        Account companyA = new Account();
		companyA.CIS__c = '1';
		companyA.Encrypt_Name_TH__c = 'CompanyA';
		companyA.Name = 'CompanyA';
		companyA.Temporary_Customer__c  = true;
		companyA.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(ORGANIZATION_CUSTOMER);
		Account companyB = new Account();
		companyB.CIS__c = '2';
		companyB.Encrypt_Name_TH__c = 'CompanyB';
		companyB.Name = 'CompanyB';
		companyB.Temporary_Customer__c  = true;
		companyB.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(ORGANIZATION_CUSTOMER);
		Account companyC = new Account();
		companyC.CIS__c = '3';
		companyC.Encrypt_Name_TH__c = 'CompanyC';
		companyC.Name = 'CompanyC';
		companyC.Temporary_Customer__c  = true;
		companyC.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(ORGANIZATION_CUSTOMER);
		insert companyA; 
		insert companyB; 
		insert companyC;

        // Mock SLL
		// A เป็นผู้ถือหุ้น B, B ถูกถือหุ้นโดย A and share 80%
		SLL_Relation__c sllCompanyACompanyB = new SLL_Relation__c();
		sllCompanyACompanyB.Subject_CIS_ID__c = companyA.CIS__c;
		sllCompanyACompanyB.Subject_Relation_Code__c = '205';
		sllCompanyACompanyB.Subject_Type_Code__c = 'O';
		sllCompanyACompanyB.Object_CIS_ID__c = companyB.CIS__c;
		sllCompanyACompanyB.Object_Relation_Code__c = 'B05';
		sllCompanyACompanyB.Object_Type_Code__c = 'O';
		sllCompanyACompanyB.Percent_Share__c = 80;
		sllCompanyACompanyB.SLL_ExternalId__c = companyA.CIS__c + '_' + companyB.CIS__c + '_' + sllCompanyACompanyB.Subject_Relation_Code__c + '_' + sllCompanyACompanyB.Object_Relation_Code__c;
		insert sllCompanyACompanyB;
		SLL_Relation__c sllCompanyACompanyC = new SLL_Relation__c();
		sllCompanyACompanyC.Subject_CIS_ID__c = companyA.CIS__c;
		sllCompanyACompanyC.Subject_Relation_Code__c = '205';
		sllCompanyACompanyC.Subject_Type_Code__c = 'O';
		sllCompanyACompanyC.Object_CIS_ID__c = companyC.CIS__c;
		sllCompanyACompanyC.Object_Relation_Code__c = 'B05';
		sllCompanyACompanyC.Object_Type_Code__c = 'O';
		sllCompanyACompanyC.Percent_Share__c = 65;
		sllCompanyACompanyC.SLL_ExternalId__c = companyA.CIS__c + '_' + companyC.CIS__c + '_' + sllCompanyACompanyC.Subject_Relation_Code__c + '_' + sllCompanyACompanyC.Object_Relation_Code__c;
		insert sllCompanyACompanyC;

		// Mock reciprocal role
		FinServ__ReciprocalRole__c reciprocalRole = new FinServ__ReciprocalRole__c();
		reciprocalRole.Name = 'เป็นผู้ถือหุ้น';
		reciprocalRole.Role_Code__c = '205';
		reciprocalRole.FinServ__InverseRole__c = 'ถูกถือหุ้นโดย';
		reciprocalRole.Inverse_Role_Code__c = 'B05';
		reciprocalRole.Role_External_ID__c = '205_B05_A';
		reciprocalRole.FinServ__RelationshipType__c = 'Account Account Relation';
		reciprocalRole.FinServ__CreateInverseRole__c = false;
		insert reciprocalRole;

		FinServ__ReciprocalRole__c reciprocalRoleInverse = new FinServ__ReciprocalRole__c();
		reciprocalRoleInverse.Name = 'ถูกถือหุ้นโดย';
		reciprocalRoleInverse.Role_Code__c = 'B05';
		reciprocalRoleInverse.FinServ__InverseRole__c = 'เป็นผู้ถือหุ้น';
		reciprocalRoleInverse.Inverse_Role_Code__c = '205';
		reciprocalRoleInverse.Role_External_ID__c = 'B05_205_A';
		reciprocalRoleInverse.FinServ__RelationshipType__c = 'Account Account Relation';
		reciprocalRoleInverse.FinServ__CreateInverseRole__c = false;
		insert reciprocalRoleInverse;

		reciprocalRole.FinServ__InverseRelationship__c = reciprocalRoleInverse.Id;
		reciprocalRoleInverse.FinServ__InverseRelationship__c = reciprocalRole.Id;
		update reciprocalRole;
		update reciprocalRoleInverse;

		insert new User_Management__c(Allow_Edit_Customer_Relationship__c=true);
    }

	@isTest
	static void itShouldCreateAARelationWhenSllHasAA() {
		// Given
		List<SLL_Relation__c> sllRelationList = [SELECT Id, Subject_CIS_ID__c, Object_CIS_ID__c, Subject_Relation_Code__c, Object_Relation_Code__c, Subject_Type_Code__c, Object_Type_Code__c, Percent_Share__c, SLL_ExternalId__c FROM SLL_Relation__c];
		List<String> sllCisId = new List<String>();
		for (SLL_Relation__c sllItem : sllRelationList) {
			sllCisId.add(sllItem.Subject_CIS_ID__c);
			sllCisId.add(sllItem.Object_CIS_ID__c);
		}
		List<Account> sllCustomerList = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId, RecordTypeId FROM Account WHERE CIS__c IN :sllCisId];
		Map<String, Account> customerSllInfo = new Map<String, Account>();
		for(Account customer : sllCustomerList) {
			customerSllInfo.put(customer.CIS__c, customer);
		}
		List<FinServ__ReciprocalRole__c> reciprocalRoleList = [SELECT Id, Name, FinServ__InverseRole__c, Role_Code__c, Inverse_Role_Code__c, Role_External_ID__c FROM FinServ__ReciprocalRole__c];
		final String RECORD_TYPE_ORG_PROSPECT = 'Organization_Prospect';
		final String RECORD_TYPE_ORG_CUST = 'Organization_Customer';
		List<String> recordTypeOrganization = new List<String>();
		Map<String, Id> accountRecordTypeMap = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
		recordTypeOrganization.add(accountRecordTypeMap.get(RECORD_TYPE_ORG_PROSPECT));
		recordTypeOrganization.add(accountRecordTypeMap.get(RECORD_TYPE_ORG_CUST));

		// When
		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		AccountAccountRelation accountAccountRelation = new AccountAccountRelation(reciprocalRoleList, recordTypeOrganization, errorLogList);
		for (SLL_Relation__c sllItem : sllRelationList) {
			accountAccountRelation.AddRelationToList(sllItem);
		}
		accountAccountRelation.InsertRelation(customerSllInfo);
		Map<String, SLL_Relation__c> returnSllRelationMap = accountAccountRelation.getSllRelationMapAfterAddRelation();

		// Then
		List<FinServ__AccountAccountRelation__c> aaRelation = [SELECT Id, FinServ__Account__c, FinServ__Role__r.Name, Percent_Share__c, SLL_ExternalId__c FROM FinServ__AccountAccountRelation__c];
		FinServ__AccountAccountRelation__c companyBRelation = [SELECT Id, FinServ__Account__c, FinServ__Role__r.Name, Percent_Share__c, SLL_ExternalId__c FROM FinServ__AccountAccountRelation__c WHERE FinServ__Account__c = :customerSllInfo.get('2').Id];
		FinServ__AccountAccountRelation__c companyCRelation = [SELECT Id, FinServ__Account__c, FinServ__Role__r.Name, Percent_Share__c FROM FinServ__AccountAccountRelation__c WHERE FinServ__Account__c = :customerSllInfo.get('3').Id];
		FinServ__AccountAccountRelation__c companyABRelation = [SELECT Id, FinServ__Account__c, FinServ__Role__r.Name, Percent_Share__c FROM FinServ__AccountAccountRelation__c WHERE FinServ__Account__c = :customerSllInfo.get('1').Id AND FinServ__RelatedAccount__c = :customerSllInfo.get('2').Id];
		FinServ__AccountAccountRelation__c companyACRelation = [SELECT Id, FinServ__Account__c, FinServ__Role__r.Name, Percent_Share__c FROM FinServ__AccountAccountRelation__c WHERE FinServ__Account__c = :customerSllInfo.get('1').Id AND FinServ__RelatedAccount__c = :customerSllInfo.get('3').Id];
		System.assertEquals(companyABRelation.FinServ__Role__r.Name, 'ถูกถือหุ้นโดย');
		System.assertEquals(companyABRelation.Percent_Share__c, 80);
		System.assertEquals(companyBRelation.FinServ__Role__r.Name, 'เป็นผู้ถือหุ้น');
		
		System.assertEquals(companyACRelation.FinServ__Role__r.Name, 'ถูกถือหุ้นโดย');
		System.assertEquals(companyACRelation.Percent_Share__c, 65);
		System.assertEquals(companyCRelation.FinServ__Role__r.Name, 'เป็นผู้ถือหุ้น');

		System.assertEquals(true, returnSllRelationMap.get(companyBRelation.SLL_ExternalId__c).Is_Relation_Generated__c);
	}

	@isTest
	static void itShouldReturnErrorWhenSubjectAndObjectIsTheSame() {
		// Mock subject and object are the same
		Account companyA = [SELECT CIS__c FROM Account WHERE CIS__c = '1'];
		SLL_Relation__c sllCompanyACompanyA = new SLL_Relation__c();
		sllCompanyACompanyA.Subject_CIS_ID__c = companyA.CIS__c;
		sllCompanyACompanyA.Subject_Relation_Code__c = '205';
		sllCompanyACompanyA.Subject_Type_Code__c = 'O';
		sllCompanyACompanyA.Object_CIS_ID__c = companyA.CIS__c;
		sllCompanyACompanyA.Object_Relation_Code__c = 'B05';
		sllCompanyACompanyA.Object_Type_Code__c = 'O';
		sllCompanyACompanyA.Percent_Share__c = 80;
		sllCompanyACompanyA.SLL_ExternalId__c = companyA.CIS__c + '_' + companyA.CIS__c + '_' + sllCompanyACompanyA.Subject_Relation_Code__c + '_' + sllCompanyACompanyA.Object_Relation_Code__c;
		insert sllCompanyACompanyA;

		// Given
		List<SLL_Relation__c> sllRelationList = [SELECT Id, Subject_CIS_ID__c, Object_CIS_ID__c, Subject_Relation_Code__c, Object_Relation_Code__c, Subject_Type_Code__c, Object_Type_Code__c, Percent_Share__c, SLL_ExternalId__c FROM SLL_Relation__c];
		List<String> sllCisId = new List<String>();
		for (SLL_Relation__c sllItem : sllRelationList) {
			sllCisId.add(sllItem.Subject_CIS_ID__c);
			sllCisId.add(sllItem.Object_CIS_ID__c);
		}
		List<Account> sllCustomerList = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId, RecordTypeId FROM Account WHERE CIS__c IN :sllCisId];
		Map<String, Account> customerSllInfo = new Map<String, Account>();
		for(Account customer : sllCustomerList) {
			customerSllInfo.put(customer.CIS__c, customer);
		}
		List<FinServ__ReciprocalRole__c> reciprocalRoleList = [SELECT Id, Name, FinServ__InverseRole__c, Role_Code__c, Inverse_Role_Code__c, Role_External_ID__c FROM FinServ__ReciprocalRole__c];
		final String RECORD_TYPE_ORG_PROSPECT = 'Organization_Prospect';
		final String RECORD_TYPE_ORG_CUST = 'Organization_Customer';
		List<String> recordTypeOrganization = new List<String>();
		Map<String, Id> accountRecordTypeMap = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
		recordTypeOrganization.add(accountRecordTypeMap.get(RECORD_TYPE_ORG_PROSPECT));
		recordTypeOrganization.add(accountRecordTypeMap.get(RECORD_TYPE_ORG_CUST));

		// When
		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		AccountAccountRelation accountAccountRelation = new AccountAccountRelation(reciprocalRoleList, recordTypeOrganization, errorLogList);
		for (SLL_Relation__c sllItem : sllRelationList) {
			accountAccountRelation.AddRelationToList(sllItem);
		}
		accountAccountRelation.InsertRelation(customerSllInfo);

		// Then
		System.assertNotEquals(0, errorLogList.size());
	}
}