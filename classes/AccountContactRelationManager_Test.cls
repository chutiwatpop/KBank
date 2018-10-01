@isTest
private class AccountContactRelationManager_Test
{
	public static final String ORGANIZATION_CUSTOMER = 'Organization Customer';
	public static final String INDIVIDUAL_CUSTOMER = 'Individual Customer';
    
	@testSetup static void setupMockData() {
        Test.startTest();

		// Mock account Object
        Account tracy = new Account();
		tracy.CIS__c = '1';
		tracy.Encrypt_Name_TH__c = 'Tracy';
		tracy.Encrypt_Surname_TH__c = 'Rainer';
		tracy.LastName = 'Rainer';
		tracy.RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(INDIVIDUAL_CUSTOMER);
		tracy.Temporary_Customer__c = true;
		Account arri = new Account();
		arri.CIS__c = '2';
		arri.Encrypt_Name_TH__c = 'Arri';
		arri.Encrypt_Surname_TH__c = 'Djurkovic';
		arri.LastName = 'Djurkovic';
		arri.RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(INDIVIDUAL_CUSTOMER);
		arri.Temporary_Customer__c = true;
		insert tracy; 
		insert arri;

        // Mock company Object
        Account companyA = new Account();
		companyA.CIS__c = '11';
		companyA.Encrypt_Name_TH__c = 'CompanyA';
		companyA.Name = 'CompanyA';
		companyA.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(ORGANIZATION_CUSTOMER);
		companyA.Temporary_Customer__c = true;
		Account companyB = new Account();
		companyB.CIS__c = '12';
		companyB.Encrypt_Name_TH__c = 'CompanyB';
		companyB.Name = 'CompanyB';
		companyB.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(ORGANIZATION_CUSTOMER);
		companyB.Temporary_Customer__c = true;
		insert companyA; 
		insert companyB; 

        // Mock SLL
		// Tracy เป็นผู้ถือหุ้น CompanyA, CompanyA ถูกถือหุ้นโดย Tracy and share 80%
		SLL_Relation__c sllTracyCompanyA = new SLL_Relation__c();
		sllTracyCompanyA.Subject_CIS_ID__c = tracy.CIS__c;
		sllTracyCompanyA.Subject_Relation_Code__c = '205';
		sllTracyCompanyA.Subject_Type_Code__c = 'I';
		sllTracyCompanyA.Object_CIS_ID__c = companyA.CIS__c;
		sllTracyCompanyA.Object_Relation_Code__c = 'B05';
		sllTracyCompanyA.Object_Type_Code__c = 'O';
		sllTracyCompanyA.SLL_ExternalId__c = tracy.CIS__c + '_' + companyA.CIS__c + '_' + sllTracyCompanyA.Subject_Relation_Code__c + '_' + sllTracyCompanyA.Object_Relation_Code__c;
		sllTracyCompanyA.Percent_Share__c = 80;
		insert sllTracyCompanyA;
		SLL_Relation__c sllCompanyBArri = new SLL_Relation__c();
		sllCompanyBArri.Subject_CIS_ID__c = companyB.CIS__c;
		sllCompanyBArri.Subject_Relation_Code__c = 'B05';
		sllCompanyBArri.Subject_Type_Code__c = 'O';
		sllCompanyBArri.Object_CIS_ID__c = arri.CIS__c;
		sllCompanyBArri.Object_Relation_Code__c = '205';
		sllCompanyBArri.Object_Type_Code__c = 'I';
		sllCompanyBArri.SLL_ExternalId__c = companyB.CIS__c + '_' + arri.CIS__c + '_' + sllCompanyBArri.Subject_Relation_Code__c + '_' + sllCompanyBArri.Object_Relation_Code__c;
		sllCompanyBArri.Percent_Share__c = 65;
		insert sllCompanyBArri;
		SLL_Relation__c sllSingleTracyCompanyA = new SLL_Relation__c();
		sllSingleTracyCompanyA.Subject_CIS_ID__c = tracy.CIS__c;
		sllSingleTracyCompanyA.Subject_Relation_Code__c = '304';
		sllSingleTracyCompanyA.Subject_Type_Code__c = 'I';
		sllSingleTracyCompanyA.Object_CIS_ID__c = companyA.CIS__c;
		sllSingleTracyCompanyA.Object_Relation_Code__c = '304';
		sllSingleTracyCompanyA.Object_Type_Code__c = 'O';
		sllSingleTracyCompanyA.SLL_ExternalId__c = tracy.CIS__c + '_' + companyA.CIS__c + '_' + sllSingleTracyCompanyA.Subject_Relation_Code__c + '_' + sllSingleTracyCompanyA.Object_Relation_Code__c;
		insert sllSingleTracyCompanyA;
    }

