@isTest
private class MapAroundPin_Test {
	
	public static String CUSTOMER_RM_TEMP_POOL 	= 'A';
	public static String PROSPECT_RM 			= 'B';
	public static String PROSPECT_RM_TEMP 		= 'C';
    public static String O_CUSTOMER_TM_POOL_PER = 'D';
    public static String O_CUSTOMER_ADMIN_PER  	= 'E';
    public static String CUSTOMER_RM_PER_PORT  	= 'F';
    
	@testSetup static void setupAccount(){
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
	}

	public static Map<String, String> getMockData(Boolean isMockAddress, String recordTypeId) {
		Map<String, String> resultMap = new Map<String, String>();
		Account mockAccount = new Account(
	        Name = '1234',
	        Port_Pool__c = GlobalConstants.PORT,
	        RecordTypeId = recordTypeId,
	        Primary_Segment_Code__c = 'SM',
            Is_createby_Integration__c = true
	    );
	    insert mockAccount;
	    resultMap.put('AccountId', mockAccount.Id);

	    Contact mockContact = new Contact(
            	LastName = 'lastname',
				Contact_Firstname__c = 'Firstname',
				AccountId = mockAccount.Id,
				Phone_Numbers__c = '023450789'
            );
		insert mockContact;
		resultMap.put('ContactId', mockContact.Id);

		if(isMockAddress) {
			Address__c mockAddress = new Address__c(
				CIS_ID__c = mockAccount.Id,
				Place__c = 'place',
				Pin_Location__Latitude__s = 13.001,
				Pin_Location__Longitude__s = 100.001
			);
			insert mockAddress;	
			resultMap.put('AddressId', mockAddress.Id);
		}

	    return resultMap;
	}

	@isTest static void testNegativeNoPin() {
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
		SME_MapAroundPin_Controller mapController = new SME_MapAroundPin_Controller();
		Test.startTest();
			System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
				Account mockAccount = new Account(
			        Name = '1234',
			        Port_Pool__c = GlobalConstants.PORT,
			        RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME),
			        Primary_Segment_Code__c = 'SM',
		            Is_createby_Integration__c = true
			    );
			    insert mockAccount;
				System.assertEquals(1, [SELECT Count() FROM Account]);
				try {
					List<SME_MapAroundPin_Controller.AddressWrapper> getAllAddress = SME_MapAroundPin_Controller.getAllAddress(13, 100, 1000, 'Port', 'searchString');    
				} catch (Exception e) {
				    System.assertEquals(Label.NO_PIN_LOCATION_FOUND, e.getMessage());
				}
			}
		Test.stopTest();
	}

	@isTest static void testNegativeNoCustomer() {
		SME_MapAroundPin_Controller mapController = new SME_MapAroundPin_Controller();
		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			try {
				List<SME_MapAroundPin_Controller.AddressWrapper> getAllAddress = SME_MapAroundPin_Controller.getAllAddress(13, 100, 1000, 'CIS', 'searchString');    
			} catch (Exception e) {
			    System.assertEquals(Label.NO_CUSTOMER_FOUND, e.getMessage());
			}
		}
		Test.stopTest();
	}

	@isTest static void testPinSearchPort() {
		SME_MapAroundPin_Controller mapController = new SME_MapAroundPin_Controller();
		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Map<String, String> mockDataMap = getMockData(true, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
			System.assertEquals(1, [SELECT Count() FROM Account]);
			try {
				List<SME_MapAroundPin_Controller.AddressWrapper> getAllAddress = SME_MapAroundPin_Controller.getAllAddress(13, 100, 1000, 'Port', 'searchString');    
				List<Contact> contacts = SME_MapAroundPin_Controller.getContacts(mockDataMap.get('AccountId'));
				SME_MapAroundPin_Controller.FraudResponse fraudResponse = SME_MapAroundPin_Controller.getFraudStatus(mockDataMap.get('AccountId'));
				SME_MapAroundPin_Controller.getAddressDetail(mockDataMap.get('AddressId'));
			} catch (Exception e) {
			    
			}
		}
		Test.stopTest();
	}

	@isTest static void testPinSearchCIS() {
		SME_MapAroundPin_Controller mapController = new SME_MapAroundPin_Controller();

		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Map<String, String> mockDataMap = getMockData(true, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER));
			Call_Report__c mockCallReport = new Call_Report__c(
	            Collect_Documents__c = true,
	            CIS_ID__c = mockDataMap.get('AccountId'),
	            Status__c = GlobalConstants.PLAN,
	            Plan_Date__c = System.Today(),
	            Contact__c = mockDataMap.get('ContactId'),
	            Expected_Credit_Amount__c = 5000,
	            RecordtypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME),
	            Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว',
	            Offer_Interest__c = GlobalConstants.OFFER_INTEREST_WITH_CONDITION
	        );
	        insert mockCallReport;
			System.assertEquals(1, [SELECT Count() FROM Account]);
			try {
				List<SME_MapAroundPin_Controller.AddressWrapper> getAllAddress = SME_MapAroundPin_Controller.getAllAddress(13, 100, 1000, 'CIS', '1234');    
				List<Contact> contacts = SME_MapAroundPin_Controller.getContacts(mockDataMap.get('AccountId'));
				SME_MapAroundPin_Controller.FraudResponse fraudResponse = SME_MapAroundPin_Controller.getFraudStatus(mockDataMap.get('AccountId'));
			} catch (Exception e) {
			    
			}
		}
		Test.stopTest();
	}

	@isTest static void testPinSearchTemp() {
		SME_MapAroundPin_Controller mapController = new SME_MapAroundPin_Controller();
		
		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
			Map<String, String> mockDataMap = getMockData(true, Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_PROSPECT));
			System.assertEquals(1, [SELECT Count() FROM Account]);
			try {
				List<SME_MapAroundPin_Controller.AddressWrapper> getAllAddress = SME_MapAroundPin_Controller.getAllAddress(13, 100, 1000, 'Temporary', '');    
				Account newAccount = SME_MapAroundPin_Controller.getAccountFromId(mockDataMap.get('AccountId'));
				List<Contact> contacts = SME_MapAroundPin_Controller.getContacts(mockDataMap.get('AccountId'));
				SME_MapAroundPin_Controller.FraudResponse fraudResponse = SME_MapAroundPin_Controller.getFraudStatus(mockDataMap.get('AccountId'));
			} catch (Exception e) {
			    
			}
		}
		Test.stopTest();
	}
	
}