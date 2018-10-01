@isTest
private class HouseHoldRelation_Test
{	
	public static final String INDIVIDUAL_CUSTOMER = 'Individual Customer';
	public static final String ORGANIZATION_CUSTOMER = 'Organization Customer';
    
	@testSetup static void setupMockData() {
        Test.startTest();

        // Mock account Object
        Account father = new Account();
		father.CIS__c = '1';
		father.Encrypt_Name_TH__c = 'Father';
		father.Encrypt_Surname_TH__c = 'Family';
		father.LastName = 'Family';
		father.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(INDIVIDUAL_CUSTOMER);
		father.Temporary_Customer__c = true;
		Account mother = new Account();
		mother.CIS__c = '2';
		mother.Encrypt_Name_TH__c = 'Mother';
		mother.Encrypt_Surname_TH__c = 'Family';
		mother.LastName = 'Family';
		mother.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(INDIVIDUAL_CUSTOMER);
		mother.Temporary_Customer__c = true;
		Account children = new Account();
		children.CIS__c = '3';
		children.Encrypt_Name_TH__c = 'Children';
		children.Encrypt_Surname_TH__c = 'Family';
		children.LastName = 'Family';
		children.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(INDIVIDUAL_CUSTOMER);
		children.Temporary_Customer__c = true;
		insert father; 
		insert mother; 
		insert children;

        // Mock SLL
		SLL_Relation__c sllFatherChildren = new SLL_Relation__c();
		sllFatherChildren.Subject_CIS_ID__c = father.CIS__c;
		sllFatherChildren.Subject_Relation_Code__c = '301';
		sllFatherChildren.Subject_Type_Code__c = 'I';
		sllFatherChildren.Object_CIS_ID__c = children.CIS__c;
		sllFatherChildren.Object_Relation_Code__c = 'C01';
		sllFatherChildren.Object_Type_Code__c = 'I';
		sllFatherChildren.SLL_ExternalId__c = father.CIS__c + '_' + children.CIS__c + '_' + sllFatherChildren.Subject_Relation_Code__c + '_' + sllFatherChildren.Object_Relation_Code__c;
		insert sllFatherChildren;
		SLL_Relation__c sllSpouse = new SLL_Relation__c();
		sllSpouse.Subject_CIS_ID__c = father.CIS__c;
		sllSpouse.Subject_Relation_Code__c = '302';
		sllSpouse.Subject_Type_Code__c = 'I';
		sllSpouse.Object_CIS_ID__c = mother.CIS__c;
		sllSpouse.Object_Relation_Code__c = '302';
		sllSpouse.Object_Type_Code__c = 'I';
		sllSpouse.SLL_ExternalId__c = father.CIS__c + '_' + mother.CIS__c + '_' + sllSpouse.Subject_Relation_Code__c + '_' + sllSpouse.Object_Relation_Code__c;
		insert sllSpouse;
    }

	@isTest
	static void itShouldCreateHouseHoldWhenSllHasHousehold() {
		// Given
		String houseHoldRecordTypeId = Mockup_Test.getRecordTypeAccountIdByName('Household');
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

		// When
		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		HouseHoldRelation houseHoldRelation = new HouseHoldRelation(houseHoldRecordTypeId, errorLogList);
		for (SLL_Relation__c sllItem : sllRelationList) {
			houseHoldRelation.addRelationToList(sllItem);
		}
		houseHoldRelation.insertRelation(customerSllInfo);
		Map<String, SLL_Relation__c> returnSllRelationMap = houseHoldRelation.getSllRelationMapAfterAddRelation();

		// Then
		Account houseHoldAccountResult = [SELECT Id, Name FROM Account WHERE RecordTypeId = :houseHoldRecordTypeId];
		AccountContactRelation fatherRelation = [SELECT Id, Roles, ContactId, SLL_ExternalId__c FROM AccountContactRelation WHERE ContactId IN (SELECT PersonContactId FROM Account WHERE CIS__c = '1')];
		AccountContactRelation motherRelation = [SELECT Id, Roles, ContactId, SLL_ExternalId__c FROM AccountContactRelation WHERE ContactId IN (SELECT PersonContactId FROM Account WHERE CIS__c = '2')];
		AccountContactRelation childrenRelation = [SELECT Id, Roles, ContactId FROM AccountContactRelation WHERE ContactId IN (SELECT PersonContactId FROM Account WHERE CIS__c = '3')];
		System.assertEquals('บ้านคุณFather Family', houseHoldAccountResult.Name);
		System.assertEquals('คู่สมรส;พ่อแม่', fatherRelation.Roles);
		System.assertEquals('คู่สมรส', motherRelation.Roles);
		System.assertEquals('บุตร', childrenRelation.Roles);
		System.assertEquals(true, returnSllRelationMap.get(motherRelation.SLL_ExternalId__c).Is_Relation_Generated__c);
	}