	@isTest
	static void itShouldCreateACRelationWhenSllHasAC()
	{
		// Given
		List<SLL_Relation__c> sllRelationList = [SELECT Id, Subject_CIS_ID__c, Object_CIS_ID__c, Subject_Relation_Code__c, Object_Relation_Code__c, Subject_Type_Code__c, Object_Type_Code__c, Percent_Share__c, SLL_ExternalId__c FROM SLL_Relation__c];
		List<String> sllCisId = new List<String>();
		for (SLL_Relation__c sllItem : sllRelationList) {
			sllCisId.add(sllItem.Subject_CIS_ID__c);
			sllCisId.add(sllItem.Object_CIS_ID__c);
		}
		List<Account> sllCustomerList = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId FROM Account WHERE CIS__c IN :sllCisId];
		Map<String, Account> customerSllInfo = new Map<String, Account>();
		for(Account customer : sllCustomerList) {
			customerSllInfo.put(customer.CIS__c, customer);
		}

		// When
		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		AccountContactRelationManager accountContactRelationManager = new AccountContactRelationManager(errorLogList);
		for (SLL_Relation__c sllItem : sllRelationList) {
			accountContactRelationManager.addRelationToList(sllItem);
		}
		accountContactRelationManager.insertRelation(customerSllInfo);
		Map<String, SLL_Relation__c> returnSllRelationMap = accountContactRelationManager.getSllRelationMapAfterAddRelation();

