@isTest
private class ContactContactRelation_Test
{
	public static final String INDIVIDUAL_CUSTOMER = 'Individual Customer';
	public static final String ORGANIZATION_CUSTOMER = 'Organization Customer';
    
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
		Account marylin = new Account();
		marylin.CIS__c = '3';
		marylin.Encrypt_Name_TH__c = 'Marylin';
		marylin.Encrypt_Surname_TH__c = 'Erington';
		marylin.LastName = 'Erington';
		marylin.RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(INDIVIDUAL_CUSTOMER);
		marylin.Temporary_Customer__c = true;
		insert tracy; 
		insert arri; 
		insert marylin;

        // Mock SLL
		SLL_Relation__c sllTracyArri = new SLL_Relation__c();
		sllTracyArri.Subject_CIS_ID__c = tracy.CIS__c;
		sllTracyArri.Subject_Relation_Code__c = '224';
		sllTracyArri.Subject_Type_Code__c = 'I';
		sllTracyArri.Object_CIS_ID__c = arri.CIS__c;
		sllTracyArri.Object_Relation_Code__c = 'B24';
		sllTracyArri.Object_Type_Code__c = 'I';
		sllTracyArri.SLL_ExternalId__c = tracy.CIS__c + '_' + arri.CIS__c + '_' + sllTracyArri.Subject_Relation_Code__c + '_' + sllTracyArri.Object_Relation_Code__c;
		insert sllTracyArri;
		SLL_Relation__c sllTracyMarylin = new SLL_Relation__c();
		sllTracyMarylin.Subject_CIS_ID__c = tracy.CIS__c;
		sllTracyMarylin.Subject_Relation_Code__c = '224';
		sllTracyMarylin.Subject_Type_Code__c = 'I';
		sllTracyMarylin.Object_CIS_ID__c = marylin.CIS__c;
		sllTracyMarylin.Object_Relation_Code__c = 'B24';
		sllTracyMarylin.Object_Type_Code__c = 'I';
		sllTracyMarylin.SLL_ExternalId__c = tracy.CIS__c + '_' + marylin.CIS__c + '_' + sllTracyMarylin.Subject_Relation_Code__c + '_' + sllTracyMarylin.Object_Relation_Code__c;
		insert sllTracyMarylin;

		// Mock reciprocal role
		FinServ__ReciprocalRole__c reciprocalRole = new FinServ__ReciprocalRole__c();
		reciprocalRole.Name = 'เป็นลูกหนี้การค้า';
		reciprocalRole.Role_Code__c = '224';
		reciprocalRole.FinServ__InverseRole__c = 'เจ้าหนี้การค้า';
		reciprocalRole.Inverse_Role_Code__c = 'B24';
		reciprocalRole.Role_External_ID__c = '224_B24_C';
		reciprocalRole.FinServ__RelationshipType__c = 'Contact Contact Relation';
		reciprocalRole.FinServ__CreateInverseRole__c = false;
		reciprocalRole.RecordTypeId = Schema.SObjectType.FinServ__ReciprocalRole__c.getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
		insert reciprocalRole;

		FinServ__ReciprocalRole__c reciprocalRoleInverse = new FinServ__ReciprocalRole__c();
		reciprocalRoleInverse.Name = 'เจ้าหนี้การค้า';
		reciprocalRoleInverse.Role_Code__c = 'B24';
		reciprocalRoleInverse.FinServ__InverseRole__c = 'เป็นลูกหนี้การค้า';
		reciprocalRoleInverse.Inverse_Role_Code__c = '224';
		reciprocalRoleInverse.Role_External_ID__c = 'B24_224_C';
		reciprocalRoleInverse.FinServ__RelationshipType__c = 'Contact Contact Relation';
		reciprocalRoleInverse.FinServ__CreateInverseRole__c = false;
		reciprocalRoleInverse.RecordTypeId = Schema.SObjectType.FinServ__ReciprocalRole__c.getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
		insert reciprocalRoleInverse;

		reciprocalRole.FinServ__InverseRelationship__c = reciprocalRoleInverse.Id;
		reciprocalRoleInverse.FinServ__InverseRelationship__c = reciprocalRole.Id;
		update reciprocalRole;
		update reciprocalRoleInverse;

