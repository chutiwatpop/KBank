@isTest
private class PurgeProductUsageCustomSetting_Test
{
	private static void setUpCustomSetting(){
		insert	new Product_Usage_Market_Code__c(Name='0001');
		insert	new Product_Usage_Idnx_Interest_Rate_Type__c(Name='0001');
		insert	new Product_Usage_Interest_Rate_Type__c(Name='0001');
	}
	@isTest
	static void PurgeAllThreeCustomSetting()
	{
		// Given
		setUpCustomSetting();
		// When
		Test.startTest();
			Database.executeBatch(new PurgeProductUsageCustomSetting());
		Test.stopTest();
		// Then
		System.assertEquals(0,[Select count() From Product_Usage_Market_Code__c]);
		System.assertEquals(0,[Select count() From Product_Usage_Idnx_Interest_Rate_Type__c]);
		System.assertEquals(0,[Select count() From Product_Usage_Interest_Rate_Type__c]);
	}
}