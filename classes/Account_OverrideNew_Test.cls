@isTest
private class Account_OverrideNew_Test {
	
	private static void createTemporaryAccount() {
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
		
		insert new Account(LastName = 'temp', Temporary_Customer__c = true, RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME));
		insert new Account(Name = 'temp', Temporary_Customer__c = true, RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME));
		insert new Account(LastName = 'temp', Temporary_Customer__c = true, RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_BOL_DEVNAME));
		insert new Account(Name = 'temp', Temporary_Customer__c = true, RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_BOL_DEVNAME));

	}

	@isTest static void createWithoutTemporaryAccount() {
		Account expectedAccount = new Account(CIS__c='983332', LastName='surname');
		mockWebservice(expectedAccount, 'NO_ADDRESS','I');

		Account newAccount = new Account();
		ApexPages.StandardController stdController = new ApexPages.StandardController(newAccount);
		Account_OverrideNew_Controller accController = new Account_OverrideNew_Controller(stdController);
		accController.inputLastName = '983332';
		
		Test.startTest();
			accController.save();    
		Test.stopTest();

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessages.size());
		for(ApexPages.Message message : pageMessages) {
			System.assertEquals(Label.Temporary_Customer_Empty, message.getDetail());
		}
	}

	@isTest static void createWithLastNameText() {
		createTemporaryAccount();
		String EXPECTED_NAME = 'prospect';

		Account newAccount = new Account();
		ApexPages.StandardController stdController = new ApexPages.StandardController(newAccount);
		Account_OverrideNew_Controller accController = new Account_OverrideNew_Controller(stdController);
		accController.inputLastName = EXPECTED_NAME;
		accController.save();

		Account targetAccount;
		for(Account eachAccount : [SELECT Id, LastName, PersonContact.LastName FROM Account]) {
			if(eachAccount.LastName == EXPECTED_NAME && eachAccount.PersonContact.LastName == EXPECTED_NAME) {
				targetAccount = eachAccount;
			}
		}
		System.assertNotEquals(null, targetAccount);
	}

	@isTest static void createWithNameText() {
		createTemporaryAccount();
		String EXPECTED_NAME = 'prospect';

		Account newAccount = new Account();
		ApexPages.StandardController stdController = new ApexPages.StandardController(newAccount);
		Account_OverrideNew_Controller accController = new Account_OverrideNew_Controller(stdController);
		accController.customerType = GlobalConstants.ORGANIZATION;
		Account controllerRecord = (Account) stdController.getRecord();
		controllerRecord.Name = EXPECTED_NAME;
		accController.save();

		Account targetAccount;
		for(Account eachAccount : [SELECT Id, Name FROM Account]) {
			if(eachAccount.Name == EXPECTED_NAME) {
				targetAccount = eachAccount;
			}
		}
		System.assertNotEquals(null, targetAccount);
	}

	@isTest static void createWithCISExistSFDC() {
		createTemporaryAccount();
		Account existAccount = new Account();
		existAccount.Name = 'Beryl8';
		existAccount.CIS__c = '12345';
		existAccount.Temporary_Customer__c = true;
		insert existAccount;

		Account newAccount = new Account();
		ApexPages.StandardController stdController = new ApexPages.StandardController(newAccount);
		Account_OverrideNew_Controller accController = new Account_OverrideNew_Controller(stdController);
		accController.getSalutations();
		accController.getCustomerTypeItems();
		Account controllerRecord = (Account) stdController.getRecord();
		controllerRecord.Name = '12345';

		accController.save();
	}

	@isTest static void createWithCISNotExistSFDCExistDIHIndividual() {
		Account expectedAccount = new Account(CIS__c='983332', LastName='surname');
		createTemporaryAccount();
		mockWebservice(expectedAccount, 'NO_ADDRESS','I');

		Account newAccount = new Account();
		ApexPages.StandardController stdController = new ApexPages.StandardController(newAccount);
		Account_OverrideNew_Controller accController = new Account_OverrideNew_Controller(stdController);
		accController.inputLastName = '983332';

		Test.startTest();
			accController.save();
		Test.stopTest();

		Account targetAccount = [SELECT Id, PersonContact.LastName, CIS__c, RecordType.DeveloperName FROM Account WHERE CIS__c = '983332'];
		System.assertEquals(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME,targetAccount.RecordType.DeveloperName);
		System.assertEquals('983332',targetAccount.CIS__c);
	}

	@isTest static void createWithCISNotExistSFDCExistDIHOrganization() {
		Account expectedAccount = new Account(CIS__c='983332', Name='surname');
		createTemporaryAccount();
		mockWebservice(expectedAccount, 'NO_ADDRESS','O');

		Account newAccount = new Account();
		ApexPages.StandardController stdController = new ApexPages.StandardController(newAccount);
		Account_OverrideNew_Controller accController = new Account_OverrideNew_Controller(stdController);
		accController.customerType = GlobalConstants.ORGANIZATION;
		Account controllerRecord = (Account) stdController.getRecord();
		controllerRecord.Name = '983332';
		accController.save();

		Account targetAccount = [SELECT Id, Name, CIS__c, RecordType.DeveloperName FROM Account WHERE CIS__c = '983332'];
		System.assertEquals(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME, targetAccount.RecordType.DeveloperName);
		System.assertEquals('983332',targetAccount.CIS__c);
		System.assertEquals(expectedAccount.Name, targetAccount.Name);
	}

	@isTest static void createWithCISNotExistSFDCNotExistDIH() {
		createTemporaryAccount();
		mockWebservice(null, 'NOT_EXIST','O');

		Account newAccount = new Account();
		ApexPages.StandardController stdController = new ApexPages.StandardController(newAccount);
		Account_OverrideNew_Controller accController = new Account_OverrideNew_Controller(stdController);
		accController.inputLastName = '983332';
		accController.save();

		Account targetAccount = [SELECT Id, LastName, CIS__c, RecordType.DeveloperName FROM Account WHERE CIS__c = '983332'];
		System.assertEquals('983332',targetAccount.LastName);
		System.assertEquals('983332',targetAccount.CIS__c);
		System.assertEquals(GlobalConstants.INDIVIDUAL_PROSPECT_DEVNAME,targetAccount.RecordType.DeveloperName);
	}

	@isTest static void createWithIdAndDateNotExistSFDCExistDIHOrganization() {
		createTemporaryAccount();
		String EXPECTED_ID = '1231231231231';
		Account expectedAccount = new Account(Name='surname');
		mockWebservice(expectedAccount, 'WITH_IDENT','O');

		Account newAccount = new Account();
		ApexPages.StandardController stdController = new ApexPages.StandardController(newAccount);
		Account_OverrideNew_Controller accController = new Account_OverrideNew_Controller(stdController);
		accController.customerType = GlobalConstants.ORGANIZATION;
		Account controllerRecord = (Account) stdController.getRecord();
		controllerRecord.Name = 'test';
		controllerRecord.Encrypt_Identification_No__c = EXPECTED_ID;
		controllerRecord.Birthdate_Registration_Date__c = System.today() - 200;
		accController.save();

		Account targetAccount;
		for(Account eachAccount : [SELECT Id, Name, CIS__c, Encrypt_Identification_No__c, RecordType.DeveloperName FROM Account]) {
			if(eachAccount.Encrypt_Identification_No__c == EXPECTED_ID) {
				targetAccount = eachAccount;
			}
		}
		System.assertEquals(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME, targetAccount.RecordType.DeveloperName);
		System.assertEquals('12345678910', targetAccount.CIS__c);
	}

	@isTest static void createWithCISNotExistSFDCExistDIHIndividualWithAddress() {
		Account expectedAccount = new Account(CIS__c='983332', LastName='surname');
		createTemporaryAccount();
		mockWebservice(expectedAccount, 'WITH_ADDRESS','I');

		Account newAccount = new Account();
		ApexPages.StandardController stdController = new ApexPages.StandardController(newAccount);
		Account_OverrideNew_Controller accController = new Account_OverrideNew_Controller(stdController);
		accController.inputLastName = '983332';

		Test.startTest();
			accController.save();
		Test.stopTest();

		Account targetAccount = [SELECT Id, PersonContact.LastName, CIS__c, RecordType.DeveloperName FROM Account WHERE CIS__c = '983332'];
		System.assertEquals(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME,targetAccount.RecordType.DeveloperName);
		System.assertEquals('983332',targetAccount.CIS__c);
		System.assertNotEquals(0, [SELECT Count() FROM Address__c WHERE CIS_ID__c = :targetAccount.Id]);
	}

	@isTest static void createWithIdAndDateNotExistSFDCNotExistDIH() {
		String EXPECTED_NAME = 'test';
		createTemporaryAccount();
		mockWebservice(null, 'NOT_EXIST','O');

		Account newAccount = new Account();
		ApexPages.StandardController stdController = new ApexPages.StandardController(newAccount);
		Account_OverrideNew_Controller accController = new Account_OverrideNew_Controller(stdController);
		Account controllerRecord = (Account) stdController.getRecord();
		accController.customerType = GlobalConstants.ORGANIZATION;
		controllerRecord.Name = 'test';
		controllerRecord.Encrypt_Identification_No__c = '1231231231231';
		controllerRecord.Birthdate_Registration_Date__c = System.today() - 200;
		accController.save();

		Account targetAccount;
		for(Account eachAccount : [SELECT Id, Name, CIS__c, Encrypt_Identification_No__c, RecordType.DeveloperName FROM Account]) {
			if(eachAccount.Name == EXPECTED_NAME) {
				targetAccount = eachAccount;
			}
		}
		System.assertEquals(null,targetAccount.CIS__c);
		System.assertEquals(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME,targetAccount.RecordType.DeveloperName);
	}

	@isTest static void createWithCISBOLAccount() {
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
		Account expectedAccount = new Account(CIS__c='983332', LastName='surname');
		createTemporaryAccount();
		Account bolExistAccount = new Account();
		bolExistAccount.LastName = '983332';
		bolExistAccount.RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.INDIVIDUAL_BOL_DEVNAME);
		bolExistAccount.Is_createby_Integration__c = TRUE;
		insert bolExistAccount;
		mockWebservice(expectedAccount, 'NO_ADDRESS','I');

		ApexPages.StandardController stdController = new ApexPages.StandardController(bolExistAccount);
		Account_OverrideNew_Controller accController = new Account_OverrideNew_Controller(stdController);
		Account controllerRecord = (Account) stdController.getRecord();
		accController.customerType = GlobalConstants.INDIVIDUAL;
		accController.inputLastName = '983332';

		Test.startTest();
			accController.save();
		Test.stopTest(); 

		Account targetAccount = [SELECT Id, PersonContact.LastName, CIS__c, RecordType.DeveloperName FROM Account WHERE CIS__c = '983332'];
		Account oldAccount = [SELECT Id, PersonContact.LastName, CIS__c, RecordType.DeveloperName,Convertedrecord__c FROM Account WHERE Id = :bolExistAccount.Id];
		System.assertEquals(GlobalConstants.INDIVIDUAL_CUSTOMER_DEVNAME,targetAccount.RecordType.DeveloperName);
		System.assertEquals(oldAccount.Convertedrecord__c,targetAccount.Id);
		System.assertEquals('983332',targetAccount.CIS__c);
	}

	@isTest static void createWithCISBOLConvertedAccount() {
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
		Account expectedAccount = new Account(CIS__c='983332', Name='name');
		createTemporaryAccount();
		Account prospectAccount = new Account(CIS__c='1212121',Name='name',RecordTypeId=recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_PROSPECT_DEVNAME),Is_createby_Integration__c = TRUE);
		insert prospectAccount;
		Account bolExistAccount = new Account();
		bolExistAccount.Name = '983332';
		bolExistAccount.Convertedrecord__c = prospectAccount.Id;
		bolExistAccount.RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_BOL_DEVNAME);
		bolExistAccount.Is_createby_Integration__c = TRUE;
		insert bolExistAccount;
		mockWebservice(expectedAccount, 'NO_ADDRESS','I');

		ApexPages.StandardController stdController = new ApexPages.StandardController(bolExistAccount);
		Account_OverrideNew_Controller accController = new Account_OverrideNew_Controller(stdController);
		Account controllerRecord = (Account) stdController.getRecord();
		accController.customerType = GlobalConstants.ORGANIZATION;
		accController.inputLastName = '983332';

		Test.startTest();
			accController.save();
			accController.gotoReference();
		Test.stopTest(); 

	}

	private static void mockWebservice(Account requestAccount, String testMode, String customerType){
		String jsonString = '';
		if(testMode=='NOT_EXIST') {
			jsonString = '{"customerModel":null,"customerAddresses":[]}';
		} else {
			String lastName = requestAccount.LastName != null ? requestAccount.LastName : requestAccount.Name;	
			if(GlobalUtility.isNumberAlphabet(requestAccount.CIS__c)) {
				if(testMode == 'NO_ADDRESS') {
					// No Address
					jsonString = '{"customerModel":{"IP_ID":"' + requestAccount.CIS__c + '","TH_FRST_NM":"' + lastName + '","TH_SURNM":"' + lastName + '","PRVN_F":"C","IP_TP_CD":"'+customerType+'","BRTH_ESTB_DT":"","DOC_ITM_CD":"11","IP_PERF_ST_CD":"G","PRIM_SEG_CD":"LM","PRIM_SUB_SEG_CD":"01","DUAL_SEG_CD":"","DUAL_SUB_SEG_CD":"","KBNK_IDY_CL_CD":"010050000","CO_IDY_CL_CD":""},"customerAddresses":[]}';
				} else if(testMode == 'WITH_ADDRESS') {
					// With Address
					jsonString = '{"customerModel":{"IP_ID":"' + requestAccount.CIS__c + '","TH_FRST_NM":"' + lastName + + '","TH_SURNM":"' + lastName + '","PRVN_F":"C","IP_TP_CD":"'+customerType+'","BRTH_ESTB_DT":"","DOC_ITM_CD":"11","IP_PERF_ST_CD":"G","PRIM_SEG_CD":"LM","PRIM_SUB_SEG_CD":"01","DUAL_SEG_CD":"","DUAL_SUB_SEG_CD":"","KBNK_IDY_CL_CD":"010050000","CO_IDY_CL_CD":""},"customerAddresses":[{"ADR_ID":"A001","ADR_USE_TP_CD":"02","WRKPLC_NM":"","BOX_NO":"","HS_NO":"1878","VILL_NO":"","VILL":"","BLD_NM":"","ROOM_NO":"","FLR_NO":"","ALY":"","STR_NM":"พระรามที่ 4","SUBDSTC":"คลองเตย","DSTC":"คลองเตย","PROV":"กทม.","CIS_SRC_STM_CD":"","PSTCD_AREA_CD":"10110","CTY_CD":"TH"},{"ADR_ID":"A002","ADR_USE_TP_CD":"03","WRKPLC_NM":"","BOX_NO":"","HS_NO":"2000","VILL_NO":"","VILL":"","BLD_NM":"","ROOM_NO":"","FLR_NO":"","ALY":"","STR_NM":"พระรามที่ 4","SUBDSTC":"คลองเตย","DSTC":"คลองเตย","PROV":"กทม.","CIS_SRC_STM_CD":"","PSTCD_AREA_CD":"10110","CTY_CD":"TH"}]}';
				}
			} else if(testMode=='WITH_IDENT') {
				jsonString = '{"customerModel":{"IP_ID":"12345678910","PRVN_F":"C","IP_TP_CD":"'  + customerType + '","TH_FRST_NM":"' + lastName + '","TH_SURNM":"' + lastName + '","BRTH_ESTB_DT":"","DOC_ITM_CD":"11","IP_PERF_ST_CD":"G","PRIM_SEG_CD":"UM","PRIM_SUB_SEG_CD":"02","DUAL_SEG_CD":"","DUAL_SUB_SEG_CD":"","KBNK_IDY_CL_CD":"033350000","CO_IDY_CL_CD":"","IDENT_NO":"1231231231231"},"customerAddresses":[]}';
			}
		}
			
		CreateProspect_Webservice.mockJSONResponse = jsonString;
	}
}