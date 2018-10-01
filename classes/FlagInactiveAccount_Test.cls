@isTest
private class FlagInactiveAccount_Test
{
	@isTest
	static void Batch_stampAccount_shouldSetIsActiveToTrue()
	{
		// Given
		Account acct = new Account(
            CIS__c = '1',
            Encrypt_Name_TH__c = 'Org customer',
            Name = 'Org customer',
            RecordTypeId = GlobalUtility.getRecordtypeAccountIdByName('Organization Customer'),
            Is_createby_Integration__c  = true,
			IsActive__c = true
        );
        insert acct;
		System.assertEquals(true, acct.IsActive__c, 'Setup IsActive__c wrong');
		// When
        Test.StartTest();
        Database.executeBatch(new flagInactiveAccount_Batch(), 500);
        Test.StopTest();
		// Then
		Account result = [SELECT IsActive__c FROM Account WHERE Id =: acct.Id];
		System.assertEquals(true, acct.IsActive__c, 'IsActive was updated to false');
	}

	@isTest
	static void Batch_stampAccount_shouldSetIsActiveToFalse()
	{
		// Given
		List<sObject> ls = Test.loadData(Account.sObjectType, 'FlagInactiveAccount');
		Set<Id> accountIdSet = new Set<Id>();
		for(Account acct : (List<Account>) ls) {
			accountIdSet.add(acct.Id);
			System.assertEquals(true, acct.IsActive__c, 'Setup IsActive__c wrong');
		}
		Account acct = new Account(
            CIS__c = '1',
            Encrypt_Name_TH__c = 'Org customer',
            Name = 'Org customer',
            RecordTypeId = GlobalUtility.getRecordtypeAccountIdByName('Organization Customer'),
            Is_createby_Integration__c  = true,
			IsActive__c = false
        );
        insert acct;
		accountIdSet.add(acct.Id);

		// When
        Test.StartTest();
        Database.executeBatch(new flagInactiveAccount_Batch(), 500);
        Test.StopTest();

		// Then
		List<Account> results = [SELECT IsActive__c, LastModifiedDate FROM Account WHERE Id IN: accountIdSet];
		for(Account result : results) {
			System.assertEquals(false, result.IsActive__c, 'IsActive was updated to false');
		}
	}
}