	private static void insertSecondFamily() {
		// Mock account Object
        Account father = new Account();
		father.CIS__c = '4';
		father.Encrypt_Name_TH__c = 'Father2';
		father.Encrypt_Surname_TH__c = 'Happy2Family';
		father.LastName = 'Happy2Family';
		father.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(INDIVIDUAL_CUSTOMER);
		father.Temporary_Customer__c = true;
		Account mother = new Account();
		mother.CIS__c = '5';
		mother.Encrypt_Name_TH__c = 'Mother2';
		mother.Encrypt_Surname_TH__c = 'Happy2Family';
		mother.LastName = 'Happy2Family';
		mother.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(INDIVIDUAL_CUSTOMER);
		mother.Temporary_Customer__c = true;
		Account children = new Account();
		children.CIS__c = '6';
		children.Encrypt_Name_TH__c = 'Children2';
		children.Encrypt_Surname_TH__c = 'Happy2Family';
		children.LastName = 'Happy2Family';
		children.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(INDIVIDUAL_CUSTOMER);
		children.Temporary_Customer__c = true;
		insert father; 
		insert mother; 
		insert children;

		// Mock SLL
		SLL_Relation__c sllFatherChildren = new SLL_Relation__c();
		sllFatherChildren.Subject_CIS_ID__c = father.CIS__c;
		sllFatherChildren.Subject_Relation_Code__c = '301';
		sllFatherChildren.Subject_Type_Code__c = 'I';
		sllFatherChildren.Object_CIS_ID__c = children.CIS__c;
		sllFatherChildren.Object_Relation_Code__c = 'C01';
		sllFatherChildren.Object_Type_Code__c = 'I';
		sllFatherChildren.SLL_ExternalId__c = father.CIS__c + '_' + children.CIS__c + '_' + sllFatherChildren.Subject_Relation_Code__c + '_' + sllFatherChildren.Object_Relation_Code__c;
		insert sllFatherChildren;
		SLL_Relation__c sllSpouse = new SLL_Relation__c();
		sllSpouse.Subject_CIS_ID__c = father.CIS__c;
		sllSpouse.Subject_Relation_Code__c = '302';
		sllSpouse.Subject_Type_Code__c = 'I';
		sllSpouse.Object_CIS_ID__c = mother.CIS__c;
		sllSpouse.Object_Relation_Code__c = '302';
		sllSpouse.Object_Type_Code__c = 'I';
		sllSpouse.SLL_ExternalId__c = father.CIS__c + '_' + mother.CIS__c + '_' + sllSpouse.Subject_Relation_Code__c + '_' + sllSpouse.Object_Relation_Code__c;
		insert sllSpouse;
	}

	@isTest
	static void itShouldCreateTwoHouseHoldWhenSllHasTwoHousehold() {
		// Given
		InsertSecondFamily();
		String houseHoldRecordTypeId = Mockup_Test.getRecordTypeAccountIdByName('Household');
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

		// When
		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		HouseHoldRelation houseHoldRelation = new HouseHoldRelation(houseHoldRecordTypeId, errorLogList);
		for (SLL_Relation__c sllItem : sllRelationList) {
			houseHoldRelation.AddRelationToList(sllItem);
		}
		houseHoldRelation.InsertRelation(customerSllInfo);

		// Then
		List<Account> houseHoldAccountResult = [SELECT Id, Name FROM Account WHERE RecordTypeId = :houseHoldRecordTypeId];
		AccountContactRelation father1Relation = [SELECT Id, Roles, ContactId FROM AccountContactRelation WHERE ContactId IN (SELECT PersonContactId FROM Account WHERE CIS__c = '1')];
		AccountContactRelation mother1Relation = [SELECT Id, Roles, ContactId FROM AccountContactRelation WHERE ContactId IN (SELECT PersonContactId FROM Account WHERE CIS__c = '2')];
		AccountContactRelation children1Relation = [SELECT Id, Roles, ContactId FROM AccountContactRelation WHERE ContactId IN (SELECT PersonContactId FROM Account WHERE CIS__c = '3')];
		System.assertEquals('บ้านคุณFather Family', houseHoldAccountResult.get(0).Name);
		System.assertEquals('คู่สมรส;พ่อแม่', father1Relation.Roles);
		System.assertEquals('คู่สมรส', mother1Relation.Roles);
		System.assertEquals('บุตร', children1Relation.Roles);
		AccountContactRelation father2Relation = [SELECT Id, Roles, ContactId FROM AccountContactRelation WHERE ContactId IN (SELECT PersonContactId FROM Account WHERE CIS__c = '4')];
		AccountContactRelation mother2Relation = [SELECT Id, Roles, ContactId FROM AccountContactRelation WHERE ContactId IN (SELECT PersonContactId FROM Account WHERE CIS__c = '5')];
		AccountContactRelation children2Relation = [SELECT Id, Roles, ContactId FROM AccountContactRelation WHERE ContactId IN (SELECT PersonContactId FROM Account WHERE CIS__c = '6')];
		System.assertEquals('บ้านคุณFather2 Happy2Family', houseHoldAccountResult.get(1).Name);
		System.assertEquals('คู่สมรส;พ่อแม่', father2Relation.Roles);
		System.assertEquals('คู่สมรส', mother2Relation.Roles);
		System.assertEquals('บุตร', children2Relation.Roles);
	}

