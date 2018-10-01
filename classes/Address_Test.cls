@isTest
private class Address_Test {
	
	public static Map<String, String> getMockData() {
		Around_Pin_Config__c configValue = new Around_Pin_Config__c();
		configValue.API_KEY__c = 'AIzaSyBkUxCY6xrgP9eA1JIKD835xs1Ee6Pz9Vw';
		configValue.Geocoding_URL__c = 'https://maps.googleapis.com/maps/api/geocode/json';
		insert configValue;

		Map<String, String> resultMap = new Map<String, String>();
		Account mockAccount = new Account(
	        Name = '1234',
	        Port_Pool__c = GlobalConstants.PORT,
	        RecordTypeId = Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.ORGANIZATION_CUSTOMER),
	        Primary_Segment_Code__c = 'SM',
	        Is_createby_Integration__c = true
	    );
	    insert mockAccount;
	    resultMap.put('AccountId', mockAccount.Id);

		Address__c mockAddress = new Address__c(
			CIS_ID__c = mockAccount.Id,
			Place__c = 'place',
			Sales_Smart_Address__c = false,
			Pin_Location__Latitude__s = 13.001,
			Pin_Location__Longitude__s = 100.001
		);
		insert mockAddress;

		Address__c mockAddress2 = new Address__c(
			CIS_ID__c = mockAccount.Id,
			Place__c = 'place',
			District__c = 'จอมทอง',
			Postcode__c = '10150',
			Sales_Smart_Address__c = false
		);
		insert mockAddress2;

		resultMap.put('AddressId', mockAddress.Id);
		resultMap.put('AddressNoPin', mockAddress2.Id);
		
	    return resultMap;
	}

	@isTest static void testNewAddress() {
		ApexPages.StandardController stdController = new ApexPages.StandardController(new Address__c());
		Address_OverrideEdit_Controller addressController = new Address_OverrideEdit_Controller(stdController);
		
		Test.startTest();
			Address__c controllerRecord = (Address__c) stdController.getRecord();
			controllerRecord.Street__c = 'street';
			controllerRecord.Place__c = 'place';
			controllerRecord.Alley__c = 'alley';

			addressController.save();
		Test.stopTest();
	}

	@isTest static void testDeleteAddress() {
		Map<String, String> mockDataMap = getMockData();
		Test.startTest();
			Address__c targetAddress = [SELECT Id FROM Address__c WHERE Id = :mockDataMap.get('AddressId')];
			try {
				delete targetAddress;
			} catch (Exception e) {
				Boolean result = e.getMessage().contains(Label.CANNOT_DELETE_SYS_ADDRESS);
				System.assertEquals(true, result);
			}
		Test.stopTest();
	}

	@isTest static void testBatchAddressPositive() {
		Map<String, String> mockDataMap = getMockData();
		Address__c targetAddress = [SELECT Id, Initial_Location_Date__c, Pin_Location__Latitude__s,Pin_Location__Longitude__s FROM Address__c WHERE Id = :mockDataMap.get('AddressNoPin')];
		System.assertEquals(null, targetAddress.Initial_Location_Date__c);
		System.assertEquals(null, targetAddress.Pin_Location__Latitude__s);
		System.assertEquals(null, targetAddress.Pin_Location__Longitude__s);

		Test.startTest();
			Database.executeBatch(new AddressInitialPinLocation_Batch());
		Test.stopTest();
		targetAddress = [SELECT Id, Initial_Location_Date__c, Pin_Location__Latitude__s,Pin_Location__Longitude__s FROM Address__c WHERE Id = :mockDataMap.get('AddressNoPin')];
		System.assertNotEquals(null, targetAddress.Initial_Location_Date__c);
		System.assertNotEquals(null, targetAddress.Pin_Location__Latitude__s);
		System.assertNotEquals(null, targetAddress.Pin_Location__Longitude__s);
	}

	@isTest static void testBatchAddressOverLimit() {
		GoogleGeocoding_Webservice.testMode = 'OVER_QUERY_LIMIT';
		Map<String, String> mockDataMap = getMockData();
		Address__c targetAddress = [SELECT Id, Initial_Location_Date__c, Pin_Location__Latitude__s,Pin_Location__Longitude__s FROM Address__c WHERE Id = :mockDataMap.get('AddressNoPin')];
		System.assertEquals(null, targetAddress.Initial_Location_Date__c);
		System.assertEquals(null, targetAddress.Pin_Location__Latitude__s);
		System.assertEquals(null, targetAddress.Pin_Location__Longitude__s);

		Test.startTest();
			Database.executeBatch(new AddressInitialPinLocation_Batch());
		Test.stopTest();
		targetAddress = [SELECT Id, Initial_Location_Date__c, Pin_Location__Latitude__s,Pin_Location__Longitude__s FROM Address__c WHERE Id = :mockDataMap.get('AddressNoPin')];
		System.assertEquals(null, targetAddress.Initial_Location_Date__c);
		System.assertEquals(null, targetAddress.Pin_Location__Latitude__s);
		System.assertEquals(null, targetAddress.Pin_Location__Longitude__s);
	}

	@isTest static void testBatchAddressZeroResults() {
		GoogleGeocoding_Webservice.testMode = 'ZERO_RESULTS';
		Map<String, String> mockDataMap = getMockData();
		Address__c targetAddress = [SELECT Id, Initial_Location_Date__c, Pin_Location__Latitude__s,Pin_Location__Longitude__s FROM Address__c WHERE Id = :mockDataMap.get('AddressNoPin')];
		System.assertEquals(null, targetAddress.Initial_Location_Date__c);
		System.assertEquals(null, targetAddress.Pin_Location__Latitude__s);
		System.assertEquals(null, targetAddress.Pin_Location__Longitude__s);

		Test.startTest();
			Database.executeBatch(new AddressInitialPinLocation_Batch());
		Test.stopTest();
		Application_Log__c exceptionLog = [SELECT Id, Message__c FROM Application_Log__c WHERE Source__c = 'GoogleGeocoding_Webservice' LIMIT 1];
		System.assertNotEquals(null, exceptionLog);
		System.assertEquals(true, exceptionLog.Message__c.contains('Coord cannot be found from search address.'));
	}
}