		insert new User_Management__c(Allow_Edit_Customer_Relationship__c=true);
    }

	@isTest
	static void itShouldCreateCCRelationWhenSllHasCC()
	{
		// Given
		List<SLL_Relation__c> sllRelationList = [SELECT Id, Subject_CIS_ID__c, Object_CIS_ID__c, Subject_Relation_Code__c, Object_Relation_Code__c, Subject_Type_Code__c, Object_Type_Code__c, SLL_ExternalId__c FROM SLL_Relation__c];
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
		List<FinServ__ReciprocalRole__c> reciprocalRoleList = [SELECT Id, Name, FinServ__InverseRole__c, Role_Code__c, Inverse_Role_Code__c, Role_External_ID__c FROM FinServ__ReciprocalRole__c];

		// When
		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		ContactContactRelation contactContactRelation = new ContactContactRelation(reciprocalRoleList, errorLogList);
		for (SLL_Relation__c sllItem : sllRelationList) {
			contactContactRelation.addRelationToList(sllItem);
		}
		contactContactRelation.insertRelation(customerSllInfo);
		Map<String, SLL_Relation__c> returnSllRelationMap = contactContactRelation.getSllRelationMapAfterAddRelation();

		// Then
		FinServ__ContactContactRelation__c arriRelation = [SELECT Id, FinServ__Contact__c, FinServ__Role__r.Name, SLL_ExternalId__c FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c = :customerSllInfo.get('2').PersonContactId];
		FinServ__ContactContactRelation__c marylinRelation = [SELECT Id, FinServ__Contact__c, FinServ__Role__r.Name FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c = :customerSllInfo.get('3').PersonContactId];
		FinServ__ContactContactRelation__c tracyArriRelation = [SELECT Id, FinServ__Contact__c, FinServ__Role__r.Name FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c = :customerSllInfo.get('1').PersonContactId AND FinServ__RelatedContact__c = :customerSllInfo.get('2').PersonContactId];
		FinServ__ContactContactRelation__c tracyMarylinRelation = [SELECT Id, FinServ__Contact__c, FinServ__Role__r.Name FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c = :customerSllInfo.get('1').PersonContactId AND FinServ__RelatedContact__c = :customerSllInfo.get('3').PersonContactId];
		System.assertEquals('เจ้าหนี้การค้า', tracyArriRelation.FinServ__Role__r.Name);
		System.assertEquals('เป็นลูกหนี้การค้า', arriRelation.FinServ__Role__r.Name);
		System.assertEquals('เจ้าหนี้การค้า', tracyMarylinRelation.FinServ__Role__r.Name);
		System.assertEquals('เป็นลูกหนี้การค้า', marylinRelation.FinServ__Role__r.Name);
		System.assertEquals(true, returnSllRelationMap.get(arriRelation.SLL_ExternalId__c).Is_Relation_Generated__c);
	}

	@isTest
	static void itShouldCreateCCRelationForSingleReciprocalRole()
	{
		// Given
		FinServ__ReciprocalRole__c singleReciprocalRole = new FinServ__ReciprocalRole__c();
		singleReciprocalRole.Name = 'บัญชีร่วม';
		singleReciprocalRole.Role_Code__c = '304';
		singleReciprocalRole.FinServ__InverseRole__c = 'บัญชีร่วม';
		singleReciprocalRole.Inverse_Role_Code__c = '304';
		singleReciprocalRole.Role_External_ID__c = '304_304_C';
		singleReciprocalRole.FinServ__RelationshipType__c = 'Contact Contact Relation';
		singleReciprocalRole.FinServ__CreateInverseRole__c = false;
		singleReciprocalRole.RecordTypeId = Schema.SObjectType.FinServ__ReciprocalRole__c.getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
		insert singleReciprocalRole;
		Account customerTracyInfo = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId FROM Account WHERE CIS__c = '1'];
		Account customerArriInfo = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId FROM Account WHERE CIS__c = '2'];
		SLL_Relation__c sllTracyArri = new SLL_Relation__c();
		sllTracyArri.Subject_CIS_ID__c = customerTracyInfo.CIS__c;
		sllTracyArri.Subject_Relation_Code__c = '304';
		sllTracyArri.Subject_Type_Code__c = 'I';
		sllTracyArri.Object_CIS_ID__c = customerArriInfo.CIS__c;
		sllTracyArri.Object_Relation_Code__c = '304';
		sllTracyArri.Object_Type_Code__c = 'I';
		sllTracyArri.SLL_ExternalId__c = customerTracyInfo.CIS__c + '_' + customerArriInfo.CIS__c + '_' + sllTracyArri.Subject_Relation_Code__c + '_' + sllTracyArri.Object_Relation_Code__c;
		insert sllTracyArri;

		List<SLL_Relation__c> sllRelationList = [SELECT Id, Subject_CIS_ID__c, Object_CIS_ID__c, Subject_Relation_Code__c, Object_Relation_Code__c, Subject_Type_Code__c, Object_Type_Code__c, SLL_ExternalId__c FROM SLL_Relation__c];
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
		List<FinServ__ReciprocalRole__c> reciprocalRoleList = [SELECT Id, Name, FinServ__InverseRole__c, Role_Code__c, Inverse_Role_Code__c, Role_External_ID__c FROM FinServ__ReciprocalRole__c];		

		// When
		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		ContactContactRelation contactContactRelation = new ContactContactRelation(reciprocalRoleList, errorLogList);
		for (SLL_Relation__c sllItem : sllRelationList) {
			contactContactRelation.addRelationToList(sllItem);
		}
		contactContactRelation.insertRelation(customerSllInfo);

		System.debug('test' + customerSllInfo);

		// Then
		FinServ__ContactContactRelation__c tracyRelation = [SELECT Id, FinServ__Contact__c, FinServ__Role__r.Name FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c = :customerSllInfo.get('1').PersonContactId AND FinServ__Role__c = :singleReciprocalRole.Id];
		FinServ__ContactContactRelation__c arriRelation = [SELECT Id, FinServ__Contact__c, FinServ__Role__r.Name FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c = :customerSllInfo.get('2').PersonContactId AND FinServ__Role__c = :singleReciprocalRole.Id];
		System.assertEquals('บัญชีร่วม', tracyRelation.FinServ__Role__r.Name);
		System.assertEquals('บัญชีร่วม', arriRelation.FinServ__Role__r.Name);
	}

	@isTest
	// Negative test scenario, when sll map incorrect data, (company to individual or individual to company)
	static void itShouldNotCreateCCRelationWhenNoPerContactId()
	{
		// Given
		// Mock account Object
        Account companyA = new Account();
		companyA.CIS__c = '11';
		companyA.Encrypt_Name_TH__c = 'CompanyA';
		companyA.Name = 'CompanyA';
		companyA.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(ORGANIZATION_CUSTOMER);
		companyA.Temporary_Customer__c = true;
		insert companyA;

		Account customerTracyInfo = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId FROM Account WHERE CIS__c = '1'];
		SLL_Relation__c sllTracyArri = new SLL_Relation__c();
		sllTracyArri.Subject_CIS_ID__c = companyA.CIS__c;
		sllTracyArri.Subject_Relation_Code__c = '224';
		sllTracyArri.Subject_Type_Code__c = 'I';
		sllTracyArri.Object_CIS_ID__c = customerTracyInfo.CIS__c;
		sllTracyArri.Object_Relation_Code__c = 'B04';
		sllTracyArri.Object_Type_Code__c = 'I';
		sllTracyArri.SLL_ExternalId__c = companyA.CIS__c + '_' + customerTracyInfo.CIS__c + '_' + sllTracyArri.Subject_Relation_Code__c + '_' + sllTracyArri.Object_Relation_Code__c;
		insert sllTracyArri;

		List<SLL_Relation__c> sllRelationList = [SELECT Id, Subject_CIS_ID__c, Object_CIS_ID__c, Subject_Relation_Code__c, Object_Relation_Code__c, Subject_Type_Code__c, Object_Type_Code__c, SLL_ExternalId__c FROM SLL_Relation__c];
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
		List<FinServ__ReciprocalRole__c> reciprocalRoleList = [SELECT Id, Name, FinServ__InverseRole__c, Role_Code__c, Inverse_Role_Code__c, Role_External_ID__c FROM FinServ__ReciprocalRole__c];		

		// When
		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		ContactContactRelation contactContactRelation = new ContactContactRelation(reciprocalRoleList, errorLogList);
		for (SLL_Relation__c sllItem : sllRelationList) {
			contactContactRelation.addRelationToList(sllItem);
		}
		contactContactRelation.insertRelation(customerSllInfo);

		// Then
		//Id roleId = [SELECT Id, Name, FinServ__InverseRole__c, Role_Code__c, Inverse_Role_Code__c, Role_External_ID__c FROM FinServ__ReciprocalRole__c WHERE Inverse_Role_Code__c = '224'].Id;
		List<FinServ__ContactContactRelation__c> tracyRelation = [SELECT Id, FinServ__Contact__c, FinServ__Role__r.Name FROM FinServ__ContactContactRelation__c 
			WHERE FinServ__Contact__c = :customerSllInfo.get('1').PersonContactId AND FinServ__RelatedContact__c = :customerSllInfo.get('11').PersonContactId];
		System.assertEquals(tracyRelation.size(), 0);
	}

	@isTest
	static void itShouldReturnErrorWhenSubjectAndObjectIsTheSame()
	{
		// Given
		// Mock account Object
		Account customerTracyInfo = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId FROM Account WHERE CIS__c = '1'];
		SLL_Relation__c sllTracyTracy = new SLL_Relation__c();
		sllTracyTracy.Subject_CIS_ID__c = customerTracyInfo.CIS__c;
		sllTracyTracy.Subject_Relation_Code__c = '224';
		sllTracyTracy.Subject_Type_Code__c = 'I';
		sllTracyTracy.Object_CIS_ID__c = customerTracyInfo.CIS__c;
		sllTracyTracy.Object_Relation_Code__c = 'B04';
		sllTracyTracy.Object_Type_Code__c = 'I';
		insert sllTracyTracy;

		List<SLL_Relation__c> sllRelationList = [SELECT Id, Subject_CIS_ID__c, Object_CIS_ID__c, Subject_Relation_Code__c, Object_Relation_Code__c, Subject_Type_Code__c, Object_Type_Code__c, SLL_ExternalId__c FROM SLL_Relation__c];
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
		List<FinServ__ReciprocalRole__c> reciprocalRoleList = [SELECT Id, Name, FinServ__InverseRole__c, Role_Code__c, Inverse_Role_Code__c, Role_External_ID__c FROM FinServ__ReciprocalRole__c];		

		// When
		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		ContactContactRelation contactContactRelation = new ContactContactRelation(reciprocalRoleList, errorLogList);
		for (SLL_Relation__c sllItem : sllRelationList) {
			contactContactRelation.addRelationToList(sllItem);
		}
		contactContactRelation.insertRelation(customerSllInfo);

		// Then
		System.assertNotEquals(0, errorLogList.size());
	}
}