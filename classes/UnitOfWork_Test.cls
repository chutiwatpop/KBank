@isTest
private class UnitOfWork_Test {
	@isTest static void testNewList() {
		Account account1 = Mockup_Test.newAccountObj('Name1', GlobalConstants.PORT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		Account account2 = Mockup_Test.newAccountObj('Name2', GlobalConstants.PORT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		List<Account> accountList = new List<Account>{account1, account2};
		UnitOfWork.getInstance().setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
		UnitOfWork.getInstance().registerNew(accountList);
		UnitOfWork.getInstance().commitWork();

		System.assertEquals(2, [SELECT Count() FROM Account]);
	}

	@isTest static void testNew() {
		Account account1 = Mockup_Test.newAccountObj('Name1', GlobalConstants.PORT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		UnitOfWork.getInstance().setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
		UnitOfWork.getInstance().registerNew(account1);
		
		UnitOfWork.getInstance().commitWork();
		System.assertEquals(1, [SELECT Count() FROM Account]);
	}
	
	@isTest static void testUpdate() {
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode().newAccount('Name1', GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		Account account1 = [SELECT Id FROM Account LIMIT 1];
		account1.Customer_Importance_Note__c = 'NameEdited1';

		UnitOfWork.getInstance().setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
		UnitOfWork.getInstance().registerUpdate(account1);
		UnitOfWork.getInstance().commitWork();

		Account targetAccount = [SELECT Id, Customer_Importance_Note__c FROM Account WHERE Id = :account1.Id LIMIT 1];
		System.assertEquals('NameEdited1', targetAccount.Customer_Importance_Note__c);
	}

	@isTest static void testUpdateList() {
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
		mt.newAccount('Name1', GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		mt.newAccount('Name2', GlobalConstants.POOL, GlobalConstants.OWNERSHIP_TEMPORARY, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME));
		Account account1 = [SELECT Id FROM Account WHERE Port_Pool__c = 'Port' LIMIT 1];
		account1.Customer_Importance_Note__c = 'NameEdited1';

		Account account2 = [SELECT Id FROM Account WHERE Port_Pool__c = 'Pool' LIMIT 1];
		account2.Customer_Importance_Note__c = 'NameEdited2';
		List<Account> accountList = new List<Account>{account1, account2};

		UnitOfWork.getInstance().setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
		UnitOfWork.getInstance().registerUpdate(accountList);
		UnitOfWork.getInstance().commitWork();

		Account targetAccount = [SELECT Id, Customer_Importance_Note__c FROM Account WHERE Id = :account1.Id LIMIT 1];
		System.assertEquals('NameEdited1', targetAccount.Customer_Importance_Note__c);

		Account targetAccount2 = [SELECT Id, Customer_Importance_Note__c FROM Account WHERE Id = :account2.Id LIMIT 1];
		System.assertEquals('NameEdited2', targetAccount2.Customer_Importance_Note__c);
	}

	@isTest static void testUpdateByPass() {
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
		mt.newAccount('Name1', GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		mt.newAccount('Name2', GlobalConstants.POOL, GlobalConstants.OWNERSHIP_TEMPORARY, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME));
		Account account1 = [SELECT Id FROM Account WHERE Port_Pool__c = 'Port' LIMIT 1];
		account1.Customer_Importance_Note__c = 'NameEdited1';

		Account account2 = [SELECT Id FROM Account WHERE Port_Pool__c = 'Pool' LIMIT 1];
		account2.Customer_Importance_Note__c = 'NameEdited2';
		List<Account> accountList = new List<Account>{account1, account2};

		UnitOfWork.getInstance().setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
		UnitOfWork.getInstance().registerUpdateByPass(accountList);
		UnitOfWork.getInstance().commitWork();

		Account targetAccount = [SELECT Id, Customer_Importance_Note__c FROM Account WHERE Id = :account1.Id LIMIT 1];
		System.assertEquals('NameEdited1', targetAccount.Customer_Importance_Note__c);

		Account targetAccount2 = [SELECT Id, Customer_Importance_Note__c FROM Account WHERE Id = :account2.Id LIMIT 1];
		System.assertEquals('NameEdited2', targetAccount2.Customer_Importance_Note__c);
	}

	@isTest static void testDelete() {
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode().newAccount('Name1', GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		Account account1 = [SELECT Id FROM Account LIMIT 1];
		account1.Name = 'NameEdited1';

		UnitOfWork.getInstance().setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
		UnitOfWork.getInstance().registerDeleted(account1);
		UnitOfWork.getInstance().commitWork();

		System.assertEquals(0, [SELECT Count() FROM Account]);
	}

	@isTest static void testDeleteList() {
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
		mt.newAccount('Name1', GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		mt.newAccount('Name2', GlobalConstants.POOL, GlobalConstants.OWNERSHIP_TEMPORARY, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME));
		Account account1 = [SELECT Id FROM Account WHERE Port_Pool__c = 'Port' LIMIT 1];
		account1.Name = 'NameEdited1';

		Account account2 = [SELECT Id FROM Account WHERE Port_Pool__c = 'Pool' LIMIT 1];
		account2.Name = 'NameEdited2';
		List<Account> accountList = new List<Account>{account1, account2};

		UnitOfWork.getInstance().setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
		UnitOfWork.getInstance().registerDeleted(accountList);
		UnitOfWork.getInstance().commitWork();

		System.assertEquals(0, [SELECT Count() FROM Account]);
	}
	
	@isTest static void testNegativeUpdate() {
		Account account1 = Mockup_Test.newAccountObj('Name1', GlobalConstants.PORT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		try {
			UnitOfWork.getInstance().setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
			UnitOfWork.getInstance().registerUpdate(account1);
			UnitOfWork.getInstance().commitWork();    
		} catch (UnitOfWork.UnitOfWorkException e) {
		 	System.assertEquals(Label.NEW_RECORD_CANNOT_UPDATE, e.getMessage());
		}
	}

	@isTest static void testNegativeDelete() {
		Account account1 = Mockup_Test.newAccountObj('Name1', GlobalConstants.PORT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		try {
			UnitOfWork.getInstance().setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
			UnitOfWork.getInstance().registerDeleted(account1);
			UnitOfWork.getInstance().commitWork();    
		} catch (UnitOfWork.UnitOfWorkException e) {
		 	System.assertEquals(Label.NEW_RECORD_CANNOT_DELETE, e.getMessage());
		}
	}

	@isTest static void testNegativeNew() {
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode().newAccount('Name1', GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		Account account1 = [SELECT Id FROM Account LIMIT 1];
		try {
			UnitOfWork.getInstance().setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
			UnitOfWork.getInstance().registerNew(account1);
			UnitOfWork.getInstance().commitWork();    
		} catch (UnitOfWork.UnitOfWorkException e) {
		 	System.assertEquals(Label.CANNOT_REGISTERED_NEW, e.getMessage());
		}
	}

	@isTest static void testNegativeTypeNew() {
		Contact newContact = new Contact(LastName = 'Contact1');
		String errorMessage;
		UnitOfWork newUOW = new UnitOfWork();
		try {
			newUOW.setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
			newUOW.registerNew(newContact);
			newUOW.commitWork();
		} catch (UnitOfWork.UnitOfWorkException e) {
			errorMessage = e.getMessage();
		}
		System.assertEquals(String.format(Label.TYPE_NOT_SUPPORTED, new String[]{'Contact'}), errorMessage);
		try {
			errorMessage = '';
	 		newUOW.registerNew(new List<Contact>{newContact});
	 	} catch (UnitOfWork.UnitOfWorkException ex) {
	 		errorMessage = ex.getMessage();
	 	}
	 	System.assertEquals(String.format(Label.TYPE_NOT_SUPPORTED, new String[]{'Contact'}), errorMessage);
	}

	@isTest static void testNegativeTypeUpdate() {
		Contact newContact = new Contact(LastName = 'Contact1',Phone_Numbers__c = '1234567890');
		insert newContact;
		String errorMessage;
		UnitOfWork newUOW = new UnitOfWork();
		try {
			newUOW.setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
			newUOW.registerUpdate(newContact);
			newUOW.commitWork();
		} catch (UnitOfWork.UnitOfWorkException e) {
			errorMessage = e.getMessage();
		}
		System.assertEquals(String.format(Label.TYPE_NOT_SUPPORTED, new String[]{'Contact'}), errorMessage);
		try {
			errorMessage = '';
	 		newUOW.registerUpdate(new List<Contact>{newContact});
	 	} catch (UnitOfWork.UnitOfWorkException ex) {
	 		errorMessage = ex.getMessage();
	 	}
	 	System.assertEquals(String.format(Label.TYPE_NOT_SUPPORTED, new String[]{'Contact'}), errorMessage);
	}

	@isTest static void testNegativeTypeDeleted() {
		Contact newContact = new Contact(LastName = 'Contact1',Phone_Numbers__c = '1234567890');
		insert newContact;
		String errorMessage;
		UnitOfWork newUOW = new UnitOfWork();
		try {
			newUOW.setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
			newUOW.registerDeleted(newContact);
			newUOW.commitWork();
		} catch (UnitOfWork.UnitOfWorkException e) {
			errorMessage = e.getMessage();
		}
		System.assertEquals(String.format(Label.TYPE_NOT_SUPPORTED, new String[]{'Contact'}), errorMessage);
		try {
			errorMessage = '';
	 		newUOW.registerDeleted(new List<Contact>{newContact});
	 	} catch (UnitOfWork.UnitOfWorkException ex) {
	 		errorMessage = ex.getMessage();
	 	}
	 	System.assertEquals(String.format(Label.TYPE_NOT_SUPPORTED, new String[]{'Contact'}), errorMessage);
	}

	@isTest static void testNewSimpleDML() {
		Account account1 = Mockup_Test.newAccountObj('Name1', GlobalConstants.PORT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		UnitOfWork.getInstance().setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
		UnitOfWork.getInstance().setDML(new UnitOfWork.SimpleDML());
		UnitOfWork.getInstance().registerNew(account1);
		UnitOfWork.getInstance().commitWork();
		System.assertEquals(1, [SELECT Count() FROM Account]);
	}

	@isTest static void testUpdateSimpleDML() {
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode().newAccount('Name1', GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		Account account1 = [SELECT Id FROM Account LIMIT 1];
		account1.Customer_Importance_Note__c = 'NameEdited1';

		UnitOfWork.getInstance().setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
		UnitOfWork.getInstance().setDML(new UnitOfWork.SimpleDML());
		UnitOfWork.getInstance().registerUpdate(account1);
		UnitOfWork.getInstance().commitWork();

		Account targetAccount = [SELECT Id, Customer_Importance_Note__c FROM Account WHERE Id = :account1.Id LIMIT 1];
		System.assertEquals('NameEdited1', targetAccount.Customer_Importance_Note__c);
	}

	@isTest static void testDeleteSimpleDML() {
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode().newAccount('Name1', GlobalConstants.PORT, GlobalConstants.OWNERSHIP_PERMANENT, GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account').get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		Account account1 = [SELECT Id FROM Account LIMIT 1];
		account1.Name = 'NameEdited1';

		UnitOfWork.getInstance().setDML(new UnitOfWork.SimpleDML());
		UnitOfWork.getInstance().setSObjectList(new List<Schema.SObjectType>{Account.SObjectType});
		UnitOfWork.getInstance().registerDeleted(account1);
		UnitOfWork.getInstance().commitWork();

		System.assertEquals(0, [SELECT Count() FROM Account]);
	}

}