	@isTest
	static void itShouldNotAddMemberToHouseHoldWhenNoPerContactId()
	{
		// Given
		String houseHoldRecordTypeId = Mockup_Test.getRecordTypeAccountIdByName('Household');
		// Mock company Object
        Account companyA = new Account();
		companyA.CIS__c = '11';
		companyA.Encrypt_Name_TH__c = 'CompanyA';
		companyA.Name = 'CompanyA';
		companyA.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(ORGANIZATION_CUSTOMER);
		companyA.Temporary_Customer__c = true;
		insert companyA;
		Account father = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId FROM Account WHERE CIS__c = '1'];

		// Mock SLL
		SLL_Relation__c sllFatherChildren = new SLL_Relation__c();
		sllFatherChildren.Subject_CIS_ID__c = father.CIS__c;
		sllFatherChildren.Subject_Relation_Code__c = '301';
		sllFatherChildren.Subject_Type_Code__c = 'I';
		sllFatherChildren.Object_CIS_ID__c = companyA.CIS__c;
		sllFatherChildren.Object_Relation_Code__c = 'C01';
		sllFatherChildren.Object_Type_Code__c = 'I';
		sllFatherChildren.SLL_ExternalId__c = father.CIS__c + '_' + companyA.CIS__c + '_' + sllFatherChildren.Subject_Relation_Code__c + '_' + sllFatherChildren.Object_Relation_Code__c;
		insert sllFatherChildren;

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

		// When
		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		HouseHoldRelation houseHoldRelation = new HouseHoldRelation(houseHoldRecordTypeId, errorLogList);
		for (SLL_Relation__c sllItem : sllRelationList) {
			houseHoldRelation.addRelationToList(sllItem);
		}
		houseHoldRelation.insertRelation(customerSllInfo);

		// Then
		List<FinServ__ContactContactRelation__c> fatherRelation = [SELECT Id, FinServ__Contact__c, FinServ__Role__r.Name FROM FinServ__ContactContactRelation__c 
			WHERE FinServ__Contact__c = :customerSllInfo.get('1').PersonContactId AND FinServ__RelatedContact__c = :customerSllInfo.get('11').PersonContactId];
		System.assertEquals(0, fatherRelation.size());
	}

	@isTest
	static void itShouldReturnErrorWhenSubjectAndObjectIsTheSame() {
		// Given
		String houseHoldRecordTypeId = Mockup_Test.getRecordTypeAccountIdByName('Household');
		// Mock company Object
        Account companyA = new Account();
		companyA.CIS__c = '11';
		companyA.Encrypt_Name_TH__c = 'CompanyA';
		companyA.Name = 'CompanyA';
		companyA.RecordTypeId =  Mockup_Test.getRecordTypeAccountIdByName(ORGANIZATION_CUSTOMER);
		companyA.Temporary_Customer__c = true;
		insert companyA;
		Account father = [SELECT Id, CIS__c, Name, Encrypt_Name_TH__c, Encrypt_Surname_TH__c, PersonContactId FROM Account WHERE CIS__c = '1'];

		// Mock SLL
		SLL_Relation__c sllFatherChildren = new SLL_Relation__c();
		sllFatherChildren.Subject_CIS_ID__c = father.CIS__c;
		sllFatherChildren.Subject_Relation_Code__c = '301';
		sllFatherChildren.Subject_Type_Code__c = 'I';
		sllFatherChildren.Object_CIS_ID__c = father.CIS__c;
		sllFatherChildren.Object_Relation_Code__c = 'C01';
		sllFatherChildren.Object_Type_Code__c = 'I';
		sllFatherChildren.SLL_ExternalId__c = father.CIS__c + '_' + father.CIS__c + '_' + sllFatherChildren.Subject_Relation_Code__c + '_' + sllFatherChildren.Object_Relation_Code__c;
		
		insert sllFatherChildren;

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

		// When
		List<Application_Log__c> errorLogList = new List<Application_Log__c>();
		HouseHoldRelation houseHoldRelation = new HouseHoldRelation(houseHoldRecordTypeId, errorLogList);
		for (SLL_Relation__c sllItem : sllRelationList) {
			houseHoldRelation.addRelationToList(sllItem);
		}
		houseHoldRelation.insertRelation(customerSllInfo);

		// Then
		System.assertNotEquals(0, errorLogList.size());
	}
}