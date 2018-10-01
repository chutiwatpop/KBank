@isTest
private class CustomerSearch_Management_Test
{
	@isTest
	static void queryAllSOSLValueTest()
	{
		CustomerSearch_Management customerSearch = new CustomerSearch_Management();
		// Given
		Account newAccount = new Account();
		newAccount.name = 'Mockup1';
		newAccount.cis__c = '5137447';
		newAccount.phone = '0838579485';
		newAccount.Is_createby_Integration__c = true;
		//newAccount.Title_EN__c = 'Mr.';
		insert newAccount;
		
		System.debug('newAccount' + newAccount);
		String inputValue = '5137447';
		// When
		List<List<SObject>> returnResult = customerSearch.queryAllSOSLValue(inputValue,'ALL');
		// Then
		System.debug('returnResult' + returnResult);
	}
}