		// Then
		AccountContactRelation tracyCompanyARelation = [SELECT Id, AccountId, ContactId, Roles, Percent_Share__c, SLL_ExternalId__c FROM AccountContactRelation WHERE AccountId = :customerSllInfo.get('11').Id AND ContactId = :customerSllInfo.get('1').PersonContactId];
		AccountContactRelation companyBArriRelation = [SELECT Id, AccountId, ContactId, Roles, Percent_Share__c FROM AccountContactRelation WHERE AccountId = :customerSllInfo.get('12').Id AND ContactId = :customerSllInfo.get('2').PersonContactId];
		System.assertEquals('เป็นผู้ถือหุ้น;บัญชีร่วม', tracyCompanyARelation.Roles);
		System.assertEquals('เป็นผู้ถือหุ้น', companyBArriRelation.Roles);
		System.assertEquals(80, tracyCompanyARelation.Percent_Share__c);
		System.assertEquals(65, companyBArriRelation.Percent_Share__c);
		System.assertEquals(true, returnSllRelationMap.get(tracyCompanyARelation.SLL_ExternalId__c).Is_Relation_Generated__c);
	}

	@isTest
	static void itShouldNotCreateACRelationWhenNoPersonContactId()
	{
		// Given
		// Mock company Object
        Account noPersonContact = new Account();
		noPersonContact.CIS__c = '3';
		noPersonContact.Encrypt_Name_TH__c = 'NoContact';
		noPersonContact.Name = 'NoContact';
		noPersonContact.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(ORGANIZATION_CUSTOMER);
		noPersonContact.Temporary_Customer__c = true;
		insert noPersonContact;
		Account companyA = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId FROM Account WHERE CIS__c = '11'];
		Account companyB = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId FROM Account WHERE CIS__c = '12'];
		SLL_Relation__c sllNoPersonContactCompanyA = new SLL_Relation__c();
		sllNoPersonContactCompanyA.Subject_CIS_ID__c = noPersonContact.CIS__c;
		sllNoPersonContactCompanyA.Subject_Relation_Code__c = '205';
		sllNoPersonContactCompanyA.Subject_Type_Code__c = 'I';
		sllNoPersonContactCompanyA.Object_CIS_ID__c = companyA.CIS__c;
		sllNoPersonContactCompanyA.Object_Relation_Code__c = 'B05';
		sllNoPersonContactCompanyA.Object_Type_Code__c = 'O';
		sllNoPersonContactCompanyA.SLL_ExternalId__c = noPersonContact.CIS__c + '_' + companyA.CIS__c + '_' + sllNoPersonContactCompanyA.Subject_Relation_Code__c + '_' + sllNoPersonContactCompanyA.Object_Relation_Code__c;
		sllNoPersonContactCompanyA.Percent_Share__c = 80;
		insert sllNoPersonContactCompanyA;
		SLL_Relation__c sllCompanyBNoPersonContact = new SLL_Relation__c();
		sllCompanyBNoPersonContact.Subject_CIS_ID__c = companyB.CIS__c;
		sllCompanyBNoPersonContact.Subject_Relation_Code__c = 'B05';
		sllCompanyBNoPersonContact.Subject_Type_Code__c = 'O';
		sllCompanyBNoPersonContact.Object_CIS_ID__c = noPersonContact.CIS__c;
		sllCompanyBNoPersonContact.Object_Relation_Code__c = '205';
		sllCompanyBNoPersonContact.Object_Type_Code__c = 'I';
		sllCompanyBNoPersonContact.SLL_ExternalId__c = companyB.CIS__c + '_' + noPersonContact.CIS__c + '_' + sllCompanyBNoPersonContact.Subject_Relation_Code__c + '_' + sllCompanyBNoPersonContact.Object_Relation_Code__c;
		sllCompanyBNoPersonContact.Percent_Share__c = 40;
		insert sllCompanyBNoPersonContact;

		List<SLL_Relation__c> sllRelationList = [SELECT Id, Subject_CIS_ID__c, Object_CIS_ID__c, Subject_Relation_Code__c, Object_Relation_Code__c, Subject_Type_Code__c, Object_Type_Code__c, Percent_Share__c, SLL_ExternalId__c FROM SLL_Relation__c];
		List<String> sllCisId = new List<String>();
		for (SLL_Relation__c sllItem : sllRelationList) {
			sllCisId.add(sllItem.Subject_CIS_ID__c);
			sllCisId.add(sllItem.Object_CIS_ID__c);
		}
		List<Account> sllCustomerList = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId FROM Account WHERE CIS__c IN :sllCisId];
		Map<String, Account> customerSllInfo = new Map<String, Account>();
		for(Account customer : sllCustomerList) {
			customerSllInfo.put(customer.CIS__c, customer);
		}

		// When
		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		AccountContactRelationManager accountContactRelationManager = new AccountContactRelationManager(errorLogList);
		for (SLL_Relation__c sllItem : sllRelationList) {
			accountContactRelationManager.addRelationToList(sllItem);
		}
		accountContactRelationManager.insertRelation(customerSllInfo);

		// Then
		List<AccountContactRelation> noPersonContactCompanyARelation = [SELECT Id, AccountId, ContactId, Roles FROM AccountContactRelation 
			WHERE AccountId = :companyA.Id AND ContactId = :noPersonContact.PersonContactId];
		List<AccountContactRelation> companyBNoPersonContactRelation = [SELECT Id, AccountId, ContactId, Roles FROM AccountContactRelation 
			WHERE AccountId = :companyB.Id AND ContactId = :noPersonContact.PersonContactId];
		System.assertEquals(0, noPersonContactCompanyARelation.size());
		System.assertEquals(0, companyBNoPersonContactRelation.size());
	}

	@isTest
	static void itShouldReturnErrorWhenSubjectAndObjectIsTheSame()
	{
		// Given
		Account companyA = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId FROM Account WHERE CIS__c = '11'];
		SLL_Relation__c sllCompanyACompanyA = new SLL_Relation__c();
		sllCompanyACompanyA.Subject_CIS_ID__c = companyA.CIS__c;
		sllCompanyACompanyA.Subject_Relation_Code__c = '205';
		sllCompanyACompanyA.Subject_Type_Code__c = 'I';
		sllCompanyACompanyA.Object_CIS_ID__c = companyA.CIS__c;
		sllCompanyACompanyA.Object_Relation_Code__c = 'B05';
		sllCompanyACompanyA.Object_Type_Code__c = 'O';
		sllCompanyACompanyA.Percent_Share__c = 80;
		insert sllCompanyACompanyA;

		List<SLL_Relation__c> sllRelationList = [SELECT Id, Subject_CIS_ID__c, Object_CIS_ID__c, Subject_Relation_Code__c, Object_Relation_Code__c, Subject_Type_Code__c, Object_Type_Code__c, Percent_Share__c, SLL_ExternalId__c FROM SLL_Relation__c];
		List<String> sllCisId = new List<String>();
		for (SLL_Relation__c sllItem : sllRelationList) {
			sllCisId.add(sllItem.Subject_CIS_ID__c);
			sllCisId.add(sllItem.Object_CIS_ID__c);
		}
		List<Account> sllCustomerList = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId FROM Account WHERE CIS__c IN :sllCisId];
		Map<String, Account> customerSllInfo = new Map<String, Account>();
		for(Account customer : sllCustomerList) {
			customerSllInfo.put(customer.CIS__c, customer);
		}

		// When
		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		AccountContactRelationManager accountContactRelationManager = new AccountContactRelationManager(errorLogList);
		for (SLL_Relation__c sllItem : sllRelationList) {
			accountContactRelationManager.addRelationToList(sllItem);
		}
		accountContactRelationManager.insertRelation(customerSllInfo);

		// Then
		System.assertNotEquals(0, errorLogList.size());
	}
	
}