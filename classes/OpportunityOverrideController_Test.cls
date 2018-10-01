@isTest
private class OpportunityOverrideController_Test {
	
	@isTest static void test_getAccountInformation_MustReturnString() {
		// Given
		Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Account');
		Account dataVal = new Account();
		dataVal.Name = 'Test123';
		dataVal.RecordTypeId = recordTypeMapByDevName.get(GlobalConstants.ORGANIZATION_CUSTOMER_DEVNAME);
		dataVal.Is_createby_Integration__c = true;
		insert dataVal;

		// When
		String result = OpportunityOverrideController.getAccountInformation(dataVal.Id);

		// Then
		System.assertNotEquals(null, result);
	}
	
	
}